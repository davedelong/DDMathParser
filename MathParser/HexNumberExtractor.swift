//
//  HexNumberExtractor.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/6/15.
//
//

import Foundation

internal struct HexNumberExtractor: TokenExtractor {
    
    func matchesPreconditions(_ buffer: TokenCharacterBuffer) -> Bool {
        return buffer.peekNext() == "0" && buffer.peekNext(1, lowercase: true) == "x"
    }
    
    func extract(_ buffer: TokenCharacterBuffer) -> TokenIterator.Element {
        let start = buffer.currentIndex
        
        guard buffer.peekNext() == "0" && buffer.peekNext(1, lowercase: true) == "x" else {
            let error = MathParserError(kind: .cannotParseHexNumber, range: start ..< start)
            return .error(error)
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
        
        let result: TokenIterator.Element
        
        if buffer.currentIndex - start > 0 {
            let range: Range<Int> = indexBeforeHexNumbers ..< buffer.currentIndex
            let raw = buffer[range]
            result = .value(RawToken(kind: .hexNumber, string: raw, range: range))
        } else {
            let range: Range<Int> = start ..< buffer.currentIndex
            let error = MathParserError(kind: .cannotParseHexNumber, range: range)
            result = .error(error)
        }
        
        return result
    }

}
