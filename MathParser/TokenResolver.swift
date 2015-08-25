//
//  TokenResolver.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/8/15.
//
//

import Foundation

public struct TokenResolverOptions: OptionSetType {
    public let rawValue: UInt
    
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
    
    public static let None = TokenResolverOptions(rawValue: 0)
    public static let AllowArgumentlessFunctions = TokenResolverOptions(rawValue: 1 << 0)
    public static let AllowImplicitMultiplication = TokenResolverOptions(rawValue: 1 << 1)
    public static let UseHighPrecedenceImplicitMultiplication = TokenResolverOptions(rawValue: 1 << 2)
    
    public static let DefaultOptions: TokenResolverOptions = [.AllowArgumentlessFunctions, .AllowImplicitMultiplication]
}

public struct TokenResolver {
    
    private let tokenizer: Tokenizer
    private let options: TokenResolverOptions
    internal var operatorSet: OperatorSet { return tokenizer.operatorSet }
    
    public init(tokenizer: Tokenizer, options: TokenResolverOptions = TokenResolverOptions.DefaultOptions) {
        self.tokenizer = tokenizer
        self.options = options
    }
    
    public init(string: String, operatorSet: OperatorSet = OperatorSet.defaultOperatorSet, options: TokenResolverOptions = TokenResolverOptions.DefaultOptions) {
        self.tokenizer = Tokenizer(string: string, operatorSet: operatorSet)
        self.options = options
    }
    
    public func resolve() throws -> Array<ResolvedToken> {
        let rawTokens = try tokenizer.tokenize()
        
        var resolvedTokens = Array<ResolvedToken>()
        
        for rawToken in rawTokens {
            let resolved = try resolveToken(rawToken, previous: resolvedTokens.last)
            resolvedTokens.appendContentsOf(resolved)
        }
        
        let finalResolved = try resolveToken(nil, previous: resolvedTokens.last)
        resolvedTokens.appendContentsOf(finalResolved)
        
        return resolvedTokens
    }
    
}

extension TokenResolver {
    private func resolveToken(raw: RawToken?, previous: ResolvedToken?) throws -> Array<ResolvedToken> {
        
        guard let raw = raw else {
            // this is the case where the we check for argumentless stuff
            // after the last token
            if options.contains(.AllowArgumentlessFunctions) {
                return extraTokensForArgumentlessFunction(nil, previous: previous)
            } else {
                return []
            }
        }
        
        let resolved = try resolveRawToken(raw, previous: previous)
        
        var resolvedTokens = Array<ResolvedToken>()
        
        // check for argumentless functions
        if options.contains(.AllowArgumentlessFunctions) {
            let extras = extraTokensForArgumentlessFunction(resolved, previous: previous)
            resolvedTokens.appendContentsOf(extras)
        }
        
        // check for implicit multiplication
        if options.contains(.AllowImplicitMultiplication) {
            let last = resolvedTokens.last ?? previous
            let extras = extraTokensForImplicitMultiplication(resolved, previous: last)
            resolvedTokens.appendContentsOf(extras)
        }
        
        resolvedTokens.append(resolved)
        
        return resolvedTokens
    }
    
    private func resolveRawToken(rawToken: RawToken, previous: ResolvedToken?) throws -> ResolvedToken {
        
        let resolvedToken: ResolvedToken
        
        switch rawToken.kind {
            case .HexNumber:
                if let number = UInt(rawToken.string, radix: 16) {
                    resolvedToken = ResolvedToken(kind: .Number(Double(number)), string: rawToken.string, range: rawToken.range)
                } else {
                    throw TokenResolverError(kind: .CannotParseHexNumber, rawToken: rawToken)
                }
                
            case .Number:
                let cleaned = rawToken.string.stringByReplacingOccurrencesOfString("−", withString: "-")
                let number = NSDecimalNumber(string: cleaned)
                resolvedToken = ResolvedToken(kind: .Number(number.doubleValue), string: rawToken.string, range: rawToken.range)
                
            case .Variable:
                resolvedToken = ResolvedToken(kind: .Variable(rawToken.string), string: rawToken.string, range: rawToken.range)
                
            case .Identifier:
                resolvedToken = ResolvedToken(kind: .Identifier(rawToken.string), string: rawToken.string, range: rawToken.range)
                
            case .Operator:
                resolvedToken = try resolveOperator(rawToken, previous: previous)
        }
        
        return resolvedToken
    }
    
