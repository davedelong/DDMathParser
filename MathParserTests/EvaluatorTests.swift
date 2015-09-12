//
//  EvaluatorTests.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/24/15.
//
//

import XCTest
import MathParser

func TestString(string: String, value: Double, file: String = __FILE__, line: UInt = __LINE__) {
    
    guard let d = XCTAssertNoThrows(try string.evaluate()) else {
        XCTFail(file: file, line: line)
        return
    }
    XCTAssertEqualWithAccuracy(d, value, accuracy: DBL_EPSILON, file: file, line: line)
}

class EvaluatorTests: XCTestCase {

    func testNumber() {
        guard let d = XCTAssertNoThrows(try "1".evaluate()) else { return }
        XCTAssertEqual(d, 1)
    }
    
    func testVariable() {
        guard let d = XCTAssertNoThrows(try "$foo".evaluate(["foo": 42])) else { return }
        XCTAssertEqual(d, 42)
    }
    
    func testFunction() {
        guard let d = XCTAssertNoThrows(try "1 + 2".evaluate()) else { return }
        XCTAssertEqual(d, 3)
    }
    
    func testAlias() {
        let eval = Evaluator()
        eval.registerAlias("foo", forFunctionName: "add")
        
        guard let e = XCTAssertNoThrows(try Expression(string: "foo(1, 2)")) else { return }
        
        guard let d = XCTAssertNoThrows(try eval.evaluate(e)) else { return }
        XCTAssertEqual(d, 3)
    }
    
    func testCustomFunction() {
        let eval = Evaluator()
        eval.registerFunction("foo", functionEvaluator: { _ in
            return 42
        })
        
        guard let e = XCTAssertNoThrows(try Expression(string: "foo()")) else { return }
        
        guard let d = XCTAssertNoThrows(try eval.evaluate(e)) else { return }
        XCTAssertEqual(d, 42)
    }
    
    func testVariableResolution() {
        var eval = Evaluator()
        
        struct Resolver: VariableResolver {
            private func resolveVariable(variable: String) -> Double? {
                return 42
            }
        }
        
        eval.variableResolver = Resolver()
        
        guard let e = XCTAssertNoThrows(try Expression(string: "$foo")) else { return }
        
        guard let d = XCTAssertNoThrows(try eval.evaluate(e)) else { return }
        XCTAssertEqual(d, 42)
    }
    
    func testFunctionResolution() {
        var eval = Evaluator()
        
        struct Resolver: FunctionResolver {
            private func resolveFunction(function: String, arguments: Array<Expression>, substitutions: Substitutions, evaluator: Evaluator) throws -> Double? {
                return 42
            }
        }
        
        eval.functionResolver = Resolver()
        
        guard let e = XCTAssertNoThrows(try Expression(string: "foo()")) else { return }
        
        guard let d = XCTAssertNoThrows(try eval.evaluate(e)) else { return }
        XCTAssertEqual(d, 42)
    }
    
    func testFunctionOverride() {
        var eval = Evaluator()
        
        struct Overrider: FunctionOverrider {
            private func overrideFunction(function: String, arguments: Array<Expression>, substitutions: Substitutions, evaluator: Evaluator) throws -> Double? {
                return 42
            }
        }
        
        eval.functionOverrider = Overrider()
        
        guard let e = XCTAssertNoThrows(try Expression(string: "(foo()*foo()+foo()-foo())!")) else { return }
        
        guard let d = XCTAssertNoThrows(try eval.evaluate(e)) else { return }
        XCTAssertEqual(d, 42)
    }
    
    func testUnknownVariable() {
        do {
            let _ = try "$foo".evaluate()
        } catch let e {
            guard let error = e as? EvaluationError else {
                XCTFail("Unexpected error: \(e)")
                return
            }
            
            guard case let .UnknownVariable(v) = error else {
                XCTFail("Unexpected error: \(error)")
                return
            }
            
            XCTAssertEqual(v, "foo")
        }
    }
    
    func testUnknownFunction() {
        do {
            let _ = try "foo()".evaluate()
        } catch let e {
            guard let error = e as? EvaluationError else {
                XCTFail("Unexpected error: \(e)")
                return
            }
            
            guard case let .UnknownFunction(f) = error else {
                XCTFail("Unexpected error: \(error)")
                return
            }
            
            XCTAssertEqual(f, "foo")
        }
    }
    
