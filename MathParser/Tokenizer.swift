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
    private let operatorSet: OperatorSet
    
    public init(string: String, operatorSet: OperatorSet = OperatorSet.defaultOperatorSet) {
        self.string = string
        self.operatorSet = operatorSet
    }
    
    public func generate() -> Generator {
        return TokenGenerator(string: string, operatorSet: operatorSet)
    }
    
}

public typealias RawToken = Token<RawTokenKind>

public enum RawTokenKind {
    case HexNumber
    case Number
    case Variable
    case Operator
    case Identifier
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
