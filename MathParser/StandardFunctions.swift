//
//  StandardFunctions.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/20/15.
//
//

import Foundation

public class StandardFunctions {
    
    private static let largestIntegerFactorial: Int = {
        var n = Int.max
        var i = 2
        while i < n {
            n /= i
            i++
        }
        return i - 1
    }()
    
    private static let functionMap = [
        "add": StandardFunctions.add,
        "subtract": StandardFunctions.subtract,
        "multiply": StandardFunctions.multiply,
        "divide": StandardFunctions.divide,
        "mod": StandardFunctions.mod,
        "negate": StandardFunctions.negate,
        "factorial": StandardFunctions.factorial,
        "pow": StandardFunctions.pow,
        "sqrt": StandardFunctions.sqrt,
        "cuberoot": StandardFunctions.cuberoot,
        "nthroot": StandardFunctions.nthroot,
        "random": StandardFunctions.random,
        "log": StandardFunctions.log,
        "ln": StandardFunctions.ln,
        "log2": StandardFunctions.log2,
        "exp": StandardFunctions.exp,
        "abs": StandardFunctions.abs,
        "percent": StandardFunctions.percent,
        
        "and": StandardFunctions.and,
        "or": StandardFunctions.or,
        "not": StandardFunctions.not,
        "xor": StandardFunctions.xor,
        "lshift": StandardFunctions.lshift,
        "rshift": StandardFunctions.rshift,
        
        "average": StandardFunctions.average,
        "sum": StandardFunctions.sum,
        "product": StandardFunctions.product,
        "count": StandardFunctions.count,
        "min": StandardFunctions.min,
        "max": StandardFunctions.max,
        "median": StandardFunctions.median,
        "stddev": StandardFunctions.stddev,
        "ceil": StandardFunctions.ceil,
        "floor": StandardFunctions.floor,
        
        "sin": StandardFunctions.sin,
        "cos": StandardFunctions.cos,
        "tan": StandardFunctions.tan,
        "asin": StandardFunctions.asin,
        "acos": StandardFunctions.acos,
        "atan": StandardFunctions.atan,
        "atan2": StandardFunctions.atan2,
        "csc": StandardFunctions.csc,
        "sec": StandardFunctions.sec,
        "cotan": StandardFunctions.cotan,
        "acsc": StandardFunctions.acsc,
        "asec": StandardFunctions.asec,
        "acotan": StandardFunctions.acotan,
        
        "sinh": StandardFunctions.sinh,
        "cosh": StandardFunctions.cosh,
        "tanh": StandardFunctions.tanh,
        "asinh": StandardFunctions.asinh,
        "acosh": StandardFunctions.acosh,
        "atanh": StandardFunctions.atanh,
        "csch": StandardFunctions.csch,
        "sech": StandardFunctions.sech,
        "cotanh": StandardFunctions.cotanh,
        "acsch": StandardFunctions.acsch,
        "asech": StandardFunctions.asech,
        "acotanh": StandardFunctions.acotanh,
        
        "versin": StandardFunctions.versin,
        "vercosin": StandardFunctions.vercosin,
        "coversin": StandardFunctions.coversin,
        "covercosin": StandardFunctions.covercosin,
        "haversin": StandardFunctions.haversin,
        "havercosin": StandardFunctions.havercosin,
        "hacoversin": StandardFunctions.hacoversin,
        "hacovercosin": StandardFunctions.hacovercosin,
        "exsec": StandardFunctions.exsec,
        "excsc": StandardFunctions.excsc,
        "crd": StandardFunctions.crd,
        "dtor": StandardFunctions.dtor,
        "rtod": StandardFunctions.rtod,
        
        "phi": StandardFunctions.phi,
        "pi": StandardFunctions.pi,
        "pi_2": StandardFunctions.pi_2,
        "pi_4": StandardFunctions.pi_4,
        "tau": StandardFunctions.tau,
        "sqrt2": StandardFunctions.sqrt2,
        "e": StandardFunctions.e,
        "log2e": StandardFunctions.log2e,
        "log10e": StandardFunctions.log10e,
        "ln2": StandardFunctions.ln2,
        "ln10": StandardFunctions.ln10,
        
        "l_and": StandardFunctions.l_and,
        "l_or": StandardFunctions.l_or,
        "l_not": StandardFunctions.l_not,
        "l_eq": StandardFunctions.l_eq,
        "l_neq": StandardFunctions.l_neq,
        "l_lt": StandardFunctions.l_lt,
        "l_gt": StandardFunctions.l_gt,
        "l_ltoe": StandardFunctions.l_ltoe,
        "l_gtoe": StandardFunctions.l_gtoe,
        "l_if": StandardFunctions.l_if
    ]
    
