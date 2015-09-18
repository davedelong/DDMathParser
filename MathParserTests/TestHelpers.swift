//
//  TestHelpers.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/12/15.
//
//

import Foundation
import XCTest
import MathParser

func XCTAssertNoThrows(@autoclosure expression: () throws -> Void, _ message: String = "", file: String = __FILE__, line: UInt = __LINE__) -> Bool {
    var ok = false
    do {
        try expression()
        ok = true
    } catch let e {
        let failMessage = "Unexpected exception: \(e). \(message)"
        XCTFail(failMessage, file: file, line: line)
    }
    return ok
}

func XCTAssertNoThrows<T>(@autoclosure expression: () throws -> T, _ message: String = "", file: String = __FILE__, line: UInt = __LINE__) -> T? {
    var t: T? = nil
    do {
        t = try expression()
    } catch let e {
        let failMessage = "Unexpected exception: \(e). \(message)"
        XCTFail(failMessage, file: file, line: line)
    }
    return t
}

func XCTAssertThrows<T>(@autoclosure expression: () throws -> T, _ message: String = "", file: String = __FILE__, line: UInt = __LINE__) {
    do {
        let _ = try expression()
        XCTFail("Expected thrown error", file: file, line: line)
    } catch _ {
    }
}

func TestString(string: String, value: Double, evaluator: Evaluator = Evaluator.defaultEvaluator, file: String = __FILE__, line: UInt = __LINE__) {
    
    guard let e = XCTAssertNoThrows(try Expression(string: string), file: file, line: line) else {
        return
    }
    
    guard let d = XCTAssertNoThrows(try evaluator.evaluate(e), file: file, line: line) else {
        return
    }
    XCTAssertEqualWithAccuracy(d, value, accuracy: DBL_EPSILON, file: file, line: line)
}
