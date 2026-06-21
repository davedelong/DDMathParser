//
//  DynamicResolution.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/24/15.
//
//

import Foundation

/// Customize ``Expression`` evaluation.
///
/// Set the ``Evaluator/resolver`` property on your ``Evaluator`` instance to customize the evaluation of ``Expression``s by that evaluator.
public protocol EvaluationResolver {
    
    /// Provide a custom value for a function expression during evaluation.
    ///
    /// The default implementation returns `nil`.
    /// - Parameter function: The name of the function. This may be a typical function (`sin`, as in `sin(42)`),
    /// or it may be the name of the function used to implement an operator (`add`, as in `1 + 2`).
    /// - Parameter state: The current ``EvaluationState``. This includes any parameters to the function,
    /// substitution values, and the methods to recursively perform other evaluations.
    /// - Throws: An `Error` if your custom evaluation encountered an error.
    /// - Returns: The numeric value of the function, or `nil` to indicate that the ``EvaluationResolver`` does not want
    /// to provide a value for this function. If you return `nil`, the underlying ``Evaluator`` will attempt to evaluate the function itself.
    func evaluateFunction(_ function: String, state: EvaluationState) throws -> Double?
    
    /// Provide a custom value for a variable expression during evaluation.
    ///
    /// In some cases, the variable name may actually be a function name. Due to how function evaluation works, an unknown
    /// function will be evaluated as a variable as a method of last resort.
    ///
    /// The default implementation returns `nil`.
    /// - Parameter variable: The name of the variable, as parsed from the original text.
    /// - Returns: The numeric value of the variable, or `nil` to indicate that the ``EvaluationResolver`` does not want
    /// to provide a value for this variable. If you return `nil`, the underlying ``Evaluator`` will attempt to evaluate the variable itself.
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

public typealias Variables = Dictionary<String, Double>
