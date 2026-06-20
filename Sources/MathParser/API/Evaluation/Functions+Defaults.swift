//
//  StandardFunctions.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/20/15.
//
//

import Foundation

extension Function {
    
    // MARK: - Angle mode helpers
    
    public static func dtor(_ d: Double, mode: Evaluator.AngleMode) -> Double {
        guard mode == .degrees else { return d }
        return d / 180 * Double.pi
    }
    
    public static func rtod(_ d: Double, mode: Evaluator.AngleMode) -> Double {
        guard mode == .degrees else { return d }
        return d / Double.pi * 180
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
    
    public static let add = Function(name: "add", body: { state throws -> Double in
        guard state.arguments.count == 2 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluate(argument: 0)
        let arg2 = try state.evaluate(argument: 1)
        return arg1 + arg2
    })
    
    public static let subtract = Function(name: "subtract", body: { state throws -> Double in
        guard state.arguments.count == 2 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluate(argument: 0)
        let arg2 = try state.evaluate(argument: 1)
        return arg1 - arg2
    })
    
    public static let multiply = Function(names: ["multiply", "implicitmultiply"], body: { state throws -> Double in
        guard state.arguments.count == 2 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluate(argument: 0)
        let arg2 = try state.evaluate(argument: 1)
        return arg1 * arg2
    })
    
    public static let divide = Function(name: "divide", body: { state throws -> Double in
        guard state.arguments.count == 2 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluate(argument: 0)
        let arg2 = try state.evaluate(argument: 1)
        
        guard arg2 != 0 else { throw MathParserError(code: .divideByZero, range: state.expressionRange) }
        return arg1 / arg2
    })
    
    public static let mod = Function(names: ["mod", "modulo"], body: { state throws -> Double in
        guard state.arguments.count == 2 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluate(argument: 0)
        let arg2 = try state.evaluate(argument: 1)
        
        return fmod(arg1, arg2)
    })
    
    public static let negate = Function(name: "negate", body: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluate(argument: 0)
        
        return -arg1
    })
    
