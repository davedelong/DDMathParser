//
//  Function.swift
//  DDMathParser
//
//  Created by Dave DeLong on 9/17/15.
//
//

import Foundation

public typealias FunctionEvaluator = (Array<Expression>, Substitutions, Evaluator) throws -> Double

public struct Function {
    
    public static let standardFunctions: Array<Function> = [
        add, subtract, multiply, divide,
        mod, negate, factorial, factorial2,
        pow, sqrt, cuberoot, nthroot,
        random, abs, percent,
        log, ln, log2, exp,
        and, or, not, xor, lshift, rshift,
        sum, product,
        count, min, max, average, median, stddev,
        ceil, floor,
        sin, cos, tan, asin, acos, atan, atan2,
        csc, sec, cotan, acsc, asec, acotan,
        sinh, cosh, tanh, asinh, acosh, atanh,
        csch, sech, cotanh, acsch, asech, acotanh,
        versin, vercosin, coversin, covercosin, haversin, havercosin, hacoversin, hacovercosin, exsec, excsc, crd,
        dtor, rtod,
        phi, pi, pi_2, pi_4, tau, sqrt2, e, log2e, log10e, ln2, ln10,
        l_and, l_or, l_not, l_eq, l_neq, l_lt, l_gt, l_ltoe, l_gtoe, l_if
    ]
    
    public let name: String
    public let aliases: Set<String>
    public let evaluator: FunctionEvaluator
    
    public init(name: String, aliases: Set<String> = [], evaluator: FunctionEvaluator) {
        self.name = name
        self.aliases = aliases
        self.evaluator = evaluator
    }
}
