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
    XCTAssertEqual(d, value, file: file, line: line)
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
            private func resolveFunction(function: String, arguments: Array<Expression>, substitutions: Dictionary<String, Double>) throws -> Double? {
                return 42
            }
        }
        
        eval.functionResolver = Resolver()
        
        guard let e = XCTAssertNoThrows(try Expression(string: "foo()")) else { return }
        
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
        TestString("2**3", value: 8)
        TestString("√9", value: 3)
        TestString("∛27", value: 3)
        TestString("nthroot(256, 4)", value: 4)
        
        TestString("log(100)", value: 2)
        TestString("ln(e**2)", value: 2)
        TestString("log2(16)", value: 4)
        TestString("exp(1)", value: M_E)
        TestString("abs(-42)", value: 42)
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
        //stddev??
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
    }
    
    func testHyperbolicTrigonometricFunctions() {
        
    }
    
    func testGeometricFunctions() {
        
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
