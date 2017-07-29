//
//  GithubIssues.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/24/15.
//
//

import XCTest
import MathParser

class GithubIssues: XCTestCase {

    func testIssue2() {
        guard let d = XCTAssertNoThrows(try "3+3-3+3".evaluate()) else { return }
        XCTAssertEqual(d, 6)
    }
    
    func testIssue4() {
        XCTAssertThrows(try "**2".evaluate())
    }
    
    func testIssue7() {
        guard let d = XCTAssertNoThrows(try "sin(3 * tau / 4)".evaluate()) else { return }
        XCTAssertTrue(d < 0)
    }
    
    func testIssue9() {
        guard let d = XCTAssertNoThrows(try "sin(0.01)".evaluate()) else { return }
        XCTAssertTrue(d != Double.nan)
        XCTAssertEqual(d, sin(0.01))
    }
    
    func testIssue10() {
        guard let d = XCTAssertNoThrows(try "1000!".evaluate()) else { return }
        XCTAssertEqual(d, Double.infinity)
    }
    
    func testIssue11() {
        guard let d = XCTAssertNoThrows(try "3+9!+3".evaluate()) else { return }
        XCTAssertEqual(d, 362886)
    }
    
    func testIssue12() {
        guard let d = XCTAssertNoThrows(try "exp(ln(42))".evaluate()) else { return }
        // d is 42.00000000000000711
        // that's pretty close, but we need to fudge in some ε
        XCTAssertEqualWithAccuracy(d, 42, accuracy: 32 * .ulpOfOne)
    }
    
    func testIssue14() {
        guard let d = XCTAssertNoThrows(try "rtod(asin(sin(30°)))".evaluate()) else { return }
        XCTAssertEqual(d, 30)
    }
    
    func testIssue15() {
        guard let d = XCTAssertNoThrows(try "sin(π/6)".evaluate()) else { return }
        XCTAssertEqualWithAccuracy(d, 0.5, accuracy: .ulpOfOne)
    }
    
    func testIssue16() {
        guard let d = XCTAssertNoThrows(try "π * e".evaluate()) else { return }
        XCTAssertEqual(d, .pi * M_E)
    }
    
    func testIssue19() {
        guard let d = XCTAssertNoThrows(try "2−1".evaluate()) else { return }
        XCTAssertEqual(d, 1)
    }
    
    func testIssue23() {
        guard let d = XCTAssertNoThrows(try "32+32.1".evaluate()) else { return }
        XCTAssertEqual(d, 64.1)
    }
    
    func testIssue27() {
        guard let d = XCTAssertNoThrows(try "sum(7, -8)".evaluate()) else { return }
        XCTAssertEqual(d, -1)
    }
    
    func testIssue29() {
        var eval = Evaluator()
        eval.angleMeasurementMode = .degrees
        
        guard let e1 = XCTAssertNoThrows(try Expression(string: "sin(45)")) else { return }
        guard let d1 = XCTAssertNoThrows(try eval.evaluate(e1)) else { return }
        XCTAssertEqualWithAccuracy(d1, 2.squareRoot() / 2, accuracy: .ulpOfOne)
        
        guard let e2 = XCTAssertNoThrows(try Expression(string: "sin(π/2)")) else { return }
        guard let d2 = XCTAssertNoThrows(try eval.evaluate(e2)) else { return }
        XCTAssertEqualWithAccuracy(d2, 0.02741213359204429, accuracy: .ulpOfOne)
        
        
        eval.angleMeasurementMode = .radians
        
        guard let e3 = XCTAssertNoThrows(try Expression(string: "sin(45)")) else { return }
        guard let d3 = XCTAssertNoThrows(try eval.evaluate(e3)) else { return }
        XCTAssertEqual(d3, 0.8509035245341184)
        
        guard let e4 = XCTAssertNoThrows(try Expression(string: "sin(π/2)")) else { return }
        guard let d4 = XCTAssertNoThrows(try eval.evaluate(e4)) else { return }
        XCTAssertEqual(d4, 1)
    }
    
    func testIssue30() {
        guard let d = XCTAssertNoThrows(try "1−1".evaluate()) else { return }
        XCTAssertEqual(d, 0)
    }
    
    func testIssue31() {
        guard let d = XCTAssertNoThrows(try "12!".evaluate()) else { return }
        XCTAssertEqual(d, 479001600)
    }
    
    func testIssue38() {
        guard let d = XCTAssertNoThrows(try "69!÷69−68!".evaluate()) else { return }
        XCTAssertEqual(d, 0)
        
    }
    
    func testIssue39() {
        guard let d = XCTAssertNoThrows(try "1e−2".evaluate()) else { return }
        XCTAssertEqual(d, 0.01)
        
    }
    
