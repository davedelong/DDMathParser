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
        
        let resolvedTokens = try raw.resolve(options: options, locale: locale ?? .current, operators: operatorSet, previousToken: previous)
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
