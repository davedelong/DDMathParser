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
    
    func extract(buffer: TokenCharacterBuffer) -> TokenGenerator.Element {
        let start = buffer.currentIndex
        guard buffer.peekNext() == "$" else {
            // variables must start with "$"
            let range = start ..< start
            let error = TokenizerError(kind: .CannotParseVariable, sourceRange: range)
            return TokenGenerator.Element.Error(error)
        }
        
        buffer.consume()
    
        let identifierResult = identifierExtractor.extract(buffer)
    
        let result: TokenGenerator.Element
        
        switch identifierResult {
            case .Error(let e):
                let range = start ..< e.sourceRange.endIndex
                let error = TokenizerError(kind: .CannotParseVariable, sourceRange: range)
                result = .Error(error)
            case .Value(let t):
                let range = start ..< t.sourceRange.endIndex
                let token = Token(kind: .Variable, string: t.string, sourceRange: range)
                result = .Value(token)
        }
        
        return result
    }
    
}
