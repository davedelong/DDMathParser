//
//  Evaluator.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/20/15.
//
//

import Foundation

public enum EvaluationError: ErrorType {
    case UnknownFunction(String)
    case UnknownVariable(String)
    case DivideByZero
    case InvalidArguments
}

public struct Evaluator {
    
    public static let defaultEvaluator = Evaluator()
    
    private let operatorSet: OperatorSet
    private var registeredFunctions = Dictionary<String, FunctionEvaluator>()
    
    public var functionResolver: FunctionResolver?
    public var variableResolver: VariableResolver?
    
    public init(operatorSet: OperatorSet = OperatorSet.defaultOperatorSet) {
        self.operatorSet = operatorSet
    }
    
    public func evaluate(expression: Expression, substitutions: Dictionary<String, Double> = [:]) throws -> Double {
        switch expression.kind {
            case .Number(let d):
                return d
            case .Variable(let s):
                return try evaluateVariable(s, substitutions: substitutions)
            case .Function(let f, let args):
                return try evaluateFunction(f, arguments: args, substitutions: substitutions)
        }
    }
    
    public mutating func registerFunction(name: String, functionEvaluator: FunctionEvaluator) {
        let normalized = StandardFunctions.normalizeFunctionName(name)
        registeredFunctions[normalized] = functionEvaluator
    }
    
    private func evaluateVariable(name: String, substitutions: Dictionary<String, Double>) throws -> Double {
        if let value = substitutions[name] { return value }
        
        // substitutions were insufficient
        // use the variable resolver
        
        if let resolved = variableResolver?.resolveVariable(name) {
            return resolved
        }
        
        throw EvaluationError.UnknownVariable(name)
    }
    
    private func evaluateFunction(name: String, arguments: Array<Expression>, substitutions: Dictionary<String, Double>) throws -> Double {
        let normalized = StandardFunctions.normalizeFunctionName(name)
        
        // TODO: check for function overrides?
        
        if let value = try StandardFunctions.performFunction(normalized, arguments: arguments, substitutions: substitutions, evaluator: self) {
            return value
        }
        
        // a standard function with this name does not exist
        
        // check the registered functions
        if let registered = registeredFunctions[normalized] {
            if let value = try registered(arguments, substitutions, self) {
                return value
            }
        }
        
        // use the function resolver
        if let value = try functionResolver?.resolveFunction(normalized, arguments: arguments, substitutions: substitutions) {
            return value
        }
        
        throw EvaluationError.UnknownFunction(name)
    }
    
}
