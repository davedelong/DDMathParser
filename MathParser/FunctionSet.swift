//
//  FunctionSet.swift
//  DDMathParser
//
//  Created by Dave DeLong on 9/18/15.
//
//

import Foundation

public class FunctionSet {
    private var functionsByName: Dictionary<String, FunctionRegistration>
    private let caseSensitive: Bool
    
    public init(usesCaseSensitiveFunctions: Bool) {
        caseSensitive = usesCaseSensitiveFunctions
        let functions = Function.standardFunctions.map { FunctionRegistration(function: $0, caseSensitive: usesCaseSensitiveFunctions) }
        
        var functionsByName = Dictionary<String, FunctionRegistration>()
        functions.forEach { reg in
            reg.names.forEach {
                functionsByName[$0] = reg
            }
        }
        self.functionsByName = functionsByName
    }
    
    internal func normalize(name: String) -> String {
        return caseSensitive ? name : name.lowercaseString
    }
    
    private func registeredFunctionForName(name: String) -> FunctionRegistration? {
        let casedName = normalize(name)
        return functionsByName[casedName]
    }
    
    public func functionForName(name: String) -> Function? {
        return registeredFunctionForName(name)?.function
    }
    
    public func addAlias(alias: String, forFunctionName name: String) throws {
        guard registeredFunctionForName(alias) == nil else {
            // TODO: throw error "function with name already exists"
            return
        }
        guard let registration = registeredFunctionForName(name) else {
            // TODO: throw error "no such function"
            return
        }
        
        let casedAlias = normalize(alias)
        registration.addAlias(casedAlias)
        functionsByName[casedAlias] = registration
    }
    
    public func registerFunction(function: Function) throws {
        guard registeredFunctionForName(function.name) == nil else {
            // TODO: throw error "function with name already exists"
            return
        }
        
        let registration = FunctionRegistration(function: function, caseSensitive: caseSensitive)
        registration.names.forEach {
            self.functionsByName[$0] = registration
        }
    }
}

internal class FunctionRegistration {
    internal private(set) var names: Set<String>
    internal let function: Function
    
    init(function: Function, caseSensitive: Bool) {
        self.function = function
        
        var names = Set<String>()
        names.unionInPlace(function.aliases.map { caseSensitive ? $0.lowercaseString : $0 })
        names.insert(caseSensitive ? function.name.lowercaseString : function.name)
        self.names = names
    }
    
    func addAlias(name: String) {
        names.insert(name)
    }
}

