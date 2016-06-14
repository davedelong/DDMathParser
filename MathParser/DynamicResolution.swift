//
//  DynamicResolution.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/24/15.
//
//

import Foundation

public protocol FunctionOverrider {
    func overrideFunction(_ function: String, state: EvaluationState) throws -> Double?
}

public protocol FunctionResolver {
    func resolveFunction(_ function: String, state: EvaluationState) throws -> Double?
}

public protocol VariableResolver {
    func resolveVariable(_ variable: String) -> Double?
}

public typealias Substitutions = Dictionary<String, Double>
