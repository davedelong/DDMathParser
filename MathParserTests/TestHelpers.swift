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

func TestToken<T>(t: Token<T>?, kind: T, string: String, file: String = __FILE__, line: UInt = __LINE__) {
    XCTAssert(t != nil, "Missing token", file: file, line: line)
    XCTAssert(t?.kind == kind, "Unexpected token kind", file: file, line: line)
    XCTAssertEqual(t?.string, string, "Unexpected token string", file: file, line: line)
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
