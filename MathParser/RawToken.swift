//
//  RawToken.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/12/15.
//
//

import Foundation

public struct RawToken {
    
    public enum Kind {
        case HexNumber
        case OctalNumber
        case Number
        case LocalizedNumber
        case Exponent
        case Variable
        case Operator
        case Identifier
    }
    
    public let kind: Kind
    public let string: String
    public let range: Range<String.Index>
}
