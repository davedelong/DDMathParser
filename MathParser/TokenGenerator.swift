//
//  TokenGenerator.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/6/15.
//
//

import Foundation

internal class TokenGenerator: GeneratorType {
    typealias Element = Either<RawToken, TokenizerError>
    
    private let buffer: TokenCharacterBuffer
    private let extractors: Array<TokenExtractor>
    
    internal let operatorSet: OperatorSet
    
    init(string: String, operatorSet: OperatorSet) {
        self.operatorSet = operatorSet
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
    
    func next() -> Element? {
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
        
        return errors.first
    }
    
}
