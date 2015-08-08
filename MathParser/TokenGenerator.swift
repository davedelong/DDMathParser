//
//  TokenGenerator.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/6/15.
//
//

import Foundation

public class TokenGenerator: GeneratorType {
    public typealias Element = Either<Token, TokenizerError>
    
    private let buffer: TokenCharacterBuffer
    private let extractors: Array<TokenExtractor>
    private var hasReturnedError = false
    
    public init(string: String, operatorSet: OperatorSet) {
        let operatorTokens = operatorSet.operatorTokenSet
        
        buffer = TokenCharacterBuffer(string: string)
        extractors = [
            HexNumberExtractor(),
            NumberExtractor(),
            VariableExtractor(operatorTokens: operatorTokens),
            QuotedVariableExtractor(),
            OperatorExtractor(operatorTokens: operatorTokens),
            IdentifierExtractor(operatorTokens: operatorTokens)
        ]
    }
    
    public func next() -> Element? {
        // once the generator has produced an error,
        // it can't produce anything else
        guard hasReturnedError == false else { return nil }
        
        while buffer.peekNext()?.isWhitespaceOrNewline == true {
            buffer.consume()
        }
        
        guard buffer.isAtEnd == false else { return nil }

        let start = buffer.currentIndex
        var errors = Array<Element>()
        
        for extractor in extractors {
            buffer.resetTo(start)
            
            if extractor.matchesPreconditions(buffer) {
                let result = extractor.extract(buffer)
                
                switch result {
                    case .Value(_):
                        return result
                    case .Error(_):
                        errors.append(result)
                }
            }
        }
        
        let error = errors.first
        hasReturnedError = (error != nil)
        return error
    }
    
}
