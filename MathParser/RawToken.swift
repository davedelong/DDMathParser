//
//  RawToken.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/12/15.
//
//

import Foundation

public class RawToken {
    public let string: String
    public let range: Range<Int>
    
    public init(string: String, range: Range<Int>) {
        self.string = string
        self.range = range
    }
    
    public func resolve(options: TokenResolverOptions, locale: Locale, operators: OperatorSet, previousToken: ResolvedToken? = nil) throws -> Array<ResolvedToken> {
        fatalError("\(#function) must be overridden for this token type")
    }
}
