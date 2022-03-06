//
//  Function.swift
//  DDMathParser
//
//  Created by Dave DeLong on 9/17/15.
//
//

import Foundation

public struct EvaluationState {
    public let expressionRange: Range<String.Index>
    public let arguments: Array<Expression>
    public let substitutions: Substitutions
    public let evaluator: Evaluator
}

public struct Function {
    
    public typealias Evaluator = (EvaluationState) throws -> Double
    
    public let names: Set<String>
    public let evaluator: Evaluator
    
    public init(name: String, evaluator: @escaping Evaluator) {
        self.init(names: [name], evaluator: evaluator)
    }
    
    public init(names: Set<String>, evaluator: @escaping Evaluator) {
        self.names = names
        self.evaluator = evaluator
    }
}
