//
//  Tokenizer.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/6/15.
//
//

import Foundation

public struct Tokenizer {
    private let string: String
    internal let locale: NSLocale?
    internal let operatorSet: OperatorSet
    
    public init(string: String, operatorSet: OperatorSet = OperatorSet.defaultOperatorSet, locale: NSLocale? = nil) {
        self.string = string
        self.operatorSet = operatorSet
        self.locale = locale
    }
    
    public func tokenize() throws -> Array<RawToken> {
        let g = TokenGenerator(string: string, operatorSet: operatorSet, locale: locale)
        var tokens = Array<RawToken>()
        
        while let next = g.next() {
            switch next {
                case .Error(let e): throw e
                case .Value(let t): tokens.append(t)
            }
        }
        
        return tokens
    }
    
}
