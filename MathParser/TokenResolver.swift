//
//  TokenResolver.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/8/15.
//
//

import Foundation

public struct TokenResolver {
    
    private let tokenizer: Tokenizer
    private var configuration: Configuration { return tokenizer.configuration }
    fileprivate let numberFormatters: Array<NumberFormatter>
    internal var operatorSet: OperatorSet { return configuration.operatorSet }
    
    private static func formattersForLocale(_ locale: Locale?) -> Array<NumberFormatter> {
        guard let locale = locale else { return [] }
        
        let decimal = NumberFormatter()
        decimal.locale = locale
        decimal.numberStyle = .decimal
        
        return [decimal]
    }
    
    public init(tokenizer: Tokenizer) {
        self.tokenizer = tokenizer
        let locale = tokenizer.configuration.locale
        self.numberFormatters = TokenResolver.formattersForLocale(locale)
    }
    
    public init(string: String, configuration: Configuration = .default) {
        let t = Tokenizer(string: string, configuration: configuration)
        self.init(tokenizer: t)
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
            if configuration.allowArgumentlessFunctions {
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
        if configuration.allowArgumentlessFunctions {
            let extras = extraTokensForArgumentlessFunction(firstResolved, previous: previous)
            final.append(contentsOf: extras)
        }
        
        // check for implicit multiplication
        if configuration.allowImplicitMultiplication {
            let last = final.last ?? previous
            let extras = extraTokensForImplicitMultiplication(firstResolved, previous: last)
            final.append(contentsOf: extras)
        }
        
        final.append(contentsOf: resolvedTokens)
        
        return final
    }
    
    private func resolveRawToken(_ rawToken: RawToken, previous: ResolvedToken?) throws -> Array<ResolvedToken> {
        
        var resolvedTokens = Array<ResolvedToken>()
        
        switch rawToken {
            case is HexNumberToken:
                if let number = UInt(rawToken.string, radix: 16) {
                    resolvedTokens.append(ResolvedToken(kind: .number(Double(number)), string: rawToken.string, range: rawToken.range))
                } else {
                    throw MathParserError(kind: .cannotParseHexNumber, range: rawToken.range)
                }
            
            case is OctalNumberToken:
                if let number = UInt(rawToken.string, radix: 8) {
                    resolvedTokens.append(ResolvedToken(kind: .number(Double(number)), string: rawToken.string, range: rawToken.range))
                } else {
                    throw MathParserError(kind: .cannotParseOctalNumber, range: rawToken.range)
                }
            
            case is FractionNumberToken:
                if previous?.kind.isNumber == true {
                    let add = operatorSet.addFractionOperator
                    let addToken = ResolvedToken(kind: .operator(add), string: "+", range: rawToken.range.lowerBound ..< rawToken.range.lowerBound)
                    resolvedTokens.append(addToken)
                }
            
                // first, see if it's a special number
                if let character = rawToken.string.first, let value = FractionNumberExtractor.fractions[character] {
                    resolvedTokens.append(ResolvedToken(kind: .number(value), string: rawToken.string, range: rawToken.range))
                } else {
                    throw MathParserError(kind: .cannotParseFractionalNumber, range: rawToken.range)
                }
            
            case is DecimalNumberToken:
                let cleaned = rawToken.string.replacingOccurrences(of: "−", with: "-")
                let number = NSDecimalNumber(string: cleaned)
                resolvedTokens.append(ResolvedToken(kind: .number(number.doubleValue), string: rawToken.string, range: rawToken.range))
            
            case is LocalizedNumberToken:
                resolvedTokens.append(try resolveLocalizedNumber(rawToken))
            
            case is ExponentToken:
                resolvedTokens.append(contentsOf: try resolveExponent(rawToken))
                
            case is VariableToken:
                resolvedTokens.append(ResolvedToken(kind: .variable(rawToken.string), string: rawToken.string, range: rawToken.range))
                
            case is IdentifierToken:
                resolvedTokens.append(ResolvedToken(kind: .identifier(rawToken.string), string: rawToken.string, range: rawToken.range))
                
            case is OperatorToken:
                resolvedTokens.append(try resolveOperator(rawToken, previous: previous))
            
            default: fatalError("Unknown raw token: \(rawToken)")
        }
        
        return resolvedTokens
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
        
        let exponentTokenizer = Tokenizer(string: raw.string, configuration: configuration)
        let exponentResolver = TokenResolver(tokenizer: exponentTokenizer)
        
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
        if configuration.useHighPrecedenceImplicitMultiplication {
            multiplyOperator = operatorSet.implicitMultiplyOperator
        } else {
            multiplyOperator = operatorSet.multiplyOperator
        }
     
        return [ResolvedToken(kind: .operator(multiplyOperator), string: "*", range: next.range.lowerBound ..< next.range.lowerBound)]
    }
}