    private func resolveOperator(raw: RawToken, previous: ResolvedToken?) throws -> ResolvedToken {
        let matches = operatorSet.operatorForToken(raw.string)
        
        if matches.isEmpty {
            throw TokenResolverError(kind: .UnknownOperator, rawToken: raw)
        }
        
        if matches.count == 1 {
            let op = matches[0]
            return ResolvedToken(kind: .Operator(op), string: raw.string, range: raw.range)
        }
        
        // more than one operator has this token
        
        var resolvedOperator: Operator? = nil
        
        if let previous = previous {
            switch previous.kind {
                case .Operator(let o):
                    resolvedOperator = resolveOperator(raw, previousOperator: o)
                
                default:
                    // a number/variable can be followed by:
                    // a left-assoc unary operator,
                    // a binary operator,
                    // or a right-assoc unary operator (assuming implicit multiplication)
                    // we'll prefer them from left-to-right:
                    // left-assoc unary, binary, right-assoc unary
                    // TODO: is this correct?? should we be looking at precedence instead?
                    resolvedOperator = operatorSet.operatorForToken(raw.string, arity: .Unary, associativity: .Left).first
                    
                    if resolvedOperator == nil {
                        resolvedOperator = operatorSet.operatorForToken(raw.string, arity: .Binary).first
                    }
                    
                    if resolvedOperator == nil {
                        resolvedOperator = operatorSet.operatorForToken(raw.string, arity: .Unary, associativity: .Right).first
                    }
            }
            
        } else {
            // no previous token, so this must be a right-assoc unary operator
            resolvedOperator = operatorSet.operatorForToken(raw.string, arity: .Unary, associativity: .Right).first
        }
        
        if let resolved = resolvedOperator {
            return ResolvedToken(kind: .Operator(resolved), string: raw.string, range: raw.range)
        } else {
            throw TokenResolverError(kind: .AmbiguousOperator, rawToken: raw)
        }
    }
    
    private func resolveOperator(raw: RawToken, previousOperator o: Operator) -> Operator? {
        var resolvedOperator: Operator?
        
        switch (o.arity, o.associativity) {
            
            case (.Unary, .Left):
                // a left-assoc unary operator can be followed by either:
                // another left-assoc unary operator
                // or a binary operator
                resolvedOperator = operatorSet.operatorForToken(raw.string, arity: .Unary, associativity: .Left).first
                
                if resolvedOperator == nil {
                    resolvedOperator = operatorSet.operatorForToken(raw.string, arity: .Binary).first
                }
            
            
            default:
                // either a binary operator or a right-assoc unary operator
                
                // a binary operator can only be followed by a right-assoc unary operator
                //a right-assoc operator can only be followed by a right-assoc unary operator
                resolvedOperator = operatorSet.operatorForToken(raw.string, arity: .Unary, associativity: .Right).first
            
        }
        
        return resolvedOperator
    }
    
    private func extraTokensForArgumentlessFunction(next: ResolvedToken?, previous: ResolvedToken?) -> Array<ResolvedToken> {
        guard let previous = previous else { return [] }
        // we only insert tokens here if the previous token was an identifier
        guard let _ = previous.kind.identifier else { return [] }
        
        
        let nextOperator = next?.kind.resolvedOperator
        if nextOperator == nil || nextOperator?.builtInOperator != .ParenthesisOpen {
            let range = previous.range.endIndex ..< previous.range.endIndex
            
            let openParenOp = Operator(builtInOperator: .ParenthesisOpen)
            let openParen = ResolvedToken(kind: .Operator(openParenOp), string: "(", range: range)
            
            let closeParenOp = Operator(builtInOperator: .ParenthesisClose)
            let closeParen = ResolvedToken(kind: .Operator(closeParenOp), string: ")", range: range)
            
            return [openParen, closeParen]
        }
        
        return []
    }
    
    private func extraTokensForImplicitMultiplication(next: ResolvedToken, previous: ResolvedToken?) -> Array<ResolvedToken> {
        guard let previousKind = previous?.kind else { return [] }
        let nextKind = next.kind
        
        let previousMatches = previousKind.isNumber || previousKind.isVariable || (previousKind.resolvedOperator?.arity == .Unary && previousKind.resolvedOperator?.associativity == .Left)
        
        let nextMatches = nextKind.isOperator == false || (nextKind.resolvedOperator?.arity == .Unary && nextKind.resolvedOperator?.associativity == .Right)
        
        guard previousMatches && nextMatches else { return [] }
        
        let multiplyOperator: Operator
        if options.contains(.UseHighPrecedenceImplicitMultiplication) {
            multiplyOperator = operatorSet.implicitMultiplyOperator
        } else {
            multiplyOperator = operatorSet.multiplyOperator
        }
     
        return [ResolvedToken(kind: .Operator(multiplyOperator), string: "*", range: next.range.startIndex ..< next.range.startIndex)]
    }
}
