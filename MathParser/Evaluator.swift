//
//  Evaluator.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/20/15.
//
//

import Foundation

public enum FunctionRegistrationError: ErrorType {
    case FunctionAlreadyExists(String)
    case FunctionDoesNotExist(String)
}

public struct Evaluator {
    
    public enum AngleMode {
        case Radians
        case Degrees
    }
    
    public static let defaultEvaluator = Evaluator()
    private let functionSet: FunctionSet
    
    public var angleMeasurementMode = AngleMode.Radians
    public var functionOverrider: FunctionOverrider?
    public var functionResolver: FunctionResolver?
    public var variableResolver: VariableResolver?
    
    public init(caseSensitive: Bool = false) {
        functionSet = FunctionSet(caseSensitive: caseSensitive)
    }
    
    public func evaluate(expression: Expression, substitutions: Substitutions = [:]) throws -> Double {
        switch expression.kind {
            case .Number(let d):
                return d
            case .Variable(let s):
                return try evaluateVariable(s, substitutions: substitutions, range: expression.range)
            case .Function(let f, let args):
                return try evaluateFunction(f, arguments: args, substitutions: substitutions, range: expression.range)
        }
    }
    
    public func registerFunction(function: Function) throws {
        try functionSet.registerFunction(function)
    }
    
    public func registerAlias(alias: String, forFunctionName name: String) throws {
        try functionSet.addAlias(alias, forFunctionName: name)
    }
    
    private func evaluateVariable(name: String, substitutions: Substitutions, range: Range<String.Index>) throws -> Double {
        if let value = substitutions[name] { return value }
        
        // substitutions were insufficient
        // use the variable resolver
        
        if let resolved = variableResolver?.resolveVariable(name) {
            return resolved
        }
        
        throw MathParserError(kind: .UnknownVariable(name), range: range)
    }
    
    private func evaluateFunction(name: String, arguments: Array<Expression>, substitutions: Substitutions, range: Range<String.Index>) throws -> Double {
        let state = EvaluationState(expressionRange: range, arguments: arguments, substitutions: substitutions, evaluator: self)
        
        // check for function overrides
        if let value = try functionOverrider?.overrideFunction(name, state: state) {
            return value
        }
        
        if let function = functionSet.evaluatorForName(name) {
            return try function(state)
        }
        
        // a function with this name does not exist
        // use the function resolver
        let normalized = functionSet.normalize(name)
        if let value = try functionResolver?.resolveFunction(normalized, state: state) {
            return value
        }
        
        throw MathParserError(kind: .UnknownFunction(name), range: range)
    }
    
}
