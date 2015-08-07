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
    
    public init(string: String) {
        let operatorTokens = OperatorTokenSet(tokens: [])
        
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
        while buffer.peekNext()?.isWhitespaceOrNewline == true {
            buffer.consume()
        }
        
        guard buffer.isAtEnd == false else { return nil }

        let start = buffer.currentIndex
        var errors = Array<Element>()
        
        for extractor in extractors {
            buffer.resetTo(start)
            
            let result = extractor.extract(buffer)
            
            switch result {
                case .Value(_):
                    return result
                case .Error(_):
                    errors.append(result)
            }
        }
        return errors.first
    }
    
}
