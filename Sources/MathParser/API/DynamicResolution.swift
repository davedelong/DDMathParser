//
//  DynamicResolution.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/24/15.
//
//

import Foundation

public protocol EvaluationResolver {
    func evaluateFunction(_ function: String, state: EvaluationState) throws -> Double?
    func evaluateVariable(_ variable: String) -> Double?
}

extension EvaluationResolver {
    
    public func evaluateFunction(_ function: String, state: EvaluationState) throws -> Double? {
        return nil
    }
    
    public func evaluateVariable(_ variable: String) -> Double? {
        return nil
    }
    
}

public protocol Substitution {
    func substitutionValue(using evaluator: Evaluator, substitutions: Substitutions) throws -> Double
    func substitutionValue(using evaluator: Evaluator) throws -> Double
    
    func simplified(using evaluator: Evaluator, substitutions: Substitutions) -> Substitution
    func simplified(using evaluator: Evaluator) -> Substitution
}

public extension Substitution {
    func substitutionValue(using evaluator: Evaluator) throws -> Double {
        return try substitutionValue(using: evaluator, substitutions: [:])
    }
    
    func simplified(using evaluator: Evaluator) -> Substitution {
        return simplified(using: evaluator, substitutions: [:])
    }
}

public typealias Substitutions = Dictionary<String, Substitution>
