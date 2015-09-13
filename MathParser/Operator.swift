//
//  Operator.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/7/15.
//
//

import Foundation

public class Operator: Equatable {
    
    public enum Arity {
        case Unary
        case Binary
    }
    
    public enum Associativity {
        case Left
        case Right
    }
    
    public let function: String
    public let arity: Arity
    public let associativity: Associativity
    
    public internal(set) var tokens: Set<String>
    public internal(set) var precedence: Int?
    
    public init(function: String, arity: Arity, associativity: Associativity, tokens: Set<String> = []) {
        self.function = function
        self.arity = arity
        self.associativity = associativity
        self.tokens = tokens
    }
}

extension Operator: CustomStringConvertible {
    
    public var description: String {
        let tokenInfo = tokens.joinWithSeparator(", ")
        let arityInfo = arity == .Unary ? "Unary" : "Binary"
        let assocInfo = associativity == .Left ? "Left" : "Right"
        let precedenceInfo = precedence?.description ?? "UNKNOWN"
        return "{[\(tokenInfo)] -> \(function)(), \(arityInfo) \(assocInfo), precedence: \(precedenceInfo)}"
    }
}

public func ==(lhs: Operator, rhs: Operator) -> Bool {
    return lhs.arity == rhs.arity && lhs.associativity == rhs.associativity && lhs.function == rhs.function
}
