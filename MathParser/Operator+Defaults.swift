//
//  Operator+Defaults.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/8/15.
//
//

import Foundation

private let DefaultPowerAssociativity: Operator.Associativity = {
    
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
    
    internal var builtInOperator: BuiltInOperator? { return BuiltInOperator(rawValue: self.function) }
    
    public init(builtInOperator: BuiltInOperator) {
        self.function = builtInOperator.rawValue
        
        switch builtInOperator {
            case .LogicalOr:
                self.arity = .Binary
                self.associativity = .Left
                self.tokens = ["||", "∨"]
            case .LogicalAnd:
                self.arity = .Binary
                self.associativity = .Left
                self.tokens = ["&&", "∧"]
            case .LogicalNot:
                self.arity = .Unary
                self.associativity = .Right
                self.tokens = ["!", "¬"]
            case .LogicalEqual:
                self.arity = .Binary
                self.associativity = .Left
                self.tokens = ["==", "="]
            case .LogicalNotEqual:
                self.arity = .Binary
                self.associativity = .Left
                self.tokens = ["!=", "≠"]
                
            case .LogicalLessThan:
                self.arity = .Binary
                self.associativity = .Left
                self.tokens = ["<"]
            case .LogicalGreaterThan:
                self.arity = .Binary
                self.associativity = .Left
                self.tokens = [">"]
            case .LogicalLessThanOrEqual:
                self.arity = .Binary
                self.associativity = .Left
                self.tokens = ["<=", "=<", "≤", "≯"]
            case .LogicalGreaterThanOrEqual:
                self.arity = .Binary
                self.associativity = .Left
                self.tokens = [">=", "=>", "≥", "≮"]
            
            case .BitwiseOr:
                self.arity = .Binary
                self.associativity = .Left
                self.tokens = ["|"]
            case .BitwiseXor:
                self.arity = .Binary
                self.associativity = .Left
                self.tokens = ["^"]
            case .BitwiseAnd:
                self.arity = .Binary
                self.associativity = .Left
                self.tokens = ["&"]
            case .LeftShift:
                self.arity = .Binary
                self.associativity = .Left
                self.tokens = ["<<"]
            case .RightShift:
                self.arity = .Binary
                self.associativity = .Left
                self.tokens = [">>"]
            
            case .Minus:
                self.arity = .Binary
                self.associativity = .Left
                self.tokens = ["-", "−"]
            case .Add:
                self.arity = .Binary
                self.associativity = .Left
                self.tokens = ["+"]
            
            case .Divide:
                self.arity = .Binary
                self.associativity = .Left
                self.tokens = ["/", "÷"]
            case .Multiply:
                self.arity = .Binary
                self.associativity = .Left
                self.tokens = ["*", "×"]
            case .ImplicitMultiply:
                self.arity = .Binary
                self.associativity = .Left
                self.tokens = []
            
            case .Modulo:
                self.arity = .Binary
                self.associativity = .Left
                self.tokens = ["%"]
            
            case .BitwiseNot:
                self.arity = .Unary
                self.associativity = .Right
                self.tokens = ["~"]
            
            // Unary Left operators
            case .Factorial:
                self.arity = .Unary
                self.associativity = .Left
                self.tokens = ["!"]
            case .Degree:
                self.arity = .Unary
                self.associativity = .Left
                self.tokens = ["º", "°", "∘"]
            case .Percent:
                self.arity = .Unary
                self.associativity = .Left
                self.tokens = ["%"]
            
            case .Power:
                self.arity = .Binary
                self.associativity = DefaultPowerAssociativity
                self.tokens = ["**"]
            
            // Unary Right operators
            case .UnaryMinus:
                self.arity = .Unary
                self.associativity = .Right
                self.tokens = ["-", "−"]
            case .UnaryPlus:
                self.arity = .Unary
                self.associativity = .Right
                self.tokens = ["+"]
            case .SquareRoot:
                self.arity = .Unary
                self.associativity = .Right
                self.tokens = ["√"]
            case .CubeRoot:
                self.arity = .Unary
                self.associativity = .Right
                self.tokens = ["∛"]
                
            // these are defined as .Unary .Right/.Left associative for convenience
            case .ParenthesisOpen:
                self.arity = .Unary
                self.associativity = .Right
                self.tokens = ["("]
            case .ParenthesisClose:
                self.arity = .Unary
                self.associativity = .Left
                self.tokens = [")"]
                
            case .Comma:
                self.arity = .Binary
                self.associativity = .Left
                self.tokens = [","]
        }
        
        self.precedence = nil
    }
    
    internal init(builtInOperator: BuiltInOperator, precedence: Int) {
        self.init(builtInOperator: builtInOperator)
        self.precedence = precedence
    }
    
}
