//
//  FunctionSet.swift
//  DDMathParser
//
//  Created by Dave DeLong on 9/18/15.
//
//

import Foundation

internal final class FunctionSet {
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
    
    internal func normalize(_ name: String) -> String {
        return caseSensitive ? name : name.lowercased()
    }
    
    private func registeredFunctionForName(_ name: String) -> FunctionRegistration? {
        let casedName = normalize(name)
        return functionsByName[casedName]
    }
    
    internal func evaluatorForName(_ name: String) -> FunctionEvaluator? {
        return registeredFunctionForName(name)?.function
    }
    
    internal func addAlias(_ alias: String, forFunctionName name: String) throws {
        guard registeredFunctionForName(alias) == nil else {
            throw FunctionRegistrationError.functionAlreadyExists(alias)
        }
        guard let registration = registeredFunctionForName(name) else {
            throw FunctionRegistrationError.functionDoesNotExist(name)
        }
        
        let casedAlias = normalize(alias)
        registration.addAlias(casedAlias)
        functionsByName[casedAlias] = registration
    }
    
    internal func registerFunction(_ function: Function) throws {
        let registration = FunctionRegistration(function: function, caseSensitive: caseSensitive)
        
        // we need to make sure that every name is accounted for
        for name in registration.names {
            guard registeredFunctionForName(name) == nil else {
                throw FunctionRegistrationError.functionAlreadyExists(name)
            }
        }
        
        registration.names.forEach {
            self.functionsByName[$0] = registration
        }
    }
}

private final class FunctionRegistration {
    var names: Set<String>
    let function: FunctionEvaluator
    
    init(function: Function, caseSensitive: Bool) {
        self.function = function.evaluator
        self.names = Set(function.names.map { caseSensitive ? $0 : $0.lowercased() })
    }
    
    func addAlias(_ name: String) {
        names.insert(name)
    }
}

