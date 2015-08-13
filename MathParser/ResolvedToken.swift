//
//  ResolvedToken.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/8/15.
//
//

import Foundation

public enum ResolvedTokenKind: Equatable {
    case Number(UInt)
    case Variable(String)
    case Identifier(String)
    case Operator(MathParser.Operator)
}

public func ==(lhs: ResolvedTokenKind, rhs: ResolvedTokenKind) -> Bool {
    switch (lhs, rhs) {
        case (.Number(let l), .Number(let r)): return l == r
        case (.Variable(let l), .Variable(let r)): return l == r
        case (.Identifier(let l), .Identifier(let r)): return l == r
        case (.Operator(let l), .Operator(let r)): return l == r
        default: return false
    }
}

public typealias ResolvedToken = Token<ResolvedTokenKind>
