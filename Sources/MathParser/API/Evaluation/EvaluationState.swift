//
//  File.swift
//  
//
//  Created by Dave DeLong on 8/25/23.
//

import Foundation

public struct EvaluationState {
    private var expressions: Array<Expression>
    
    public var currentExpression: Expression {
        expressions[expressions.count - 1]
    }
    
    public var parentState: EvaluationState? {
        guard let parent = parentExpression else { return nil }
        return EvaluationState(expression: parent, variables: variables, evaluator: evaluator)
    }
    
    public var parentExpression: Expression? {
        let index = expressions.count - 2
        guard index >= expressions.startIndex else { return nil }
        return expressions[index]
    }
    
    public var expressionRange: Range<String.Index> { currentExpression.range }
    public var arguments: Array<Expression> { currentExpression.functionArguments ?? [] }
    public var argumentCount: Int { arguments.count }
    
    public let variables: Variables
    private let evaluator: Evaluator
    
    public var angleMeasurementMode: Evaluator.AngleMode { evaluator.angleMeasurementMode }
    
    internal init(expression: Expression, variables: Variables, evaluator: Evaluator) {
        self.expressions = [expression]
        self.variables = variables
        self.evaluator = evaluator
    }
    
    internal mutating func push(_ expression: Expression) {
        expressions.append(expression)
    }
    
    public func evaluate(argument index: Int) throws -> Double {
        return try evaluator.evaluate(arguments[index], variables: variables, state: self)
    }
    
    public func evaluate(_ expression: Expression) throws -> Double {
        // TODO: should this behave differently if the expression is not an argument?
        return try evaluator.evaluate(expression, variables: variables, state: self)
    }
    
    internal func requireArgumentCount(_ count: Int) throws {
        if arguments.count == count { return }
        throw MathParserError(code: .invalidArguments, range: expressionRange)
    }
    
    internal func requireMinArgumentCount(_ count: Int) throws {
        if arguments.count >= count { return }
        throw MathParserError(code: .invalidArguments, range: expressionRange)
    }
    
    internal func requireMaxArgumentCount(_ count: Int) throws {
        if arguments.count <= count { return }
        throw MathParserError(code: .invalidArguments, range: expressionRange)
    }
}
