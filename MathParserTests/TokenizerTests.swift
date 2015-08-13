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
    
    func testEmpty() {
        let tokens = XCTAssertNoThrows(try Tokenizer(string: "").tokenize())
        XCTAssertEqual(tokens?.count, 0)
    }
    
    func testWhitespace() {
        let tokens = XCTAssertNoThrows(try Tokenizer(string: "     ").tokenize())
        XCTAssertEqual(tokens?.count, 0)
    }
    
    func testWhitespaceBetweenTokens() {
        let tokens = XCTAssertNoThrows(try Tokenizer(string: "1 2").tokenize())
        
        XCTAssertEqual(tokens?.count, 2)
        TestToken(tokens?[0], kind: RawTokenKind.Number, string: "1")
        TestToken(tokens?[1], kind: RawTokenKind.Number, string: "2")
    }
    
    func testHexNumber() {
        let tokens = XCTAssertNoThrows(try Tokenizer(string: "0x0123").tokenize())
        
        XCTAssertEqual(tokens?.count, 1)
        TestToken(tokens?[0], kind: RawTokenKind.HexNumber, string: "0123")
    }
    
    func testBadHexNumber() {
        // this looks like a bad hex number,
        // but it's really a zero followed by an x
        let tokens = XCTAssertNoThrows(try Tokenizer(string: "0x").tokenize())
        
        XCTAssertEqual(tokens?.count, 2)
        TestToken(tokens?[0], kind: RawTokenKind.Number, string: "0")
        TestToken(tokens?[1], kind: RawTokenKind.Identifier, string: "x")
    }
    
    func testNumber() {
        let tokens = XCTAssertNoThrows(try Tokenizer(string: "0123").tokenize())
        
        XCTAssertEqual(tokens?.count, 1)
        TestToken(tokens?[0], kind: RawTokenKind.Number, string: "0123")
    }
    
    func testFloatNumber() {
        let tokens = XCTAssertNoThrows(try Tokenizer(string: "1.23").tokenize())
        
        XCTAssertEqual(tokens?.count, 1)
        TestToken(tokens?[0], kind: RawTokenKind.Number, string: "1.23")
    }
    
    func testENumber() {
        let tokens = XCTAssertNoThrows(try Tokenizer(string: "1.23e5").tokenize())
        
        XCTAssertEqual(tokens?.count, 1)
        TestToken(tokens?[0], kind: RawTokenKind.Number, string: "1.23e5")
    }
    
    func testEPlusNumber() {
        let tokens = XCTAssertNoThrows(try Tokenizer(string: "1.23e+5").tokenize())
        
        XCTAssertEqual(tokens?.count, 1)
        TestToken(tokens?[0], kind: RawTokenKind.Number, string: "1.23e+5")
    }
    
    func testEMinusNumber() {
        let tokens = XCTAssertNoThrows(try Tokenizer(string: "1.23e-5").tokenize())
        
        XCTAssertEqual(tokens?.count, 1)
        TestToken(tokens?[0], kind: RawTokenKind.Number, string: "1.23e-5")
    }
    
    func testMissingExponentNumber() {
        let tokens = XCTAssertNoThrows(try Tokenizer(string: "1.23e").tokenize())
        
        XCTAssertEqual(tokens?.count, 2)
        TestToken(tokens?[0], kind: RawTokenKind.Number, string: "1.23")
        TestToken(tokens?[1], kind: RawTokenKind.Identifier, string: "e")
    }

    func testVariable() {
        let tokens = XCTAssertNoThrows(try Tokenizer(string: "$foo").tokenize())
        
        XCTAssertEqual(tokens?.count, 1)
        TestToken(tokens?[0], kind: RawTokenKind.Variable, string: "foo")
    }
    
    func testDoubleQuotedVariable() {
        let tokens = XCTAssertNoThrows(try Tokenizer(string: "\"foo\"").tokenize())
        
        XCTAssertEqual(tokens?.count, 1)
        TestToken(tokens?[0], kind: RawTokenKind.Variable, string: "foo")
    }
    
    func testSingleQuotedVariable() {
        let tokens = XCTAssertNoThrows(try Tokenizer(string: "'foo'").tokenize())
        
        XCTAssertEqual(tokens?.count, 1)
        TestToken(tokens?[0], kind: RawTokenKind.Variable, string: "foo")
    }
    
    func testQuotedAndEscapedVariable() {
        let tokens = XCTAssertNoThrows(try Tokenizer(string: "\"foo\\\"\"").tokenize())
        
        XCTAssertEqual(tokens?.count, 1)
        TestToken(tokens?[0], kind: RawTokenKind.Variable, string: "foo\"")
    }
    
    func testMissingQuoteVariable() {
        do {
            try Tokenizer(string: "\"foo").tokenize()
            XCTFail("Expected thrown error")
        } catch let e as TokenizerError {
            XCTAssert(e.kind == .CannotParseQuotedVariable, "Expected variable error")
        } catch let other {
            XCTFail("Unexpected error: \(other)")
        }
    }
    
    func testEmptyQuotedVariable() {
        do {
            try Tokenizer(string: "\"\"").tokenize()
            XCTFail("Expected thrown error")
        } catch let e as TokenizerError {
            XCTAssert(e.kind == .ZeroLengthVariable, "Expected zero-length variable error")
        } catch let other {
            XCTFail("Unexpected error: \(other)")
        }
    }
    
    func testBadVariable() {
        do {
            try Tokenizer(string: "$").tokenize()
            XCTFail("Expected thrown error")
        } catch let e as TokenizerError {
            XCTAssert(e.kind == .CannotParseVariable, "Expected variable error")
        } catch let other {
            XCTFail("Unexpected error: \(other)")
        }
    }
    
    func testBasicOperator() {
        let tokens = XCTAssertNoThrows(try Tokenizer(string: "+").tokenize())
        
        XCTAssertEqual(tokens?.count, 1)
        TestToken(tokens?[0], kind: RawTokenKind.Operator, string: "+")
    }
    
    func testGreedyOperator() {
        let tokens = XCTAssertNoThrows(try Tokenizer(string: "***").tokenize())
        
        XCTAssertEqual(tokens?.count, 2)
        TestToken(tokens?[0], kind: RawTokenKind.Operator, string: "**")
        TestToken(tokens?[1], kind: RawTokenKind.Operator, string: "*")
    }
    
    func testConsecutiveOperators() {
        let tokens = XCTAssertNoThrows(try Tokenizer(string: "+-*/").tokenize())
        
        XCTAssertEqual(tokens?.count, 4)
        TestToken(tokens?[0], kind: RawTokenKind.Operator, string: "+")
        TestToken(tokens?[1], kind: RawTokenKind.Operator, string: "-")
        TestToken(tokens?[2], kind: RawTokenKind.Operator, string: "*")
        TestToken(tokens?[3], kind: RawTokenKind.Operator, string: "/")
    }
    
}