    private let standardAliases = [
        "avg": "average",
        "mean": "average",
        "trunc": "floor",
        "modulo": "mod",
        "π": "pi",
        "τ": "tau",
        "tau_2": "pi",
        "tau_4": "pi_2",
        "tau_8": "pi_4",
        "ϕ": "phi",
        "implicitmultiply": "multiply",
        "if": "l_if",
        "∑": "sum",
        "∏": "product",
        
        "vers": "versin",
        "ver": "versin",
        "vercos": "vercosin",
        "cvs": "coversin",
        "chord": "crd"
    ]
    
    private var aliases = Dictionary<String, String>()
    private var registeredFunctions = Dictionary<String, FunctionEvaluator>()
    
    public var functions: Array<String> {
        var names: Set<String> = Set(registeredFunctions.keys)
        names.unionInPlace(aliases.keys)
        names.unionInPlace(standardAliases.keys)
        names.unionInPlace(StandardFunctions.functionMap.keys)
        return names.sort { $0 < $1 }
    }
    
    // MARK: - Basic functionality
    
    internal func normalizeFunctionName(name: String) -> String {
        let lowerName = name.lowercaseString
        
        var normalized = aliases[lowerName] ?? lowerName
        normalized = standardAliases[normalized] ?? normalized
        
        return normalized
    }
    
    public func addAlias(alias: String, forFunctionName name: String) {
        aliases[alias.lowercaseString] = name.lowercaseString
    }
    
    public func registerFunction(name: String, functionEvaluator: FunctionEvaluator) {
        registeredFunctions[name.lowercaseString] = functionEvaluator
    }
    
