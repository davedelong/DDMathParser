//
//  OperatorSet.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/7/15.
//
//

import Foundation

public class OperatorSet {
    public static let defaultOperatorSet = OperatorSet()
    
    public enum Relation {
        case LessThan
        case EqualTo
        case GreaterThan
    }
    
    public init(interpretsPercentSignAsModulo: Bool = true) {
        var ops = Array<Operator>()
        var precedence = 1
        
        // == and != have the same precedence
        ops.append(Operator(builtInOperator: .LogicalEqual, precedence: precedence))
        ops.append(Operator(builtInOperator: .LogicalNotEqual, precedence: precedence++))
        
        ops.append(Operator(builtInOperator: .LogicalOr, precedence: precedence++))
        ops.append(Operator(builtInOperator: .LogicalAnd, precedence: precedence++))
        
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
        
        multiplyOperator = Operator(builtInOperator: .Multiply, precedence: precedence)
        ops.append(multiplyOperator)
        ops.append(Operator(builtInOperator: .Divide, precedence: precedence++))
        
        implicitMultiplyOperator = Operator(builtInOperator: .ImplicitMultiply, precedence: precedence++)
        ops.append(implicitMultiplyOperator)
            
        // NOTE: percent-as-modulo precedence goes here (between ImplicitMultiply and Bitwise Not)
        
        ops.append(Operator(builtInOperator: .BitwiseNot, precedence: precedence++))
        
        // all right associative unary operators have the same precedence
        ops.append(Operator(builtInOperator: .UnaryMinus, precedence: precedence))
        ops.append(Operator(builtInOperator: .UnaryPlus, precedence: precedence))
        ops.append(Operator(builtInOperator: .SquareRoot, precedence: precedence))
        ops.append(Operator(builtInOperator: .CubeRoot, precedence: precedence++))
        
        // all left associative unary operators have the same precedence
        ops.append(Operator(builtInOperator: .DoubleFactorial, precedence: precedence))
        ops.append(Operator(builtInOperator: .Factorial, precedence: precedence))
        // NOTE: percent-as-percent precedence goes here (same as Factorial)
        ops.append(Operator(builtInOperator: .Degree, precedence: precedence++))
        
        powerOperator = Operator(builtInOperator: .Power, precedence: precedence++)
        ops.append(powerOperator)
        
        // these are defined as unary right/left associative for convenience
        ops.append(Operator(builtInOperator: .ParenthesisOpen, precedence: precedence))
        ops.append(Operator(builtInOperator: .ParenthesisClose, precedence: precedence++))
        
        ops.append(Operator(builtInOperator: .Comma, precedence: precedence++))
        
        self.operators = ops
        self.interpretsPercentSignAsModulo = interpretsPercentSignAsModulo
        self.knownTokens = Set(ops.flatMap { $0.tokens })
        
        interpretPercentSignAsModulo(self.interpretsPercentSignAsModulo)
    }
    
    public var interpretsPercentSignAsModulo: Bool {
        didSet(oldValue) {
            if oldValue != interpretsPercentSignAsModulo {
                interpretPercentSignAsModulo(interpretsPercentSignAsModulo)
            }
        }
    }
    private func interpretPercentSignAsModulo(interpretAsModulo: Bool) {
        let percent = Operator(builtInOperator: .Percent)
        let modulo = Operator(builtInOperator: .Modulo)
        
        // remove the old one and add the new one
        if interpretAsModulo {
            removeOperator(percent)
            addOperator(modulo, relatedBy: .GreaterThan, toOperator: Operator(builtInOperator: .ImplicitMultiply))
        } else {
            removeOperator(modulo)
            addOperator(percent, relatedBy: .EqualTo, toOperator: Operator(builtInOperator: .Factorial))
        }
    }
    
    private var _operatorTokenSet: OperatorTokenSet? = nil
    internal var operatorTokenSet: OperatorTokenSet {
        if _operatorTokenSet == nil {
            _operatorTokenSet = OperatorTokenSet(tokens: knownTokens)
        }
        guard let set = _operatorTokenSet else { fatalError("Missing operator token set") }
        return set
    }
    
    public private(set) var operators: Array<Operator> {
        didSet {
            operatorsDidChange()
        }
    }
    
    private func operatorsDidChange() {
        knownTokens = Set(operators.flatMap { $0.tokens })
        _operatorTokenSet = nil
    }
    
    internal let multiplyOperator: Operator
    internal let implicitMultiplyOperator: Operator
    internal let powerOperator: Operator
    
    private var knownTokens: Set<String>
    
    private func removeOperator(op: Operator) {
        guard let index = operators.indexOf(op) else { return }
        operators.removeAtIndex(index)
        operatorsDidChange()
    }
    
    public func addTokens(tokens: Array<String>, forOperator op: Operator) {
        let allowed = tokens.map { $0.lowercaseString }.filter {
            self.operatorForToken($0).isEmpty
        }
        
        guard let existing = existingOperator(op) else { return }
        existing.tokens.unionInPlace(allowed)
        operatorsDidChange()
    }
    
    public func addOperator(let op: Operator, relatedBy: Relation, toOperator existingOp: Operator) {
        guard let existing = existingOperator(existingOp) else { return }
        
        let newOperator = op
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
    
    private func processOperator(op: Operator, sorter: Operator -> Bool) {
        if let existing = existingOperator(op) {
            existing.tokens.unionInPlace(op.tokens)
            operatorsDidChange()
        } else {
            let overlap = knownTokens.intersect(op.tokens)
            guard overlap.isEmpty == true else {
                NSLog("cannot add operator with conflicting tokens: \(overlap)")
                return
            }
            
            let newOperators = operators.map { orig -> Operator in
                let new = Operator(function: orig.function, arity: orig.arity, associativity: orig.associativity)
                new.tokens = orig.tokens
                
                var precedence = orig.precedence ?? 0
                if sorter(orig) { precedence++ }
                new.precedence = precedence
                return new
            }
            operators = newOperators
            operators.append(op)
            operatorsDidChange()
        }
    }
    
    public func operatorForToken(token: String, arity: Operator.Arity? = nil, associativity: Operator.Associativity? = nil) -> Array<Operator> {
        
        return operators.filter {
            guard $0.tokens.contains(token) else { return false }
            
            if let arity = arity {
                if $0.arity != arity { return false }
            }
            
            if let associativity = associativity {
                if $0.associativity != associativity { return false }
            }
            
            return true
        }        
    }
    
}
