//
//  VariableExtractor.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/7/15.
//
//

import Foundation

internal struct VariableExtractor: TokenExtractor {
    
    let specialCharacters: Set<Character> = ["$"]
    
    private let identifierExtractor: IdentifierExtractor
    
    init(operatorTokens: OperatorTokenSet) {
        identifierExtractor = IdentifierExtractor(operatorTokens: operatorTokens)
    }
    
    func matchesPreconditions(_ buffer: TokenCharacterBuffer, configuration: Configuration) -> Bool {
        return buffer.peekNext() == "$"
    }
    
    func extract(_ buffer: TokenCharacterBuffer, configuration: Configuration, specialCharacters: Set<Character>) -> Result<RawToken, MathParserError> {
        let start = buffer.currentIndex
        
        buffer.consume() // consume the opening $
        
        let identifierMatches = identifierExtractor.matchesPreconditions(buffer, configuration: configuration)
        
        if identifierMatches == false {
            if configuration.allowZeroLengthVariables {
                let token = VariableToken(string: "", range: start ..< buffer.currentIndex)
                return .success(token)
            } else {
                // the stuff that follow "$" must be a valid identifier
                let range = start ..< start
                let error = MathParserError(kind: .cannotParseVariable, range: range)
                return .failure(error)
            }
        }
    
        let identifierStart = buffer.currentIndex
        let identifierResult = identifierExtractor.extract(buffer, configuration: configuration, specialCharacters: specialCharacters)
    
        let result: Result<RawToken, MathParserError>
        
        switch identifierResult {
            case .failure(let e):
                if e.kind == .cannotParseIdentifier && configuration.allowZeroLengthVariables {
                    buffer.resetTo(identifierStart)
                    let token = VariableToken(string: "", range: start ..< identifierStart)
                    result = .success(token)
                } else {
                    let range = start ..< e.range.upperBound
                    let error = MathParserError(kind: .cannotParseVariable, range: range)
                    result = .failure(error)
                }
            case .success(let t):
                let range = start ..< t.range.upperBound
                let token = VariableToken(string: t.string, range: range)
                result = .success(token)
        }
        
        return result
    }
    
}
