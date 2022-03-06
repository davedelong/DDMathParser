//
//  HexNumberExtractor.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/6/15.
//
//

import Foundation

internal struct HexNumberExtractor: TokenExtractor {
    
    let specialCharacters: Set<Character> = []
    
    func matchesPreconditions(_ buffer: TokenCharacterBuffer, configuration: Configuration) -> Bool {
        return buffer.peekNext() == "0" && buffer.peekNext(1, lowercase: true) == "x"
    }
    
    func extract(_ buffer: TokenCharacterBuffer, configuration: Configuration, specialCharacters: Set<Character>) -> Result<RawToken, MathParserError> {
        let start = buffer.currentIndex
        
        guard buffer.peekNext() == "0" && buffer.peekNext(1, lowercase: true) == "x" else {
            let error = MathParserError(kind: .cannotParseHexNumber, range: start ..< start)
            return .failure(error)
        }
        
        
        buffer.consume(2) // 0x
        
        let indexBeforeHexNumbers = buffer.currentIndex
        while buffer.peekNext()?.isHexDigit == true {
            buffer.consume()
        }
        
        if buffer.currentIndex == indexBeforeHexNumbers {
            // there wasn't anything after 0[xX]
            buffer.resetTo(start)
        }
        
        let result: Result<RawToken, MathParserError>
        
        if buffer.currentDistance(from: start) > 0 {
            let range = indexBeforeHexNumbers ..< buffer.currentIndex
            let raw = buffer[range]
            result = .success(HexNumberToken(string: raw, range: range))
        } else {
            let range = start ..< buffer.currentIndex
            let error = MathParserError(kind: .cannotParseHexNumber, range: range)
            result = .failure(error)
        }
        
        return result
    }

}
