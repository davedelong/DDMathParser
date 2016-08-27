//
//  Expressionizer.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/17/15.
//
//

import Foundation

fileprivate extension GroupedToken {
    fileprivate var groupedOperator: Operator? {
        guard case .operator(let o) = self.kind else { return nil }
        return o
    }
}

private enum TokenOrExpression {
    case token(GroupedToken)
    case expression(Expression)
    
    var token: GroupedToken? {
        guard case .token(let t) = self else { return nil }
        return t
    }
    
    var expression: Expression? {
        guard case .expression(let e) = self else { return nil }
        return e
    }
    
// <rdar://problem/27805272> Segfault when compiling "Result" enum
//    var isToken: Bool { return token != nil }
    var isToken: Bool {
        if case .token(_) = self { return true }
        return false
    }
    
    var range: Range<Int> {
        switch self {
            case .token(let t): return t.range
            case .expression(let e): return e.range
        }
    }
}

public struct Expressionizer {
    private let grouper: TokenGrouper
    
    public init(grouper: TokenGrouper) {
        self.grouper = grouper
    }
    
    public func expression() throws -> Expression {
        let rootToken = try grouper.group()
        
        return try expressionizeToken(rootToken)
    }
    
    internal func expressionizeToken(_ token: GroupedToken) throws -> Expression {
        switch token.kind {
            case .number(let d):
                return Expression(kind: .number(d), range: token.range)
            case .variable(let v):
                return Expression(kind: .variable(v), range: token.range)
            
            case .function(let f, let parameters):
                var parameterExpressions = Array<Expression>()
                for parameter in parameters {
                    let info = try expressionizeToken(parameter)
                    parameterExpressions.append(info)
                }
                return Expression(kind: .function(f, parameterExpressions), range: token.range)
            
            case .operator(_):
                // this will ultimately result in an error,
                // but we'll let the group logic take care of that
                let newGroup = GroupedToken(kind: .group([token]), range: token.range)
                return try expressionizeToken(newGroup)
            
            case .group(let tokens):
                return try expressionizeGroup(tokens)
        }
    }
    
    private func expressionizeGroup(_ tokens: Array<GroupedToken>) throws -> Expression {
        var wrappers = tokens.map { TokenOrExpression.token($0) }
        
        while wrappers.count > 1 || wrappers.first?.isToken == true {
            let (indices, maybeOp) = operatorWithHighestPrecedence(wrappers)
            guard let first = indices.first else {
                let range: Range<Int> = wrappers.first?.range ?? 0 ..< 0
                throw MathParserError(kind: .invalidFormat, range: range)
            }
            guard let last = indices.last else { fatalError("If there's a first, there's a last") }
            guard let op = maybeOp else { fatalError("Indices but no operator??") }
            
            let index = op.associativity == .left ? first : last
            wrappers = try collapseWrappers(wrappers, aroundOperator: op, atIndex: index)
        }
        
        guard let wrapper = wrappers.first else {
            fatalError("Implementation flaw")
        }
        
        switch wrapper {
            case .token(let t):
                return try expressionizeToken(t)
            case .expression(let e):
                return e
        }
    }
    
    private func operatorWithHighestPrecedence(_ wrappers: Array<TokenOrExpression>) -> (Array<Int>, Operator?) {
        var indices = Array<Int>()
        
        var precedence = Int.min
        var op: Operator?
        
        wrappers.enumerated().forEach { (index, wrapper) in
            guard let token = wrapper.token else { return }
            guard case let .operator(o) = token.kind else { return }
            guard let p = o.precedence else {
                fatalError("Operator with unknown precedence")
            }
            
            if p == precedence {
                indices.append(index)
            } else if p > precedence {
                precedence = p
                op = o
                indices.removeAll()
                indices.append(index)
            }
        }
        
        return (indices, op)
    }
    
    private func collapseWrappers(_ wrappers: Array<TokenOrExpression>, aroundOperator op: Operator, atIndex index: Int) throws -> Array<TokenOrExpression> {
        switch (op.arity, op.associativity) {
            case (.binary, _):
                return try collapseWrappers(wrappers, aroundBinaryOperator: op, atIndex: index)
            case (.unary, .left):
                var inoutIndex = index
                return try collapseWrappers(wrappers, aroundLeftUnaryOperator: op, atIndex: &inoutIndex)
            case (.unary, .right):
                return try collapseWrappers(wrappers, aroundRightUnaryOperator: op, atIndex: index)
            
        }
    }
    
