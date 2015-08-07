//
//  QuotedVariableExtractor.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/7/15.
//
//

import Foundation

internal struct QuotedVariableExtractor: TokenExtractor {
    
    func extract(buffer: TokenCharacterBuffer) -> TokenGenerator.Element {
        let start = buffer.currentIndex
        guard let quoteCharacter = buffer.peekNext() where quoteCharacter == "\"" || quoteCharacter == "'" else {
            
            let range = start ..< start
            let error = TokenizerError(kind: .CannotParseQuotedVariable, sourceRange: range)
            return TokenGenerator.Element.Error(error)
        }
        
        // consume the opening quote
        buffer.consume()
        
        var isEscaped = false
        var cleaned = ""
        while let next = buffer.peekNext() {
            
            if isEscaped == false {
                if next == "\\" {
                    isEscaped = true
                    buffer.consume()
                } else if next != quoteCharacter {
                    cleaned.append(next)
                    buffer.consume()
                } else {
                    // it's a close quote
                    break
                }
            } else {
                cleaned.append(next)
                isEscaped = false
                buffer.consume()
            }
            
        }
        
        let result: TokenGenerator.Element
        
        if buffer.peekNext() != quoteCharacter {
            let errorRange = start ..< buffer.currentIndex
            let error = TokenizerError(kind: .CannotParseQuotedVariable, sourceRange: errorRange)
            result = .Error(error)
        } else {
            buffer.consume()
            let range = start ..< buffer.currentIndex
            // check to make sure we don't have an empty string
            if cleaned.characters.isEmpty {
                let error = TokenizerError(kind: .ZeroLengthVariable, sourceRange: range)
                result = .Error(error)
            } else {
                let token = Token(string: cleaned, sourceRange: range)
                result = .Value(token)
            }
        }
        
        return result
    }
    
}
