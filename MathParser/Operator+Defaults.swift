//
//  Operator+Defaults.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/8/15.
//
//

import Foundation

public enum BuiltInOperator: String {
    case LogicalOr = "l_or"
    case LogicalAnd = "l_and"
    case LogicalNot = "l_not"
    case LogicalEqual = "l_eq"
    case LogicalNotEqual = "l_neq"
    case LogicalLessThan = "l_lt"
    case LogicalGreaterThan = "l_gt"
    case LogicalLessThanOrEqual = "l_ltoe"
    case LogicalGreaterThanOrEqual = "l_gtoe"
    case BitwiseOr = "or"
    case BitwiseXor = "xor"
    case BitwiseAnd = "and"
    case LeftShift = "lshift"
    case RightShift = "rshift"
    case Minus = "subtract"
    case Add = "add"
    case Divide = "divide"
    case Multiply = "multiply"
    case ImplicitMultiply = "implicitMultiply"
    case Modulo = "mod"
    case BitwiseNot = "not"
    case Factorial = "factorial"
    case DoubleFactorial = "factorial2"
    case Degree = "dtor"
    case Percent = "percent"
    case Power = "pow"
    case ParenthesisOpen = "open_paren"
    case ParenthesisClose = "close_paren"
    case Comma = "comma"
    case UnaryMinus = "negate"
    case UnaryPlus = "positive"
    case SquareRoot = "sqrt"
    case CubeRoot = "cuberoot"
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
            case .LogicalOr:
                arity = .binary
                associativity = .left
                tokens = ["||", "∨"]
            case .LogicalAnd:
                arity = .binary
                associativity = .left
                tokens = ["&&", "∧"]
            case .LogicalNot:
                arity = .unary
                associativity = .right
                tokens = ["!", "¬"]
            case .LogicalEqual:
                arity = .binary
                associativity = .left
                tokens = ["==", "="]
            case .LogicalNotEqual:
                arity = .binary
                associativity = .left
                tokens = ["!=", "≠"]
                
            case .LogicalLessThan:
                arity = .binary
                associativity = .left
                tokens = ["<"]
            case .LogicalGreaterThan:
                arity = .binary
                associativity = .left
                tokens = [">"]
            case .LogicalLessThanOrEqual:
                arity = .binary
                associativity = .left
                tokens = ["<=", "=<", "≤", "≯"]
            case .LogicalGreaterThanOrEqual:
                arity = .binary
                associativity = .left
                tokens = [">=", "=>", "≥", "≮"]
            
            case .BitwiseOr:
                arity = .binary
                associativity = .left
                tokens = ["|"]
            case .BitwiseXor:
                arity = .binary
                associativity = .left
                tokens = ["^"]
            case .BitwiseAnd:
                arity = .binary
                associativity = .left
                tokens = ["&"]
            case .LeftShift:
                arity = .binary
                associativity = .left
                tokens = ["<<"]
            case .RightShift:
                arity = .binary
                associativity = .left
                tokens = [">>"]
            
            case .Minus:
                arity = .binary
                associativity = .left
                tokens = ["-", "−"]
            case .Add:
                arity = .binary
                associativity = .left
                tokens = ["+"]
            
            case .Divide:
                arity = .binary
                associativity = .left
                tokens = ["/", "÷"]
            case .Multiply:
                arity = .binary
                associativity = .left
                tokens = ["*", "×"]
            case .ImplicitMultiply:
                arity = .binary
                associativity = .left
                tokens = ["*", "×"]
            
            case .Modulo:
                arity = .binary
                associativity = .left
                tokens = ["%"]
            
            case .BitwiseNot:
                arity = .unary
                associativity = .right
                tokens = ["~"]
            
            // Unary Left operators
            case .Factorial:
                arity = .unary
                associativity = .left
                tokens = ["!"]
            case .DoubleFactorial:
                arity = .unary
                associativity = .left
                tokens = ["!!"]
            case .Degree:
                arity = .unary
                associativity = .left
                tokens = ["º", "°", "∘"]
            case .Percent:
                arity = .unary
                associativity = .left
                tokens = ["%"]
            
            case .Power:
                arity = .binary
                associativity = Operator.defaultPowerAssociativity
                tokens = ["**"]
            
            // Unary Right operators
            case .UnaryMinus:
                arity = .unary
                associativity = .right
                tokens = ["-", "−"]
            case .UnaryPlus:
                arity = .unary
                associativity = .right
                tokens = ["+"]
            case .SquareRoot:
                arity = .unary
                associativity = .right
                tokens = ["√"]
            case .CubeRoot:
                arity = .unary
                associativity = .right
                tokens = ["∛"]
                
            // these are defined as .Unary .Right/.Left associative for convenience
            case .ParenthesisOpen:
                arity = .unary
                associativity = .right
                tokens = ["("]
            case .ParenthesisClose:
                arity = .unary
                associativity = .left
                tokens = [")"]
                
            case .Comma:
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
