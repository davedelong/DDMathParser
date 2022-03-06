//
//  ResolvedToken.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/8/15.
//
//

import Foundation

internal struct ResolvedToken: Hashable {
    internal enum Kind: Hashable {
        case number(Double)
        case variable(String)
        case identifier(String)
        case `operator`(Operator)
    }
    
    internal let kind: Kind
    internal let string: String
    internal let range: Range<String.Index>
}

extension ResolvedToken.Kind {
    
    internal var number: Double? {
        guard case .number(let o) = self else { return nil }
        return o
    }
    
    internal var variable: String? {
        guard case .variable(let v) = self else { return nil }
        return v
    }
    
    internal var identifier: String? {
        guard case .identifier(let i) = self else { return nil }
        return i
    }
    
    internal var resolvedOperator: Operator? {
        guard case .operator(let o) = self else { return nil }
        return o
    }

    internal var isNumber: Bool { return number != nil }
    internal var isVariable: Bool { return variable != nil }
    internal var isIdentifier: Bool { return identifier != nil }
    internal var isOperator: Bool { return resolvedOperator != nil }
}
