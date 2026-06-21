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
    public var substitutions: Substitutions
    
    public init() {
        self.init(caseSensitive: false,
                  configuration: .default,
                  substitutions: [:])
    }
    
    public init(caseSensitive: Bool, configuration: Configuration, substitutions: Substitutions) {
        self.functionSet = FunctionSet(caseSensitive: caseSensitive)
        self.configuration = configuration
        self.substitutions = substitutions
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
                do {
                    let function = Function(name: name, body: newValue)
                    try functionSet.registerFunction(function)
                } catch {
                    
                }
            } else {
                functionSet.unregisterFunction(name)
            }
        }
    }
    
    public mutating func registerAlias(_ alias: String, forFunctionName name: String) throws {
        try functionSet.addAlias(alias, forFunctionName: name)
    }
    
    public func evaluate(_ expression: Expression, substitutions: Substitutions = [:]) throws -> Double {
        return try evaluate(expression, substitutions: substitutions, state: nil)
    }
    
    public func simplify(_ expression: Expression) -> Expression {
        switch expression.kind {
            case .number:
                return expression
                
            case .variable(let variableName):
                if let value = try? self.evaluateVariable(variableName, substitutions: self.substitutions, range: expression.range) {
                    return Expression(kind: .number(value), range: expression.range)
                }
                
                return expression
                
            case .function(let name, let arguments):
                let simplifiedArguments = arguments.map { self.simplify($0) }
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
    
    internal func evaluate(_ expression: Expression, substitutions: Substitutions, state: EvaluationState?) throws -> Double {
        switch expression.kind {
            case .number(let d):
                return d
                
            case .variable(let s):
                return try evaluateVariable(s, substitutions: substitutions, range: expression.range)
                
            case .function(let f, let args):
                let functionState: EvaluationState
                if var parent = state {
                    parent.push(expression)
                    functionState = parent
                } else {
                    functionState = EvaluationState(expression: expression, substitutions: substitutions, evaluator: self)
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
                if args.isEmpty, let value = try? evaluateVariable(f, substitutions: substitutions, range: expression.range) {
                    return value
                }
                
                throw MathParserError(code: .unknownFunction(f), range: expression.range)
        }
    }
    
    private func evaluateVariable(_ name: String, substitutions: Substitutions, range: Range<String.Index>) throws -> Double {
        // the resolver always gets the first opportunity to interpose its own value
        if let resolved = resolver?.evaluateVariable(name) {
            return resolved
        }
        
        // TODO: follow the case insensitivity parameter
        if let value = try substitutions[name]?.substitutionValue(using: self, substitutions: substitutions) {
            return value
        }
        
        throw MathParserError(code: .unknownVariable(name), range: range)
    }
    
}
