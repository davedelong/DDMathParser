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
        return true
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
        
        if start.distanceTo(buffer.currentIndex) > 0 {
            let raw = buffer[range]
            result = .Value(Token(kind: .Operator, string: raw, sourceRange: range))
        } else {
            let error = TokenizerError(kind: .CannotParseOperator, sourceRange: range)
            result = .Error(error)
        }
        
        return result
    }
}
