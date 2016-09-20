//
//  OperatorSet.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/7/15.
//
//

import Foundation

public final class OperatorSet {
    public static let `default` = OperatorSet()
    
    public enum Relation {
        case lessThan
        case equalTo
        case greaterThan
    }
    
    public init(interpretsPercentSignAsModulo: Bool = true) {
        var ops = Array<Operator>()
        var precedence = 1
        
        // == and != have the same precedence
        ops.append(Operator(builtInOperator: .logicalEqual, precedence: precedence))
        ops.append(Operator(builtInOperator: .logicalNotEqual, precedence: precedence))
        precedence += 1
        
        ops.append(Operator(builtInOperator: .logicalOr, precedence: precedence))
        precedence += 1
        ops.append(Operator(builtInOperator: .logicalAnd, precedence: precedence))
        precedence += 1
        
        ops.append(Operator(builtInOperator: .logicalLessThan, precedence: precedence))
        precedence += 1
        ops.append(Operator(builtInOperator: .logicalGreaterThan, precedence: precedence))
        precedence += 1
        ops.append(Operator(builtInOperator: .logicalLessThanOrEqual, precedence: precedence))
        precedence += 1
        ops.append(Operator(builtInOperator: .logicalGreaterThanOrEqual, precedence: precedence))
        precedence += 1
        ops.append(Operator(builtInOperator: .logicalNot, precedence: precedence))
        precedence += 1
        ops.append(Operator(builtInOperator: .bitwiseOr, precedence: precedence))
        precedence += 1
        ops.append(Operator(builtInOperator: .bitwiseXor, precedence: precedence))
        precedence += 1
        ops.append(Operator(builtInOperator: .bitwiseAnd, precedence: precedence))
        precedence += 1
        ops.append(Operator(builtInOperator: .leftShift, precedence: precedence))
        precedence += 1
        ops.append(Operator(builtInOperator: .rightShift, precedence: precedence))
        precedence += 1
        
        ops.append(Operator(builtInOperator: .add, precedence: precedence))
        ops.append(Operator(builtInOperator: .minus, precedence: precedence))
        precedence += 1
        
        multiplyOperator = Operator(builtInOperator: .multiply, precedence: precedence)
        ops.append(multiplyOperator)
        ops.append(Operator(builtInOperator: .divide, precedence: precedence))
        precedence += 1
        
        implicitMultiplyOperator = Operator(builtInOperator: .implicitMultiply, precedence: precedence)
        precedence += 1
        ops.append(implicitMultiplyOperator)
            
        // NOTE: percent-as-modulo precedence goes here (between ImplicitMultiply and Bitwise Not)
        
        ops.append(Operator(builtInOperator: .bitwiseNot, precedence: precedence))
        precedence += 1
        
        // all right associative unary operators have the same precedence
        ops.append(Operator(builtInOperator: .unaryMinus, precedence: precedence))
        ops.append(Operator(builtInOperator: .unaryPlus, precedence: precedence))
        ops.append(Operator(builtInOperator: .squareRoot, precedence: precedence))
        ops.append(Operator(builtInOperator: .cubeRoot, precedence: precedence))
        precedence += 1
        
        // all left associative unary operators have the same precedence
        ops.append(Operator(builtInOperator: .doubleFactorial, precedence: precedence))
        ops.append(Operator(builtInOperator: .factorial, precedence: precedence))
        // NOTE: percent-as-percent precedence goes here (same as Factorial)
        ops.append(Operator(builtInOperator: .degree, precedence: precedence))
        precedence += 1
        
        powerOperator = Operator(builtInOperator: .power, precedence: precedence)
        precedence += 1
        ops.append(powerOperator)
        
        // these are defined as unary right/left associative for convenience
        ops.append(Operator(builtInOperator: .parenthesisOpen, precedence: precedence))
        ops.append(Operator(builtInOperator: .parenthesisClose, precedence: precedence))
        precedence += 1
        
        ops.append(Operator(builtInOperator: .comma, precedence: precedence))
        precedence += 1
        
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
    private func interpretPercentSignAsModulo(_ interpretAsModulo: Bool) {
        let percent = Operator(builtInOperator: .percent)
        let modulo = Operator(builtInOperator: .modulo)
        
        // remove the old one and add the new one
        if interpretAsModulo {
            removeOperator(percent)
            addOperator(modulo, relatedBy: .greaterThan, toOperator: Operator(builtInOperator: .implicitMultiply))
        } else {
            removeOperator(modulo)
            addOperator(percent, relatedBy: .equalTo, toOperator: Operator(builtInOperator: .factorial))
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
    
    private func removeOperator(_ op: Operator) {
        guard let index = operators.index(of: op) else { return }
        operators.remove(at: index)
        operatorsDidChange()
    }
    
    public func addTokens(_ tokens: Array<String>, forOperator op: Operator) {
        let allowed = tokens.map { $0.lowercased() }.filter {
            self.operatorForToken($0).isEmpty
        }
        
        guard let existing = existingOperator(op) else { return }
        existing.tokens.formUnion(allowed)
        operatorsDidChange()
    }
    
    public func addOperator(_ op: Operator, relatedBy: Relation, toOperator existingOp: Operator) {
        guard let existing = existingOperator(existingOp) else { return }
        guard let existingP = existing.precedence else { fatalError("Existing operator missing precedence \(existing)") }
        
        let newOperator = op
        newOperator.precedence = existing.precedence
        
        let sorter: (Operator) -> Bool
        
        switch relatedBy {
            case .equalTo:
                sorter = { _ in return false }
            case .lessThan:
                sorter = { other in
                    guard let otherP = other.precedence else { fatalError("Operator missing precedence: \(other)") }
                    return otherP >= existingP
                }
            case .greaterThan:
                sorter = { other in
                    guard let otherP = other.precedence else { fatalError("Operator missing precedence: \(other)") }
                    return otherP > existingP
                }
        }
        
        processOperator(newOperator, sorter: sorter)
        
    }
    
    private func existingOperator(_ op: Operator) -> Operator? {
        let matches = operators.filter { $0 == op }
        return matches.first
    }
    
    private func processOperator(_ op: Operator, sorter: (Operator) -> Bool) {
        if let existing = existingOperator(op) {
            existing.tokens.formUnion(op.tokens)
            operatorsDidChange()
        } else {
            let overlap = knownTokens.intersection(op.tokens)
            guard overlap.isEmpty == true else {
                NSLog("cannot add operator with conflicting tokens: \(overlap)")
                return
            }
            
            let newOperators = operators.map { orig -> Operator in
                let new = Operator(function: orig.function, arity: orig.arity, associativity: orig.associativity)
                new.tokens = orig.tokens
                
                var precedence = orig.precedence ?? 0
                if sorter(orig) { precedence += 1 }
                new.precedence = precedence
                return new
            }
            operators = newOperators
            operators.append(op)
            operatorsDidChange()
        }
    }
    
    public func operatorForToken(_ token: String, arity: Operator.Arity? = nil, associativity: Operator.Associativity? = nil) -> Array<Operator> {
        
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
