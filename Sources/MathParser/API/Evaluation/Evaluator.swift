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
    
    public init() {
        self.init(caseSensitiveFunctions: false,
                  configuration: .default)
    }
    
    public init(caseSensitive: Bool) {
        var configuration = Configuration()
        configuration.caseSensitiveVariables = caseSensitive
        
        self.functionSet = FunctionSet(caseSensitive: caseSensitive)
        self.configuration = configuration
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
                if let value = try? self.evaluateVariable(variableName, variables: variables, range: expression.range) {
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
        switch expression.kind {
            case .number(let d):
                return d
                
            case .variable(let s):
                return try evaluateVariable(s, variables: variables, range: expression.range)
                
            case .function(let f, let args):
                let functionState: EvaluationState
                if var parent = state {
                    parent.push(expression)
                    functionState = parent
                } else {
                    functionState = EvaluationState(expression: expression, variables: variables, evaluator: self)
                }
                
                // the resolver always gets the first opportunity to interpose its own value
                if let value = try resolver?.evaluateFunction(f, state: functionState) {
                    return value
                }
                
                if let function = functionSet.evaluatorForName(f) {
                    return try function(functionState)
                }
                
                // if we get here, then let's fall back to trying it as a variable,
                // but only if it has no arguments. and we'll ignore the error if evaluation fails
                if args.isEmpty, let value = try? evaluateVariable(f, variables: variables, range: expression.range) {
                    return value
                }
                
                throw MathParserError(code: .unknownFunction(f), range: expression.range)
        }
    }
    
    private func evaluateVariable(_ name: String, variables: Variables, range: Range<String.Index>) throws -> Double {
        
        // first look in our known variables:
        if configuration.caseSensitiveVariables {
            if let value = variables[name] {
                return value
            }
        } else {
            let lowercasedName = name.lowercased()
            if let value = variables.first(where: { $0.key.lowercased() == lowercasedName })?.value {
                return value
            }
        }
        
        // dynamically resolve the variable
        if let resolved = resolver?.evaluateVariable(name) {
            return resolved
        }
        
        throw MathParserError(code: .unknownVariable(name), range: range)
    }
    
}
