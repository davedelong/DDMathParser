//
//  OperatorExtractor.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/7/15.
//
//

import Foundation

internal struct OperatorExtractor: TokenExtractor {
    let operatorTokens: OperatorTokenSet
    
    init(operatorTokens: OperatorTokenSet) {
        self.operatorTokens = operatorTokens
    }
    
    func matchesPreconditions(buffer: TokenCharacterBuffer) -> Bool {
        guard let peek = buffer.peekNext() else { return false }
        return operatorTokens.hasOperatorWithPrefix(String(peek))
    }
    
    func extract(buffer: TokenCharacterBuffer) -> TokenGenerator.Element {
        let start = buffer.currentIndex
        
        var lastGoodIndex = start
        var current = ""
        
        while let next = buffer.peekNext(lowercase: true) {
            current.append(next)
            if operatorTokens.hasOperatorWithPrefix(current) {
                buffer.consume()
                
                if operatorTokens.isOperatorToken(current) {
                    lastGoodIndex = buffer.currentIndex
                }
            } else {
                break
            }
        }
        
        buffer.resetTo(lastGoodIndex)
        
        let range = start ..< buffer.currentIndex
        let result: TokenGenerator.Element
        
        if buffer[start].isAlphabetic && buffer.peekNext()?.isAlphabetic == true {
            // This operator starts with an alphabetic character and
            // the next character after it is also alphabetic, and not whitespace.
            // This *probably* isn't an operator, but is instead the beginning
            // of an identifier that happens to have the same prefix as an operator token.
            buffer.resetTo(start)
        }
        
        if start.distanceTo(buffer.currentIndex) > 0 {
            let raw = buffer[range]
            result = .Value(RawToken(kind: .Operator, string: raw, range: range))
        } else {
            let error = TokenizerError(kind: .CannotParseOperator, sourceRange: range)
            result = .Error(error)
        }
        
        return result
    }
}
