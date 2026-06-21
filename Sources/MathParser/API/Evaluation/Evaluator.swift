//
//  Evaluator.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/20/15.
//
//

import Foundation

/// An error that may be thrown during attempts to register custom functions or aliases with an ``Evaluator``
public struct FunctionRegistrationError: Error {
    
    /// The code of the error being thrown
    public enum Code {
        /// Indicates that a function with the same name or alias already exists,
        /// and the new function (or alias) being registered would cause a naming conflict.
        case functionExists
        
        /// Indicates that the alias name being registered cannot be tied to any particular function,
        /// because a function with the specified name cannot be found.
        case functionDoesNotExist
    }
    
    /// The function or alias name that produced this error.
    public let functionName: String
    
    /// The registration error code.
    public let code: Code
    
    internal init(code: Code, functionName: String) {
        self.functionName = functionName
        self.code = code
    }
}

public struct Evaluator {
    
    public enum AngleMode {
        case radians
        case degrees
    }
    
    public static let `default` = Evaluator()
    private var functionSet: FunctionSet
    
    public var angleMeasurementMode = AngleMode.radians
    public var resolver: EvaluationResolver?
    public var configuration: Configuration
    
    /// Whether variables should be treated with case sensitivity or not.
    ///
    /// When this value is `true`, then variables that are spelled the same but differ only by their case are treated as distinct. For example,
    /// `$FOO` would be a *different* variable than `$foo`.
    ///
    /// When this value is `false`, then variables are treated as *case insensitive*, and `$FOO` would be considered the same variable as `$foo`.
    ///
    /// The default value is `true`, meaning variables that by differ by their case are considered distinct.
    public var caseSensitiveVariables: Bool = true
    
    public init() {
        self.init(caseSensitiveFunctions: false,
                  configuration: .default)
    }
    
    public init(caseSensitive: Bool) {
        self.functionSet = FunctionSet(caseSensitive: caseSensitive)
        self.configuration = Configuration()
        self.caseSensitiveVariables = caseSensitive
    }
    
    public init(caseSensitiveFunctions: Bool, configuration: Configuration) {
        self.functionSet = FunctionSet(caseSensitive: caseSensitiveFunctions)
        self.configuration = configuration
    }
    
    public mutating func registerFunction(_ function: Function) throws {
        try functionSet.registerFunction(function)
    }
    
    public mutating func registerFunction(_ name: String, body: @escaping Function.Body) throws {
        let function = Function(name: name, body: body)
        try functionSet.registerFunction(function)
    }
    
    public subscript(name: String) -> Function.Body? {
        get {
            functionSet.evaluatorForName(name)
        }
        set {
            if let newValue {
                let function = Function(name: name, body: newValue)
                try? functionSet.registerFunction(function)
            } else {
                functionSet.unregisterFunction(name)
            }
        }
    }
    
    public mutating func registerAlias(_ alias: String, forFunctionName name: String) throws {
        try functionSet.addAlias(alias, forFunctionName: name)
    }
    
    public func evaluate(_ expression: Expression, variables: Variables = [:]) throws -> Double {
        return try evaluate(expression, variables: variables, state: nil)
    }
    
    public func simplify(_ expression: Expression, variables: Variables = [:]) -> Expression {
        switch expression.kind {
            case .number:
                return expression
                
            case .variable(let variableName):
                let state = EvaluationState(expression: expression, variables: variables, evaluator: self)
                if let value = try? self.evaluateVariable(variableName, state: state) {
                    return Expression(kind: .number(value), range: expression.range)
                }
                
                return expression
                
            case .function(let name, let arguments):
                let simplifiedArguments = arguments.map { self.simplify($0, variables: variables) }
                let areAllArgumentsNumbers = simplifiedArguments.allSatisfy(\.isNumber)
                
                guard areAllArgumentsNumbers else {
                    return Expression(kind: .function(name, simplifiedArguments), range: expression.range)
                }
                
                guard let value = try? self.evaluate(expression) else {
                    return Expression(kind: .function(name, simplifiedArguments), range: expression.range)
                }
                
                return Expression(kind: .number(value), range: expression.range)
        }
    }
    
    internal func evaluate(_ expression: Expression, variables: Variables, state: EvaluationState?) throws -> Double {
        let evaluationState: EvaluationState
        if var parent = state {
            parent.push(expression)
            evaluationState = parent
        } else {
            evaluationState = EvaluationState(expression: expression, variables: variables, evaluator: self)
        }
        
        switch expression.kind {
            case .number(let d):
                return d
                
            case .variable(let s):
                return try evaluateVariable(s, state: evaluationState)
                
            case .function(let f, let args):
                // the resolver always gets the first opportunity to interpose its own value
                if let value = try resolver?.evaluateFunction(f, state: evaluationState) {
                    return value
                }
                
                if let function = functionSet.evaluatorForName(f) {
                    return try function(evaluationState)
                }
                
                // if we get here, then let's fall back to trying it as a variable,
                // but only if it has no arguments. and we'll ignore the error if evaluation fails
                if args.isEmpty, let value = try? evaluateVariable(f, state: evaluationState) {
                    return value
                }
                
                throw MathParserError(code: .unknownFunction(f), range: expression.range)
        }
    }
    
    private func evaluateVariable(_ name: String, state: EvaluationState) throws -> Double {
        
        // dynamically resolve the variable
        if let resolved = resolver?.evaluateVariable(name) {
            return resolved
        }
        
        // look in our known variables:
        if self.caseSensitiveVariables {
            if let value = state.variables[name] {
                return value
            }
        } else {
            let lowercasedName = name.lowercased()
            if let value = state.variables.first(where: { $0.key.lowercased() == lowercasedName })?.value {
                return value
            }
        }
        
        throw MathParserError(code: .unknownVariable(name), range: state.expressionRange)
    }
    
}