    func testIssue40() {
        let operatorSet = OperatorSet(interpretsPercentSignAsModulo: false)
        guard let e = XCTAssertNoThrows(try Expression(string: "7+5%", operatorSet: operatorSet)) else { return }
        
        let eval = Evaluator.default
        guard let d = XCTAssertNoThrows(try eval.evaluate(e)) else { return }
        XCTAssertEqual(d, 7.35)
    }
    
    func testIssue42() {
        guard let d = XCTAssertNoThrows(try "sin('hello')".evaluate(["hello": 0])) else { return }
        XCTAssertEqual(d, 0)
    }
    
    func testIssue43() {
        do {
            let _ = try "hl=en&client=safari".evaluate()
            XCTFail("Expected thrown error")
        } catch let error as MathParserError {
            guard case .unknownFunction(_) = error.kind else {
                XCTFail("Unexpected error \(error)")
                return
            }
        } catch let e {
            XCTFail("Unexpected error \(e)")
        }
    }
    
    func testIssue49() {
        var eval = Evaluator()
        eval.angleMeasurementMode = .degrees
        
        TestString("sinh(42)", value: sinh(42), evaluator: eval)
        TestString("cosh(42)", value: cosh(42), evaluator: eval)
        TestString("tanh(42)", value: tanh(42), evaluator: eval)
        TestString("asinh(0.42)", value: asinh(0.42), evaluator: eval)
        TestString("acosh(1.42)", value: acosh(1.42), evaluator: eval)
        TestString("atanh(0.42)", value: atanh(0.42), evaluator: eval)
        
        TestString("csch(1)", value: 0.850918128239321545133842763287175284181724660910339616990421, evaluator: eval)
        TestString("sech(1)", value: 0.648054273663885399574977353226150323108489312071942023037865, evaluator: eval)
        TestString("cotanh(1)", value: 1.313035285499331303636161246930847832912013941240452655543152, evaluator: eval)
        TestString("acsch(0.850918128239321545133842763287175284181724660910339616990421)", value: 1)
        
        // These aren't exact because they're Doubles.
        TestString("asech(0.648054273663885399574977353226150323108489312071942023037865)", value: 0.99999999999999967, evaluator: eval)
        TestString("acotanh(1.313035285499331303636161246930847832912013941240452655543152)", value: 1.00000000000000067, evaluator: eval)
    }
    
    func testIssue56() {
        guard let d = XCTAssertNoThrows(try "2**3**2".evaluate()) else { return }
        
        if Operator.defaultPowerAssociativity == .left {
            XCTAssertEqual(d, 64)
        } else {
            XCTAssertEqual(d, 512)
        }
    }
    
    func testIssue57() {
        var eval = Evaluator()
        
        struct Overrider: FunctionOverrider {
            func overrideFunction(_ function: String, state: EvaluationState) throws -> Double? {
                guard state.arguments.count == 0 else { return nil }
                let value = function.utf8.first ?? 1
                return Double(value)
            }
        }
        
        eval.functionOverrider = Overrider()
        
        // T = 84, t = 116
        guard let e = XCTAssertNoThrows(try Expression(string: "t + T")) else { return }
        guard let d = XCTAssertNoThrows(try eval.evaluate(e)) else { return }
        XCTAssertEqual(d, 200.0)
    }
    
    func testIssue63() {
        guard let d = XCTAssertNoThrows(try "nthroot(-27, 3)".evaluate()) else { return }
        XCTAssertEqual(d, -3)
    }
    
    func testIssue64() {
        guard let d = XCTAssertNoThrows(try "1/2$foo".evaluate(["foo": 4])) else { return }
        XCTAssertEqual(d, 0.125)
    }
    
    func testIssue75() {
        let operatorSet = OperatorSet()
        operatorSet.addTokens(["and"], forOperator: Operator(builtInOperator: .logicalAnd))
        
        guard let e = XCTAssertNoThrows(try Expression(string: "1 and 2", operatorSet: operatorSet)) else { return }
        
        let eval = Evaluator.default
        guard let d = XCTAssertNoThrows(try eval.evaluate(e)) else { return }
        XCTAssertEqual(d, 1)
    }
    
    func testIssue79() {
        guard let original = XCTAssertNoThrows(try Expression(string: "sqrt((99**$foo)**2)")) else { return }
        guard let expected = XCTAssertNoThrows(try Expression(string: "abs(99**$foo)")) else { return }
        
        let rewritten = ExpressionRewriter.default.rewriteExpression(original)
        XCTAssertEqual(rewritten, expected)
    }
    
