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

func XCTAssertNoThrows(_ expression: @autoclosure () throws -> Void, _ message: String = "", file: StaticString = #file, line: UInt = #line) -> Bool {
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

func XCTAssertNoThrows<T>(_ expression: @autoclosure () throws -> T, _ message: String = "", file: StaticString = #file, line: UInt = #line) -> T? {
    var t: T? = nil
    do {
        t = try expression()
    } catch let e {
        let failMessage = "Unexpected exception: \(e). \(message)"
        XCTFail(failMessage, file: file, line: line)
    }
    return t
}

func XCTAssertThrows<T>(_ expression: @autoclosure () throws -> T, _ message: String = "", file: StaticString = #file, line: UInt = #line) {
    do {
        let _ = try expression()
        XCTFail("Expected thrown error", file: file, line: line)
    } catch _ {
    }
}

func TestString(_ string: String, value: Double, evaluator: Evaluator = Evaluator.default, file: StaticString = #file, line: UInt = #line) {
    
    guard let e = XCTAssertNoThrows(try Expression(string: string), file: file, line: line) else {
        return
    }
    
    guard let d = XCTAssertNoThrows(try evaluator.evaluate(e), file: file, line: line) else {
        return
    }
    XCTAssertEqualWithAccuracy(d, value, accuracy: .ulpOfOne, file: file, line: line)
}
