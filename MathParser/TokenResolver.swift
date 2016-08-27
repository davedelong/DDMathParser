//
//  TokenResolver.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/8/15.
//
//

import Foundation

public struct TokenResolverOptions: OptionSet {
    public let rawValue: UInt
    
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
    
    public static let none = TokenResolverOptions(rawValue: 0)
    public static let allowArgumentlessFunctions = TokenResolverOptions(rawValue: 1 << 0)
    public static let allowImplicitMultiplication = TokenResolverOptions(rawValue: 1 << 1)
    public static let useHighPrecedenceImplicitMultiplication = TokenResolverOptions(rawValue: 1 << 2)
    
    public static let `default`: TokenResolverOptions = [.allowArgumentlessFunctions, .allowImplicitMultiplication, .useHighPrecedenceImplicitMultiplication]
}

public struct TokenResolver {
    
    private let tokenizer: Tokenizer
    fileprivate let options: TokenResolverOptions
    fileprivate let locale: Locale?
    fileprivate let numberFormatters: Array<NumberFormatter>
    internal var operatorSet: OperatorSet { return tokenizer.operatorSet }
    
    private static func formattersForLocale(_ locale: Locale?) -> Array<NumberFormatter> {
        guard let locale = locale else { return [] }
        
        let decimal = NumberFormatter()
        decimal.locale = locale
        decimal.numberStyle = .decimal
        
        return [decimal]
    }
    
    public init(tokenizer: Tokenizer, options: TokenResolverOptions = TokenResolverOptions.default) {
        self.tokenizer = tokenizer
        self.options = options
        self.locale = tokenizer.locale
        self.numberFormatters = TokenResolver.formattersForLocale(tokenizer.locale)
    }
    
    public init(string: String, operatorSet: OperatorSet = OperatorSet.default, options: TokenResolverOptions = TokenResolverOptions.default, locale: Locale? = nil) {
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
            resolvedTokens.append(contentsOf: resolved)
        }
        
        let finalResolved = try resolveToken(nil, previous: resolvedTokens.last)
        resolvedTokens.append(contentsOf: finalResolved)
        
        return resolvedTokens
    }
    
}