    func testBasicFunctions() {
        TestString("1+2", value: 3)
        TestString("1-2", value: -1)
        TestString("2*3", value: 6)
        TestString("1/2", value: 0.5)
        TestString("mod(10,3)", value: 1)
        TestString("-4", value: -4)
        TestString("4!", value: 24)
        TestString("4!!", value: 8)
        TestString("2**3", value: 8)
        TestString("√9", value: 3)
        TestString("∛27", value: 3)
        TestString("nthroot(256, 4)", value: 4)
        
        TestString("log(100)", value: 2)
        TestString("ln(e**2)", value: 2)
        TestString("log2(16)", value: 4)
        TestString("exp(1)", value: M_E)
        TestString("abs(-42)", value: 42)
        TestString("10 * percent(10)", value: 1)
        TestString("10 + percent(10)", value: 11)
    }
    
    func testBitwiseFunctions() {
        TestString("1 & 2", value: 0)
        TestString("1 | 2", value: 3)
        TestString("~0", value: -1)
        TestString("2 ^ 3", value: 1)
        TestString("1 << 2", value: 4)
        TestString("4 >> 2", value: 1)
    }
    
    func testAggregateFunctions() {
        TestString("average(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10)", value: 5)
        TestString("sum(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)", value: 55)
        TestString("count(1, 2, 3)", value: 3)
        TestString("min(1, 2, 3)", value: 1)
        TestString("max(1, 2, 3)", value: 3)
        TestString("median(1, 2, 3)", value: 2)
        TestString("median(1, 2, 3, 4)", value: 2.5)
        TestString("stddev(2, 4, 4, 4, 5, 5, 7, 9)", value: 2)
        TestString("stddev(0, 1, 2, 3, 4, 5, 6, 7, 8, 9)", value: 2.872281323269014329925)
        TestString("ceil(1.234)", value: 2)
        TestString("floor(1.234)", value: 1)
    }
    
    func testTrigonometricFunctions() {
        TestString("sin(42)", value: sin(42))
        TestString("cos(42)", value: cos(42))
        TestString("tan(42)", value: tan(42))
        TestString("asin(0.42)", value: asin(0.42))
        TestString("acos(0.42)", value: acos(0.42))
        TestString("atan(0.42)", value: atan(0.42))
        
        TestString("csc(π/4)", value: sqrt(2))
        TestString("sec(π/4)", value: sqrt(2))
        TestString("cotan(π/4)", value: 1)
        TestString("acsc(sqrt(2))", value: M_PI_4)
        TestString("asec(sqrt(2))", value: M_PI_4)
        TestString("acotan(1)", value: M_PI_4)
    }
    
    func testHyperbolicTrigonometricFunctions() {
        TestString("sinh(42)", value: sinh(42))
        TestString("cosh(42)", value: cosh(42))
        TestString("tanh(42)", value: tanh(42))
        TestString("asinh(0.42)", value: asinh(0.42))
        TestString("acosh(1.42)", value: acosh(1.42))
        TestString("atanh(0.42)", value: atanh(0.42))
        
        TestString("csch(1)", value: 0.850918128239321545133842763287175284181724660910339616990421)
        TestString("sech(1)", value: 0.648054273663885399574977353226150323108489312071942023037865)
        TestString("cotanh(1)", value: 1.313035285499331303636161246930847832912013941240452655543152)
        TestString("acsch(0.850918128239321545133842763287175284181724660910339616990421)", value: 1)
        
        // These aren't exact because they're Doubles.
        TestString("asech(0.648054273663885399574977353226150323108489312071942023037865)", value: 0.99999999999999967)
        TestString("acotanh(1.313035285499331303636161246930847832912013941240452655543152)", value: 1.00000000000000067)
    }
    
    func testGeometricFunctions() {
        XCTFail("Not implemented")
    }
    
    func testConstantFunctions() {
        TestString("phi", value: 1.6180339887498948)
        TestString("pi", value: M_PI)
        TestString("pi_2", value: M_PI_2)
        TestString("pi_4", value: M_PI_4)
        TestString("tau", value: 2 * M_PI)
        TestString("sqrt2", value: M_SQRT2)
        TestString("e", value: M_E)
        TestString("log2e", value: M_LOG2E)
        TestString("log10e", value: M_LOG10E)
        TestString("ln2", value: M_LN2)
        TestString("ln10", value: M_LN10)
    }
    
    func testLogicalFunctions() {
        TestString("1 && 2", value: 1)
        TestString("1 || 0", value: 1)
        TestString("!1 || 0", value: 0)
        TestString("42 == 42", value: 1)
        TestString("42 != 42", value: 0)
        TestString("42 > 4", value: 1)
        TestString("4 < 42", value: 1)
        TestString("42 <= 42", value: 1)
        TestString("42 >= 42", value: 1)
        TestString("if(1, 2, 3)", value: 2)
        TestString("if(0, 2, 3)", value: 3)
    }
}
