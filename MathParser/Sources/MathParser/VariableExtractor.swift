//
//  VariableExtractor.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/7/15.
//
//

import Foundation

internal struct VariableExtractor: TokenExtractor {
    private let identifierExtractor: IdentifierExtractor
    
    init(operatorTokens: OperatorTokenSet) {
        identifierExtractor = IdentifierExtractor(operatorTokens: operatorTokens)
    }
    
    func matchesPreconditions(_ buffer: TokenCharacterBuffer, configuration: Configuration) -> Bool {
        return buffer.peekNext() == "$"
    }
    
    func extract(_ buffer: TokenCharacterBuffer, configuration: Configuration) -> Tokenizer.Result {
        let start = buffer.currentIndex
        
        buffer.consume() // consume the opening $
        
        let identifierMatches = identifierExtractor.matchesPreconditions(buffer, configuration: configuration)
        
        if identifierMatches == false {
            if configuration.allowZeroLengthVariables {
                let token = VariableToken(string: "", range: start ..< buffer.currentIndex)
                return Tokenizer.Result.value(token)
            } else {
                // the stuff that follow "$" must be a valid identifier
                let range: Range<Int> = start ..< start
                let error = MathParserError(kind: .cannotParseVariable, range: range)
                return Tokenizer.Result.error(error)
            }
        }
    
        let identifierStart = buffer.currentIndex
        let identifierResult = identifierExtractor.extract(buffer, configuration: configuration)
    
        let result: Tokenizer.Result
        
        switch identifierResult {
            case .error(let e):
                if e.kind == .cannotParseIdentifier && configuration.allowZeroLengthVariables {
                    buffer.resetTo(identifierStart)
                    let token = VariableToken(string: "", range: start ..< identifierStart)
                    result = .value(token)
                } else {
                    let range: Range<Int> = start ..< e.range.upperBound
                    let error = MathParserError(kind: .cannotParseVariable, range: range)
                    result = .error(error)
                }
            case .value(let t):
                let range: Range<Int> = start ..< t.range.upperBound
                let token = VariableToken(string: t.string, range: range)
                result = .value(token)
        }
        
        return result
    }
    
}
