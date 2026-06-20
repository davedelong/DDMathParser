//
//  Operator.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/7/15.
//
//

import Foundation

public struct Operator: Equatable, Hashable {
    
    public enum Arity: Hashable {
        case unary
        case binary
        
        internal var argumentCount: Int {
            switch self {
                case .unary: return 1
                case .binary: return 2
            }
        }
    }
    
    public enum Associativity: Hashable {
        case left
        case right
    }
    
    internal let isBuiltIn: Bool
    public let function: String
    public let arity: Arity
    public let associativity: Associativity
    
    public internal(set) var tokens: Set<String>
    public internal(set) var precedence: Int?
    
    public init(function: String, arity: Arity, associativity: Associativity, tokens: Set<String> = []) {
        self.isBuiltIn = false
        self.function = function
        self.arity = arity
        self.associativity = associativity
        self.tokens = tokens
    }
    
    internal init(builtinFunction: String, arity: Arity, associativity: Associativity, tokens: Set<String>) {
        self.isBuiltIn = true
        self.function = builtinFunction
        self.arity = arity
        self.associativity = associativity
        self.tokens = tokens
    }
    
    public static func ==(lhs: Operator, rhs: Operator) -> Bool {
        return lhs.arity == rhs.arity && lhs.associativity == rhs.associativity && lhs.function == rhs.function
    }
    
    public func hash(into hasher: inout Hasher) {
        function.hash(into: &hasher)
        arity.hash(into: &hasher)
        associativity.hash(into: &hasher)
    }
}

extension Operator: CustomStringConvertible {
    
    public var description: String {
        let tokenInfo = tokens.joined(separator: ", ")
        let arityInfo = arity == .unary ? "Unary" : "Binary"
        let assocInfo = associativity == .left ? "Left" : "Right"
        let precedenceInfo = precedence?.description ?? "UNKNOWN"
        return "{[\(tokenInfo)] -> \(function)(), \(arityInfo) \(assocInfo), precedence: \(precedenceInfo)}"
    }
    
}
