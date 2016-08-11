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
    
    func matchesPreconditions(_ buffer: TokenCharacterBuffer) -> Bool {
        guard let peek = buffer.peekNext() else { return false }
        return operatorTokens.hasOperatorWithPrefix(String(peek))
    }
    
    func extract(_ buffer: TokenCharacterBuffer) -> TokenIterator.Element {
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
        
        let range: Range<Int> = start ..< buffer.currentIndex
        let result: TokenIterator.Element
        
        if buffer[start].isAlphabetic && buffer.peekNext()?.isAlphabetic == true {
            // This operator starts with an alphabetic character and
            // the next character after it is also alphabetic, and not whitespace.
            // This *probably* isn't an operator, but is instead the beginning
            // of an identifier that happens to have the same prefix as an operator token.
            buffer.resetTo(start)
        }
        
        if buffer.currentIndex - start > 0 {
            let raw = buffer[range]
            result = .value(RawToken(kind: .operator, string: raw, range: range))
        } else {
            let error = MathParserError(kind: .cannotParseOperator, range: range)
            result = .error(error)
        }
        
        return result
    }
}
