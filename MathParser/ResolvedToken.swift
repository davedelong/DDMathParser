//
//  ResolvedToken.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/8/15.
//
//

import Foundation

public typealias ResolvedToken = Token<ResolvedTokenKind>

public enum ResolvedTokenKind: Equatable {
    case Number(Double)
    case Variable(String)
    case Identifier(String)
    case Operator(MathParser.Operator)
    
    public var number: Double? {
        guard case .Number(let o) = self else { return nil }
        return o
    }
    
    public var variable: String? {
        guard case .Variable(let v) = self else { return nil }
        return v
    }
    
    public var identifier: String? {
        guard case .Identifier(let i) = self else { return nil }
        return i
    }
    
    public var resolvedOperator: MathParser.Operator? {
        guard case .Operator(let o) = self else { return nil }
        return o
    }
    
    public var isNumber: Bool { return number != nil }
    public var isVariable: Bool { return variable != nil }
    public var isIdentifier: Bool { return identifier != nil }
    public var isOperator: Bool { return resolvedOperator != nil }
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

public struct TokenResolverError: ErrorType {
    public enum Kind {
        case CannotParseHexNumber
        case UnknownOperator
        case AmbiguousOperator
    }
    
    public let kind: Kind
    public let rawToken: RawToken
}
