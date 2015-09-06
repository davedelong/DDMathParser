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
    
    public static let defaultPowerAssociativity: Operator.Associativity = {
        
        //determine what associativity NSPredicate/NSExpression is using
        //mathematically, it should be Right associative, but it's usually parsed as Left associative
        //rdar://problem/8692313
        
        let expression = NSExpression(format: "2 ** 3 ** 2")
        let result = expression.expressionValueWithObject(nil, context: nil)
        
        if result.intValue == 512 {
            return .Right
        } else {
            return .Left
        }
    }()
    
    internal var builtInOperator: BuiltInOperator? { return BuiltInOperator(rawValue: self.function) }
    
    public convenience init(builtInOperator: BuiltInOperator) {
        let arity: Arity
        let associativity: Associativity
        let tokens: Set<String>

        switch builtInOperator {
            case .LogicalOr:
                arity = .Binary
                associativity = .Left
                tokens = ["||", "∨"]
            case .LogicalAnd:
                arity = .Binary
                associativity = .Left
                tokens = ["&&", "∧"]
            case .LogicalNot:
                arity = .Unary
                associativity = .Right
                tokens = ["!", "¬"]
            case .LogicalEqual:
                arity = .Binary
                associativity = .Left
                tokens = ["==", "="]
            case .LogicalNotEqual:
                arity = .Binary
                associativity = .Left
                tokens = ["!=", "≠"]
                
            case .LogicalLessThan:
                arity = .Binary
                associativity = .Left
                tokens = ["<"]
            case .LogicalGreaterThan:
                arity = .Binary
                associativity = .Left
                tokens = [">"]
            case .LogicalLessThanOrEqual:
                arity = .Binary
                associativity = .Left
                tokens = ["<=", "=<", "≤", "≯"]
            case .LogicalGreaterThanOrEqual:
                arity = .Binary
                associativity = .Left
                tokens = [">=", "=>", "≥", "≮"]
            
            case .BitwiseOr:
                arity = .Binary
                associativity = .Left
                tokens = ["|"]
            case .BitwiseXor:
                arity = .Binary
                associativity = .Left
                tokens = ["^"]
            case .BitwiseAnd:
                arity = .Binary
                associativity = .Left
                tokens = ["&"]
            case .LeftShift:
                arity = .Binary
                associativity = .Left
                tokens = ["<<"]
            case .RightShift:
                arity = .Binary
                associativity = .Left
                tokens = [">>"]
            
            case .Minus:
                arity = .Binary
                associativity = .Left
                tokens = ["-", "−"]
            case .Add:
                arity = .Binary
                associativity = .Left
                tokens = ["+"]
            
            case .Divide:
                arity = .Binary
                associativity = .Left
                tokens = ["/", "÷"]
            case .Multiply:
                arity = .Binary
                associativity = .Left
                tokens = ["*", "×"]
            case .ImplicitMultiply:
                arity = .Binary
                associativity = .Left
                tokens = ["*", "×"]
            
            case .Modulo:
                arity = .Binary
                associativity = .Left
                tokens = ["%"]
            
            case .BitwiseNot:
                arity = .Unary
                associativity = .Right
                tokens = ["~"]
            
            // Unary Left operators
            case .Factorial:
                arity = .Unary
                associativity = .Left
                tokens = ["!"]
            case .DoubleFactorial:
                arity = .Unary
                associativity = .Left
                tokens = ["!!"]
            case .Degree:
                arity = .Unary
                associativity = .Left
                tokens = ["º", "°", "∘"]
            case .Percent:
                arity = .Unary
                associativity = .Left
                tokens = ["%"]
            
            case .Power:
                arity = .Binary
                associativity = Operator.defaultPowerAssociativity
                tokens = ["**"]
            
            // Unary Right operators
            case .UnaryMinus:
                arity = .Unary
                associativity = .Right
                tokens = ["-", "−"]
            case .UnaryPlus:
                arity = .Unary
                associativity = .Right
                tokens = ["+"]
            case .SquareRoot:
                arity = .Unary
                associativity = .Right
                tokens = ["√"]
            case .CubeRoot:
                arity = .Unary
                associativity = .Right
                tokens = ["∛"]
                
            // these are defined as .Unary .Right/.Left associative for convenience
            case .ParenthesisOpen:
                arity = .Unary
                associativity = .Right
                tokens = ["("]
            case .ParenthesisClose:
                arity = .Unary
                associativity = .Left
                tokens = [")"]
                
            case .Comma:
                arity = .Binary
                associativity = .Left
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
