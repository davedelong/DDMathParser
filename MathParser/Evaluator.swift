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
    
    private let functions = StandardFunctions()
    
    public var functionOverrider: FunctionOverrider?
    public var functionResolver: FunctionResolver?
    public var variableResolver: VariableResolver?
    
    public init() { }
    
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
    
    public func registerFunction(name: String, functionEvaluator: FunctionEvaluator) {
        functions.registerFunction(name, functionEvaluator: functionEvaluator)
    }
    
    public func registerAlias(alias: String, forFunctionName name: String) {
        functions.addAlias(alias, forFunctionName: name)
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
        let normalized = functions.normalizeFunctionName(name)
        
        // check for function overrides
        if let value = try functionOverrider?.overrideFunction(name, arguments: arguments, substitutions: substitutions, evaluator: self) {
            return value
        }
        
        if let value = try functions.performFunction(normalized, arguments: arguments, substitutions: substitutions, evaluator: self) {
            return value
        }
        
        // a function with this name does not exist
        // use the function resolver
        if let value = try functionResolver?.resolveFunction(normalized, arguments: arguments, substitutions: substitutions, evaluator: self) {
            return value
        }
        
        throw EvaluationError.UnknownFunction(name)
    }
    
}
