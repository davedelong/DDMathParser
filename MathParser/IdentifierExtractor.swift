//
//  IdentifierExtractor.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/7/15.
//
//

import Foundation

internal struct IdentifierExtractor: TokenExtractor {
    let operatorTokens: OperatorTokenSet
    
    init(operatorTokens: OperatorTokenSet) {
        self.operatorTokens = operatorTokens
    }
    
    func matchesPreconditions(buffer: TokenCharacterBuffer) -> Bool {
        // An identifier can't start with these, because other things already do
        let next = buffer.peekNext()
        return next != "$" && next?.isDigit == false && next != "\"" && next != "'"
    }
    
    func extract(buffer: TokenCharacterBuffer) -> TokenGenerator.Element {
        let start = buffer.currentIndex
        
        while let next = buffer.peekNext() where next.isWhitespace == false && operatorTokens.isOperatorCharacter(next) == false {
            buffer.consume()
        }
        
        let range = start ..< buffer.currentIndex
        let result: TokenGenerator.Element
        
        if start.distanceTo(buffer.currentIndex) > 0 {
            let raw = buffer[range]
            result = .Value(RawToken(kind: .Identifier, string: raw, range: range))
        } else {
            let error = TokenizerError(kind: .CannotParseIdentifier, sourceRange: range)
            result = .Error(error)
        }
        
        return result
    }
    
}
