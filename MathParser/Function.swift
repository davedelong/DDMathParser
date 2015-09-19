//
//  Function.swift
//  DDMathParser
//
//  Created by Dave DeLong on 9/17/15.
//
//

import Foundation

public typealias FunctionEvaluator = (Array<Expression>, Substitutions, Evaluator) throws -> Double

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
