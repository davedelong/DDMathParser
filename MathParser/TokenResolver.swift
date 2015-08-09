//
//  TokenResolver.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/8/15.
//
//

import Foundation

public struct TokenResolver: SequenceType {
    public typealias Generator = ResolvedTokenGenerator
    
    private let tokenizer: Tokenizer
    
    public init(tokenizer: Tokenizer) {
        self.tokenizer = tokenizer
    }
    
    public func generate() -> ResolvedTokenGenerator {
        return ResolvedTokenGenerator(generator: tokenizer.generate())
    }
    
}

extension TokenResolver {
    
    public init(string: String, operatorSet: OperatorSet = OperatorSet.defaultOperatorSet) {
        self.tokenizer = Tokenizer(string: string, operatorSet: operatorSet)
    }
    
}
