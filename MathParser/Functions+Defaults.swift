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
            i++
        }
        return i - 1
    }()
    
    // MARK: - Angle mode helpers
    
    internal static func _dtor(d: Double, evaluator: Evaluator) -> Double {
        guard evaluator.angleMeasurementMode == .Degrees else { return d }
        return d / 180 * M_PI
    }
    
    internal static func _rtod(d: Double, evaluator: Evaluator) -> Double {
        guard evaluator.angleMeasurementMode == .Degrees else { return d }
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
    
    public static let add = Function(name: "add", evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 2 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        let arg2 = try evaluator.evaluate(args[1], substitutions: substitutions)
        return arg1 + arg2
    })
    
    public static let subtract = Function(name: "subtract", evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 2 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        let arg2 = try evaluator.evaluate(args[1], substitutions: substitutions)
        return arg1 - arg2
    })
    
    public static let multiply = Function(names: ["multiply", "implicitmultiply"], evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 2 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        let arg2 = try evaluator.evaluate(args[1], substitutions: substitutions)
        return arg1 * arg2
    })
    
    public static let divide = Function(name: "divide", evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 2 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        let arg2 = try evaluator.evaluate(args[1], substitutions: substitutions)
        
        guard arg2 != 0 else { throw EvaluationError.DivideByZero }
        return arg1 / arg2
    })
    
    public static let mod = Function(names: ["mod", "modulo"], evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 2 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        let arg2 = try evaluator.evaluate(args[1], substitutions: substitutions)
        
        return fmod(arg1, arg2)
    })
    
    public static let negate = Function(name: "negate", evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        
        return -arg1
    })
    
    public static let factorial = Function(name: "factorial", evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        return arg1.factorial()
    })
    
    public static let factorial2 = Function(name: "factorial2", evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        guard arg1 >= 1 else { throw EvaluationError.InvalidArguments }
        guard arg1 == Darwin.floor(arg1) else { throw EvaluationError.InvalidArguments }
        
        if arg1 % 2 == 0 {
            let k = arg1 / 2
            return Darwin.pow(2, k) * k.factorial()
        } else {
            let k = (arg1 + 1) / 2
            
            let numerator = (2*k).factorial()
            let denominator = Darwin.pow(2, k) * k.factorial()
            
            guard denominator != 0 else { throw EvaluationError.DivideByZero }
            return numerator / denominator
        }
    })
    
    public static let pow = Function(name: "pow", evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 2 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        let arg2 = try evaluator.evaluate(args[1], substitutions: substitutions)
        
        return Darwin.pow(arg1, arg2)
    })
    
    public static let sqrt = Function(name: "sqrt", evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let value = try evaluator.evaluate(args[0], substitutions: substitutions)
        
        return Darwin.sqrt(value)
    })
    
    public static let cuberoot = Function(name: "cuberoot", evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        
        return Darwin.pow(arg1, 1.0/3.0)
    })
    
    public static let nthroot = Function(name: "nthroot", evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 2 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        let arg2 = try evaluator.evaluate(args[1], substitutions: substitutions)
        
        guard arg2 != 0 else { throw EvaluationError.DivideByZero }
        
        if arg1 < 0 && arg2 % 2 == 1 {
            // for negative numbers with an odd root, the result will be negative
            let root = Darwin.pow(-arg1, 1/arg2)
            return -root
        } else {
            return Darwin.pow(arg1, 1/arg2)
        }
    })
    
    public static let random = Function(name: "random", evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count <= 2 else { throw EvaluationError.InvalidArguments }
        
        var argValues = Array<Double>()
        for arg in args {
            let argValue = try evaluator.evaluate(arg, substitutions: substitutions)
            argValues.append(argValue)
        }
        
        let lowerBound = argValues.count > 0 ? argValues[0] : DBL_MIN
        let upperBound = argValues.count > 1 ? argValues[1] : DBL_MAX
        
        guard lowerBound < upperBound else { throw EvaluationError.InvalidArguments }
        
        let range = upperBound - lowerBound
        
        return (drand48() % range) + lowerBound
    })
    
    public static let log = Function(name: "log", evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        return Darwin.log10(arg1)
    })
    
    public static let ln = Function(name: "ln", evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        return Darwin.log(arg1)
    })
    
    public static let log2 = Function(name: "log2", evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        return Darwin.log2(arg1)
    })
    
    public static let exp = Function(name: "exp", evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        return Darwin.exp(arg1)
    })
    
    public static let abs = Function(name: "abs", evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        return Swift.abs(arg1)
    })
    
    public static let percent = Function(name: "percent", evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let percentArgument = args[0]
        let percentValue = try evaluator.evaluate(percentArgument, substitutions: substitutions)
        let percent = percentValue / 100
        
        let percentExpression = percentArgument.parent
        let percentContext = percentExpression?.parent
        
        guard let contextKind = percentContext?.kind else { return percent }
        guard case let .Function(f, contextArgs) = contextKind else { return percent }
        
        // must be XXXX + n% or XXXX - n%
        guard let builtIn = BuiltInOperator(rawValue: f) where builtIn == .Add || builtIn == .Minus else { return percent }
        
        // cannot be n% + XXXX or n% - XXXX
        guard contextArgs[1] === percentExpression else { return percent }
        
        let context = try evaluator.evaluate(contextArgs[0], substitutions: substitutions)
        
        return context * percent
    })
    
    // MARK: - Bitwise functions
    
    public static let and = Function(name: "and", evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 2 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        let arg2 = try evaluator.evaluate(args[1], substitutions: substitutions)
        
        return Double(Int(arg1) & Int(arg2))
    })
    
    public static let or = Function(name: "or", evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 2 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        let arg2 = try evaluator.evaluate(args[1], substitutions: substitutions)
        
        return Double(Int(arg1) | Int(arg2))
    })
    
    public static let not = Function(name: "not", evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        
        return Double(~Int(arg1))
    })
    
    public static let xor = Function(name: "xor", evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 2 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        let arg2 = try evaluator.evaluate(args[1], substitutions: substitutions)
        
        return Double(Int(arg1) ^ Int(arg2))
    })
    
    public static let rshift = Function(name: "rshift", evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 2 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        let arg2 = try evaluator.evaluate(args[1], substitutions: substitutions)
        
        return Double(Int(arg1) >> Int(arg2))
    })
    
    public static let lshift = Function(name: "lshift", evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 2 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        let arg2 = try evaluator.evaluate(args[1], substitutions: substitutions)
        
        return Double(Int(arg1) << Int(arg2))
    })
    
    // MARK: - Aggregate functions
    
    public static let average = Function(names: ["average", "avg", "mean"], evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count > 0 else { throw EvaluationError.InvalidArguments }
        
        let value = try sum.evaluator(args, substitutions, evaluator)
        
        return value / Double(args.count)
    })
    
    public static let sum = Function(names: ["sum", "∑"], evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count > 0 else { throw EvaluationError.InvalidArguments }
        
        var value = 0.0
        for arg in args {
            value += try evaluator.evaluate(arg, substitutions: substitutions)
        }
        return value
    })
    
    public static let product = Function(names: ["product", "∏"], evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count > 0 else { throw EvaluationError.InvalidArguments }
        
        var value = 1.0
        for arg in args {
            value *= try evaluator.evaluate(arg, substitutions: substitutions)
        }
        return value
    })
    
    public static let count = Function(name: "count", evaluator: { (args, substitutions, evaluator) throws -> Double in
        return Double(args.count)
    })
    
    public static let min = Function(name: "min", evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count > 0 else { throw EvaluationError.InvalidArguments }
        
        var value = DBL_MAX
        for arg in args {
            let argValue = try evaluator.evaluate(arg, substitutions: substitutions)
            value = Swift.min(value, argValue)
        }
        return value
    })
    
    public static let max = Function(name: "max", evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count > 0 else { throw EvaluationError.InvalidArguments }
        
        var value = DBL_MIN
        for arg in args {
            let argValue = try evaluator.evaluate(arg, substitutions: substitutions)
            value = Swift.max(value, argValue)
        }
        return value
    })
    
    public static let median = Function(name: "median", evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count >= 2 else { throw EvaluationError.InvalidArguments }
        
        var evaluated = Array<Double>()
        for arg in args {
            evaluated.append(try evaluator.evaluate(arg, substitutions: substitutions))
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
    
    public static let stddev = Function(name: "stddev", evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count >= 2 else { throw EvaluationError.InvalidArguments }
        
        let avg = try average.evaluator(args, substitutions, evaluator)
        
        var stddev = 0.0
        for arg in args {
            let value = try evaluator.evaluate(arg, substitutions: substitutions)
            let diff = avg - value
            stddev += (diff * diff)
        }
        
        return Darwin.sqrt(stddev / Double(args.count))
    })
    
    public static let ceil = Function(name: "ceil", evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        return Darwin.ceil(arg1)
    })
    
    public static let floor = Function(names: ["floor", "trunc"], evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        return Darwin.floor(arg1)
    })
    
    // MARK: - Trigonometric functions
    
    public static let sin = Function(name: "sin", evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        return Darwin.sin(Function._dtor(arg1, evaluator: evaluator))
    })
    
    public static let cos = Function(name: "cos", evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        return Darwin.cos(Function._dtor(arg1, evaluator: evaluator))
    })
    
    public static let tan = Function(name: "tan", evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        return Darwin.tan(Function._dtor(arg1, evaluator: evaluator))
    })
    
    public static let asin = Function(name: "asin", evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        return Function._rtod(Darwin.asin(arg1), evaluator: evaluator)
    })
    
    public static let acos = Function(name: "acos", evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        return Function._rtod(Darwin.acos(arg1), evaluator: evaluator)
    })
    
    public static let atan = Function(name: "atan", evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        return Function._rtod(Darwin.atan(arg1), evaluator: evaluator)
    })
    
    public static let atan2 = Function(name: "atan2", evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 2 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        let arg2 = try evaluator.evaluate(args[1], substitutions: substitutions)
        return Function._rtod(Darwin.atan2(arg1, arg2), evaluator: evaluator)
    })
    
    public static let csc = Function(name: "csc", evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        let sinArg = Darwin.sin(Function._dtor(arg1, evaluator: evaluator))
        guard sinArg != 0 else { throw EvaluationError.DivideByZero }
        return 1.0 / sinArg
    })
    
    public static let sec = Function(name: "sec", evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        let sinArg = Darwin.cos(Function._dtor(arg1, evaluator: evaluator))
        guard sinArg != 0 else { throw EvaluationError.DivideByZero }
        return 1.0 / sinArg
    })
    
    public static let cotan = Function(name: "cotan", evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        let sinArg = Darwin.tan(Function._dtor(arg1, evaluator: evaluator))
        guard sinArg != 0 else { throw EvaluationError.DivideByZero }
        return 1.0 / sinArg
    })
    
    public static let acsc = Function(name: "acsc", evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        guard arg1 != 0 else { throw EvaluationError.DivideByZero }
        return Function._rtod(Darwin.asin(1.0 / arg1), evaluator: evaluator)
    })
    
    public static let asec = Function(name: "asec", evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        guard arg1 != 0 else { throw EvaluationError.DivideByZero }
        return Function._rtod(Darwin.acos(1.0 / arg1), evaluator: evaluator)
    })
    
    public static let acotan = Function(name: "acotan", evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        guard arg1 != 0 else { throw EvaluationError.DivideByZero }
        return Function._rtod(Darwin.atan(1.0 / arg1), evaluator: evaluator)
    })
    
    // MARK: - Hyperbolic trigonometric functions
    
    public static let sinh = Function(name: "sinh", evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        return Darwin.sinh(arg1)
    })
    
    public static let cosh = Function(name: "cosh", evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        return Darwin.cosh(arg1)
    })
    
    public static let tanh = Function(name: "tanh", evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        return Darwin.tanh(arg1)
    })
    
    public static let asinh = Function(name: "asinh", evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        return Darwin.asinh(arg1)
    })
    
    public static let acosh = Function(name: "acosh", evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        return Darwin.acosh(arg1)
    })
    
    public static let atanh = Function(name: "atanh", evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        return Darwin.atanh(arg1)
    })
    
    public static let csch = Function(name: "csch", evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        let sinArg = Darwin.sinh(arg1)
        guard sinArg != 0 else { throw EvaluationError.DivideByZero }
        return 1.0 / sinArg
    })
    
    public static let sech = Function(name: "sech", evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        let sinArg = Darwin.cosh(arg1)
        guard sinArg != 0 else { throw EvaluationError.DivideByZero }
        return 1.0 / sinArg
    })
    
    public static let cotanh = Function(name: "cotanh", evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        let sinArg = Darwin.tanh(arg1)
        guard sinArg != 0 else { throw EvaluationError.DivideByZero }
        return 1.0 / sinArg
    })
    
    public static let acsch = Function(name: "acsch", evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        guard arg1 != 0 else { throw EvaluationError.DivideByZero }
        return Darwin.asinh(1.0 / arg1)
    })
    
    public static let asech = Function(name: "asech", evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        guard arg1 != 0 else { throw EvaluationError.DivideByZero }
        return Darwin.acosh(1.0 / arg1)
    })
    
    public static let acotanh = Function(name: "acotanh", evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        guard arg1 != 0 else { throw EvaluationError.DivideByZero }
        return Darwin.atanh(1.0 / arg1)
    })
    
    // MARK: - Geometric functions
    
    public static let versin = Function(names: ["versin", "vers", "ver"], evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        return 1.0 - Darwin.cos(Function._dtor(arg1, evaluator: evaluator))
    })
    
    public static let vercosin = Function(names: ["vercosin", "vercos"], evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        return 1.0 + Darwin.cos(Function._dtor(arg1, evaluator: evaluator))
    })
    
    public static let coversin = Function(names: ["coversin", "cvs"], evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        return 1.0 - Darwin.sin(Function._dtor(arg1, evaluator: evaluator))
    })
    
    public static let covercosin = Function(name: "covercosin", evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        return 1.0 + Darwin.sin(Function._dtor(arg1, evaluator: evaluator))
    })
    
    public static let haversin = Function(name: "haversin", evaluator: { (args, substitutions, evaluator) throws -> Double in
        return try versin.evaluator(args, substitutions, evaluator) / 2.0
    })
    
    public static let havercosin = Function(name: "havercosin", evaluator: { (args, substitutions, evaluator) throws -> Double in
        return try vercosin.evaluator(args, substitutions, evaluator) / 2.0
    })
    
    public static let hacoversin = Function(name: "hacoversin", evaluator: { (args, substitutions, evaluator) throws -> Double in
        return try coversin.evaluator(args, substitutions, evaluator) / 2.0
    })
    
    public static let hacovercosin = Function(name: "hacovercosin", evaluator: { (args, substitutions, evaluator) throws -> Double in
        return try covercosin.evaluator(args, substitutions, evaluator) / 2.0
    })
    
    public static let exsec = Function(name: "exsec", evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        let cosArg1 = Darwin.cos(Function._dtor(arg1, evaluator: evaluator))
        guard cosArg1 != 0 else { throw EvaluationError.DivideByZero }
        return (1.0/cosArg1) - 1.0
    })
    
    public static let excsc = Function(name: "excsc", evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        let sinArg1 = Darwin.sin(Function._dtor(arg1, evaluator: evaluator))
        guard sinArg1 != 0 else { throw EvaluationError.DivideByZero }
        return (1.0/sinArg1) - 1.0
    })
    
    public static let crd = Function(names: ["crd", "chord"], evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        let sinArg1 = Darwin.sin(Function._dtor(arg1, evaluator: evaluator) / 2.0)
        return 2 * sinArg1
    })
    
    public static let dtor = Function(name: "dtor", evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        return arg1 / 180.0 * M_PI
    })
    
    public static let rtod = Function(name: "rtod", evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        return arg1 / M_PI * 180
    })
    
    // MARK: - Constant functions
    
    public static let `true` = Function(names: ["true", "yes"], evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 0 else { throw EvaluationError.InvalidArguments }
        return 1.0
    })
    
    public static let `false` = Function(names: ["false", "no"], evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 0 else { throw EvaluationError.InvalidArguments }
        return 0.0
    })
    
    public static let phi = Function(names: ["phi", "ϕ"], evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 0 else { throw EvaluationError.InvalidArguments }
        return 1.6180339887498948
    })
    
    public static let pi = Function(names: ["pi", "π", "tau_2"], evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 0 else { throw EvaluationError.InvalidArguments }
        return M_PI
    })
    
    public static let pi_2 = Function(names: ["pi_2", "tau_4"], evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 0 else { throw EvaluationError.InvalidArguments }
        return M_PI_2
    })
    
    public static let pi_4 = Function(names: ["pi_4", "tau_8"], evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 0 else { throw EvaluationError.InvalidArguments }
        return M_PI_4
    })
    
    public static let tau = Function(names: ["tau", "τ"], evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 0 else { throw EvaluationError.InvalidArguments }
        return 2 * M_PI
    })
    
    public static let sqrt2 = Function(name: "sqrt2", evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 0 else { throw EvaluationError.InvalidArguments }
        return M_SQRT2
    })
    
    public static let e = Function(name: "e", evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 0 else { throw EvaluationError.InvalidArguments }
        return M_E
    })
    
    public static let log2e = Function(name: "log2e", evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 0 else { throw EvaluationError.InvalidArguments }
        return M_LOG2E
    })
    
    public static let log10e = Function(name: "log10e", evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 0 else { throw EvaluationError.InvalidArguments }
        return M_LOG10E
    })
    
    public static let ln2 = Function(name: "ln2", evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 0 else { throw EvaluationError.InvalidArguments }
        return M_LN2
    })
    
    public static let ln10 = Function(name: "ln10", evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 0 else { throw EvaluationError.InvalidArguments }
        return M_LN10
    })
    
    // MARK: - Logical Functions
    
    public static let l_and = Function(name: "l_and", evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 2 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        let arg2 = try evaluator.evaluate(args[1], substitutions: substitutions)
        return (arg1 != 0 && arg2 != 0) ? 1.0 : 0.0
    })
    
    public static let l_or = Function(name: "l_or", evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 2 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        let arg2 = try evaluator.evaluate(args[1], substitutions: substitutions)
        return (arg1 != 0 || arg2 != 0) ? 1.0 : 0.0
    })
    
    public static let l_not = Function(name: "l_not", evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        return (arg1 == 0) ? 1.0 : 0.0
    })
    
    public static let l_eq = Function(name: "l_eq", evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 2 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        let arg2 = try evaluator.evaluate(args[1], substitutions: substitutions)
        return (arg1 == arg2) ? 1.0 : 0.0
    })
    
    public static let l_neq = Function(name: "l_neq", evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 2 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        let arg2 = try evaluator.evaluate(args[1], substitutions: substitutions)
        return (arg1 != arg2) ? 1.0 : 0.0
    })
    
    public static let l_lt = Function(name: "l_lt", evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 2 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        let arg2 = try evaluator.evaluate(args[1], substitutions: substitutions)
        return (arg1 < arg2) ? 1.0 : 0.0
    })
    
    public static let l_gt = Function(name: "l_gt", evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 2 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        let arg2 = try evaluator.evaluate(args[1], substitutions: substitutions)
        return (arg1 > arg2) ? 1.0 : 0.0
    })
    
    public static let l_ltoe = Function(name: "l_ltoe", evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 2 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        let arg2 = try evaluator.evaluate(args[1], substitutions: substitutions)
        return (arg1 <= arg2) ? 1.0 : 0.0
    })
    
    public static let l_gtoe = Function(name: "l_gtoe", evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 2 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        let arg2 = try evaluator.evaluate(args[1], substitutions: substitutions)
        return (arg1 == arg2) ? 1.0 : 0.0
    })
    
    public static let l_if = Function(names: ["l_if", "if"], evaluator: { (args, substitutions, evaluator) throws -> Double in
        guard args.count == 3 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        
        if arg1 != 0 {
            return try evaluator.evaluate(args[1], substitutions: substitutions)
        } else {
            return try evaluator.evaluate(args[2], substitutions: substitutions)
        }
    })
    

}
