//
//  QuotedVariableExtractor.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/7/15.
//
//

import Foundation

internal struct QuotedVariableExtractor: TokenExtractor {
    
    func matchesPreconditions(_ buffer: TokenCharacterBuffer, configuration: Configuration) -> Bool {
        return buffer.peekNext() == "\"" || buffer.peekNext() == "'"
    }
    
    func extract(_ buffer: TokenCharacterBuffer, configuration: Configuration) -> Tokenizer.Result {
        let start = buffer.currentIndex
        
        // consume the opening quote
        let quoteCharacter = buffer.peekNext()
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
                if configuration.unescapesQuotedVariables == true {
                    switch next {
                        case "n": cleaned.append("\n")
                        case "r": cleaned.append("\r")
                        case "t": cleaned.append("\t")
                        default: cleaned.append(next)
                    }
                } else {
                    cleaned.append("\\")
                    cleaned.append(next)
                }
                isEscaped = false
                buffer.consume()
            }
            
        }
        
        let result: Tokenizer.Result
        
        if buffer.peekNext() != quoteCharacter {
            let errorRange: Range<Int> = start ..< buffer.currentIndex
            let error = MathParserError(kind: .cannotParseQuotedVariable, range: errorRange)
            result = .error(error)
        } else {
            buffer.consume()
            let range: Range<Int> = start ..< buffer.currentIndex
            // check to make sure we don't have an empty string
            if cleaned.isEmpty && configuration.allowZeroLengthVariables == false {
                let error = MathParserError(kind: .zeroLengthVariable, range: range)
                result = .error(error)
            } else {
                let token = VariableToken(string: cleaned, range: range)
                result = .value(token)
            }
        }
        
        return result
    }
    
}
