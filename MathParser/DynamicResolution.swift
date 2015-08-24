//
//  DynamicResolution.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/24/15.
//
//

import Foundation

public protocol FunctionResolver {
    func resolveFunction(function: String, arguments: Array<Expression>, substitutions: Dictionary<String, Double>) throws -> Double?
}

public protocol VariableResolver {
    func resolveVariable(variable: String) -> Double?
}

public typealias FunctionEvaluator = (Array<Expression>, Dictionary<String, Double>, Evaluator) throws -> Double?