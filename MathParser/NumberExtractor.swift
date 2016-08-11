//
//  NumberExtractor.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/6/15.
//
//

import Foundation

internal struct NumberExtractor: TokenExtractor {
    
    func matchesPreconditions(_ buffer: TokenCharacterBuffer) -> Bool {
        return buffer.peekNext()?.isDigit == true
    }
    
    func extract(_ buffer: TokenCharacterBuffer) -> TokenIterator.Element {
        let start = buffer.currentIndex
        
        while buffer.peekNext()?.isDigit == true {
            buffer.consume()
        }
        
        if buffer.peekNext() == "." {
            buffer.consume()
            
            // consume fractional digits
            while buffer.peekNext()?.isDigit == true {
                buffer.consume()
            }
        }
        
        let indexBeforeE = buffer.currentIndex
        if buffer.peekNext() == "e" || buffer.peekNext() == "E" {
            buffer.consume()
            
            // there might be a "-" or "+" character preceding the exponent
            if buffer.peekNext() == "-" || buffer.peekNext() == "−" || buffer.peekNext() == "+" {
                buffer.consume()
            }
            
            let indexAtExponentDigits = buffer.currentIndex
            
            while buffer.peekNext()?.isDigit == true {
                buffer.consume()
            }
            
            if buffer.currentIndex == indexAtExponentDigits {
                // we didn't read anything after the [eE][-+]
                // so the entire exponent range is invalid
                buffer.resetTo(indexBeforeE)
            }
        }
        
        let length = buffer.currentIndex - start
        let range: Range<Int> = start ..< buffer.currentIndex
        let error = MathParserError(kind: .cannotParseNumber, range: range)
        
        var result = TokenIterator.Element.error(error)
        if length > 0 {
            if length != 1 || buffer[start] != "." {
                let raw = buffer[range]
                result = .value(RawToken(kind: .number, string: raw, range: range))
            }
        }
        return result
    }
    
}
