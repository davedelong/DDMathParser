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
        case number(Double)
        case variable(String)
        case `operator`(Operator)
        case function(String, Array<GroupedToken>)
        case group(Array<GroupedToken>)
    }
    
    public let kind: Kind
    public let range: Range<Int>
}
