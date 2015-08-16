//
//  RawToken.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/12/15.
//
//

import Foundation

public struct RawToken: Equatable {
    
    public enum Kind {
        case HexNumber
        case Number
        case Variable
        case Operator
        case Identifier
    }
    
    public let kind: Kind
    public let string: String
    public let range: Range<String.Index>
}

public func ==(lhs: RawToken, rhs: RawToken) -> Bool {
    return lhs.kind == rhs.kind && lhs.string == rhs.string && lhs.range == rhs.range
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
