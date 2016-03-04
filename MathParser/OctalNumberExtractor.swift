//
//  OctalNumberExtractor.swift
//  DDMathParser
//
//  Created by Dave DeLong on 3/3/16.
//
//

import Foundation

internal struct OctalNumberExtractor: TokenExtractor {
    
    func matchesPreconditions(buffer: TokenCharacterBuffer) -> Bool {
        return buffer.peekNext() == "0" && buffer.peekNext(1, lowercase: true) == "o"
    }
    
    func extract(buffer: TokenCharacterBuffer) -> TokenGenerator.Element {
        let start = buffer.currentIndex
        
        guard buffer.peekNext() == "0" && buffer.peekNext(1, lowercase: true) == "o" else {
            let error = TokenizerError(kind: .CannotParseHexNumber, sourceRange: start ..< start)
            return .Error(error)
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
        
        let result: TokenGenerator.Element
        
        if start.distanceTo(buffer.currentIndex) > 0 {
            let range = indexBeforeOctalNumbers ..< buffer.currentIndex
            let raw = buffer[range]
            result = .Value(RawToken(kind: .OctalNumber, string: raw, range: range))
        } else {
            let range = start ..< buffer.currentIndex
            let error = TokenizerError(kind: .CannotParseOctalNumber, sourceRange: range)
            result = .Error(error)
        }
        
        return result
    }
    
}
