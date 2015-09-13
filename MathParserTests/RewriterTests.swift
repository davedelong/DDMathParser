//
//  RewriterTests.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/27/15.
//
//

import XCTest
import MathParser

func TestRewrite(original: String, expected: String, substitutions: Substitutions = [:], evaluator: Evaluator = Evaluator.defaultEvaluator, file: String = __FILE__, line: UInt = __LINE__) {
    
    guard let originalE = XCTAssertNoThrows(try Expression(string: original), file: file, line: line) else { return }
    
    guard let expectedE = XCTAssertNoThrows(try Expression(string: expected), file: file, line: line) else { return }
    
    let rewritter = ExpressionRewriter.defaultRewriter
    let rewritten = rewritter.rewriteExpression(originalE, substitutions: substitutions, evaluator: evaluator)
    
    XCTAssertEqual(rewritten, expectedE, file: file, line: line)
}

class RewriterTests: XCTestCase {

    func testDefaultRules() {
        TestRewrite("0 + $foo", expected: "$foo")
        TestRewrite("$foo + 0", expected: "$foo")
        TestRewrite("$foo + $foo", expected: "$foo * 2")
        TestRewrite("$foo - $foo", expected: "0")
        TestRewrite("1 * $foo", expected: "$foo")
        TestRewrite("$foo * 1", expected: "$foo")
        TestRewrite("$foo * $foo", expected: "$foo ** 2")
        TestRewrite("__num1 * __var1", expected: "__var1 * __num1")
        TestRewrite("0 * $foo", expected: "0")
        TestRewrite("$foo * 0", expected: "0")
        TestRewrite("--$foo", expected: "$foo")
        TestRewrite("abs(-$foo)", expected: "abs($foo)")
        TestRewrite("exp($foo) * exp($bar)", expected: "exp($foo + $bar)")
        TestRewrite("($foo ** $baz) * ($bar ** $baz)", expected: "($foo * $bar) ** $baz")
        TestRewrite("$foo ** 0", expected: "1")
        TestRewrite("$foo ** 1", expected: "$foo")
        TestRewrite("sqrt($foo ** 2)", expected: "abs($foo)")
        TestRewrite("dtor(rtod($foo))", expected: "$foo")
        TestRewrite("rtod(dtor($foo))", expected: "$foo")
        
        
        //division
        TestRewrite("$foo / $foo", expected: "1", substitutions: ["foo": 1])
        TestRewrite("$foo / $foo", expected: "$foo / $foo")
        
        TestRewrite("($foo * $bar) / $bar", expected: "$foo", substitutions: ["bar": 1])
        TestRewrite("($foo * $bar) / $bar", expected: "($foo * $bar) / $bar")
        
        
        TestRewrite("($bar * $foo) / $bar", expected: "$foo", substitutions: ["bar": 1])
        TestRewrite("($bar * $foo) / $bar", expected: "($bar * $foo) / $bar")
        
        TestRewrite("$bar / ($bar * $foo)", expected: "1/$foo", substitutions: ["bar": 1])
        TestRewrite("$bar / ($bar * $foo)", expected: "$bar / ($bar * $foo)")
        
        TestRewrite("$bar / ($foo * $bar)", expected: "1/$foo", substitutions: ["bar": 1])
        TestRewrite("$bar / ($foo * $bar)", expected: "$bar / ($foo * $bar)")
        
        
        //exponents and roots
        TestRewrite("nthroot(pow($foo, $bar), $bar)", expected: "abs($foo)", substitutions: ["bar": 2])
        TestRewrite("nthroot(pow($foo, $bar), $bar)", expected: "nthroot(pow($foo, $bar), $bar)")
        
        
        TestRewrite("nthroot(pow($foo, $bar), $bar)", expected: "$foo", substitutions: ["bar": 1])
        TestRewrite("nthroot(pow($foo, $bar), $bar)", expected: "nthroot(pow($foo, $bar), $bar)")
        
        TestRewrite("abs($foo)", expected: "1", substitutions: ["foo": 1])
        TestRewrite("abs($foo)", expected: "abs($foo)")
    }
    
}
