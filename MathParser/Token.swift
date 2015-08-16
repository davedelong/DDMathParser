//
//  Token.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/6/15.
//
//

import Foundation

public struct Token<T: Equatable> {
    public let kind: T
    public let string: String
    public let sourceRange: Range<String.CharacterView.Index>
    
}

public func ==<T>(lhs: Token<T>, rhs: Token<T>) -> Bool {
    return lhs.kind == rhs.kind && lhs.string == rhs.string && lhs.sourceRange == rhs.sourceRange
}
