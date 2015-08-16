//
//  ResolvedToken.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/8/15.
//
//

import Foundation

public struct ResolvedToken: Equatable {
    public enum Kind: Equatable {
        case Number(Double)
        case Variable(String)
        case Identifier(String)
        case Operator(MathParser.Operator)
    }
    
    public let kind: Kind
    public let string: String
    public let range: Range<String.Index>
}

public func ==(lhs: ResolvedToken.Kind, rhs: ResolvedToken.Kind) -> Bool {
    switch (lhs, rhs) {
        case (.Number(let l), .Number(let r)): return l == r
        case (.Variable(let l), .Variable(let r)): return l == r
        case (.Identifier(let l), .Identifier(let r)): return l == r
        case (.Operator(let l), .Operator(let r)): return l == r
        default: return false
    }
}

public func ==(lhs: ResolvedToken, rhs: ResolvedToken) -> Bool {
    return lhs.kind == rhs.kind && lhs.string == rhs.string && lhs.range == rhs.range
}

public extension ResolvedToken.Kind {
    
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
    
    public var builtInOperator: BuiltInOperator? {
        return resolvedOperator?.builtInOperator
    }
    
    public var isNumber: Bool { return number != nil }
    public var isVariable: Bool { return variable != nil }
    public var isIdentifier: Bool { return identifier != nil }
    public var isOperator: Bool { return resolvedOperator != nil }
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