    func testIssue92() {
        guard let d = XCTAssertNoThrows(try "$_foo".evaluate(["_foo": 4])) else { return }
        XCTAssertEqual(d, 4)
    }
    
    func testIssue95() {
        guard let d = XCTAssertNoThrows(try "50!".evaluate()) else { return }
        XCTAssertNotEqual(d, 0)
        
        guard let e = XCTAssertNoThrows(try "20000!".evaluate()) else { return }
        XCTAssertNotEqual(e, 0)
    }
    
    func testIssue97() {
        var eval = Evaluator()
        
        struct Overrider: FunctionOverrider {
            func overrideFunction(_ function: String, state: EvaluationState) throws -> Double? {
                guard function == BuiltInOperator.logicalNotEqual.rawValue else { return nil }
                guard state.arguments.count == 2 else { return nil }
                guard case let .variable(left) = state.arguments[0].kind else { return nil }
                guard case let .variable(right) = state.arguments[1].kind else { return nil }
                
                return (left != right) ? 1.0 : 0.0
            }
        }
        
        eval.functionOverrider = Overrider()
        
        guard let e = XCTAssertNoThrows(try Expression(string: "('B' != 'A') && ('k' != 'K')")) else { return }
        let subs = ["B": 1.0, "A": 1.0, "k": 1.0, "K": 1.0]
        guard let d = XCTAssertNoThrows(try eval.evaluate(e, substitutions: subs)) else { return }
        XCTAssertEqual(d, 1.0)
    }
    
    func testIssue104() {
        guard let tokens = XCTAssertNoThrows(try Tokenizer(string: "+").tokenize()) else {
            return
        }
        XCTAssertEqual(tokens.count, 1)
        XCTAssertEqual(tokens[0].kind, RawToken.Kind.operator)
        XCTAssertEqual(tokens[0].string, "+")
    }
    
    func testIssue105() {
        let operatorSet = OperatorSet()
        operatorSet.addTokens(["or"], forOperator: Operator(builtInOperator: .logicalOr))
        
        guard let e = XCTAssertNoThrows(try Expression(string: "cos(pi)", operatorSet: operatorSet)) else { return }
        
        let eval = Evaluator.default
        guard let d = XCTAssertNoThrows(try eval.evaluate(e)) else { return }
        XCTAssertEqual(d, -1)
    }
    
    func testIssue108() {
        guard let d = XCTAssertNoThrows(try "3++++3".evaluate()) else { return }
        XCTAssertEqual(d, 6)
        
        guard let e = XCTAssertNoThrows(try Expression(string: "ln3")) else { return }
        switch e.kind {
            case .function(let f, let args):
                XCTAssertEqual(f, "ln3")
                XCTAssertEqual(args.count, 0)
            default:
                XCTFail("Unexpected expression kind")
        }
    }
    
    func testIssue109() {
        let operatorSet = OperatorSet()
        operatorSet.addTokens(["as"], forOperator: Operator(builtInOperator: .logicalEqual))
        
        guard let e = XCTAssertNoThrows(try Expression(string: "asin(0.5)", operatorSet: operatorSet)) else { return }
        
        let eval = Evaluator.default
        guard let d = XCTAssertNoThrows(try eval.evaluate(e)) else { return }
        XCTAssertEqual(d, .pi / 6)
    }
    
    func testIssue110() {
        var eval = Evaluator(caseSensitive: false)
        
        guard let e1 = XCTAssertNoThrows(try Expression(string: "sin(0)")) else { return }
        guard let d1 = XCTAssertNoThrows(try eval.evaluate(e1)) else { return }
        XCTAssertEqual(d1, 0)
        
        eval = Evaluator(caseSensitive: true)
        guard let e2 = XCTAssertNoThrows(try Expression(string: "SIN(0)")) else { return }
        XCTAssertThrows(try eval.evaluate(e2))
    }
    
    func testIssue113() {
        let number = Double(Int.max) + 1
        
        guard let d = XCTAssertNoThrows(try "\(number)!".evaluate()) else { return }
        XCTAssertTrue(d > 0)
    }
    
    func testIssue134() {
        guard let d = XCTAssertNoThrows(try "( 1 == 3 || 2 == 2)".evaluate()) else { return }
        XCTAssertEqual(d, 1)
    }
    
    func testIssue138() {
        let tokenizer = Tokenizer(string: "pow")
        let resolver = TokenResolver(tokenizer: tokenizer, options: .default)
        let grouper = TokenGrouper(resolver: resolver)
        let expressionizer = Expressionizer(grouper: grouper)
        let expression = try! expressionizer.expression()
        let description = expression.description
        
        XCTAssertEqual(description, "pow()")
    }
}
