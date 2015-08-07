//
//  TokenizerTests.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/7/15.
//
//

import XCTest
import MathParser

class TokenizerTests: XCTestCase {
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
    }
    
    func testHexNumber() {
        let g = Tokenizer(string: "0x0123").generate()
        
        let t = g.next()
        XCTAssert(t != nil, "Expected non-nil token")
        XCTAssert(t?.hasValue == true, "Expected value token")

        let token = t?.value
        XCTAssert(token != nil, "Expected token")
        XCTAssertEqual(token?.kind, .HexNumber, "Expected hex number")
        XCTAssertEqual(token?.string, "0x0123", "Unexpected hex number")
        
        XCTAssert(g.next() == nil, "Unexpected supplementary token")
    }
    
    func testNumber() {
        let g = Tokenizer(string: "0123").generate()
        
        let t = g.next()
        XCTAssert(t != nil, "Expected non-nil token")
        XCTAssert(t?.hasValue == true, "Expected value token")
        
        let token = t?.value
        XCTAssert(token != nil, "Expected token")
        XCTAssertEqual(token?.kind, .Number, "Expected number")
        XCTAssertEqual(token?.string, "0123", "Unexpected number")
        
        XCTAssert(g.next() == nil, "Unexpected supplementary token")
    }
    
    func testVariable() {
        let g = Tokenizer(string: "$foo").generate()
        
        let t = g.next()
        XCTAssert(t != nil, "Expected non-nil token")
        XCTAssert(t?.hasValue == true, "Expected value token")
        
        let token = t?.value
        XCTAssert(token != nil, "Expected token")
        XCTAssertEqual(token?.kind, .Variable, "Expected variable")
        XCTAssertEqual(token?.string, "foo", "Unexpected variable")
        
        XCTAssert(g.next() == nil, "Unexpected supplementary token")
    }
    
    func testDoubleQuotedVariable() {
        let g = Tokenizer(string: "\"foo\"").generate()
        
        let t = g.next()
        XCTAssert(t != nil, "Expected non-nil token")
        XCTAssert(t?.hasValue == true, "Expected value token")
        
        let token = t?.value
        XCTAssert(token != nil, "Expected token")
        XCTAssertEqual(token?.kind, .Variable, "Expected variable")
        XCTAssertEqual(token?.string, "foo", "Unexpected variable")
        
        XCTAssert(g.next() == nil, "Unexpected supplementary token")
    }
    
    func testSingleQuotedVariable() {
        let g = Tokenizer(string: "'foo'").generate()
        
        let t = g.next()
        XCTAssert(t != nil, "Expected non-nil token")
        XCTAssert(t?.hasValue == true, "Expected value token")
        
        let token = t?.value
        XCTAssert(token != nil, "Expected token")
        XCTAssertEqual(token?.kind, .Variable, "Expected variable")
        XCTAssertEqual(token?.string, "foo", "Unexpected variable")
        
        XCTAssert(g.next() == nil, "Unexpected supplementary token")
    }
    
    func testBadVariable() {
        let g = Tokenizer(string: "$").generate()
        
        let t = g.next()
        XCTAssert(t != nil, "Expected non-nil token")
        XCTAssertEqual(t?.hasValue, true, "Expected value token")
        
        let token = t?.value
        XCTAssert(token != nil, "Expected token")
        XCTAssertEqual(token?.kind, .Identifier, "Expected variable")
        XCTAssertEqual(token?.string, "$", "Unexpected variable")
        
        XCTAssert(g.next() == nil, "Unexpected supplementary token")
    }
    
}