extension TokenResolver {
    fileprivate func resolveToken(_ raw: RawToken?, previous: ResolvedToken?) throws -> Array<ResolvedToken> {
        
        guard let raw = raw else {
            // this is the case where the we check for argumentless stuff
            // after the last token
            if options.contains(.allowArgumentlessFunctions) {
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
        if options.contains(.allowArgumentlessFunctions) {
            let extras = extraTokensForArgumentlessFunction(firstResolved, previous: previous)
            final.append(contentsOf: extras)
        }
        
        // check for implicit multiplication
        if options.contains(.allowImplicitMultiplication) {
            let last = final.last ?? previous
            let extras = extraTokensForImplicitMultiplication(firstResolved, previous: last)
            final.append(contentsOf: extras)
        }
        
        final.append(contentsOf: resolvedTokens)
        
        return final
    }
    
    private func resolveRawToken(_ rawToken: RawToken, previous: ResolvedToken?) throws -> Array<ResolvedToken> {
        
        var resolvedTokens = Array<ResolvedToken>()
        
        switch rawToken.kind {
            case .hexNumber:
                if let number = UInt(rawToken.string, radix: 16) {
                    resolvedTokens.append(ResolvedToken(kind: .number(Double(number)), string: rawToken.string, range: rawToken.range))
                } else {
                    throw MathParserError(kind: .cannotParseHexNumber, range: rawToken.range)
                }
            
            case .octalNumber:
                if let number = UInt(rawToken.string, radix: 8) {
                    resolvedTokens.append(ResolvedToken(kind: .number(Double(number)), string: rawToken.string, range: rawToken.range))
                } else {
                    throw MathParserError(kind: .cannotParseOctalNumber, range: rawToken.range)
                }
            
            case .number:
                resolvedTokens.append(resolveNumber(rawToken))
            
            case .localizedNumber:
                resolvedTokens.append(try resolveLocalizedNumber(rawToken))
            
            case .exponent:
                resolvedTokens.append(contentsOf: try resolveExponent(rawToken))
                
            case .variable:
                resolvedTokens.append(ResolvedToken(kind: .variable(rawToken.string), string: rawToken.string, range: rawToken.range))
                
            case .identifier:
                resolvedTokens.append(ResolvedToken(kind: .identifier(rawToken.string), string: rawToken.string, range: rawToken.range))
                
            case .operator:
                resolvedTokens.append(try resolveOperator(rawToken, previous: previous))
        }
        
        return resolvedTokens
    }
    
    private func resolveNumber(_ raw: RawToken) -> ResolvedToken {
        // first, see if it's a special number
        if let character = raw.string.characters.first, let value = SpecialNumberExtractor.specialNumbers[character] {
            return ResolvedToken(kind: .number(value), string: raw.string, range: raw.range)
        }
        
        let cleaned = raw.string.replacingOccurrences(of: "−", with: "-")
        let number = NSDecimalNumber(string: cleaned)
        return ResolvedToken(kind: .number(number.doubleValue), string: raw.string, range: raw.range)
    }
    
    private func resolveLocalizedNumber(_ raw: RawToken) throws -> ResolvedToken {
        for formatter in numberFormatters {
            if let number = formatter.number(from: raw.string) {
                return ResolvedToken(kind: .number(number.doubleValue), string: raw.string, range: raw.range)
            }
        }
        
        throw MathParserError(kind: .cannotParseLocalizedNumber, range: raw.range)
    }
    
    private func resolveExponent(_ raw: RawToken) throws -> Array<ResolvedToken> {
        var resolved = Array<ResolvedToken>()
        let powerOperator = operatorSet.powerOperator
        let power = ResolvedToken(kind: .operator(powerOperator), string: "**", range: raw.range.lowerBound ..< raw.range.lowerBound)
        let openParen = ResolvedToken(kind: .operator(Operator(builtInOperator: .parenthesisOpen)), string: "(", range: raw.range.lowerBound ..< raw.range.lowerBound)
        
        resolved += [power, openParen]
        
        let exponentTokenizer = Tokenizer(string: raw.string, operatorSet: operatorSet, locale: locale)
        let exponentResolver = TokenResolver(tokenizer: exponentTokenizer, options: options)
        
        let exponentTokens = try exponentResolver.resolve()
        
        var distanceSoFar = 0
        for exponentToken in exponentTokens {
            let tokenStart = raw.range.lowerBound + distanceSoFar
            
            let tokenLength = exponentToken.range.upperBound - exponentToken.range.lowerBound
            let tokenEnd = tokenStart + tokenLength
            distanceSoFar += tokenLength
            
            resolved.append(ResolvedToken(kind: exponentToken.kind, string: exponentToken.string, range: tokenStart ..< tokenEnd))
        }
        
        let closeParen = ResolvedToken(kind: .operator(Operator(builtInOperator: .parenthesisClose)), string: ")", range: raw.range.upperBound ..< raw.range.upperBound)
        resolved.append(closeParen)
        
        return resolved
    }
    
    private func resolveOperator(_ raw: RawToken, previous: ResolvedToken?) throws -> ResolvedToken {
        let matches = operatorSet.operatorForToken(raw.string)
        
        if matches.isEmpty {
            throw MathParserError(kind: .unknownOperator, range: raw.range)
        }
        
        if matches.count == 1 {
            let op = matches[0]
            return ResolvedToken(kind: .operator(op), string: raw.string, range: raw.range)
        }
        
        // more than one operator has this token
        
        var resolvedOperator: Operator? = nil
        
        if let previous = previous {
            switch previous.kind {
                case .operator(let o):
                    resolvedOperator = resolveOperator(raw, previousOperator: o)
                
                default:
                    // a number/variable can be followed by:
                    // a left-assoc unary operator,
                    // a binary operator,
                    // or a right-assoc unary operator (assuming implicit multiplication)
                    // we'll prefer them from left-to-right:
                    // left-assoc unary, binary, right-assoc unary
                    // TODO: is this correct?? should we be looking at precedence instead?
                    resolvedOperator = operatorSet.operatorForToken(raw.string, arity: .unary, associativity: .left).first
                    
                    if resolvedOperator == nil {
                        resolvedOperator = operatorSet.operatorForToken(raw.string, arity: .binary).first
                    }
                    
                    if resolvedOperator == nil {
                        resolvedOperator = operatorSet.operatorForToken(raw.string, arity: .unary, associativity: .right).first
                    }
            }
            
        } else {
            // no previous token, so this must be a right-assoc unary operator
            resolvedOperator = operatorSet.operatorForToken(raw.string, arity: .unary, associativity: .right).first
        }
        
        if let resolved = resolvedOperator {
            return ResolvedToken(kind: .operator(resolved), string: raw.string, range: raw.range)
        } else {
            throw MathParserError(kind: .ambiguousOperator, range: raw.range)
        }
    }
    
    private func resolveOperator(_ raw: RawToken, previousOperator o: Operator) -> Operator? {
        var resolvedOperator: Operator?
        
        switch (o.arity, o.associativity) {
            
            case (.unary, .left):
                // a left-assoc unary operator can be followed by either:
                // another left-assoc unary operator
                // or a binary operator
                resolvedOperator = operatorSet.operatorForToken(raw.string, arity: .unary, associativity: .left).first
                
                if resolvedOperator == nil {
                    resolvedOperator = operatorSet.operatorForToken(raw.string, arity: .binary).first
                }
            
            
            default:
                // either a binary operator or a right-assoc unary operator
                
                // a binary operator can only be followed by a right-assoc unary operator
                //a right-assoc operator can only be followed by a right-assoc unary operator
                resolvedOperator = operatorSet.operatorForToken(raw.string, arity: .unary, associativity: .right).first
            
        }
        
        return resolvedOperator
    }
    
    private func extraTokensForArgumentlessFunction(_ next: ResolvedToken?, previous: ResolvedToken?) -> Array<ResolvedToken> {
        guard let previous = previous else { return [] }
        // we only insert tokens here if the previous token was an identifier
        guard let _ = previous.kind.identifier else { return [] }
        
        
        let nextOperator = next?.kind.resolvedOperator
        if nextOperator == nil || nextOperator?.builtInOperator != .parenthesisOpen {
            let range: Range<Int> = previous.range.upperBound ..< previous.range.upperBound
            
            let openParenOp = Operator(builtInOperator: .parenthesisOpen)
            let openParen = ResolvedToken(kind: .operator(openParenOp), string: "(", range: range)
            
            let closeParenOp = Operator(builtInOperator: .parenthesisClose)
            let closeParen = ResolvedToken(kind: .operator(closeParenOp), string: ")", range: range)
            
            return [openParen, closeParen]
        }
        
        return []
    }
    
    private func extraTokensForImplicitMultiplication(_ next: ResolvedToken, previous: ResolvedToken?) -> Array<ResolvedToken> {
        guard let previousKind = previous?.kind else { return [] }
        let nextKind = next.kind
        
        let previousMatches = previousKind.isNumber || previousKind.isVariable || (previousKind.resolvedOperator?.arity == .unary && previousKind.resolvedOperator?.associativity == .left)
        
        let nextMatches = nextKind.isOperator == false || (nextKind.resolvedOperator?.arity == .unary && nextKind.resolvedOperator?.associativity == .right)
        
        guard previousMatches && nextMatches else { return [] }
        
        let multiplyOperator: Operator
        if options.contains(.useHighPrecedenceImplicitMultiplication) {
            multiplyOperator = operatorSet.implicitMultiplyOperator
        } else {
            multiplyOperator = operatorSet.multiplyOperator
        }
     
        return [ResolvedToken(kind: .operator(multiplyOperator), string: "*", range: next.range.lowerBound ..< next.range.lowerBound)]
    }
}
