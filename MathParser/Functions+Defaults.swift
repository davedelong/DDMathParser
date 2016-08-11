//
//  StandardFunctions.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/20/15.
//
//

import Foundation

public extension Function {
    
    private static let largestIntegerFactorial: Int = {
        var n = Int.max
        var i = 2
        while i < n {
            n /= i
            i += 1
        }
        return i - 1
    }()
    
    // MARK: - Angle mode helpers
    
    internal static func _dtor(_ d: Double, evaluator: Evaluator) -> Double {
        guard evaluator.angleMeasurementMode == .degrees else { return d }
        return d / 180 * M_PI
    }
    
    internal static func _rtod(_ d: Double, evaluator: Evaluator) -> Double {
        guard evaluator.angleMeasurementMode == .degrees else { return d }
        return d / M_PI * 180
    }
    
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
        `true`, `false`,
        phi, pi, pi_2, pi_4, tau, sqrt2, e, log2e, log10e, ln2, ln10,
        l_and, l_or, l_not, l_eq, l_neq, l_lt, l_gt, l_ltoe, l_gtoe, l_if
    ]
    
    // MARK: - Basic functions
    
    public static let add = Function(name: "add", evaluator: { state throws -> Double in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        let arg2 = try state.evaluator.evaluate(state.arguments[1], substitutions: state.substitutions)
        return arg1 + arg2
    })
    
    public static let subtract = Function(name: "subtract", evaluator: { state throws -> Double in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        let arg2 = try state.evaluator.evaluate(state.arguments[1], substitutions: state.substitutions)
        return arg1 - arg2
    })
    
    public static let multiply = Function(names: ["multiply", "implicitmultiply"], evaluator: { state throws -> Double in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        let arg2 = try state.evaluator.evaluate(state.arguments[1], substitutions: state.substitutions)
        return arg1 * arg2
    })
    
    public static let divide = Function(name: "divide", evaluator: { state throws -> Double in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        let arg2 = try state.evaluator.evaluate(state.arguments[1], substitutions: state.substitutions)
        
        guard arg2 != 0 else { throw MathParserError(kind: .divideByZero, range: state.expressionRange) }
        return arg1 / arg2
    })
    
    public static let mod = Function(names: ["mod", "modulo"], evaluator: { state throws -> Double in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        let arg2 = try state.evaluator.evaluate(state.arguments[1], substitutions: state.substitutions)
        
        return fmod(arg1, arg2)
    })
    
    public static let negate = Function(name: "negate", evaluator: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        
        return -arg1
    })
    
    public static let factorial = Function(name: "factorial", evaluator: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        return arg1.factorial()
    })
    
    public static let factorial2 = Function(name: "factorial2", evaluator: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        guard arg1 >= 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        guard arg1 == Darwin.floor(arg1) else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        if arg1.truncatingRemainder(dividingBy: 2) == 0 {
            let k = arg1 / 2
            return Darwin.pow(2, k) * k.factorial()
        } else {
            let k = (arg1 + 1) / 2
            
            let numerator = (2*k).factorial()
            let denominator = Darwin.pow(2, k) * k.factorial()
            
            guard denominator != 0 else { throw MathParserError(kind: .divideByZero, range: state.expressionRange) }
            return numerator / denominator
        }
    })
    
    public static let pow = Function(name: "pow", evaluator: { state throws -> Double in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        let arg2 = try state.evaluator.evaluate(state.arguments[1], substitutions: state.substitutions)
        
        return Darwin.pow(arg1, arg2)
    })
    
    public static let sqrt = Function(name: "sqrt", evaluator: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let value = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        
        return Darwin.sqrt(value)
    })
    
    public static let cuberoot = Function(name: "cuberoot", evaluator: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        
        return Darwin.pow(arg1, 1.0/3.0)
    })
    
    public static let nthroot = Function(name: "nthroot", evaluator: { state throws -> Double in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        let arg2 = try state.evaluator.evaluate(state.arguments[1], substitutions: state.substitutions)
        
        guard arg2 != 0 else { throw MathParserError(kind: .divideByZero, range: state.expressionRange) }
        
        if arg1 < 0 && arg2.truncatingRemainder(dividingBy: 2) == 1 {
            // for negative numbers with an odd root, the result will be negative
            let root = Darwin.pow(-arg1, 1/arg2)
            return -root
        } else {
            return Darwin.pow(arg1, 1/arg2)
        }
    })
    
    public static let random = Function(name: "random", evaluator: { state throws -> Double in
        guard state.arguments.count <= 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        var argValues = Array<Double>()
        for arg in state.arguments {
            let argValue = try state.evaluator.evaluate(arg, substitutions: state.substitutions)
            argValues.append(argValue)
        }
        
        let lowerBound = argValues.count > 0 ? argValues[0] : DBL_MIN
        let upperBound = argValues.count > 1 ? argValues[1] : DBL_MAX
        
        guard lowerBound < upperBound else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let range = upperBound - lowerBound
        
        return (drand48().truncatingRemainder(dividingBy: range)) + lowerBound
    })
    
    public static let log = Function(name: "log", evaluator: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        return Darwin.log10(arg1)
    })
    
    public static let ln = Function(name: "ln", evaluator: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        return Darwin.log(arg1)
    })
    
    public static let log2 = Function(name: "log2", evaluator: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        return Darwin.log2(arg1)
    })
    
    public static let exp = Function(name: "exp", evaluator: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        return Darwin.exp(arg1)
    })
    
    public static let abs = Function(name: "abs", evaluator: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        return Swift.abs(arg1)
    })
    
    public static let percent = Function(name: "percent", evaluator: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let percentArgument = state.arguments[0]
        let percentValue = try state.evaluator.evaluate(percentArgument, substitutions: state.substitutions)
        let percent = percentValue / 100
        
        let percentExpression = percentArgument.parent
        let percentContext = percentExpression?.parent
        
        guard let contextKind = percentContext?.kind else { return percent }
        guard case let .function(f, contextArgs) = contextKind else { return percent }
        
        // must be XXXX + n% or XXXX - n%
        guard let builtIn = BuiltInOperator(rawValue: f), builtIn == .add || builtIn == .minus else { return percent }
        
        // cannot be n% + XXXX or n% - XXXX
        guard contextArgs[1] === percentExpression else { return percent }
        
        let context = try state.evaluator.evaluate(contextArgs[0], substitutions: state.substitutions)
        
        return context * percent
    })
    
    // MARK: - Bitwise functions
    
    public static let and = Function(name: "and", evaluator: { state throws -> Double in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        let arg2 = try state.evaluator.evaluate(state.arguments[1], substitutions: state.substitutions)
        
        return Double(Int(arg1) & Int(arg2))
    })
    
    public static let or = Function(name: "or", evaluator: { state throws -> Double in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        let arg2 = try state.evaluator.evaluate(state.arguments[1], substitutions: state.substitutions)
        
        return Double(Int(arg1) | Int(arg2))
    })
    
    public static let not = Function(name: "not", evaluator: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        
        return Double(~Int(arg1))
    })
    
    public static let xor = Function(name: "xor", evaluator: { state throws -> Double in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        let arg2 = try state.evaluator.evaluate(state.arguments[1], substitutions: state.substitutions)
        
        return Double(Int(arg1) ^ Int(arg2))
    })
    
    public static let rshift = Function(name: "rshift", evaluator: { state throws -> Double in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        let arg2 = try state.evaluator.evaluate(state.arguments[1], substitutions: state.substitutions)
        
        return Double(Int(arg1) >> Int(arg2))
    })
    
    public static let lshift = Function(name: "lshift", evaluator: { state throws -> Double in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        let arg2 = try state.evaluator.evaluate(state.arguments[1], substitutions: state.substitutions)
        
        return Double(Int(arg1) << Int(arg2))
    })
    
    // MARK: - Aggregate functions
    
    public static let average = Function(names: ["average", "avg", "mean"], evaluator: { state throws -> Double in
        guard state.arguments.count > 0 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let value = try sum.evaluator(state)
        
        return value / Double(state.arguments.count)
    })
    
    public static let sum = Function(names: ["sum", "∑"], evaluator: { state throws -> Double in
        guard state.arguments.count > 0 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        var value = 0.0
        for arg in state.arguments {
            value += try state.evaluator.evaluate(arg, substitutions: state.substitutions)
        }
        return value
    })
    
    public static let product = Function(names: ["product", "∏"], evaluator: { state throws -> Double in
        guard state.arguments.count > 0 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        var value = 1.0
        for arg in state.arguments {
            value *= try state.evaluator.evaluate(arg, substitutions: state.substitutions)
        }
        return value
    })
    
    public static let count = Function(name: "count", evaluator: { state throws -> Double in
        return Double(state.arguments.count)
    })
    
    public static let min = Function(name: "min", evaluator: { state throws -> Double in
        guard state.arguments.count > 0 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        var value = DBL_MAX
        for arg in state.arguments {
            let argValue = try state.evaluator.evaluate(arg, substitutions: state.substitutions)
            value = Swift.min(value, argValue)
        }
        return value
    })
    
    public static let max = Function(name: "max", evaluator: { state throws -> Double in
        guard state.arguments.count > 0 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        var value = DBL_MIN
        for arg in state.arguments {
            let argValue = try state.evaluator.evaluate(arg, substitutions: state.substitutions)
            value = Swift.max(value, argValue)
        }
        return value
    })
    
    public static let median = Function(name: "median", evaluator: { state throws -> Double in
        guard state.arguments.count >= 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        var evaluated = Array<Double>()
        for arg in state.arguments {
            evaluated.append(try state.evaluator.evaluate(arg, substitutions: state.substitutions))
        }
        if evaluated.count % 2 == 1 {
            let index = evaluated.count / 2
            return evaluated[index]
        } else {
            let highIndex = evaluated.count / 2
            let lowIndex = highIndex - 1
            
            return Double((evaluated[highIndex] + evaluated[lowIndex]) / 2)
        }
    })
    
    public static let stddev = Function(name: "stddev", evaluator: { state throws -> Double in
        guard state.arguments.count >= 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let avg = try average.evaluator(state)
        
        var stddev = 0.0
        for arg in state.arguments {
            let value = try state.evaluator.evaluate(arg, substitutions: state.substitutions)
            let diff = avg - value
            stddev += (diff * diff)
        }
        
        return Darwin.sqrt(stddev / Double(state.arguments.count))
    })
    
    public static let ceil = Function(name: "ceil", evaluator: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        return Darwin.ceil(arg1)
    })
    
    public static let floor = Function(names: ["floor", "trunc"], evaluator: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        return Darwin.floor(arg1)
    })
    
    // MARK: - Trigonometric functions
    
    public static let sin = Function(name: "sin", evaluator: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        return Darwin.sin(Function._dtor(arg1, evaluator: state.evaluator))
    })
    
    public static let cos = Function(name: "cos", evaluator: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        return Darwin.cos(Function._dtor(arg1, evaluator: state.evaluator))
    })
    
    public static let tan = Function(name: "tan", evaluator: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        return Darwin.tan(Function._dtor(arg1, evaluator: state.evaluator))
    })
    
    public static let asin = Function(name: "asin", evaluator: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        return Function._rtod(Darwin.asin(arg1), evaluator: state.evaluator)
    })
    
    public static let acos = Function(name: "acos", evaluator: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        return Function._rtod(Darwin.acos(arg1), evaluator: state.evaluator)
    })
    
    public static let atan = Function(name: "atan", evaluator: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        return Function._rtod(Darwin.atan(arg1), evaluator: state.evaluator)
    })
    
    public static let atan2 = Function(name: "atan2", evaluator: { state throws -> Double in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        let arg2 = try state.evaluator.evaluate(state.arguments[1], substitutions: state.substitutions)
        return Function._rtod(Darwin.atan2(arg1, arg2), evaluator: state.evaluator)
    })
    
    public static let csc = Function(name: "csc", evaluator: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        let sinArg = Darwin.sin(Function._dtor(arg1, evaluator: state.evaluator))
        guard sinArg != 0 else { throw MathParserError(kind: .divideByZero, range: state.expressionRange) }
        return 1.0 / sinArg
    })
    
    public static let sec = Function(name: "sec", evaluator: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        let sinArg = Darwin.cos(Function._dtor(arg1, evaluator: state.evaluator))
        guard sinArg != 0 else { throw MathParserError(kind: .divideByZero, range: state.expressionRange) }
        return 1.0 / sinArg
    })
    
    public static let cotan = Function(name: "cotan", evaluator: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        let sinArg = Darwin.tan(Function._dtor(arg1, evaluator: state.evaluator))
        guard sinArg != 0 else { throw MathParserError(kind: .divideByZero, range: state.expressionRange) }
        return 1.0 / sinArg
    })
    
    public static let acsc = Function(name: "acsc", evaluator: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        guard arg1 != 0 else { throw MathParserError(kind: .divideByZero, range: state.expressionRange) }
        return Function._rtod(Darwin.asin(1.0 / arg1), evaluator: state.evaluator)
    })
    
    public static let asec = Function(name: "asec", evaluator: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        guard arg1 != 0 else { throw MathParserError(kind: .divideByZero, range: state.expressionRange) }
        return Function._rtod(Darwin.acos(1.0 / arg1), evaluator: state.evaluator)
    })
    
    public static let acotan = Function(name: "acotan", evaluator: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        guard arg1 != 0 else { throw MathParserError(kind: .divideByZero, range: state.expressionRange) }
        return Function._rtod(Darwin.atan(1.0 / arg1), evaluator: state.evaluator)
    })
    
    // MARK: - Hyperbolic trigonometric functions
    
    public static let sinh = Function(name: "sinh", evaluator: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        return Darwin.sinh(arg1)
    })
    
    public static let cosh = Function(name: "cosh", evaluator: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        return Darwin.cosh(arg1)
    })
    
    public static let tanh = Function(name: "tanh", evaluator: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        return Darwin.tanh(arg1)
    })
    
    public static let asinh = Function(name: "asinh", evaluator: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        return Darwin.asinh(arg1)
    })
    
    public static let acosh = Function(name: "acosh", evaluator: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        return Darwin.acosh(arg1)
    })
    
    public static let atanh = Function(name: "atanh", evaluator: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        return Darwin.atanh(arg1)
    })
    
    public static let csch = Function(name: "csch", evaluator: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        let sinArg = Darwin.sinh(arg1)
        guard sinArg != 0 else { throw MathParserError(kind: .divideByZero, range: state.expressionRange) }
        return 1.0 / sinArg
    })
    
    public static let sech = Function(name: "sech", evaluator: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        let sinArg = Darwin.cosh(arg1)
        guard sinArg != 0 else { throw MathParserError(kind: .divideByZero, range: state.expressionRange) }
        return 1.0 / sinArg
    })
    
    public static let cotanh = Function(name: "cotanh", evaluator: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        let sinArg = Darwin.tanh(arg1)
        guard sinArg != 0 else { throw MathParserError(kind: .divideByZero, range: state.expressionRange) }
        return 1.0 / sinArg
    })
    
    public static let acsch = Function(name: "acsch", evaluator: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        guard arg1 != 0 else { throw MathParserError(kind: .divideByZero, range: state.expressionRange) }
        return Darwin.asinh(1.0 / arg1)
    })
    
    public static let asech = Function(name: "asech", evaluator: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        guard arg1 != 0 else { throw MathParserError(kind: .divideByZero, range: state.expressionRange) }
        return Darwin.acosh(1.0 / arg1)
    })
    
    public static let acotanh = Function(name: "acotanh", evaluator: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        guard arg1 != 0 else { throw MathParserError(kind: .divideByZero, range: state.expressionRange) }
        return Darwin.atanh(1.0 / arg1)
    })
    
    // MARK: - Geometric functions
    
    public static let versin = Function(names: ["versin", "vers", "ver"], evaluator: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        return 1.0 - Darwin.cos(Function._dtor(arg1, evaluator: state.evaluator))
    })
    
    public static let vercosin = Function(names: ["vercosin", "vercos"], evaluator: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        return 1.0 + Darwin.cos(Function._dtor(arg1, evaluator: state.evaluator))
    })
    
    public static let coversin = Function(names: ["coversin", "cvs"], evaluator: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        return 1.0 - Darwin.sin(Function._dtor(arg1, evaluator: state.evaluator))
    })
    
    public static let covercosin = Function(name: "covercosin", evaluator: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        return 1.0 + Darwin.sin(Function._dtor(arg1, evaluator: state.evaluator))
    })
    
    public static let haversin = Function(name: "haversin", evaluator: { state throws -> Double in
        return try versin.evaluator(state) / 2.0
    })
    
    public static let havercosin = Function(name: "havercosin", evaluator: { state throws -> Double in
        return try vercosin.evaluator(state) / 2.0
    })
    
    public static let hacoversin = Function(name: "hacoversin", evaluator: { state throws -> Double in
        return try coversin.evaluator(state) / 2.0
    })
    
    public static let hacovercosin = Function(name: "hacovercosin", evaluator: { state throws -> Double in
        return try covercosin.evaluator(state) / 2.0
    })
    
    public static let exsec = Function(name: "exsec", evaluator: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        let cosArg1 = Darwin.cos(Function._dtor(arg1, evaluator: state.evaluator))
        guard cosArg1 != 0 else { throw MathParserError(kind: .divideByZero, range: state.expressionRange) }
        return (1.0/cosArg1) - 1.0
    })
    
    public static let excsc = Function(name: "excsc", evaluator: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        let sinArg1 = Darwin.sin(Function._dtor(arg1, evaluator: state.evaluator))
        guard sinArg1 != 0 else { throw MathParserError(kind: .divideByZero, range: state.expressionRange) }
        return (1.0/sinArg1) - 1.0
    })
    
    public static let crd = Function(names: ["crd", "chord"], evaluator: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        let sinArg1 = Darwin.sin(Function._dtor(arg1, evaluator: state.evaluator) / 2.0)
        return 2 * sinArg1
    })
    
    public static let dtor = Function(name: "dtor", evaluator: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        return arg1 / 180.0 * M_PI
    })
    
    public static let rtod = Function(name: "rtod", evaluator: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        return arg1 / M_PI * 180
    })
    
    // MARK: - Constant functions
    
    public static let `true` = Function(names: ["true", "yes"], evaluator: { state throws -> Double in
        guard state.arguments.count == 0 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        return 1.0
    })
    
    public static let `false` = Function(names: ["false", "no"], evaluator: { state throws -> Double in
        guard state.arguments.count == 0 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        return 0.0
    })
    
    public static let phi = Function(names: ["phi", "ϕ"], evaluator: { state throws -> Double in
        guard state.arguments.count == 0 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        return 1.6180339887498948
    })
    
    public static let pi = Function(names: ["pi", "π", "tau_2"], evaluator: { state throws -> Double in
        guard state.arguments.count == 0 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        return M_PI
    })
    
    public static let pi_2 = Function(names: ["pi_2", "tau_4"], evaluator: { state throws -> Double in
        guard state.arguments.count == 0 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        return M_PI_2
    })
    
    public static let pi_4 = Function(names: ["pi_4", "tau_8"], evaluator: { state throws -> Double in
        guard state.arguments.count == 0 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        return M_PI_4
    })
    
    public static let tau = Function(names: ["tau", "τ"], evaluator: { state throws -> Double in
        guard state.arguments.count == 0 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        return 2 * M_PI
    })
    
    public static let sqrt2 = Function(name: "sqrt2", evaluator: { state throws -> Double in
        guard state.arguments.count == 0 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        return M_SQRT2
    })
    
    public static let e = Function(name: "e", evaluator: { state throws -> Double in
        guard state.arguments.count == 0 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        return M_E
    })
    
    public static let log2e = Function(name: "log2e", evaluator: { state throws -> Double in
        guard state.arguments.count == 0 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        return M_LOG2E
    })
    
    public static let log10e = Function(name: "log10e", evaluator: { state throws -> Double in
        guard state.arguments.count == 0 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        return M_LOG10E
    })
    
    public static let ln2 = Function(name: "ln2", evaluator: { state throws -> Double in
        guard state.arguments.count == 0 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        return M_LN2
    })
    
    public static let ln10 = Function(name: "ln10", evaluator: { state throws -> Double in
        guard state.arguments.count == 0 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        return M_LN10
    })
    
    // MARK: - Logical Functions
    
    public static let l_and = Function(name: "l_and", evaluator: { state throws -> Double in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        let arg2 = try state.evaluator.evaluate(state.arguments[1], substitutions: state.substitutions)
        return (arg1 != 0 && arg2 != 0) ? 1.0 : 0.0
    })
    
    public static let l_or = Function(name: "l_or", evaluator: { state throws -> Double in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        let arg2 = try state.evaluator.evaluate(state.arguments[1], substitutions: state.substitutions)
        return (arg1 != 0 || arg2 != 0) ? 1.0 : 0.0
    })
    
    public static let l_not = Function(name: "l_not", evaluator: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        return (arg1 == 0) ? 1.0 : 0.0
    })
    
    public static let l_eq = Function(name: "l_eq", evaluator: { state throws -> Double in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        let arg2 = try state.evaluator.evaluate(state.arguments[1], substitutions: state.substitutions)
        return (arg1 == arg2) ? 1.0 : 0.0
    })
    
    public static let l_neq = Function(name: "l_neq", evaluator: { state throws -> Double in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        let arg2 = try state.evaluator.evaluate(state.arguments[1], substitutions: state.substitutions)
        return (arg1 != arg2) ? 1.0 : 0.0
    })
    
    public static let l_lt = Function(name: "l_lt", evaluator: { state throws -> Double in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        let arg2 = try state.evaluator.evaluate(state.arguments[1], substitutions: state.substitutions)
        return (arg1 < arg2) ? 1.0 : 0.0
    })
    
    public static let l_gt = Function(name: "l_gt", evaluator: { state throws -> Double in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        let arg2 = try state.evaluator.evaluate(state.arguments[1], substitutions: state.substitutions)
        return (arg1 > arg2) ? 1.0 : 0.0
    })
    
    public static let l_ltoe = Function(name: "l_ltoe", evaluator: { state throws -> Double in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        let arg2 = try state.evaluator.evaluate(state.arguments[1], substitutions: state.substitutions)
        return (arg1 <= arg2) ? 1.0 : 0.0
    })
    
    public static let l_gtoe = Function(name: "l_gtoe", evaluator: { state throws -> Double in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        let arg2 = try state.evaluator.evaluate(state.arguments[1], substitutions: state.substitutions)
        return (arg1 >= arg2) ? 1.0 : 0.0
    })
    
    public static let l_if = Function(names: ["l_if", "if"], evaluator: { state throws -> Double in
        guard state.arguments.count == 3 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        
        if arg1 != 0 {
            return try state.evaluator.evaluate(state.arguments[1], substitutions: state.substitutions)
        } else {
            return try state.evaluator.evaluate(state.arguments[2], substitutions: state.substitutions)
        }
    })
    

}