    func performFunction(name: String, arguments: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double? {
        let normalized = normalizeFunctionName(name)
        
        if let function = StandardFunctions.functionMap[normalized] {
            return try function(arguments, substitutions: substitutions, evaluator: evaluator)
        }
        
        if let registeredFunction = registeredFunctions[normalized] {
            return try registeredFunction(arguments, substitutions, evaluator)
        }
        
        return nil
    }
    
    // MARK: - Angle mode helpers
    
    private static func _dtor(d: Double, evaluator: Evaluator) -> Double {
        guard evaluator.angleMeasurementMode == .Degrees else { return d }
        return d / 180 * M_PI
    }
    
    private static func _rtod(d: Double, evaluator: Evaluator) -> Double {
        guard evaluator.angleMeasurementMode == .Degrees else { return d }
        return d / M_PI * 180
    }
    
    // MARK: - Basic functions
    
    static func add(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 2 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        let arg2 = try evaluator.evaluate(args[1], substitutions: substitutions)
        return arg1 + arg2
    }
    
    static func subtract(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 2 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        let arg2 = try evaluator.evaluate(args[1], substitutions: substitutions)
        return arg1 - arg2
    }
    
    static func multiply(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 2 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        let arg2 = try evaluator.evaluate(args[1], substitutions: substitutions)
        return arg1 * arg2
    }
    
    static func divide(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 2 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        let arg2 = try evaluator.evaluate(args[1], substitutions: substitutions)
        
        guard arg2 != 0 else { throw EvaluationError.DivideByZero }
        return arg1 / arg2
    }
    
    static func mod(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 2 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        let arg2 = try evaluator.evaluate(args[1], substitutions: substitutions)
        
        return fmod(arg1, arg2)
    }
    
    static func negate(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        
        return -arg1
    }
    
    static func factorial(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        
        if Darwin.floor(arg1) == arg1 && arg1 > 1 {
            // it's an integer
            let arg1Int = Int(arg1)
            
            if arg1Int <= StandardFunctions.largestIntegerFactorial {
                return Double((1...arg1Int).reduce(1, combine: *))
            } else {
                // but it can't be represented in a word-sized Int
                var result = 1.0
                for var i = arg1; i > 1; i-- {
                    result *= i
                }
                return result
            }
        } else {
            return tgamma(arg1+1)
        }
    }
    
    static func pow(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 2 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        let arg2 = try evaluator.evaluate(args[1], substitutions: substitutions)
        
        return Darwin.pow(arg1, arg2)
    }
    
    static func sqrt(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let value = try evaluator.evaluate(args[0], substitutions: substitutions)
        
        return Darwin.sqrt(value)
    }
    
    static func cuberoot(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        
        return Darwin.pow(arg1, 1.0/3.0)
    }
    
    static func nthroot(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
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
    }
    
    static func random(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
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
    }
    
    static func log(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        return Darwin.log10(arg1)
    }
    
    static func ln(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        return Darwin.log(arg1)
    }
    
    static func log2(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        return Darwin.log2(arg1)
    }
    
    static func exp(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        return Darwin.exp(arg1)
    }
    
    static func abs(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        return Swift.abs(arg1)
    }
    
    static func percent(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
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
    }
    
    // MARK: - Bitwise functions
    
    static func and(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 2 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        let arg2 = try evaluator.evaluate(args[1], substitutions: substitutions)
        
        return Double(Int(arg1) & Int(arg2))
    }
    
    static func or(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 2 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        let arg2 = try evaluator.evaluate(args[1], substitutions: substitutions)
        
        return Double(Int(arg1) | Int(arg2))
    }
    
    static func not(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        
        return Double(~Int(arg1))
    }
    
    static func xor(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 2 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        let arg2 = try evaluator.evaluate(args[1], substitutions: substitutions)
        
        return Double(Int(arg1) ^ Int(arg2))
    }
    
    static func rshift(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 2 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        let arg2 = try evaluator.evaluate(args[1], substitutions: substitutions)
        
        return Double(Int(arg1) >> Int(arg2))
    }
    
    static func lshift(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 2 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        let arg2 = try evaluator.evaluate(args[1], substitutions: substitutions)
        
        return Double(Int(arg1) << Int(arg2))
    }
    
    // MARK: - Aggregate functions
    
    static func average(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count > 0 else { throw EvaluationError.InvalidArguments }
        
        let value = try sum(args, substitutions: substitutions, evaluator: evaluator)
        
        return value / Double(args.count)
    }
    
    static func sum(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count > 0 else { throw EvaluationError.InvalidArguments }
        
        var value = 0.0
        for arg in args {
            value += try evaluator.evaluate(arg, substitutions: substitutions)
        }
        return value
    }
    
    static func product(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count > 0 else { throw EvaluationError.InvalidArguments }
        
        var value = 1.0
        for arg in args {
            value *= try evaluator.evaluate(arg, substitutions: substitutions)
        }
        return value
    }
    
    static func count(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        return Double(args.count)
    }
    
    static func min(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count > 0 else { throw EvaluationError.InvalidArguments }
        
        var value = DBL_MAX
        for arg in args {
            let argValue = try evaluator.evaluate(arg, substitutions: substitutions)
            value = Swift.min(value, argValue)
        }
        return value
    }
    
    static func max(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count > 0 else { throw EvaluationError.InvalidArguments }
        
        var value = DBL_MIN
        for arg in args {
            let argValue = try evaluator.evaluate(arg, substitutions: substitutions)
            value = Swift.max(value, argValue)
        }
        return value
    }
    
    static func median(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
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
    }
    
    static func stddev(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count >= 2 else { throw EvaluationError.InvalidArguments }
        
        let avg = try average(args, substitutions: substitutions, evaluator: evaluator)
        
        var stddev = 0.0
        for arg in args {
            let value = try evaluator.evaluate(arg, substitutions: substitutions)
            let diff = avg - value
            stddev += (diff * diff)
        }
        
        return Darwin.sqrt(stddev / Double(args.count))
    }
    
    static func ceil(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        return Darwin.ceil(arg1)
    }
    
    static func floor(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        return Darwin.floor(arg1)
    }
    
    // MARK: - Trigonometric functions
    
    static func sin(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        return Darwin.sin(_dtor(arg1, evaluator: evaluator))
    }
    
    static func cos(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        return Darwin.cos(_dtor(arg1, evaluator: evaluator))
    }
    
    static func tan(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        return Darwin.tan(_dtor(arg1, evaluator: evaluator))
    }
    
    static func asin(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        return _rtod(Darwin.asin(arg1), evaluator: evaluator)
    }
    
    static func acos(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        return _rtod(Darwin.acos(arg1), evaluator: evaluator)
    }
    
    static func atan(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        return _rtod(Darwin.atan(arg1), evaluator: evaluator)
    }
    
    static func atan2(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 2 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        let arg2 = try evaluator.evaluate(args[1], substitutions: substitutions)
        return _rtod(Darwin.atan2(arg1, arg2), evaluator: evaluator)
    }
    
    static func csc(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        let sinArg = Darwin.sin(_dtor(arg1, evaluator: evaluator))
        guard sinArg != 0 else { throw EvaluationError.DivideByZero }
        return 1.0 / sinArg
    }
    
    static func sec(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        let sinArg = Darwin.cos(_dtor(arg1, evaluator: evaluator))
        guard sinArg != 0 else { throw EvaluationError.DivideByZero }
        return 1.0 / sinArg
    }
    
    static func cotan(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        let sinArg = Darwin.tan(_dtor(arg1, evaluator: evaluator))
        guard sinArg != 0 else { throw EvaluationError.DivideByZero }
        return 1.0 / sinArg
    }
    
    static func acsc(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        let sinArg = _rtod(Darwin.asin(arg1), evaluator: evaluator)
        guard sinArg != 0 else { throw EvaluationError.DivideByZero }
        return 1.0 / sinArg
    }
    
    static func asec(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        let sinArg = _rtod(Darwin.acos(arg1), evaluator: evaluator)
        guard sinArg != 0 else { throw EvaluationError.DivideByZero }
        return 1.0 / sinArg
    }
    
    static func acotan(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        let sinArg = _rtod(Darwin.atan(arg1), evaluator: evaluator)
        guard sinArg != 0 else { throw EvaluationError.DivideByZero }
        return 1.0 / sinArg
    }
    
    // MARK: - Hyperbolic trigonometric functions
    
    static func sinh(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        return Darwin.sinh(_dtor(arg1, evaluator: evaluator))
    }
    
    static func cosh(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        return Darwin.cosh(_dtor(arg1, evaluator: evaluator))
    }
    
    static func tanh(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        return Darwin.tanh(_dtor(arg1, evaluator: evaluator))
    }
    
    static func asinh(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        return _rtod(Darwin.asinh(arg1), evaluator: evaluator)
    }
    
    static func acosh(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        return _rtod(Darwin.acosh(arg1), evaluator: evaluator)
    }
    
    static func atanh(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        return _rtod(Darwin.atanh(arg1), evaluator: evaluator)
    }
    
    static func csch(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        let sinArg = Darwin.sinh(_dtor(arg1, evaluator: evaluator))
        guard sinArg != 0 else { throw EvaluationError.DivideByZero }
        return 1.0 / sinArg
    }
    
    static func sech(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        let sinArg = Darwin.cosh(_dtor(arg1, evaluator: evaluator))
        guard sinArg != 0 else { throw EvaluationError.DivideByZero }
        return 1.0 / sinArg
    }
    
    static func cotanh(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        let sinArg = Darwin.tanh(_dtor(arg1, evaluator: evaluator))
        guard sinArg != 0 else { throw EvaluationError.DivideByZero }
        return 1.0 / sinArg
    }
    
    static func acsch(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        let sinArg = _rtod(Darwin.asinh(arg1), evaluator: evaluator)
        guard sinArg != 0 else { throw EvaluationError.DivideByZero }
        return 1.0 / sinArg
    }
    
    static func asech(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        let sinArg = _rtod(Darwin.acosh(arg1), evaluator: evaluator)
        guard sinArg != 0 else { throw EvaluationError.DivideByZero }
        return 1.0 / sinArg
    }
    
    static func acotanh(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        let sinArg = _rtod(Darwin.atanh(arg1), evaluator: evaluator)
        guard sinArg != 0 else { throw EvaluationError.DivideByZero }
        return 1.0 / sinArg
    }
    
    // MARK: - Geometric functions
    
    static func versin(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        return 1.0 - Darwin.cos(_dtor(arg1, evaluator: evaluator))
    }
    
    static func vercosin(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        return 1.0 + Darwin.cos(_dtor(arg1, evaluator: evaluator))
    }
    
    static func coversin(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        return 1.0 - Darwin.sin(_dtor(arg1, evaluator: evaluator))
    }
    
    static func covercosin(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        return 1.0 + Darwin.sin(_dtor(arg1, evaluator: evaluator))
    }
    
    static func haversin(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        return try versin(args, substitutions: substitutions, evaluator: evaluator) / 2.0
    }
    
    static func havercosin(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        return try vercosin(args, substitutions: substitutions, evaluator: evaluator) / 2.0
    }
    
    static func hacoversin(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        return try coversin(args, substitutions: substitutions, evaluator: evaluator) / 2.0
    }
    
    static func hacovercosin(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        return try covercosin(args, substitutions: substitutions, evaluator: evaluator) / 2.0
    }
    
    static func exsec(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        let cosArg1 = Darwin.cos(_dtor(arg1, evaluator: evaluator))
        guard cosArg1 != 0 else { throw EvaluationError.DivideByZero }
        return (1.0/cosArg1) - 1.0
    }
    
    static func excsc(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        let sinArg1 = Darwin.sin(_dtor(arg1, evaluator: evaluator))
        guard sinArg1 != 0 else { throw EvaluationError.DivideByZero }
        return (1.0/sinArg1) - 1.0
    }
    
    static func crd(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        let sinArg1 = Darwin.sin(_dtor(arg1, evaluator: evaluator) / 2.0)
        return 2 * sinArg1
    }
    
    static func dtor(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        return arg1 / 180.0 * M_PI
    }
    
    static func rtod(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        return arg1 / M_PI * 180
    }
    
    // MARK: - Constant functions
    
    static func phi(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 0 else { throw EvaluationError.InvalidArguments }
        return 1.6180339887498948
    }
    
    static func pi(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 0 else { throw EvaluationError.InvalidArguments }
        return M_PI
    }
    
    static func pi_2(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 0 else { throw EvaluationError.InvalidArguments }
        return M_PI_2
    }
    
    static func pi_4(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 0 else { throw EvaluationError.InvalidArguments }
        return M_PI_4
    }
    
    static func tau(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 0 else { throw EvaluationError.InvalidArguments }
        return 2 * M_PI
    }
    
    static func sqrt2(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 0 else { throw EvaluationError.InvalidArguments }
        return M_SQRT2
    }
    
    static func e(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 0 else { throw EvaluationError.InvalidArguments }
        return M_E
    }
    
    static func log2e(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 0 else { throw EvaluationError.InvalidArguments }
        return M_LOG2E
    }
    
    static func log10e(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 0 else { throw EvaluationError.InvalidArguments }
        return M_LOG10E
    }
    
    static func ln2(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 0 else { throw EvaluationError.InvalidArguments }
        return M_LN2
    }
    
    static func ln10(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 0 else { throw EvaluationError.InvalidArguments }
        return M_LN10
    }
    
    // MARK: - Logical Functions
    
    static func l_and(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 2 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        let arg2 = try evaluator.evaluate(args[1], substitutions: substitutions)
        return (arg1 != 0 && arg2 != 0) ? 1.0 : 0.0
    }
    
    static func l_or(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 2 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        let arg2 = try evaluator.evaluate(args[1], substitutions: substitutions)
        return (arg1 != 0 || arg2 != 0) ? 1.0 : 0.0
    }
    
    static func l_not(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 1 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        return (arg1 == 0) ? 1.0 : 0.0
    }
    
    static func l_eq(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 2 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        let arg2 = try evaluator.evaluate(args[1], substitutions: substitutions)
        return (arg1 == arg2) ? 1.0 : 0.0
    }
    
    static func l_neq(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 2 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        let arg2 = try evaluator.evaluate(args[1], substitutions: substitutions)
        return (arg1 != arg2) ? 1.0 : 0.0
    }
    
    static func l_lt(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 2 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        let arg2 = try evaluator.evaluate(args[1], substitutions: substitutions)
        return (arg1 < arg2) ? 1.0 : 0.0
    }
    
    static func l_gt(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 2 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        let arg2 = try evaluator.evaluate(args[1], substitutions: substitutions)
        return (arg1 > arg2) ? 1.0 : 0.0
    }
    
    static func l_ltoe(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 2 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        let arg2 = try evaluator.evaluate(args[1], substitutions: substitutions)
        return (arg1 <= arg2) ? 1.0 : 0.0
    }
    
    static func l_gtoe(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 2 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        let arg2 = try evaluator.evaluate(args[1], substitutions: substitutions)
        return (arg1 == arg2) ? 1.0 : 0.0
    }
    
    static func l_if(args: Array<Expression>, substitutions: Dictionary<String, Double>, evaluator: Evaluator) throws -> Double {
        guard args.count == 3 else { throw EvaluationError.InvalidArguments }
        
        let arg1 = try evaluator.evaluate(args[0], substitutions: substitutions)
        
        if arg1 != 0 {
            return try evaluator.evaluate(args[1], substitutions: substitutions)
        } else {
            return try evaluator.evaluate(args[2], substitutions: substitutions)
        }
    }
    
    
}
