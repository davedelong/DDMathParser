//
//  FunctionSet.swift
//  DDMathParser
//
//  Created by Dave DeLong on 9/18/15.
//
//

import Foundation

internal class FunctionSet {
    private var functionsByName = Dictionary<String, FunctionRegistration>()
    private let caseSensitive: Bool
    
    internal init(caseSensitive: Bool) {
        self.caseSensitive = caseSensitive
        Function.standardFunctions.forEach {
            do {
                try registerFunction($0)
            } catch _ {
                fatalError("Conflicting name/alias in built-in functions")
            }
        }
    }
    
    internal func normalize(name: String) -> String {
        return caseSensitive ? name : name.lowercaseString
    }
    
    private func registeredFunctionForName(name: String) -> FunctionRegistration? {
        let casedName = normalize(name)
        return functionsByName[casedName]
    }
    
    internal func evaluatorForName(name: String) -> FunctionEvaluator? {
        return registeredFunctionForName(name)?.function
    }
    
    internal func addAlias(alias: String, forFunctionName name: String) throws {
        guard registeredFunctionForName(alias) == nil else {
            throw FunctionRegistrationError.FunctionAlreadyExists(alias)
        }
        guard let registration = registeredFunctionForName(name) else {
            throw FunctionRegistrationError.FunctionDoesNotExist(name)
        }
        
        let casedAlias = normalize(alias)
        registration.addAlias(casedAlias)
        functionsByName[casedAlias] = registration
    }
    
    internal func registerFunction(function: Function) throws {
        let registration = FunctionRegistration(function: function, caseSensitive: caseSensitive)
        
        // we need to make sure that every name is accounted for
        for name in registration.names {
            guard registeredFunctionForName(name) == nil else {
                throw FunctionRegistrationError.FunctionAlreadyExists(name)
            }
        }
        
        registration.names.forEach {
            self.functionsByName[$0] = registration
        }
    }
}

private class FunctionRegistration {
    var names: Set<String>
    let function: FunctionEvaluator
    
    init(function: Function, caseSensitive: Bool) {
        self.function = function.evaluator
        self.names = Set(function.names.map { caseSensitive ? $0.lowercaseString : $0 })
    }
    
    func addAlias(name: String) {
        names.insert(name)
    }
}

