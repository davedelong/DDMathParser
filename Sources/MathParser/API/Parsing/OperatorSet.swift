//
//  OperatorSet.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/7/15.
//
//

import Foundation

public struct OperatorSet: Sendable {
    public static var `default`: OperatorSet {
        return OperatorSet()
    }
    
    public enum Relation {
        case lessThan
        case equalTo
        case greaterThan
    }
    
    public init(interpretsPercentSignAsModulo: Bool = true) {
        var ops = Array<Operator>()
        var precedence = 1
        
        @discardableResult
        func add(_ op: Operator, precedence: Int) -> Operator {
            var copy = op
            copy.precedence = precedence
            ops.append(copy)
            return copy
        }
        
        // LogicalDisjunction
        add(.logicalOr, precedence: precedence)
        precedence += 1
        
        // LogicalConjunction
        add(.logicalAnd, precedence: precedence)
        precedence += 1
        
        // == and != have the same precedence
        
        // ComparisonPrecedence
        add(.logicalEqual, precedence: precedence)
        add(.logicalNotEqual, precedence: precedence)
        add(.logicalLessThan, precedence: precedence)
        add(.logicalGreaterThan, precedence: precedence)
        add(.logicalLessThanOrEqual, precedence: precedence)
        add(.logicalGreaterThanOrEqual, precedence: precedence)
        precedence += 1
        
        precedence += 1
        
        // AdditionPrecedence
        precedence += 1
        add(.add, precedence: precedence)
        add(.minus, precedence: precedence)
        add(.bitwiseOr, precedence: precedence)
        add(.bitwiseXor, precedence: precedence)
        precedence += 1
        
        // MultiplicationPrecedence
        multiplyOperator = add(.multiply, precedence: precedence)
        add(.divide, precedence: precedence)
        add(.bitwiseAnd, precedence: precedence)
        precedence += 1
        
        implicitMultiplyOperator = add(.implicitMultiply, precedence: precedence)
        precedence += 1
        
        // NOTE: percent-as-modulo precedence goes here (after ImplicitMultiply)
        
        // BitwiseShiftPrecedence
        add(.leftShift, precedence: precedence)
        add(.rightShift, precedence: precedence)
        precedence += 1
        
        // all right associative unary operators have the same precedence
        add(.bitwiseNot, precedence: precedence)
        add(.unaryMinus, precedence: precedence)
        add(.unaryPlus, precedence: precedence)
        add(.squareRoot, precedence: precedence)
        add(.cubeRoot, precedence: precedence)
        add(.logicalNot, precedence: precedence)
        precedence += 1
        
        // all left associative unary operators have the same precedence
        add(.doubleFactorial, precedence: precedence)
        add(.factorial, precedence: precedence)
        // NOTE: percent-as-percent precedence goes here (same as Factorial)
        add(.degree, precedence: precedence)
        precedence += 1
        
        powerOperator = add(.power, precedence: precedence)
        precedence += 1
        
        addFractionOperator = add(.add, precedence: precedence)
        precedence += 1
        
        // these are defined as unary right/left associative for convenience
        add(.parenthesisOpen, precedence: precedence)
        add(.parenthesisClose, precedence: precedence)
        precedence += 1
        
        add(.comma, precedence: precedence)
        precedence += 1
        
        self.operators = ops
        self.interpretsPercentSignAsModulo = interpretsPercentSignAsModulo
        self.knownTokens = Set(ops.flatMap { $0.tokens })
        
        interpretPercentSignAsModulo(self.interpretsPercentSignAsModulo)
    }
    
    public var interpretsPercentSignAsModulo: Bool {
        didSet {
            if oldValue != interpretsPercentSignAsModulo {
                interpretPercentSignAsModulo(interpretsPercentSignAsModulo)
            }
        }
    }
    
    private mutating func interpretPercentSignAsModulo(_ interpretAsModulo: Bool) {
        let percent = Operator.percent
        let modulo = Operator.modulo
        
        // remove the old one and add the new one
        if interpretAsModulo {
            removeOperator(percent)
            addOperator(modulo, relatedBy: .greaterThan, toOperator: .implicitMultiply)
        } else {
            removeOperator(modulo)
            addOperator(percent, relatedBy: .equalTo, toOperator: .factorial)
        }
    }
    
    internal var operatorTokenSet: OperatorTokenSet {
        OperatorTokenSet(tokens: knownTokens)
    }
    
    public private(set) var operators: Array<Operator> {
        didSet {
            knownTokens = Set(operators.flatMap { $0.tokens })
        }
    }
    
    internal let addFractionOperator: Operator
    internal let multiplyOperator: Operator
    internal let implicitMultiplyOperator: Operator
    internal let powerOperator: Operator
    
    private var knownTokens: Set<String>
    
    private mutating func removeOperator(_ op: Operator) {
        guard let index = operators.firstIndex(of: op) else { return }
        operators.remove(at: index)
    }
    
    public mutating func addTokens(_ tokens: Array<String>, forOperator op: Operator) {
        let allowed = tokens.map { $0.lowercased() }.filter {
            self.operatorForToken($0).isEmpty
        }
        
        modifyOperator(op) {
            $0.tokens.formUnion(allowed)
        }
    }
    
    public mutating func addOperator(_ op: Operator, relatedBy: Relation, toOperator existingOp: Operator) {
        guard let existing = existingOperator(existingOp) else { return }
        guard let existingP = existing.precedence else { fatalError("Existing operator missing precedence \(existing)") }
        
        var newOperator = op
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
    
    @discardableResult
    private mutating func modifyOperator(_ op: Operator, modifier: (inout Operator) -> Void) -> Bool {
        if let index = operators.firstIndex(of: op) {
            var copy = operators[index]
            modifier(&copy)
            operators[index] = copy
            return true
        } else {
            return false
        }
    }
    
    private mutating func processOperator(_ op: Operator, sorter: (Operator) -> Bool) {
        if modifyOperator(op, modifier: { $0.tokens.formUnion(op.tokens) }) == false {
            let overlap = knownTokens.intersection(op.tokens)
            guard overlap.isEmpty == true else {
                NSLog("cannot add operator with conflicting tokens: \(overlap)")
                return
            }
            
            let newOperators = operators.map { orig -> Operator in
                var new = Operator(function: orig.function, arity: orig.arity, associativity: orig.associativity)
                new.tokens = orig.tokens
                
                var precedence = orig.precedence ?? 0
                if sorter(orig) { precedence += 1 }
                new.precedence = precedence
                return new
            }
            operators = newOperators
            operators.append(op)
        }
    }
    
    internal func operatorForToken(_ token: String, arity: Operator.Arity? = nil, associativity: Operator.Associativity? = nil) -> Array<Operator> {
        
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
