//
//  File.swift
//  
//
//  Created by Dave DeLong on 8/25/23.
//

import Foundation

/// The current state of an in-progress evaluation
public struct EvaluationState {
    private var expressions: Array<Expression>
    
    /// The ``Expression`` currently being evaluated
    public var currentExpression: Expression {
        expressions[expressions.count - 1]
    }
    
    /// The state of the parent expression's evaluation
    ///
    /// If the ``currentExpression`` represents the argument to a function (or operator),
    /// then this will return the overall evaluation state of the function itself.
    public var parentState: EvaluationState? {
        guard let parent = parentExpression else { return nil }
        return EvaluationState(expression: parent, variables: variables, evaluator: evaluator)
    }
    
    /// The parent ``Expression``
    ///
    /// If the ``currentExpression`` represents the argument to a function (or operator),
    /// then this will return the expression of the function itself.
    public var parentExpression: Expression? {
        let index = expressions.count - 2
        guard index >= expressions.startIndex else { return nil }
        return expressions[index]
    }
    
    /// The current expression's range in the original source `String`
    public var expressionRange: Range<String.Index> { currentExpression.range }
    
    /// If the ``currentExpression`` is a function, then this returns its arguments.
    ///
    /// Otherwise, this returns an empty array.
    public var arguments: Array<Expression> { currentExpression.functionArguments ?? [] }
    
    /// The number of arguments to the ``currentExpression``
    public var argumentCount: Int { arguments.count }
    
    /// The set of variables known to be available to the ``currentExpression``
    public let variables: Variables
    
    private let evaluator: Evaluator
    
    /// Indicates whether angles should be interpreted as degrees or radians
    public var angleMeasurementMode: Evaluator.AngleMode { evaluator.angleMeasurementMode }
    
    internal init(expression: Expression, variables: Variables, evaluator: Evaluator) {
        self.expressions = [expression]
        self.variables = variables
        self.evaluator = evaluator
    }
    
    internal mutating func push(_ expression: Expression) {
        expressions.append(expression)
    }
    
    /// Evaluate a function's argument and return its numeric value
    /// - Parameter index: The index of the argument within the current function expression
    /// - Returns: The numeric value of the argument
    /// - Throws: Throws an `.invalidArguments` error if the current expression does not have an argument
    /// at the provided index. May throw an error if evaluate of the argument fails.
    public func evaluate(argument index: Int) throws(MathParserError) -> Double {
        try requireMinArgumentCount(index + 1)
        return try evaluator.evaluate(arguments[index], variables: variables, state: self)
    }
    
    public func evaluate(_ expression: Expression) throws(MathParserError) -> Double {
        // TODO: should this behave differently if the expression is not an argument?
        return try evaluator.evaluate(expression, variables: variables, state: self)
    }
    
    internal func requireArgumentCount(_ count: Int) throws(MathParserError) {
        if arguments.count == count { return }
        throw MathParserError(code: .invalidArguments, range: expressionRange)
    }
    
    internal func requireMinArgumentCount(_ count: Int) throws(MathParserError) {
        if arguments.count >= count { return }
        throw MathParserError(code: .invalidArguments, range: expressionRange)
    }
    
    internal func requireMaxArgumentCount(_ count: Int) throws(MathParserError) {
        if arguments.count <= count { return }
        throw MathParserError(code: .invalidArguments, range: expressionRange)
    }
}
