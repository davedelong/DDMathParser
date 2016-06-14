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
        case hexNumber
        case octalNumber
        case number
        case localizedNumber
        case exponent
        case variable
        case `operator`
        case identifier
    }
    
    public let kind: Kind
    public let string: String
    public let range: Range<Int>
}
