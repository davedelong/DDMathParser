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
        buffer = TokenCharacterBuffer(string: string)
        extractors = [
            HexNumberExtractor(),
            NumberExtractor()
        ]
    }
    
    public func next() -> Element? {

        return nil
    }
    
}