    private func collapseWrappers(_ wrappers: Array<TokenOrExpression>, aroundBinaryOperator op: Operator, atIndex index: Int) throws -> Array<TokenOrExpression> {
        let operatorWrapper = wrappers[index]
        
        guard index > 0 else {
            throw MathParserError(kind: .missingLeftOperand(op), range: operatorWrapper.range)
        }
        guard index < wrappers.count - 1 else {
            throw MathParserError(kind: .missingRightOperand(op), range: operatorWrapper.range)
        }
        
        var operatorIndex = index
        var rightIndex = operatorIndex + 1
        var rightWrapper = wrappers[rightIndex]
        
        var collapsedWrappers = wrappers
        if let t = rightWrapper.token {
            if let o = t.groupedOperator, o.associativity == .right && o.arity == .unary {
                collapsedWrappers = try collapseWrappers(collapsedWrappers, aroundRightUnaryOperator: o, atIndex: rightIndex)
                
                rightWrapper = collapsedWrappers[rightIndex]
            } else {
                rightWrapper = .expression(try expressionizeToken(t))
            }
        }
        collapsedWrappers[rightIndex] = rightWrapper
        
        var leftIndex = index - 1
        var leftWrapper = collapsedWrappers[leftIndex]
        if let t = leftWrapper.token {
            if let o = t.groupedOperator, o.associativity == .left && o.arity == .unary {
                collapsedWrappers = try collapseWrappers(collapsedWrappers, aroundLeftUnaryOperator: o, atIndex: &leftIndex)
                
                leftWrapper = collapsedWrappers[leftIndex]
                operatorIndex = leftIndex + 1
                rightIndex = operatorIndex + 1
            } else {
                leftWrapper = .expression(try expressionizeToken(t))
            }
        }
        
        guard let leftOperand = leftWrapper.expression else { fatalError("Never resolved left operand") }
        guard let rightOperand = rightWrapper.expression else { fatalError("Never resolved right operand") }
        
        let range: Range<Int> = leftOperand.range.lowerBound ..< rightOperand.range.upperBound
        let expression = Expression(kind: .function(op.function, [leftOperand, rightOperand]), range: range)
        
        let replacementRange = leftIndex ... rightIndex
        collapsedWrappers.replaceSubrange(replacementRange, with: [.expression(expression)])
        
        return collapsedWrappers
    }
    
    private func collapseWrappers(_ wrappers: Array<TokenOrExpression>, aroundLeftUnaryOperator op: Operator, atIndex index: inout Int) throws -> Array<TokenOrExpression> {
        var operatorIndex = index
        let operatorWrapper = wrappers[operatorIndex]
        
        guard operatorIndex > 0 else {
            throw MathParserError(kind: .missingLeftOperand(op), range: operatorWrapper.range) // Missing operand
        }
        
        var operandIndex = operatorIndex - 1
        var operandWrapper = wrappers[operandIndex]
        
        var collapsedWrappers = wrappers
        if let t = operandWrapper.token {
            if let o = t.groupedOperator, o.associativity == .left && o.arity == .unary {
                // recursively collapse left unary operators
                // technically, this should never happen, because left unary operators
                // are left-associative, which means they evaluate from left-to-right
                // This means that a left-assoc unary operator should never have another
                // left-assoc unary operator to its left, because it would've already
                // have been resolved
                // Regardless, this is here for completeness
                var newOperandIndex = operandIndex
                collapsedWrappers = try collapseWrappers(collapsedWrappers, aroundLeftUnaryOperator: o, atIndex: &newOperandIndex)
                
                let indexDelta = operandIndex - newOperandIndex
                operatorIndex = operatorIndex - indexDelta
                operandIndex = operandIndex - 1
            } else {
                operandWrapper = .expression(try expressionizeToken(t))
            }
        }
        
        guard let operand = operandWrapper.expression else {
            fatalError("Implementation flaw")
        }
        
        let range: Range<Int> = operandWrapper.range.lowerBound ..< operatorWrapper.range.upperBound
        let expression = Expression(kind: .function(op.function, [operand]), range: range)
        
        let replacementRange = operandIndex ... operatorIndex
        collapsedWrappers.replaceSubrange(replacementRange, with: [.expression(expression)])
        
        index = operandIndex
        return collapsedWrappers
    }
    
    private func collapseWrappers(_ wrappers: Array<TokenOrExpression>, aroundRightUnaryOperator op: Operator, atIndex index: Int) throws -> Array<TokenOrExpression> {
        var collapsedWrappers = wrappers
        
        let operatorWrapper = collapsedWrappers[index]
        let operandIndex = index + 1
        
        guard operandIndex < wrappers.count else {
            throw MathParserError(kind: .missingRightOperand(op), range: operatorWrapper.range) // Missing operand
        }
        
        
        var operandWrapper = collapsedWrappers[operandIndex];
        
        if let t = operandWrapper.token {
            if let o = t.groupedOperator, o.associativity == .right && o.arity == .unary {
                // recursively collapse right unary operators
                // technically, this should never happen, because right unary operators
                // are right-associative, which means they evaluate from right-to-left
                // This means that a right-assoc unary operator should never have another
                // right-assoc unary operator to its right, because it would've already
                // have been resolved
                // Regardless, this is here for completeness
                collapsedWrappers = try collapseWrappers(collapsedWrappers, aroundRightUnaryOperator: o, atIndex: operandIndex)
                operandWrapper = collapsedWrappers[operandIndex]
            } else {
                operandWrapper = .expression(try expressionizeToken(t))
            }
        }
        
        guard let operand = operandWrapper.expression else {
            fatalError("Implementation flaw")
        }
        
        let range: Range<Int> = operatorWrapper.range.lowerBound ..< operand.range.upperBound
        let expression: Expression
        
        if op.builtInOperator == .unaryPlus {
            // the Unary Plus operator does nothing and should be ignored
            expression = operand
        } else {
            expression = Expression(kind: .function(op.function, [operand]), range: range)
        }
        
        let replacementExpressionRange = index ... operandIndex
        collapsedWrappers.replaceSubrange(replacementExpressionRange, with: [.expression(expression)])
        
        return collapsedWrappers
    }
}
