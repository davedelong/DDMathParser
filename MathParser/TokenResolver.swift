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
    
    public static let defaultOptions: TokenResolverOptions = [.AllowArgumentlessFunctions, .AllowImplicitMultiplication, .UseHighPrecedenceImplicitMultiplication]
}

public struct TokenResolver {
    
    private let tokenizer: Tokenizer
    private let options: TokenResolverOptions
    private let locale: NSLocale?
    private let numberFormatters: Array<NSNumberFormatter>
    internal var operatorSet: OperatorSet { return tokenizer.operatorSet }
    
    private static func formattersForLocale(locale: NSLocale?) -> Array<NSNumberFormatter> {
        guard let locale = locale else { return [] }
        
        let decimal = NSNumberFormatter()
        decimal.locale = locale
        decimal.numberStyle = .DecimalStyle
        
        return [decimal]
    }
    
    public init(tokenizer: Tokenizer, options: TokenResolverOptions = TokenResolverOptions.defaultOptions) {
        self.tokenizer = tokenizer
        self.options = options
        self.locale = tokenizer.locale
        self.numberFormatters = TokenResolver.formattersForLocale(tokenizer.locale)
    }
    
    public init(string: String, operatorSet: OperatorSet = OperatorSet.defaultOperatorSet, options: TokenResolverOptions = TokenResolverOptions.defaultOptions, locale: NSLocale? = nil) {
        self.tokenizer = Tokenizer(string: string, operatorSet: operatorSet, locale: locale)
        self.options = options
        self.locale = locale
        self.numberFormatters = TokenResolver.formattersForLocale(locale)
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
        
        let resolvedTokens = try resolveRawToken(raw, previous: previous)
        guard let firstResolved = resolvedTokens.first else {
            fatalError("Implementation flaw! A token cannot resolve to nothing")
        }
        
        var final = Array<ResolvedToken>()
        
        // check for argumentless functions
        if options.contains(.AllowArgumentlessFunctions) {
            let extras = extraTokensForArgumentlessFunction(firstResolved, previous: previous)
            final.appendContentsOf(extras)
        }
        
        // check for implicit multiplication
        if options.contains(.AllowImplicitMultiplication) {
            let last = final.last ?? previous
            let extras = extraTokensForImplicitMultiplication(firstResolved, previous: last)
            final.appendContentsOf(extras)
        }
        
        final.appendContentsOf(resolvedTokens)
        
        return final
    }
    
    private func resolveRawToken(rawToken: RawToken, previous: ResolvedToken?) throws -> Array<ResolvedToken> {
        
        var resolvedTokens = Array<ResolvedToken>()
        
        switch rawToken.kind {
            case .HexNumber:
                if let number = UInt(rawToken.string, radix: 16) {
                    resolvedTokens.append(ResolvedToken(kind: .Number(Double(number)), string: rawToken.string, range: rawToken.range))
                } else {
                    throw TokenResolverError(kind: .CannotParseHexNumber, rawToken: rawToken)
                }
            
            case .OctalNumber:
                if let number = UInt(rawToken.string, radix: 8) {
                    resolvedTokens.append(ResolvedToken(kind: .Number(Double(number)), string: rawToken.string, range: rawToken.range))
                } else {
                    throw TokenResolverError(kind: .CannotParseOctalNumber, rawToken: rawToken)
                }
            
            case .Number:
                resolvedTokens.append(resolveNumber(rawToken))
            
            case .LocalizedNumber:
                resolvedTokens.append(try resolveLocalizedNumber(rawToken))
            
            case .Exponent:
                resolvedTokens.appendContentsOf(try resolveExponent(rawToken))
                
            case .Variable:
                resolvedTokens.append(ResolvedToken(kind: .Variable(rawToken.string), string: rawToken.string, range: rawToken.range))
                
            case .Identifier:
                resolvedTokens.append(ResolvedToken(kind: .Identifier(rawToken.string), string: rawToken.string, range: rawToken.range))
                
            case .Operator:
                resolvedTokens.append(try resolveOperator(rawToken, previous: previous))
        }
        
        return resolvedTokens
    }
    
    private func resolveNumber(raw: RawToken) -> ResolvedToken {
        // first, see if it's a special number
        if let character = raw.string.characters.first, let value = SpecialNumberExtractor.specialNumbers[character] {
            return ResolvedToken(kind: .Number(value), string: raw.string, range: raw.range)
        }
        
        let cleaned = raw.string.stringByReplacingOccurrencesOfString("−", withString: "-")
        let number = NSDecimalNumber(string: cleaned)
        return ResolvedToken(kind: .Number(number.doubleValue), string: raw.string, range: raw.range)
    }
    
    private func resolveLocalizedNumber(raw: RawToken) throws -> ResolvedToken {
        for formatter in numberFormatters {
            if let number = formatter.numberFromString(raw.string) {
                return ResolvedToken(kind: .Number(number.doubleValue), string: raw.string, range: raw.range)
            }
        }
        
        throw TokenResolverError(kind: .CannotParseLocalizedNumber, rawToken: raw)
    }
    
    private func resolveExponent(raw: RawToken) throws -> Array<ResolvedToken> {
        var resolved = Array<ResolvedToken>()
        let powerOperator = operatorSet.powerOperator
        let power = ResolvedToken(kind: .Operator(powerOperator), string: "**", range: raw.range.startIndex ..< raw.range.startIndex)
        let openParen = ResolvedToken(kind: .Operator(Operator(builtInOperator: .ParenthesisOpen)), string: "(", range: raw.range.startIndex ..< raw.range.startIndex)
        
        resolved += [power, openParen]
        
        let exponentTokenizer = Tokenizer(string: raw.string, operatorSet: operatorSet, locale: locale)
        let exponentResolver = TokenResolver(tokenizer: exponentTokenizer, options: options)
        
        let exponentTokens = try exponentResolver.resolve()
        
        var distanceSoFar = 0
        for exponentToken in exponentTokens {
            let tokenStart = raw.range.startIndex.advancedBy(distanceSoFar)
            
            let tokenLength = exponentToken.range.startIndex.distanceTo(exponentToken.range.endIndex)
            let tokenEnd = tokenStart.advancedBy(tokenLength)
            distanceSoFar += tokenLength
            
            resolved.append(ResolvedToken(kind: exponentToken.kind, string: exponentToken.string, range: tokenStart ..< tokenEnd))
        }
        
        let closeParen = ResolvedToken(kind: .Operator(Operator(builtInOperator: .ParenthesisClose)), string: ")", range: raw.range.endIndex ..< raw.range.endIndex)
        resolved.append(closeParen)
        
        return resolved
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
