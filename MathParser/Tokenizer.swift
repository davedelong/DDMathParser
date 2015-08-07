//
//  Tokenizer.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/6/15.
//
//

import Foundation

public struct Tokenizer: SequenceType {
    public typealias Generator = TokenGenerator
    
    private let string: String
    
    public init(string: String) {
        self.string = string
    }
    
    public func generate() -> Generator {
        return TokenGenerator(string: string)
    }
    
}

public struct TokenizerError: ErrorType {
    public enum Kind {
        case CannotParseNumber
        case CannotParseHexNumber
        case CannotParseIdentifier
        case CannotParseVariable
        case CannotParseQuotedVariable
        case CannotParseOperator
        case ZeroLengthVariable
    }
    
    public let kind: Kind
    public let sourceRange: Range<String.CharacterView.Index>
}