    public static let factorial = Function(name: "factorial", body: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluate(argument: 0)
        return arg1.factorial()
    })
    
    public static let factorial2 = Function(name: "factorial2", body: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluate(argument: 0)
        guard arg1 >= 1 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        guard arg1 == Darwin.floor(arg1) else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        if arg1.truncatingRemainder(dividingBy: 2) == 0 {
            let k = arg1 / 2
            return Darwin.pow(2, k) * k.factorial()
        } else {
            let k = (arg1 + 1) / 2
            
            let numerator = (2*k).factorial()
            let denominator = Darwin.pow(2, k) * k.factorial()
            
            guard denominator != 0 else { throw MathParserError(code: .divideByZero, range: state.expressionRange) }
            return numerator / denominator
        }
    })
    
    public static let pow = Function(name: "pow", body: { state throws -> Double in
        guard state.arguments.count == 2 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluate(argument: 0)
        let arg2 = try state.evaluate(argument: 1)
        
        return Darwin.pow(arg1, arg2)
    })
    
    public static let sqrt = Function(name: "sqrt", body: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let value = try state.evaluate(argument: 0)
        
        return Darwin.sqrt(value)
    })
    
    public static let cuberoot = Function(name: "cuberoot", body: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluate(argument: 0)
        
        if arg1 < 0 {
            let root = Darwin.pow(-arg1, 1.0/3.0)
            return -root
        } else {
            return Darwin.pow(arg1, 1.0/3.0)
        }
    })
    
    public static let nthroot = Function(name: "nthroot", body: { state throws -> Double in
        guard state.arguments.count == 2 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluate(argument: 0)
        let arg2 = try state.evaluate(argument: 1)
        
        guard arg2 != 0 else { throw MathParserError(code: .divideByZero, range: state.expressionRange) }
        
        if arg1 < 0 && arg2.truncatingRemainder(dividingBy: 2) == 1 {
            // for negative numbers with an odd root, the result will be negative
            let root = Darwin.pow(-arg1, 1/arg2)
            return -root
        } else {
            return Darwin.pow(arg1, 1/arg2)
        }
    })
    
    public static let random = Function(name: "random", body: { state throws -> Double in
        guard state.arguments.count <= 2 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        var argValues = try (0 ..< state.argumentCount).map {
            try state.evaluate(argument: $0)
        }
        var lowerBound = 0.0
        var upperBound = 1.0
        switch argValues.count {
        case 1:
            upperBound = argValues[0]
        case 2:
            lowerBound = argValues[0]
            upperBound = argValues[1]
        default:
            break
        }
        
        guard lowerBound < upperBound else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let range = upperBound - lowerBound
        
        return drand48() * range + lowerBound
    })
    
    public static let log = Function(name: "log", body: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluate(argument: 0)
        return Darwin.log10(arg1)
    })
    
    public static let ln = Function(name: "ln", body: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluate(argument: 0)
        return Darwin.log(arg1)
    })
    
    public static let log2 = Function(name: "log2", body: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluate(argument: 0)
        return Darwin.log2(arg1)
    })
    
    public static let exp = Function(name: "exp", body: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluate(argument: 0)
        return Darwin.exp(arg1)
    })
    
    public static let abs = Function(name: "abs", body: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluate(argument: 0)
        return Swift.abs(arg1)
    })
    
    public static let percent = Function(name: "percent", body: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let percentArgument = state.arguments[0]
        let percentValue = try state.evaluate(argument: 0)
        let percent = percentValue / 100
        
        let percentContext = state.parentExpression
        guard let parentState = state.parentState else { return percent }
        
        guard let contextKind = percentContext?.kind else { return percent }
        guard case let .function(f, contextArgs) = contextKind else { return percent }
        
        // must be XXXX + n% or XXXX - n%
        guard let builtIn = Operator.builtinOperator(f), builtIn == .add || builtIn == .minus else { return percent }
        
        // cannot be n% + XXXX or n% - XXXX
        guard contextArgs[1] == state.currentExpression else { return percent }
        
        let context = try parentState.evaluate(argument: 0)
        
        return context * percent
    })
    
    // MARK: - Bitwise functions
    
    public static let and = Function(name: "and", body: { state throws -> Double in
        guard state.arguments.count == 2 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluate(argument: 0)
        let arg2 = try state.evaluate(argument: 1)
        
        return Double(Int(arg1) & Int(arg2))
    })
    
    public static let or = Function(name: "or", body: { state throws -> Double in
        guard state.arguments.count == 2 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluate(argument: 0)
        let arg2 = try state.evaluate(argument: 1)
        
        return Double(Int(arg1) | Int(arg2))
    })
    
    public static let not = Function(name: "not", body: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluate(argument: 0)
        
        return Double(~Int(arg1))
    })
    
    public static let xor = Function(name: "xor", body: { state throws -> Double in
        guard state.arguments.count == 2 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluate(argument: 0)
        let arg2 = try state.evaluate(argument: 1)
        
        return Double(Int(arg1) ^ Int(arg2))
    })
    
    public static let rshift = Function(name: "rshift", body: { state throws -> Double in
        guard state.arguments.count == 2 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluate(argument: 0)
        let arg2 = try state.evaluate(argument: 1)
        
        return Double(Int(arg1) >> Int(arg2))
    })
    
    public static let lshift = Function(name: "lshift", body: { state throws -> Double in
        guard state.arguments.count == 2 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluate(argument: 0)
        let arg2 = try state.evaluate(argument: 1)
        
        return Double(Int(arg1) << Int(arg2))
    })
    
    // MARK: - Aggregate functions
    
    public static let average = Function(names: ["average", "avg", "mean"], body: { state throws -> Double in
        guard state.arguments.count > 0 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let value = try sum.body(state)
        
        return value / Double(state.arguments.count)
    })
    
    public static let sum = Function(names: ["sum", "∑"], body: { state throws -> Double in
        guard state.arguments.count > 0 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        var value = 0.0
        for arg in 0 ..< state.argumentCount {
            value += try state.evaluate(argument: arg)
        }
        return value
    })
    
    public static let product = Function(names: ["product", "∏"], body: { state throws -> Double in
        guard state.arguments.count > 0 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        var value = 1.0
        for arg in 0 ..< state.argumentCount {
            value *= try state.evaluate(argument: arg)
        }
        return value
    })
    
    public static let count = Function(name: "count", body: { state throws -> Double in
        return Double(state.arguments.count)
    })
    
    public static let min = Function(name: "min", body: { state throws -> Double in
        guard state.arguments.count > 0 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        var value = Double.greatestFiniteMagnitude
        for arg in 0 ..< state.argumentCount {
            let argValue = try state.evaluate(argument: arg)
            value = Swift.min(value, argValue)
        }
        return value
    })
    
    public static let max = Function(name: "max", body: { state throws -> Double in
        guard state.arguments.count > 0 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        var value = Double.leastNormalMagnitude
        for arg in 0 ..< state.argumentCount {
            let argValue = try state.evaluate(argument: arg)
            value = Swift.max(value, argValue)
        }
        return value
    })
    
    public static let median = Function(name: "median", body: { state throws -> Double in
        guard state.arguments.count >= 2 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let evaluated = try (0 ..< state.argumentCount).map {
            try state.evaluate(argument: $0)
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
    
    public static let stddev = Function(name: "stddev", body: { state throws -> Double in
        guard state.arguments.count >= 2 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let avg = try average.body(state)
        
        var stddev = 0.0
        for arg in 0 ..< state.argumentCount {
            let value = try state.evaluate(argument: arg)
            let diff = avg - value
            stddev += (diff * diff)
        }
        
        return Darwin.sqrt(stddev / Double(state.arguments.count))
    })
    
    public static let ceil = Function(name: "ceil", body: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluate(argument: 0)
        return Darwin.ceil(arg1)
    })
    
    public static let floor = Function(names: ["floor", "trunc"], body: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluate(argument: 0)
        return Darwin.floor(arg1)
    })
    
    // MARK: - Trigonometric functions
    
    public static let sin = Function(name: "sin", body: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluate(argument: 0)
        return Darwin.sin(Function.dtor(arg1, mode: state.angleMeasurementMode))
    })
    
    public static let cos = Function(name: "cos", body: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluate(argument: 0)
        return Darwin.cos(Function.dtor(arg1, mode: state.angleMeasurementMode))
    })
    
    public static let tan = Function(name: "tan", body: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluate(argument: 0)
        return Darwin.tan(Function.dtor(arg1, mode: state.angleMeasurementMode))
    })
    
    public static let asin = Function(names: ["asin", "sin⁻¹"], body: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluate(argument: 0)
        return Function.rtod(Darwin.asin(arg1), mode: state.angleMeasurementMode)
    })
    
    public static let acos = Function(names: ["acos", "cos⁻¹"], body: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluate(argument: 0)
        return Function.rtod(Darwin.acos(arg1), mode: state.angleMeasurementMode)
    })
    
    public static let atan = Function(names: ["atan", "tan⁻¹"], body: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluate(argument: 0)
        return Function.rtod(Darwin.atan(arg1), mode: state.angleMeasurementMode)
    })
    
    public static let atan2 = Function(name: "atan2", body: { state throws -> Double in
        guard state.arguments.count == 2 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluate(argument: 0)
        let arg2 = try state.evaluate(argument: 1)
        return Function.rtod(Darwin.atan2(arg1, arg2), mode: state.angleMeasurementMode)
    })
    
    public static let csc = Function(name: "csc", body: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluate(argument: 0)
        let sinArg = Darwin.sin(Function.dtor(arg1, mode: state.angleMeasurementMode))
        guard sinArg != 0 else { throw MathParserError(code: .divideByZero, range: state.expressionRange) }
        return 1.0 / sinArg
    })
    
    public static let sec = Function(name: "sec", body: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluate(argument: 0)
        let sinArg = Darwin.cos(Function.dtor(arg1, mode: state.angleMeasurementMode))
        guard sinArg != 0 else { throw MathParserError(code: .divideByZero, range: state.expressionRange) }
        return 1.0 / sinArg
    })
    
    public static let cotan = Function(name: "cotan", body: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluate(argument: 0)
        let sinArg = Darwin.tan(Function.dtor(arg1, mode: state.angleMeasurementMode))
        guard sinArg != 0 else { throw MathParserError(code: .divideByZero, range: state.expressionRange) }
        return 1.0 / sinArg
    })
    
    public static let acsc = Function(names: ["acsc", "csc⁻¹"], body: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluate(argument: 0)
        guard arg1 != 0 else { throw MathParserError(code: .divideByZero, range: state.expressionRange) }
        return Function.rtod(Darwin.asin(1.0 / arg1), mode: state.angleMeasurementMode)
    })
    
    public static let asec = Function(names: ["asec", "sec⁻¹"], body: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluate(argument: 0)
        guard arg1 != 0 else { throw MathParserError(code: .divideByZero, range: state.expressionRange) }
        return Function.rtod(Darwin.acos(1.0 / arg1), mode: state.angleMeasurementMode)
    })
    
    public static let acotan = Function(names: ["acotan", "cotan⁻¹"], body: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluate(argument: 0)
        guard arg1 != 0 else { throw MathParserError(code: .divideByZero, range: state.expressionRange) }
        return Function.rtod(Darwin.atan(1.0 / arg1), mode: state.angleMeasurementMode)
    })
    
    // MARK: - Hyperbolic trigonometric functions
    
    public static let sinh = Function(name: "sinh", body: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluate(argument: 0)
        return Darwin.sinh(arg1)
    })
    
    public static let cosh = Function(name: "cosh", body: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluate(argument: 0)
        return Darwin.cosh(arg1)
    })
    
    public static let tanh = Function(name: "tanh", body: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluate(argument: 0)
        return Darwin.tanh(arg1)
    })
    
    public static let asinh = Function(names: ["asinh", "sinh⁻¹"], body: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluate(argument: 0)
        return Darwin.asinh(arg1)
    })
    
    public static let acosh = Function(names: ["acosh", "cosh⁻¹"], body: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluate(argument: 0)
        return Darwin.acosh(arg1)
    })
    
    public static let atanh = Function(names: ["atanh", "tanh⁻¹"], body: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluate(argument: 0)
        return Darwin.atanh(arg1)
    })
    
    public static let csch = Function(name: "csch", body: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluate(argument: 0)
        let sinArg = Darwin.sinh(arg1)
        guard sinArg != 0 else { throw MathParserError(code: .divideByZero, range: state.expressionRange) }
        return 1.0 / sinArg
    })
    
    public static let sech = Function(name: "sech", body: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluate(argument: 0)
        let sinArg = Darwin.cosh(arg1)
        guard sinArg != 0 else { throw MathParserError(code: .divideByZero, range: state.expressionRange) }
        return 1.0 / sinArg
    })
    
    public static let cotanh = Function(name: "cotanh", body: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluate(argument: 0)
        let sinArg = Darwin.tanh(arg1)
        guard sinArg != 0 else { throw MathParserError(code: .divideByZero, range: state.expressionRange) }
        return 1.0 / sinArg
    })
    
    public static let acsch = Function(names: ["acsch", "csch⁻¹"], body: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluate(argument: 0)
        guard arg1 != 0 else { throw MathParserError(code: .divideByZero, range: state.expressionRange) }
        return Darwin.asinh(1.0 / arg1)
    })
    
    public static let asech = Function(names: ["asech", "sech⁻¹"], body: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluate(argument: 0)
        guard arg1 != 0 else { throw MathParserError(code: .divideByZero, range: state.expressionRange) }
        return Darwin.acosh(1.0 / arg1)
    })
    
    public static let acotanh = Function(names: ["acotanh", "cotanh⁻¹"], body: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluate(argument: 0)
        guard arg1 != 0 else { throw MathParserError(code: .divideByZero, range: state.expressionRange) }
        return Darwin.atanh(1.0 / arg1)
    })
    
    // MARK: - Geometric functions
    
    public static let versin = Function(names: ["versin", "vers", "ver"], body: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluate(argument: 0)
        return 1.0 - Darwin.cos(Function.dtor(arg1, mode: state.angleMeasurementMode))
    })
    
    public static let vercosin = Function(names: ["vercosin", "vercos"], body: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluate(argument: 0)
        return 1.0 + Darwin.cos(Function.dtor(arg1, mode: state.angleMeasurementMode))
    })
    
    public static let coversin = Function(names: ["coversin", "cvs"], body: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluate(argument: 0)
        return 1.0 - Darwin.sin(Function.dtor(arg1, mode: state.angleMeasurementMode))
    })
    
    public static let covercosin = Function(name: "covercosin", body: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluate(argument: 0)
        return 1.0 + Darwin.sin(Function.dtor(arg1, mode: state.angleMeasurementMode))
    })
    
    public static let haversin = Function(name: "haversin", body: { state throws -> Double in
        return try versin.body(state) / 2.0
    })
    
    public static let havercosin = Function(name: "havercosin", body: { state throws -> Double in
        return try vercosin.body(state) / 2.0
    })
    
    public static let hacoversin = Function(name: "hacoversin", body: { state throws -> Double in
        return try coversin.body(state) / 2.0
    })
    
    public static let hacovercosin = Function(name: "hacovercosin", body: { state throws -> Double in
        return try covercosin.body(state) / 2.0
    })
    
    public static let exsec = Function(name: "exsec", body: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluate(argument: 0)
        let cosArg1 = Darwin.cos(Function.dtor(arg1, mode: state.angleMeasurementMode))
        guard cosArg1 != 0 else { throw MathParserError(code: .divideByZero, range: state.expressionRange) }
        return (1.0/cosArg1) - 1.0
    })
    
    public static let excsc = Function(name: "excsc", body: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluate(argument: 0)
        let sinArg1 = Darwin.sin(Function.dtor(arg1, mode: state.angleMeasurementMode))
        guard sinArg1 != 0 else { throw MathParserError(code: .divideByZero, range: state.expressionRange) }
        return (1.0/sinArg1) - 1.0
    })
    
    public static let crd = Function(names: ["crd", "chord"], body: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluate(argument: 0)
        let sinArg1 = Darwin.sin(Function.dtor(arg1, mode: state.angleMeasurementMode) / 2.0)
        return 2 * sinArg1
    })
    
    public static let dtor = Function(name: "dtor", body: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluate(argument: 0)
        return arg1 / 180.0 * Double.pi
    })
    
    public static let rtod = Function(name: "rtod", body: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluate(argument: 0)
        return arg1 / Double.pi * 180
    })
    
    // MARK: - Constant functions
    
    public static let `true` = Function(names: ["true", "yes"], body: { state throws -> Double in
        guard state.arguments.count == 0 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        return 1.0
    })
    
    public static let `false` = Function(names: ["false", "no"], body: { state throws -> Double in
        guard state.arguments.count == 0 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        return 0.0
    })
    
    public static let phi = Function(names: ["phi", "ϕ"], body: { state throws -> Double in
        guard state.arguments.count == 0 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        return 1.6180339887498948
    })
    
    public static let pi = Function(names: ["pi", "π", "tau_2"], body: { state throws -> Double in
        guard state.arguments.count == 0 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        return Double.pi
    })
    
    public static let pi_2 = Function(names: ["pi_2", "tau_4"], body: { state throws -> Double in
        guard state.arguments.count == 0 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        return Double.pi / 2
    })
    
    public static let pi_4 = Function(names: ["pi_4", "tau_8"], body: { state throws -> Double in
        guard state.arguments.count == 0 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        return Double.pi / 4
    })
    
    public static let tau = Function(names: ["tau", "τ"], body: { state throws -> Double in
        guard state.arguments.count == 0 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        return 2 * Double.pi
    })
    
    public static let sqrt2 = Function(name: "sqrt2", body: { state throws -> Double in
        guard state.arguments.count == 0 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        return 2.squareRoot()
    })
    
    public static let e = Function(name: "e", body: { state throws -> Double in
        guard state.arguments.count == 0 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        return M_E
    })
    
    public static let log2e = Function(name: "log2e", body: { state throws -> Double in
        guard state.arguments.count == 0 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        return M_LOG2E
    })
    
    public static let log10e = Function(name: "log10e", body: { state throws -> Double in
        guard state.arguments.count == 0 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        return M_LOG10E
    })
    
    public static let ln2 = Function(name: "ln2", body: { state throws -> Double in
        guard state.arguments.count == 0 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        return M_LN2
    })
    
    public static let ln10 = Function(name: "ln10", body: { state throws -> Double in
        guard state.arguments.count == 0 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        return M_LN10
    })
    
    // MARK: - Logical Functions
    
    public static let l_and = Function(name: "l_and", body: { state throws -> Double in
        guard state.arguments.count == 2 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluate(argument: 0)
        let arg2 = try state.evaluate(argument: 1)
        return (arg1 != 0 && arg2 != 0) ? 1.0 : 0.0
    })
    
    public static let l_or = Function(name: "l_or", body: { state throws -> Double in
        guard state.arguments.count == 2 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluate(argument: 0)
        let arg2 = try state.evaluate(argument: 1)
        return (arg1 != 0 || arg2 != 0) ? 1.0 : 0.0
    })
    
    public static let l_not = Function(name: "l_not", body: { state throws -> Double in
        guard state.arguments.count == 1 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluate(argument: 0)
        return (arg1 == 0) ? 1.0 : 0.0
    })
    
    public static let l_eq = Function(name: "l_eq", body: { state throws -> Double in
        guard state.arguments.count == 2 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluate(argument: 0)
        let arg2 = try state.evaluate(argument: 1)
        return (arg1 == arg2) ? 1.0 : 0.0
    })
    
    public static let l_neq = Function(name: "l_neq", body: { state throws -> Double in
        guard state.arguments.count == 2 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluate(argument: 0)
        let arg2 = try state.evaluate(argument: 1)
        return (arg1 != arg2) ? 1.0 : 0.0
    })
    
    public static let l_lt = Function(name: "l_lt", body: { state throws -> Double in
        guard state.arguments.count == 2 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluate(argument: 0)
        let arg2 = try state.evaluate(argument: 1)
        return (arg1 < arg2) ? 1.0 : 0.0
    })
    
    public static let l_gt = Function(name: "l_gt", body: { state throws -> Double in
        guard state.arguments.count == 2 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluate(argument: 0)
        let arg2 = try state.evaluate(argument: 1)
        return (arg1 > arg2) ? 1.0 : 0.0
    })
    
    public static let l_ltoe = Function(name: "l_ltoe", body: { state throws -> Double in
        guard state.arguments.count == 2 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluate(argument: 0)
        let arg2 = try state.evaluate(argument: 1)
        return (arg1 <= arg2) ? 1.0 : 0.0
    })
    
    public static let l_gtoe = Function(name: "l_gtoe", body: { state throws -> Double in
        guard state.arguments.count == 2 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluate(argument: 0)
        let arg2 = try state.evaluate(argument: 1)
        return (arg1 >= arg2) ? 1.0 : 0.0
    })
    
    public static let l_if = Function(names: ["l_if", "if"], body: { state throws -> Double in
        guard state.arguments.count == 3 else { throw MathParserError(code: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluate(argument: 0)
        
        if arg1 != 0 {
            return try state.evaluate(argument: 1)
        } else {
            return try state.evaluate(argument: 2)
        }
    })

}
