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
    
    func matchesPreconditions(buffer: TokenCharacterBuffer) -> Bool {
        return buffer.peekNext() == "$"
    }
    
    func extract(buffer: TokenCharacterBuffer) -> TokenGenerator.Element {
        let start = buffer.currentIndex
        
        buffer.consume() // consume the opening $
        
        guard identifierExtractor.matchesPreconditions(buffer) else {
            // the stuff that follow "$" must be a valid identifier
            let range = start ..< start
            let error = TokenizerError(kind: .CannotParseVariable, sourceRange: range)
            return TokenGenerator.Element.Error(error)
        }
    
        let identifierResult = identifierExtractor.extract(buffer)
    
        let result: TokenGenerator.Element
        
        switch identifierResult {
            case .Error(let e):
                let range = start ..< e.sourceRange.endIndex
                let error = TokenizerError(kind: .CannotParseVariable, sourceRange: range)
                result = .Error(error)
            case .Value(let t):
                let range = start ..< t.range.endIndex
                let token = RawToken(kind: .Variable, string: t.string, range: range)
                result = .Value(token)
        }
        
        return result
    }
    
}
