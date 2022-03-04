//
//  Tokenizer.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/6/15.
//
//

import Foundation

internal struct Tokenizer {
    internal let source: String
    internal let configuration: Configuration
    
    private let buffer: TokenCharacterBuffer
    private let extractors: Array<TokenExtractor>
    
    internal init(string: String, configuration: Configuration = .default) {
        self.source = string
        self.configuration = configuration
        
        buffer = TokenCharacterBuffer(string: string)
        let operatorTokens = configuration.operatorSet.operatorTokenSet
        
        let numberExtractor: TokenExtractor
        if let locale = configuration.locale {
            numberExtractor = LocalizedNumberExtractor(locale: locale)
        } else {
            numberExtractor = DecimalNumberExtractor()
        }
        
        extractors = [
            HexNumberExtractor(),
            OctalNumberExtractor(),
            numberExtractor,
            FractionNumberExtractor(),
            ExponentExtractor(),
            
            VariableExtractor(operatorTokens: operatorTokens),
            QuotedVariableExtractor(),
            
            OperatorExtractor(operatorTokens: operatorTokens),
            
            IdentifierExtractor(operatorTokens: operatorTokens)
        ]
        
    }
    
    internal func tokenize() throws -> Array<RawToken> {
        var tokens = Array<RawToken>()
        
        while let next = next() {
            switch next {
                case .failure(let e): throw e
                case .success(let t): tokens.append(t)
            }
        }
        
        return tokens
    }
    
    private func next() -> Result<RawToken, MathParserError>? {
        while buffer.peekNext()?.isWhitespaceOrNewline == true {
            buffer.consume()
        }
        
        guard buffer.isAtEnd == false else { return nil }
        
        let start = buffer.currentIndex
        var errors = Array<Result<RawToken, MathParserError>>()
        
        for extractor in extractors {
            guard extractor.matchesPreconditions(buffer, configuration: configuration) else { continue }
            
            buffer.resetTo(start)
            let result = extractor.extract(buffer, configuration: configuration)
            
            switch result {
                case .success: return result
                case .failure: errors.append(result)
            }
        }
        
        return errors.first
    }
    
}
