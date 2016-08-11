//
//  ExponentExtractor.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/30/15.
//
//

import Foundation

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
    
    func extract(_ buffer: TokenCharacterBuffer) -> TokenIterator.Element {
        let start = buffer.currentIndex
        
        var exponent = ""
        while let peek = buffer.peekNext(), let regular = ExponentExtractor.exponentCharacters[peek] {
            buffer.consume()
            exponent.append(regular)
        }
        
        let length = buffer.currentIndex - start
        let range: Range<Int> = start ..< buffer.currentIndex
        
        if length > 0 {
            return .value(RawToken(kind: .exponent, string: exponent, range: range))
        } else {
            let error = MathParserError(kind: .cannotParseExponent, range: range)
            return .error(error)
        }
    }
    
}
