//
//  Evaluator.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/20/15.
//
//

import Foundation

public struct FunctionRegistrationError: Error {
    
    public enum Kind {
        case functionExists
        case functionDoesNotExist
    }
    
    public let functionName: String
    public let kind: Kind
    
    internal init(functionName: String, kind: Kind) {
        self.functionName = functionName
        self.kind = kind
    }
}

public struct Evaluator {
    
    public enum AngleMode {
        case radians
        case degrees
    }
    
    public static let `default` = Evaluator()
    private let functionSet: FunctionSet
    
    public var angleMeasurementMode = AngleMode.radians
    public var resolver: EvaluationResolver?
    
    public init(caseSensitive: Bool = false) {
        functionSet = FunctionSet(caseSensitive: caseSensitive)
    }
    
    public func registerFunction(_ function: Function) throws {
        try functionSet.registerFunction(function)
    }
    
    public func registerAlias(_ alias: String, forFunctionName name: String) throws {
        try functionSet.addAlias(alias, forFunctionName: name)
    }
    
    public func evaluate(_ expression: Expression, substitutions: Substitutions = [:]) throws -> Double {
        switch expression.kind {
            case .number(let d):
                return d
            case .variable(let s):
                return try evaluateVariable(s, substitutions: substitutions, range: expression.range)
            case .function(let f, let args):
                return try evaluateFunction(f, arguments: args, substitutions: substitutions, range: expression.range)
        }
    }
    
    private func evaluateVariable(_ name: String, substitutions: Substitutions, range: Range<String.Index>) throws -> Double {
        // the resolver always gets the first opportunity to interpose its own value
        if let resolved = resolver?.evaluateVariable(name) {
            return resolved
        }
        
        if let value = try substitutions[name]?.substitutionValue(using: self, substitutions: substitutions) {
            return value
        }
        
        throw MathParserError(kind: .unknownVariable(name), range: range)
    }
    
    private func evaluateFunction(_ name: String, arguments: Array<Expression>, substitutions: Substitutions, range: Range<String.Index>) throws -> Double {
        let state = EvaluationState(expressionRange: range, arguments: arguments, substitutions: substitutions, evaluator: self)
        
        // the resolver always gets the first opportunity to interpose its own value
        if let value = try resolver?.evaluateFunction(name, state: state) {
            return value
        }
        
        if let function = functionSet.evaluatorForName(name) {
            return try function(state)
        }
        
        // if we get here, then let's fall back to trying it as a variable,
        // but only if it has no arguments. and we'll ignore the error if evaluation fails
        if arguments.isEmpty {
            if let value = try? evaluateVariable(name, substitutions: substitutions, range: range) {
                return value
            }
        }
        
        throw MathParserError(kind: .unknownFunction(name), range: range)
    }
    
}
