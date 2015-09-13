//
//  Expressionizer.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/17/15.
//
//

import Foundation

private extension GroupedToken {
    private var groupedOperator: Operator? {
        guard case .Operator(let o) = self.kind else { return nil }
        return o
    }
}

private enum TokenOrExpression {
    case Token(GroupedToken)
    case Expression(MathParser.Expression)
    
    var token: GroupedToken? {
        guard case .Token(let t) = self else { return nil }
        return t
    }
    
    var expression: MathParser.Expression? {
        guard case .Expression(let e) = self else { return nil }
        return e
    }
    
    var isToken: Bool { return token != nil }
    
    var range: Range<String.Index> {
        switch self {
            case .Token(let t): return t.range
            case .Expression(let e): return e.range
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
    
    internal func expressionizeToken(token: GroupedToken) throws -> Expression {
        switch token.kind {
            case .Number(let d):
                return Expression(kind: .Number(d), range: token.range)
            case .Variable(let v):
                return Expression(kind: .Variable(v), range: token.range)
            
            case .Function(let f, let parameters):
                var parameterExpressions = Array<Expression>()
                for parameter in parameters {
                    let info = try expressionizeToken(parameter)
                    parameterExpressions.append(info)
                }
                return Expression(kind: .Function(f, parameterExpressions), range: token.range)
            
            case .Operator(_):
                // this will ultimately result in an error,
                // but we'll let the group logic take care of that
                let newGroup = GroupedToken(kind: .Group([token]), range: token.range)
                return try expressionizeToken(newGroup)
            
            case .Group(let tokens):
                return try expressionizeGroup(tokens)
        }
    }
    
    private func expressionizeGroup(tokens: Array<GroupedToken>) throws -> Expression {
        var wrappers = tokens.map { TokenOrExpression.Token($0) }
        
        while wrappers.count > 1 || wrappers.first?.isToken == true {
            let (indices, maybeOp) = operatorWithHighestPrecedence(wrappers)
            guard let first = indices.first else {
                let range = wrappers.first?.range ?? "".startIndex ..< "".endIndex
                throw ExpressionError(kind: .InvalidFormat, range: range)
            }
            guard let last = indices.last else { fatalError("If there's a first, there's a last") }
            guard let op = maybeOp else { fatalError("Indices but no operator??") }
            
            let index = op.associativity == .Left ? first : last
            wrappers = try collapseWrappers(wrappers, aroundOperator: op, atIndex: index)
        }
        
        guard let wrapper = wrappers.first else {
            fatalError("Implementation flaw")
        }
        
        switch wrapper {
            case .Token(let t):
                return try expressionizeToken(t)
            case .Expression(let e):
                return e
        }
    }
    
    private func operatorWithHighestPrecedence(wrappers: Array<TokenOrExpression>) -> (Array<Int>, Operator?) {
        var indices = Array<Int>()
        
        var precedence = Int.min
        var op: Operator?
        
        wrappers.enumerate().forEach { (index, wrapper) in
            guard let token = wrapper.token else { return }
            guard case let .Operator(o) = token.kind else { return }
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
    
    private func collapseWrappers(wrappers: Array<TokenOrExpression>, aroundOperator op: Operator, atIndex index: Int) throws -> Array<TokenOrExpression> {
        switch (op.arity, op.associativity) {
            case (.Binary, _):
                return try collapseWrappers(wrappers, aroundBinaryOperator: op, atIndex: index)
            case (.Unary, .Left):
                var inoutIndex = index
                return try collapseWrappers(wrappers, aroundLeftUnaryOperator: op, atIndex: &inoutIndex)
            case (.Unary, .Right):
                return try collapseWrappers(wrappers, aroundRightUnaryOperator: op, atIndex: index)
            
        }
    }
    
    private func collapseWrappers(wrappers: Array<TokenOrExpression>, aroundBinaryOperator op: Operator, atIndex index: Int) throws -> Array<TokenOrExpression> {
        let operatorWrapper = wrappers[index]
        
        guard index > 0 else {
            throw ExpressionError(kind: .MissingLeftOperand(op), range: operatorWrapper.range)
        }
        guard index < wrappers.count - 1 else {
            throw ExpressionError(kind: .MissingRightOperand(op), range: operatorWrapper.range)
        }
        
        var operatorIndex = index
        var rightIndex = operatorIndex + 1
        var rightWrapper = wrappers[rightIndex]
        
        var collapsedWrappers = wrappers
        if let t = rightWrapper.token {
            if let o = t.groupedOperator where o.associativity == .Right && o.arity == .Unary {
                collapsedWrappers = try collapseWrappers(collapsedWrappers, aroundRightUnaryOperator: o, atIndex: rightIndex)
                
                rightWrapper = collapsedWrappers[rightIndex]
            } else {
                rightWrapper = .Expression(try expressionizeToken(t))
            }
        }
        collapsedWrappers[rightIndex] = rightWrapper
        
        var leftIndex = index - 1
        var leftWrapper = collapsedWrappers[leftIndex]
        if let t = leftWrapper.token {
            if let o = t.groupedOperator where o.associativity == .Left && o.arity == .Unary {
                collapsedWrappers = try collapseWrappers(collapsedWrappers, aroundLeftUnaryOperator: o, atIndex: &leftIndex)
                
                leftWrapper = collapsedWrappers[leftIndex]
                operatorIndex = leftIndex + 1
                rightIndex = operatorIndex + 1
            } else {
                leftWrapper = .Expression(try expressionizeToken(t))
            }
        }
        
        guard let leftOperand = leftWrapper.expression else { fatalError("Never resolved left operand") }
        guard let rightOperand = rightWrapper.expression else { fatalError("Never resolved right operand") }
        
        let range = leftOperand.range.startIndex ..< rightOperand.range.endIndex
        let expression = Expression(kind: .Function(op.function, [leftOperand, rightOperand]), range: range)
        
        let replacementRange = leftIndex ... rightIndex
        collapsedWrappers.replaceRange(replacementRange, with: [.Expression(expression)])
        
        return collapsedWrappers
    }
    
    private func collapseWrappers(wrappers: Array<TokenOrExpression>, aroundLeftUnaryOperator op: Operator, inout atIndex index: Int) throws -> Array<TokenOrExpression> {
        var operatorIndex = index
        let operatorWrapper = wrappers[operatorIndex]
        
        guard operatorIndex > 0 else {
            throw ExpressionError(kind: .MissingLeftOperand(op), range: operatorWrapper.range) // Missing operand
        }
        
        var operandIndex = operatorIndex - 1
        var operandWrapper = wrappers[operandIndex]
        
        var collapsedWrappers = wrappers
        if let t = operandWrapper.token {
            if let o = t.groupedOperator where o.associativity == .Left && o.arity == .Unary {
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
                operandWrapper = .Expression(try expressionizeToken(t))
            }
        }
        
        guard let operand = operandWrapper.expression else {
            fatalError("Implementation flaw")
        }
        
        let range = operandWrapper.range.startIndex ..< operatorWrapper.range.endIndex
        let expression = Expression(kind: .Function(op.function, [operand]), range: range)
        
        let replacementRange = operandIndex ... operatorIndex
        collapsedWrappers.replaceRange(replacementRange, with: [.Expression(expression)])
        
        index = operandIndex
        return collapsedWrappers
    }
    
    private func collapseWrappers(wrappers: Array<TokenOrExpression>, aroundRightUnaryOperator op: Operator, atIndex index: Int) throws -> Array<TokenOrExpression> {
        var collapsedWrappers = wrappers
        
        let operatorWrapper = collapsedWrappers[index]
        let operandIndex = index + 1
        
        guard operandIndex < wrappers.count else {
            throw ExpressionError(kind: .MissingRightOperand(op), range: operatorWrapper.range) // Missing operand
        }
        
        
        var operandWrapper = collapsedWrappers[operandIndex];
        
        if let t = operandWrapper.token {
            if let o = t.groupedOperator where o.associativity == .Right && o.arity == .Unary {
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
                operandWrapper = .Expression(try expressionizeToken(t))
            }
        }
        
        guard let operand = operandWrapper.expression else {
            fatalError("Implementation flaw")
        }
        
        let range = operatorWrapper.range.startIndex ..< operand.range.endIndex
        let expression: Expression
        
        if op.builtInOperator == .UnaryPlus {
            // the Unary Plus operator does nothing and should be ignored
            expression = operand
        } else {
            expression = Expression(kind: .Function(op.function, [operand]), range: range)
        }
        
        let replacementExpressionRange = index ... operandIndex
        collapsedWrappers.replaceRange(replacementExpressionRange, with: [.Expression(expression)])
        
        return collapsedWrappers
    }
}
