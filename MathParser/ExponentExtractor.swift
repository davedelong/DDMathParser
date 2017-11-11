//
//  ExponentExtractor.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/30/15.
//
//

import Foundation

public class ExponentToken: RawToken {
    
    public override func resolve(options: TokenResolverOptions, locale: Locale, operators: OperatorSet, previousToken: ResolvedToken? = nil) throws -> Array<ResolvedToken> {
        // TODO: this isn't quite right
        // for the same reason it wouldn't be right for fractions; the injection of ** shouldn't happen here
        
        var resolved = Array<ResolvedToken>()
        let powerOperator = operators.powerOperator
        let power = ResolvedToken(kind: .operator(powerOperator), string: "**", range: range.lowerBound ..< range.lowerBound)
        let openParen = ResolvedToken(kind: .operator(Operator(builtInOperator: .parenthesisOpen)), string: "(", range: range.lowerBound ..< range.lowerBound)
        
        resolved += [power, openParen]
        
        let exponentTokenizer = Tokenizer(string: string, operatorSet: operators, locale: locale)
        let exponentResolver = TokenResolver(tokenizer: exponentTokenizer, options: options)
        
        let exponentTokens = try exponentResolver.resolve()
        
        var distanceSoFar = 0
        for exponentToken in exponentTokens {
            let tokenStart = range.lowerBound + distanceSoFar
            
            let tokenLength = exponentToken.range.upperBound - exponentToken.range.lowerBound
            let tokenEnd = tokenStart + tokenLength
            distanceSoFar += tokenLength
            
            resolved.append(ResolvedToken(kind: exponentToken.kind, string: exponentToken.string, range: tokenStart ..< tokenEnd))
        }
        
        let closeParen = ResolvedToken(kind: .operator(Operator(builtInOperator: .parenthesisClose)), string: ")", range: range.upperBound ..< range.upperBound)
        resolved.append(closeParen)
        
        return resolved
    }
    
}

internal struct ExponentExtractor: TokenExtractor {
    
    internal static let exponentCharacters: Dictionary<Character, Character> = [
        "⁰": "0",
        "¹": "1",
        "²": "2",
        "³": "3",
        "⁴": "4",
        "⁵": "5",
        "⁶": "6",
        "⁷": "7",
        "⁸": "8",
        "⁹": "9",
        "⁺": "+",
        "⁻": "-",
        "⁽": "(",
        "⁾": ")"
    ]
    
    func matchesPreconditions(_ buffer: TokenCharacterBuffer) -> Bool {
        guard let peek = buffer.peekNext() else { return false }
        guard let _ = ExponentExtractor.exponentCharacters[peek] else { return false }
        return true
    }
    
    func extract(_ buffer: TokenCharacterBuffer) -> Tokenizer.Result {
        let start = buffer.currentIndex
        
        var exponent = ""
        while let peek = buffer.peekNext(), let regular = ExponentExtractor.exponentCharacters[peek] {
            buffer.consume()
            exponent.append(regular)
        }
        
        let length = buffer.currentIndex - start
        let range: Range<Int> = start ..< buffer.currentIndex
        
        if length > 0 {
            return .value(ExponentToken(string: exponent, range: range))
        } else {
            let error = MathParserError(kind: .cannotParseExponent, range: range)
            return .error(error)
        }
    }
    
}
