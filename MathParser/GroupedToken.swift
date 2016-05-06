//
//  GroupedToken.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/13/15.
//
//

import Foundation

public struct GroupedToken {
    public enum Kind {
        case Number(Double)
        case Variable(String)
        case Operator(MathParser.Operator)
        case Function(String, Array<GroupedToken>)
        case Group(Array<GroupedToken>)
    }
    
    public let kind: Kind
    public let range: Range<String.Index>
}
