//
//  Operator+Defaults.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/8/15.
//
//

import Foundation

extension Operator {
    
    private static let builtinOperators = [
        logicalOr, logicalAnd, logicalNot, logicalEqual, logicalNotEqual, logicalLessThan, logicalGreaterThan, logicalLessThanOrEqual, logicalGreaterThanOrEqual, bitwiseOr, bitwiseXor, bitwiseAnd, leftShift, rightShift, minus, add, divide, multiply, implicitMultiply, modulo, bitwiseNot, factorial, doubleFactorial, degree, percent, power, unaryMinus, unaryPlus, squareRoot, cubeRoot, parenthesisOpen, parenthesisClose, comma
    ]
    
    internal static func builtinOperator(_ function: String) -> Operator? {
        return builtinOperators.first(where: { $0.function == function })
    }
    
    public static let logicalOr = Operator(builtinFunction: "l_or", arity: .binary, associativity: .left, tokens: ["||", "∨"])
    public static let logicalAnd = Operator(builtinFunction: "l_and", arity: .binary, associativity: .left, tokens: ["&&", "∧"])
    public static let logicalNot = Operator(builtinFunction: "l_not", arity: .unary, associativity: .right, tokens: ["!", "¬"])
    public static let logicalEqual = Operator(builtinFunction: "l_eq", arity: .binary, associativity: .left, tokens: ["==", "="])
    public static let logicalNotEqual = Operator(builtinFunction: "l_neq", arity: .binary, associativity: .left, tokens: ["!=", "≠"])
    public static let logicalLessThan = Operator(builtinFunction: "l_lt", arity: .binary, associativity: .left, tokens: ["<"])
    public static let logicalGreaterThan = Operator(builtinFunction: "l_gt", arity: .binary, associativity: .left, tokens: [">"])
    public static let logicalLessThanOrEqual = Operator(builtinFunction: "l_ltoe", arity: .binary, associativity: .left, tokens: ["<=", "=<", "≤", "≯"])
    public static let logicalGreaterThanOrEqual = Operator(builtinFunction: "l_gtoe", arity: .binary, associativity: .left, tokens: [">=", "=>", "≥", "≮"])
    public static let bitwiseOr = Operator(builtinFunction: "or", arity: .binary, associativity: .left, tokens: ["|"])
    public static let bitwiseXor = Operator(builtinFunction: "xor", arity: .binary, associativity: .left, tokens: ["^"])
    public static let bitwiseAnd = Operator(builtinFunction: "and", arity: .binary, associativity: .left, tokens: ["&"])
    public static let leftShift = Operator(builtinFunction: "lshift", arity: .binary, associativity: .left, tokens: ["<<"])
    public static let rightShift = Operator(builtinFunction: "rshift", arity: .binary, associativity: .left, tokens: [">>"])
    public static let minus = Operator(builtinFunction: "subtract", arity: .binary, associativity: .left, tokens: ["-", "−"])
    public static let add = Operator(builtinFunction: "add", arity: .binary, associativity: .left, tokens: ["+"])
    public static let divide = Operator(builtinFunction: "divide", arity: .binary, associativity: .left, tokens: ["/", "÷"])
    public static let multiply = Operator(builtinFunction: "multiply", arity: .binary, associativity: .left, tokens: ["*", "×"])
    public static let implicitMultiply = Operator(builtinFunction: "implicitMultiply", arity: .binary, associativity: .left, tokens: ["*", "×"])
    public static let modulo = Operator(builtinFunction: "mod", arity: .binary, associativity: .left, tokens: ["%"])
    public static let bitwiseNot = Operator(builtinFunction: "not", arity: .unary, associativity: .right, tokens: ["~"])
    public static let factorial = Operator(builtinFunction: "factorial", arity: .unary, associativity: .left, tokens: ["!"])
    public static let doubleFactorial = Operator(builtinFunction: "factorial2", arity: .unary, associativity: .left, tokens: ["!!"])
    public static let degree = Operator(builtinFunction: "dtor", arity: .unary, associativity: .left, tokens: ["º", "°", "∘"])
    public static let percent = Operator(builtinFunction: "percent", arity: .unary, associativity: .left, tokens: ["%"])
    public static let power = Operator(builtinFunction: "pow", arity: .binary, associativity: .defaultPowerAssociativity, tokens: ["**"])
    public static let unaryMinus = Operator(builtinFunction: "negate", arity: .unary, associativity: .right, tokens: ["-", "−"])
    public static let unaryPlus = Operator(builtinFunction: "positive", arity: .unary, associativity: .right, tokens: ["+"])
    public static let squareRoot = Operator(builtinFunction: "sqrt", arity: .unary, associativity: .right, tokens: ["√"])
    public static let cubeRoot = Operator(builtinFunction: "cuberoot", arity: .unary, associativity: .right, tokens: ["∛"])
    public static let parenthesisOpen = Operator(builtinFunction: "open_paren", arity: .unary, associativity: .right, tokens: ["("])
    public static let parenthesisClose = Operator(builtinFunction: "close_paren", arity: .unary, associativity: .left, tokens: [")"])
    public static let comma = Operator(builtinFunction: "comma", arity: .binary, associativity: .left, tokens: [","])
}

extension Operator.Associativity {
    
    public static let defaultPowerAssociativity: Self = {
        // determine what associativity NSExpression is using
        // mathematically, it should be right associative, but it's usually parsed as left associative
        // rdar://problem/8692313
        
        let expression = NSExpression(format: "2 ** 3 ** 2")
        let result = expression.expressionValue(with: nil, context: nil) as? NSNumber
        
        if result?.int32Value == 512 {
            return .right
        } else {
            return .left
        }
    }()
    
}
