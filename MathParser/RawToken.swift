//
//  RawToken.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/12/15.
//
//

import Foundation

public typealias RawToken = Token<RawTokenKind>

public enum RawTokenKind: Equatable {
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
