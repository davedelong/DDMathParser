//
//  TokenResolver.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/8/15.
//
//

import Foundation

public struct TokenResolver {
    
    private let tokenizer: Tokenizer
    
    public init(tokenizer: Tokenizer) {
        self.tokenizer = tokenizer
    }
    
    public func resolve() throws -> Array<ResolvedToken> {
        return []
    }
    
}

extension TokenResolver {
    
    public init(string: String, operatorSet: OperatorSet = OperatorSet.defaultOperatorSet) {
        self.tokenizer = Tokenizer(string: string, operatorSet: operatorSet)
    }
    
}
