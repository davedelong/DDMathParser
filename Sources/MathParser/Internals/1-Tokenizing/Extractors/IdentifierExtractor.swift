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
    
    let specialCharacters: Set<Character> = []
    
    init(operatorTokens: OperatorTokenSet) {
        self.operatorTokens = operatorTokens
    }
    
    func matchesPreconditions(_ buffer: TokenCharacterBuffer, configuration: Configuration) -> Bool {
        // An identifier can't start with these, because other things already do
        let next = buffer.peekNext()
        return next != "$" && next?.isDigit == false && next != "\"" && next != "'"
    }
    
    func extract(_ buffer: TokenCharacterBuffer, configuration: Configuration, specialCharacters: Set<Character>) -> Result<RawToken, MathParserError> {
        let start = buffer.currentIndex
        
        while let next = buffer.peekNext(), next.isWhitespace == false && operatorTokens.isOperatorCharacter(next) == false && specialCharacters.contains(next) == false {
            buffer.consume()
        }
        
        let range = start ..< buffer.currentIndex
        let result: Result<RawToken, MathParserError>
        
        if buffer.currentDistance(from: start) > 0 {
            let raw = buffer[range]
            result = .success(IdentifierToken(string: raw, range: range))
        } else {
            let error = MathParserError(code: .cannotParseIdentifier, range: range)
            result = .failure(error)
        }
        
        return result
    }
    
}
