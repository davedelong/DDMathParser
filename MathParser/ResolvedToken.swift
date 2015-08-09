//
//  ResolvedToken.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/8/15.
//
//

import Foundation

public enum ResolvedToken {
    
    case Number(UInt)
    case Variable(String)
    case Identifier(String)
    case Operator
    
}
