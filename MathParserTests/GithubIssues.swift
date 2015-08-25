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
        XCTAssertTrue(d != Double.NaN)
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
        XCTAssertEqualWithAccuracy(d, 42, accuracy: 32 * DBL_EPSILON)
    }
    
    func testIssue14() {
        guard let d = XCTAssertNoThrows(try "rtod(asin(sin(30°)))".evaluate()) else { return }
        XCTAssertEqual(d, 30)
    }
    
    func testIssue15() {
        guard let d = XCTAssertNoThrows(try "sin(π/6)".evaluate()) else { return }
        XCTAssertEqualWithAccuracy(d, 0.5, accuracy: DBL_EPSILON)
    }
    
    func testIssue16() {
        guard let d = XCTAssertNoThrows(try "π * e".evaluate()) else { return }
        XCTAssertEqual(d, M_PI * M_E)
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
        XCTFail("Angle Measurement Mode is unimplemented")
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
}
