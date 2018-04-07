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
    
    func matchesPreconditions(_ buffer: TokenCharacterBuffer) -> Bool {
        return buffer.peekNext() == "$"
    }
    
    func extract(_ buffer: TokenCharacterBuffer) -> Tokenizer.Result {
        let start = buffer.currentIndex
        
        buffer.consume() // consume the opening $
        
        guard identifierExtractor.matchesPreconditions(buffer) else {
            // the stuff that follow "$" must be a valid identifier
            let range: Range<Int> = start ..< start
            let error = MathParserError(kind: .cannotParseVariable, range: range)
            return Tokenizer.Result.error(error)
        }
    
        let identifierResult = identifierExtractor.extract(buffer)
    
        let result: Tokenizer.Result
        
        switch identifierResult {
            case .error(let e):
                let range: Range<Int> = start ..< e.range.upperBound
                let error = MathParserError(kind: .cannotParseVariable, range: range)
                result = .error(error)
            case .value(let t):
                let range: Range<Int> = start ..< t.range.upperBound
                let token = VariableToken(string: t.string, range: range)
                result = .value(token)
        }
        
        return result
    }
    
}
