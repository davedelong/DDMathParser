//
//  GroupedToken.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/13/15.
//
//

import Foundation

internal struct GroupedToken: Hashable {
    internal enum Kind: Hashable {
        case number(Double)
        case variable(String)
        case `operator`(Operator)
        case function(String, Array<GroupedToken>)
        case group(Array<GroupedToken>)
    }
    
    internal let kind: Kind
    internal let range: Range<String.Index>
}
