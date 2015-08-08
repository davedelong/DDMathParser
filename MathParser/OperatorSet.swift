//
//  OperatorSet.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/7/15.
//
//

import Foundation

public struct OperatorSet {
    public static let defaultOperatorSet = OperatorSet()
    
    public enum Relation {
        case LessThan
        case EqualTo
        case GreaterThan
    }
    
    public init(interpretsPercentSignAsModulo: Bool = true) {
        var ops = Array<Operator>()
        var precedence = 1
        ops.append(Operator(builtInOperator: .LogicalOr, precedence: precedence++))
        ops.append(Operator(builtInOperator: .LogicalAnd, precedence: precedence++))
        
        // == and != have the same precedence
        ops.append(Operator(builtInOperator: .LogicalEqual, precedence: precedence++))
        ops.append(Operator(builtInOperator: .LogicalNotEqual, precedence: precedence++))
        
        ops.append(Operator(builtInOperator: .LogicalLessThan, precedence: precedence++))
        ops.append(Operator(builtInOperator: .LogicalGreaterThan, precedence: precedence++))
        ops.append(Operator(builtInOperator: .LogicalLessThanOrEqual, precedence: precedence++))
        ops.append(Operator(builtInOperator: .LogicalGreaterThanOrEqual, precedence: precedence++))
        ops.append(Operator(builtInOperator: .LogicalNot, precedence: precedence++))
        ops.append(Operator(builtInOperator: .BitwiseOr, precedence: precedence++))
        ops.append(Operator(builtInOperator: .BitwiseXor, precedence: precedence++))
        ops.append(Operator(builtInOperator: .BitwiseAnd, precedence: precedence++))
        ops.append(Operator(builtInOperator: .LeftShift, precedence: precedence++))
        ops.append(Operator(builtInOperator: .RightShift, precedence: precedence++))
        ops.append(Operator(builtInOperator: .Add, precedence: precedence))
        ops.append(Operator(builtInOperator: .Minus, precedence: precedence++))
        
        ops.append(Operator(builtInOperator: .Multiply, precedence: precedence))
        ops.append(Operator(builtInOperator: .Divide, precedence: precedence++))
        
        ops.append(Operator(builtInOperator: .ImplicitMultiply, precedence: precedence++))
            
        // NOTE: percent-as-modulo precedence goes here (between ImplicitMultiply and Bitwise Not)
        
        ops.append(Operator(builtInOperator: .BitwiseNot, precedence: precedence++))
        
        // all right associative unary operators have the same precedence
        ops.append(Operator(builtInOperator: .UnaryMinus, precedence: precedence))
        ops.append(Operator(builtInOperator: .UnaryPlus, precedence: precedence))
        ops.append(Operator(builtInOperator: .SquareRoot, precedence: precedence))
        ops.append(Operator(builtInOperator: .CubeRoot, precedence: precedence++))
        
        // all left associative unary operators have the same precedence
        ops.append(Operator(builtInOperator: .Factorial, precedence: precedence))
        // NOTE: percent-as-percent precedence goes here (same as Factorial)
        ops.append(Operator(builtInOperator: .Degree, precedence: precedence++))
        
        ops.append(Operator(builtInOperator: .Power, precedence: precedence++))
        
        // these are defined as unary right/left associative for convenience
        ops.append(Operator(builtInOperator: .ParenthesisOpen, precedence: precedence))
        ops.append(Operator(builtInOperator: .ParenthesisClose, precedence: precedence++))
        
        ops.append(Operator(builtInOperator: .Comma, precedence: precedence++))
        
        self.operators = ops
        self.interpretsPercentSignAsModulo = interpretsPercentSignAsModulo
        self.knownTokens = Set(ops.flatMap { $0.tokens })
    }
    
    public var interpretsPercentSignAsModulo: Bool {
        didSet(oldValue) {
            let percent = Operator(builtInOperator: .Percent)
            let modulo = Operator(builtInOperator: .Modulo)
            
            // remove the old one
            if oldValue {
                removeOperator(modulo)
            } else {
                removeOperator(percent)
            }
            
            // add the new one
            if interpretsPercentSignAsModulo {
                addOperator(modulo, relatedBy: .GreaterThan, toOperator: Operator(builtInOperator: .ImplicitMultiply))
            } else {
                addOperator(percent, relatedBy: .EqualTo, toOperator: Operator(builtInOperator: .Factorial))
            }
        }
    }
    
    internal func operatorTokenSet() -> OperatorTokenSet {
        return OperatorTokenSet(tokens: knownTokens)
    }
    
    public private(set) var operators: Array<Operator> {
        didSet {
            let tokens = operators.flatMap { $0.tokens }
            knownTokens = Set(tokens)
        }
    }
    private var knownTokens: Set<String>
    
    private mutating func removeOperator(op: Operator) {
        guard let index = operators.indexOf(op) else { return }
        operators.removeAtIndex(index)
    }
    
    public mutating func addOperator(let op: Operator, relatedBy: Relation, toOperator existingOp: Operator) {
        guard let existing = existingOperator(existingOp) else { return }
        
        var newOperator = op
        newOperator.precedence = existing.precedence
        
        let sorter: Operator -> Bool
        
        switch relatedBy {
            case .EqualTo:
                sorter = { _ in return false }
            case .LessThan:
                sorter = { other in
                    return other.precedence >= existing.precedence
                }
            case .GreaterThan:
                sorter = { other in
                    return other.precedence > existing.precedence
                }
        }
        
        processOperator(newOperator, sorter: sorter)
        
    }
    
    private func existingOperator(op: Operator) -> Operator? {
        let matches = operators.filter { $0 == op }
        return matches.first
    }
    
    private mutating func processOperator(op: Operator, sorter: Operator -> Bool) {
        if var existing = existingOperator(op) {
            existing.tokens.unionInPlace(op.tokens)
        } else {
            let overlap = knownTokens.intersect(op.tokens)
            if overlap.isEmpty == false {
                NSLog("cannot add operator with conflicting tokens: \(overlap)")
                return
            }
            
            let newOperators = operators.map { orig -> Operator in
                var new = Operator(function: orig.function, arity: orig.arity, associativity: orig.associativity)
                new.tokens = orig.tokens
                
                var precedence = orig.precedence!
                if sorter(orig) { precedence++ }
                new.precedence = precedence
                return new
            }
            operators = newOperators
            operators.append(op)
        }
    }
    
//    public func operatorForToken(token: String, arity: Operator.Arity? = nil, associativity: Operator.Associativity? = nil) {
//        
//    }
    
}
