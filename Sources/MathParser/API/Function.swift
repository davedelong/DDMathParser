//
//  Function.swift
//  DDMathParser
//
//  Created by Dave DeLong on 9/17/15.
//
//

import Foundation

public struct EvaluationState {
    private var expressions: Array<Expression>
    
    public var currentExpression: Expression {
        expressions[expressions.count - 1]
    }
    
    public var parentState: EvaluationState? {
        guard let parent = parentExpression else { return nil }
        return EvaluationState(expression: parent, substitutions: substitutions, evaluator: evaluator)
    }
    
    public var parentExpression: Expression? {
        let index = expressions.count - 2
        guard index >= expressions.startIndex else { return nil }
        return expressions[index]
    }
    
    public var expressionRange: Range<String.Index> { currentExpression.range }
    public var arguments: Array<Expression> { currentExpression.functionArguments ?? [] }
    public var argumentCount: Int { arguments.count }
    
    public let substitutions: Substitutions
    private let evaluator: Evaluator
    
    internal init(expression: Expression, substitutions: Substitutions, evaluator: Evaluator) {
        self.expressions = [expression]
        self.substitutions = substitutions
        self.evaluator = evaluator
    }
    
    internal mutating func push(_ expression: Expression) {
        expressions.append(expression)
    }
    
    public func evaluate(argument index: Int) throws -> Double {
        return try evaluator.evaluate(arguments[index], substitutions: substitutions, state: self)
    }
    
    public func dtor(_ value: Double) -> Double {
        guard evaluator.angleMeasurementMode == .degrees else { return value }
        return value / 180 * Double.pi
    }
    
    public func rtod(_ value: Double) -> Double {
        guard evaluator.angleMeasurementMode == .degrees else { return value }
        return value / Double.pi * 180
    }
}

public struct Function {
    
    public typealias Evaluator = (EvaluationState) throws -> Double
    
    public var names: Set<String>
    public let evaluator: Evaluator
    
    public init(name: String, evaluator: @escaping Evaluator) {
        self.init(names: [name], evaluator: evaluator)
    }
    
    public init(names: Set<String>, evaluator: @escaping Evaluator) {
        self.names = names
        self.evaluator = evaluator
    }
}
