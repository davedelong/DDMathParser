//
//  Token.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/6/15.
//
//

import Foundation

public struct Token {
    public enum Kind {
        case HexNumber
        case Number
        case Variable
        case Operator
        case Identifier
    }
    
    public let kind: Kind
    public let string: String
    public let sourceRange: Range<String.CharacterView.Index>
    
}
