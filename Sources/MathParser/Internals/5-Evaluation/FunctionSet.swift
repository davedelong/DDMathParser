//
//  FunctionSet.swift
//  DDMathParser
//
//  Created by Dave DeLong on 9/18/15.
//
//

import Foundation

internal struct FunctionSet {
    private var functionsByName = Dictionary<String, Function>()
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
    
    private func functionForName(_ name: String) -> Function? {
        let casedName = normalize(name)
        return functionsByName[casedName]
    }
    
    internal func evaluatorForName(_ name: String) -> Function.Body? {
        return functionForName(name)?.body
    }
    
    internal mutating func addAlias(_ alias: String, forFunctionName name: String) throws(FunctionRegistrationError) {
        let existingFunctionForAlias = functionForName(alias)
        if let existingFunctionForAlias {
            let normalizedFunctionName = normalize(name)
            if existingFunctionForAlias.names.contains(normalizedFunctionName) {
                // this is fine; we're adding an existing alias to the same function
                // since this is redunant, it's not an error
                return
            } else {
                // a function exists for this name/alias already, but it's the wrong function
                throw FunctionRegistrationError(code: .functionExists, functionName: alias)
            }
        }
        
        // retrieve the function that will gain the alias
        guard var existingFunctionForName = functionForName(name) else {
            throw FunctionRegistrationError(code: .functionDoesNotExist, functionName: name)
        }
        
        let casedAlias = normalize(alias)
        existingFunctionForName.names.insert(casedAlias)
        // update all instances of this function
        for name in existingFunctionForName.names {
            functionsByName[name] = existingFunctionForName
        }
    }
    
    internal mutating func registerFunction(_ function: Function) throws(FunctionRegistrationError) {
        // we need to make sure that every name is accounted for
        for name in function.names {
            guard functionForName(name) == nil else {
                throw FunctionRegistrationError(code: .functionExists, functionName: name)
            }
        }
        
        function.names.forEach {
            self.functionsByName[$0] = function
        }
    }
    
    @discardableResult
    internal mutating func unregisterFunction(_ name: String) -> Function? {
        guard let function = functionForName(name) else {
            return nil
        }
        
        function.names.forEach {
            self.functionsByName.removeValue(forKey: $0)
        }
        return function
    }
}
