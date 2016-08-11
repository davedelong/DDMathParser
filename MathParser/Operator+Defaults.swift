//
//  Operator+Defaults.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/8/15.
//
//

import Foundation

public enum BuiltInOperator: String {
    case logicalOr = "l_or"
    case logicalAnd = "l_and"
    case logicalNot = "l_not"
    case logicalEqual = "l_eq"
    case logicalNotEqual = "l_neq"
    case logicalLessThan = "l_lt"
    case logicalGreaterThan = "l_gt"
    case logicalLessThanOrEqual = "l_ltoe"
    case logicalGreaterThanOrEqual = "l_gtoe"
    case bitwiseOr = "or"
    case bitwiseXor = "xor"
    case bitwiseAnd = "and"
    case leftShift = "lshift"
    case rightShift = "rshift"
    case minus = "subtract"
    case add = "add"
    case divide = "divide"
    case multiply = "multiply"
    case implicitMultiply = "implicitMultiply"
    case modulo = "mod"
    case bitwiseNot = "not"
    case factorial = "factorial"
    case doubleFactorial = "factorial2"
    case degree = "dtor"
    case percent = "percent"
    case power = "pow"
    case parenthesisOpen = "open_paren"
    case parenthesisClose = "close_paren"
    case comma = "comma"
    case unaryMinus = "negate"
    case unaryPlus = "positive"
    case squareRoot = "sqrt"
    case cubeRoot = "cuberoot"
}

public extension Operator {
    
    public static let defaultPowerAssociativity: Associativity = {
        
        //determine what associativity NSPredicate/NSExpression is using
        //mathematically, it should be Right associative, but it's usually parsed as Left associative
        //rdar://problem/8692313
        
        let expression = NSExpression(format: "2 ** 3 ** 2")
        let result = expression.expressionValue(with: nil, context: nil) as? NSNumber
        
        if result?.int32Value == 512 {
            return .right
        } else {
            return .left
        }
    }()
    
    internal var builtInOperator: BuiltInOperator? { return BuiltInOperator(rawValue: self.function) }
    
    public convenience init(builtInOperator: BuiltInOperator) {
        let arity: Arity
        let associativity: Associativity
        let tokens: Set<String>

        switch builtInOperator {
            case .logicalOr:
                arity = .binary
                associativity = .left
                tokens = ["||", "∨"]
            case .logicalAnd:
                arity = .binary
                associativity = .left
                tokens = ["&&", "∧"]
            case .logicalNot:
                arity = .unary
                associativity = .right
                tokens = ["!", "¬"]
            case .logicalEqual:
                arity = .binary
                associativity = .left
                tokens = ["==", "="]
            case .logicalNotEqual:
                arity = .binary
                associativity = .left
                tokens = ["!=", "≠"]
                
            case .logicalLessThan:
                arity = .binary
                associativity = .left
                tokens = ["<"]
            case .logicalGreaterThan:
                arity = .binary
                associativity = .left
                tokens = [">"]
            case .logicalLessThanOrEqual:
                arity = .binary
                associativity = .left
                tokens = ["<=", "=<", "≤", "≯"]
            case .logicalGreaterThanOrEqual:
                arity = .binary
                associativity = .left
                tokens = [">=", "=>", "≥", "≮"]
            
            case .bitwiseOr:
                arity = .binary
                associativity = .left
                tokens = ["|"]
            case .bitwiseXor:
                arity = .binary
                associativity = .left
                tokens = ["^"]
            case .bitwiseAnd:
                arity = .binary
                associativity = .left
                tokens = ["&"]
            case .leftShift:
                arity = .binary
                associativity = .left
                tokens = ["<<"]
            case .rightShift:
                arity = .binary
                associativity = .left
                tokens = [">>"]
            
            case .minus:
                arity = .binary
                associativity = .left
                tokens = ["-", "−"]
            case .add:
                arity = .binary
                associativity = .left
                tokens = ["+"]
            
            case .divide:
                arity = .binary
                associativity = .left
                tokens = ["/", "÷"]
            case .multiply:
                arity = .binary
                associativity = .left
                tokens = ["*", "×"]
            case .implicitMultiply:
                arity = .binary
                associativity = .left
                tokens = ["*", "×"]
            
            case .modulo:
                arity = .binary
                associativity = .left
                tokens = ["%"]
            
            case .bitwiseNot:
                arity = .unary
                associativity = .right
                tokens = ["~"]
            
            // Unary Left operators
            case .factorial:
                arity = .unary
                associativity = .left
                tokens = ["!"]
            case .doubleFactorial:
                arity = .unary
                associativity = .left
                tokens = ["!!"]
            case .degree:
                arity = .unary
                associativity = .left
                tokens = ["º", "°", "∘"]
            case .percent:
                arity = .unary
                associativity = .left
                tokens = ["%"]
            
            case .power:
                arity = .binary
                associativity = Operator.defaultPowerAssociativity
                tokens = ["**"]
            
            // Unary Right operators
            case .unaryMinus:
                arity = .unary
                associativity = .right
                tokens = ["-", "−"]
            case .unaryPlus:
                arity = .unary
                associativity = .right
                tokens = ["+"]
            case .squareRoot:
                arity = .unary
                associativity = .right
                tokens = ["√"]
            case .cubeRoot:
                arity = .unary
                associativity = .right
                tokens = ["∛"]
                
            // these are defined as .Unary .Right/.Left associative for convenience
            case .parenthesisOpen:
                arity = .unary
                associativity = .right
                tokens = ["("]
            case .parenthesisClose:
                arity = .unary
                associativity = .left
                tokens = [")"]
                
            case .comma:
                arity = .binary
                associativity = .left
                tokens = [","]
        }
        
        self.init(function: builtInOperator.rawValue, arity: arity, associativity: associativity)
        self.tokens = tokens
        self.precedence = nil
    }
    
    internal convenience init(builtInOperator: BuiltInOperator, precedence: Int) {
        self.init(builtInOperator: builtInOperator)
        self.precedence = precedence
    }
    
}
