//
//  SpecialNumberExtractor.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/30/15.
//
//

import Foundation

internal struct SpecialNumberExtractor: TokenExtractor {
    
    internal static let specialNumbers: Dictionary<Character, Double> = [
        "½": 1.0/2,
        "⅓": 1.0/3,
        "⅔": 2.0/3,
        "¼": 1.0/4,
        "¾": 3.0/4,
        "⅕": 1.0/5,
        "⅖": 2.0/5,
        "⅗": 3.0/5,
        "⅘": 4.0/5,
        "⅙": 1.0/6,
        "⅚": 5.0/6,
        "⅛": 1.0/8,
        "⅜": 3.0/8,
        "⅝": 5.0/8,
        "⅞": 7.0/8
    ]
    
    func matchesPreconditions(buffer: TokenCharacterBuffer) -> Bool {
        guard let peek = buffer.peekNext() else { return false }
        guard let _ = SpecialNumberExtractor.specialNumbers[peek] else { return false }
        return true
    }
    
    func extract(buffer: TokenCharacterBuffer) -> TokenGenerator.Element {
        let start = buffer.currentIndex
        
        // consume the character
        buffer.consume()
        
        let range = start ..< buffer.currentIndex
        let raw = buffer[range]
        return .Value(RawToken(kind: .Number, string: raw, range: range))
    }
    
}
