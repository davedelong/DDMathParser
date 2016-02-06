//
//  EvaluatorTests.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/24/15.
//
//

import XCTest
import MathParser

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
        // versin, vercosin, coversin, covercosin
        TestString("versin(1)", value: 0.459697694131860282599063392557023396267689579382077772329902)
        TestString("vercosin(1)", value: 1.540302305868139717400936607442976603732310420617922227670097)
        TestString("coversin(1)", value: 0.158529015192103493347497678369701000377436939201628934327248)
        TestString("covercosin(1)", value: 1.841470984807896506652502321630298999622563060798371065672751)
        
        // haversin, havercosin, hacoversin, hacovercosin
        TestString("haversin(1)", value: 0.229848847065930141299531696278511698133844789691038886164951)
        TestString("havercosin(1)", value: 0.770151152934069858700468303721488301866155210308961113835048)
        TestString("hacoversin(1)", value: 0.079264507596051746673748839184850500188718469600814467163624)
        TestString("hacovercosin(1)", value: 0.920735492403948253326251160815149499811281530399185532836375)
        
        // exsec, excsc, crd, dtor, rtod
        TestString("exsec(1)", value: 0.850815717680925617911753241398650193470396655094009298835158)
        TestString("excsc(1)", value: 0.188395105778121216261599452374551003527829834097962625265253)
        TestString("crd(1.287002217586570)", value: 1.20000000000000084)
        TestString("dtor(45)", value: M_PI_4)
        TestString("rtod(π/4)", value: 45)
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
    
    func testAliases() {
        let eval = Evaluator()
        
        guard XCTAssertNoThrows(try eval.registerAlias("foo", forFunctionName: "add")) else { return }
        guard let e = XCTAssertNoThrows(try Expression(string: "foo(1, 2)")) else { return }
        guard let d = XCTAssertNoThrows(try eval.evaluate(e)) else { return }
        XCTAssertEqual(d, 3)
    }
    
    func testBadAliases() {
        let eval = Evaluator()
        
        XCTAssertThrows(try eval.registerAlias("add", forFunctionName: "subtract"))
        XCTAssertThrows(try eval.registerAlias("bar", forFunctionName: "foo"))
    }
    
    func testCustomFunction() {
        let function = Function(name: "foo", evaluator: { (args, subs, eval) throws -> Double in
            return 42
        })
        
        let eval = Evaluator()
        guard XCTAssertNoThrows(try eval.registerFunction(function)) else { return }
        guard let e = XCTAssertNoThrows(try Expression(string: "foo()")) else { return }
        guard let d = XCTAssertNoThrows(try eval.evaluate(e)) else { return }
        XCTAssertEqual(d, 42)
    }
    
    func testBadCustomFunction() {
        let function = Function(name: "add", evaluator: { (args, subs, eval) throws -> Double in
            return 42
        })
        
        let eval = Evaluator()
        XCTAssertThrows(try eval.registerFunction(function))
    }
    
    func testLogic() {
        let operatorSet = OperatorSet()
        operatorSet.addTokens(["and"], forOperator: Operator(builtInOperator: .LogicalAnd))
        operatorSet.addTokens(["or"], forOperator: Operator(builtInOperator: .LogicalOr))
        operatorSet.addTokens(["is"], forOperator: Operator(builtInOperator: .LogicalEqual))
        operatorSet.addTokens(["is not"], forOperator: Operator(builtInOperator: .LogicalNotEqual))
        
        
        let tests: Dictionary<String, Double> = [
            "true and true is true": 1,
            "true and false is not true": 1,
            "true and false is true": 0,
            "false and false is false": 1,
            "true or false is true": 1
        ]
        
        for (test, value) in tests {
            guard let e = XCTAssertNoThrows(try Expression(string: test, operatorSet: operatorSet)) else { return }
            guard let d = XCTAssertNoThrows(try Evaluator.defaultEvaluator.evaluate(e)) else { return }
            XCTAssertEqual(d, value)
        }
    }
}
