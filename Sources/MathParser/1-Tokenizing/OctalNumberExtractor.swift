//
//  OctalNumberExtractor.swift
//  DDMathParser
//
//  Created by Dave DeLong on 3/3/16.
//
//

import Foundation

internal struct OctalNumberExtractor: TokenExtractor {
    
    func matchesPreconditions(_ buffer: TokenCharacterBuffer, configuration: Configuration) -> Bool {
        return buffer.peekNext() == "0" && buffer.peekNext(1, lowercase: true) == "o"
    }
    
    func extract(_ buffer: TokenCharacterBuffer, configuration: Configuration) -> Result<RawToken, MathParserError> {
        let start = buffer.currentIndex
        
        guard buffer.peekNext() == "0" && buffer.peekNext(1, lowercase: true) == "o" else {
            let error = MathParserError(kind: .cannotParseHexNumber, range: start ..< start)
            return .failure(error)
        }
        
        
        buffer.consume(2) // 0o
        
        let indexBeforeOctalNumbers = buffer.currentIndex
        while buffer.peekNext()?.isOctalDigit == true {
            buffer.consume()
        }
        
        if buffer.currentIndex == indexBeforeOctalNumbers {
            // there wasn't anything after 0[oO]
            buffer.resetTo(start)
        }
        
        let result: Result<RawToken, MathParserError>
        
        if buffer.currentDistance(from: start) > 0 {
            let range = indexBeforeOctalNumbers ..< buffer.currentIndex
            let raw = buffer[range]
            result = .success(OctalNumberToken(string: raw, range: range))
        } else {
            let range = start ..< buffer.currentIndex
            let error = MathParserError(kind: .cannotParseOctalNumber, range: range)
            result = .failure(error)
        }
        
        return result
    }
    
}
