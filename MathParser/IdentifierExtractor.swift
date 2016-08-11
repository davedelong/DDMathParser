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
    
    func matchesPreconditions(_ buffer: TokenCharacterBuffer) -> Bool {
        // An identifier can't start with these, because other things already do
        let next = buffer.peekNext()
        return next != "$" && next?.isDigit == false && next != "\"" && next != "'"
    }
    
    func extract(_ buffer: TokenCharacterBuffer) -> TokenIterator.Element {
        let start = buffer.currentIndex
        
        while let next = buffer.peekNext(), next.isWhitespace == false && operatorTokens.isOperatorCharacter(next) == false {
            buffer.consume()
        }
        
        let range: Range<Int> = start ..< buffer.currentIndex
        let result: TokenIterator.Element
        
        if buffer.currentIndex - start > 0 {
            let raw = buffer[range]
            result = .value(RawToken(kind: .identifier, string: raw, range: range))
        } else {
            let error = MathParserError(kind: .cannotParseIdentifier, range: range)
            result = .error(error)
        }
        
        return result
    }
    
}
