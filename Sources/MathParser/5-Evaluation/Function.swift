//
//  Function.swift
//  DDMathParser
//
//  Created by Dave DeLong on 9/17/15.
//
//

import Foundation

public struct EvaluationState {
    public let expressionRange: Range<Int>
    public let arguments: Array<Expression>
    public let substitutions: Substitutions
    public let evaluator: Evaluator
}

public typealias FunctionEvaluator = (EvaluationState) throws -> Double

public struct Function {
    
    public let names: Set<String>
    public let evaluator: FunctionEvaluator
    
    public init(name: String, evaluator: @escaping FunctionEvaluator) {
        self.names = [name]
        self.evaluator = evaluator
    }
    
    public init(names: Set<String>, evaluator: @escaping FunctionEvaluator) {
        self.names = names
        self.evaluator = evaluator
    }
}
