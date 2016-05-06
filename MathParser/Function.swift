//
//  Function.swift
//  DDMathParser
//
//  Created by Dave DeLong on 9/17/15.
//
//

import Foundation

public struct EvaluationState {
    let expressionRange: Range<String.Index>
    let arguments: Array<Expression>
    let substitutions: Substitutions
    let evaluator: Evaluator
}

public typealias FunctionEvaluator = EvaluationState throws -> Double

public struct Function {
    
    public let names: Set<String>
    public let evaluator: FunctionEvaluator
    
    public init(name: String, evaluator: FunctionEvaluator) {
        self.names = [name]
        self.evaluator = evaluator
    }
    
    public init(names: Set<String>, evaluator: FunctionEvaluator) {
        self.names = names
        self.evaluator = evaluator
    }
}
