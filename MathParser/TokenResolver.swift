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
    private let operatorSet: OperatorSet
    private let options: TokenResolverOptions
    
    public init(tokenizer: Tokenizer, options: TokenResolverOptions = TokenResolverOptions.DefaultOptions) {
        self.tokenizer = tokenizer
        self.operatorSet = tokenizer.operatorSet
        self.options = options
    }
    
    public init(string: String, operatorSet: OperatorSet = OperatorSet.defaultOperatorSet, options: TokenResolverOptions = TokenResolverOptions.DefaultOptions) {
        self.tokenizer = Tokenizer(string: string, operatorSet: operatorSet)
        self.operatorSet = operatorSet
        self.options = options
    }
    
    public func resolve() throws -> Array<ResolvedToken> {
        let rawTokens = try tokenizer.tokenize()
        
        var resolvedTokens = Array<ResolvedToken>()
        
        for rawToken in rawTokens {
            let resolved = try resolveToken(rawToken, previous: resolvedTokens.last)
            resolvedTokens.extend(resolved)
        }
        
        return resolvedTokens
    }
    
}

extension TokenResolver {
    private func resolveToken(raw: RawToken, previous: ResolvedToken?) throws -> Array<ResolvedToken> {
        
        let resolved = try resolveRawToken(raw, previous: previous)
        
        var resolvedTokens = Array<ResolvedToken>()
        
        // check for argumentless functions
        if options.contains(.AllowArgumentlessFunctions) {
            let extras = extraTokensForArgumentlessFunction(resolved, previous: previous)
            resolvedTokens.extend(extras)
        }
        
        // check for implicit multiplication
        if options.contains(.AllowImplicitMultiplication) {
            let last = resolvedTokens.last ?? previous
            let extras = extraTokensForImplicitMultiplication(resolved, previous: last)
            resolvedTokens.extend(extras)
        }
        
        resolvedTokens.append(resolved)
        
        return resolvedTokens
    }
    
    private func resolveRawToken(rawToken: RawToken, previous: ResolvedToken?) throws -> ResolvedToken {
        
        let resolvedToken: ResolvedToken
        
        switch rawToken.kind {
            case .HexNumber:
                if let number = UInt(rawToken.string, radix: 16) {
                    resolvedToken = ResolvedToken(kind: .Number(number), string: rawToken.string, sourceRange: rawToken.sourceRange)
                } else {
                    throw TokenResolverError(kind: .CannotParseHexNumber, rawToken: rawToken)
                }
                
            case .Number:
                let number = NSDecimalNumber(string: rawToken.string)
                // TODO: this doesn't handle non-integers
                resolvedToken = ResolvedToken(kind: .Number(number.unsignedLongValue), string: rawToken.string, sourceRange: rawToken.sourceRange)
                
            case .Variable:
                resolvedToken = ResolvedToken(kind: .Variable(rawToken.string), string: rawToken.string, sourceRange: rawToken.sourceRange)
                
            case .Identifier:
                resolvedToken = ResolvedToken(kind: .Identifier(rawToken.string), string: rawToken.string, sourceRange: rawToken.sourceRange)
                
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
            return ResolvedToken(kind: .Operator(op), string: raw.string, sourceRange: raw.sourceRange)
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
            return ResolvedToken(kind: .Operator(resolved), string: raw.string, sourceRange: raw.sourceRange)
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
    
    private func extraTokensForArgumentlessFunction(next: ResolvedToken, previous: ResolvedToken?) -> Array<ResolvedToken> {
        guard let previous = previous else { return [] }
        // we only insert tokens here if the previous token was an identifier
        guard let _ = previous.kind.identifier else { return [] }
        
        let nextOperator = next.kind.resolvedOperator
        if nextOperator == nil || nextOperator?.builtInOperator != .ParenthesisOpen {
            let openParenOp = Operator(builtInOperator: .ParenthesisOpen)
            let openParen = ResolvedToken(kind: .Operator(openParenOp), string: "(", sourceRange: next.sourceRange.startIndex ..< next.sourceRange.startIndex)
            
            let closeParenOp = Operator(builtInOperator: .ParenthesisClose)
            let closeParen = ResolvedToken(kind: .Operator(closeParenOp), string: ")", sourceRange: next.sourceRange.startIndex ..< next.sourceRange.startIndex)
            
            return [openParen, closeParen]
        }
        
        return []
    }
    
    private func extraTokensForImplicitMultiplication(next: ResolvedToken, previous: ResolvedToken?) -> Array<ResolvedToken> {
        guard let previousKind = previous?.kind else { return [] }
        let nextKind = next.kind
        
        let previousMatches = previousKind.isOperator == false || (previousKind.resolvedOperator?.arity == .Unary && previousKind.resolvedOperator?.associativity == .Left)
        
        let nextMatches = nextKind.isOperator == false || (nextKind.resolvedOperator?.arity == .Unary && nextKind.resolvedOperator?.associativity == .Right)
        
        guard previousMatches && nextMatches else { return [] }
        
        let multiplyOperator: Operator
        if options.contains(.UseHighPrecedenceImplicitMultiplication) {
            multiplyOperator = Operator(builtInOperator: .ImplicitMultiply)
        } else {
            multiplyOperator = Operator(builtInOperator: .Multiply)
        }
     
        return [ResolvedToken(kind: .Operator(multiplyOperator), string: "*", sourceRange: next.sourceRange.startIndex ..< next.sourceRange.startIndex)]
    }
}
