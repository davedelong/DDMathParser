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
    
    public let name: String
    public let aliases: Set<String>
    public let evaluator: FunctionEvaluator
    
    public init(name: String, aliases: Set<String> = [], evaluator: FunctionEvaluator) {
        self.name = name
        self.aliases = aliases
        self.evaluator = evaluator
    }
}
