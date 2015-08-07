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
        case ZeroLengthVariable
        case CannotParseQuotedVariable
        case InvalidOperatorCharacter(Character)
    }
    
    public let kind: Kind
    public let sourceRange: Range<String.CharacterView.Index>
}
