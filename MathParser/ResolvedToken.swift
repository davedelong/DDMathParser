//
//  ResolvedToken.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/8/15.
//
//

import Foundation

public enum ResolvedTokenKind {
    case Number(UInt)
    case Variable(String)
    case Identifier(String)
    case Operator(MathParser.Operator)
}

public typealias ResolvedToken = Token<ResolvedTokenKind>
