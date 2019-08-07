//
//  ResolvedToken.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/8/15.
//
//

import Foundation

public struct ResolvedToken {
    public enum Kind {
        case number(Double)
        case variable(String)
        case identifier(String)
        case `operator`(Operator)
    }
    
    public let kind: Kind
    public let string: String
    public let range: Range<Int>
}

extension ResolvedToken.Kind {
    
    public var number: Double? {
        guard case .number(let o) = self else { return nil }
        return o
    }
    
    public var variable: String? {
        guard case .variable(let v) = self else { return nil }
        return v
    }
    
    public var identifier: String? {
        guard case .identifier(let i) = self else { return nil }
        return i
    }
    
    public var resolvedOperator: Operator? {
        guard case .operator(let o) = self else { return nil }
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
