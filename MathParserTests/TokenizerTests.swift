//
//  TokenizerTests.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/7/15.
//
//

import XCTest
import MathParser

func TestToken(t: Either<Token, TokenizerError>?, kind: Token.Kind, string: String, file: String = __FILE__, line: UInt = __LINE__) {
    
    XCTAssert(t != nil, "Expected non-nil token", file: file, line: line)
    XCTAssert(t?.hasValue == true, "Expected value token", file: file, line: line)
    
    let token = t?.value
    XCTAssertEqual(token?.kind, kind, "Unexpected token kind", file: file, line: line)
    XCTAssertEqual(token?.string, string, "Unexpected token string", file: file, line: line)
}

class TokenizerTests: XCTestCase {
    
    func testEmpty() {
        let g = Tokenizer(string: "").generate()
        
        XCTAssert(g.next() == nil, "Unexpected token")
    }
    
    func testWhitespace() {
        let g = Tokenizer(string: "").generate()
        
        XCTAssert(g.next() == nil, "Unexpected token")
    }
    
    func testWhitespaceBetweenTokens() {
        let g = Tokenizer(string: "1 2").generate()
        
        TestToken(g.next(), kind: .Number, string: "1")
        TestToken(g.next(), kind: .Number, string: "2")
        XCTAssert(g.next() == nil, "Unexpected token")
    }
    
    func testHexNumber() {
        let g = Tokenizer(string: "0x0123").generate()
        
        TestToken(g.next(), kind: .HexNumber, string: "0x0123")
        XCTAssert(g.next() == nil, "Unexpected token")
    }
    
    func testBadHexNumber() {
        // this looks like a bad hex number,
        // but it's really a zero followed by an x
        let g = Tokenizer(string: "0x").generate()
        
        TestToken(g.next(), kind: .Number, string: "0")
        TestToken(g.next(), kind: .Identifier, string: "x")
        XCTAssert(g.next() == nil, "Unexpected token")
    }
    
    func testNumber() {
        let g = Tokenizer(string: "0123").generate()
        
        TestToken(g.next(), kind: .Number, string: "0123")
        XCTAssert(g.next() == nil, "Unexpected token")
    }
    
    func testFloatNumber() {
        let g = Tokenizer(string: "1.23").generate()
        
        TestToken(g.next(), kind: .Number, string: "1.23")
        XCTAssert(g.next() == nil, "Unexpected token")
    }
    
    func testENumber() {
        let g = Tokenizer(string: "1.23e5").generate()
        
        TestToken(g.next(), kind: .Number, string: "1.23e5")
        XCTAssert(g.next() == nil, "Unexpected token")
    }
    
    func testEPlusNumber() {
        let g = Tokenizer(string: "1.23e+5").generate()
        
        TestToken(g.next(), kind: .Number, string: "1.23e+5")
        XCTAssert(g.next() == nil, "Unexpected token")
    }
    
    func testEMinusNumber() {
        let g = Tokenizer(string: "1.23e-5").generate()
        
        TestToken(g.next(), kind: .Number, string: "1.23e-5")
        XCTAssert(g.next() == nil, "Unexpected token")
    }
    
    func testMissingExponentNumber() {
        let g = Tokenizer(string: "1.23e").generate()
        
        TestToken(g.next(), kind: .Number, string: "1.23")
        TestToken(g.next(), kind: .Identifier, string: "e")
        XCTAssert(g.next() == nil, "Unexpected token")
    }

    func testVariable() {
        let g = Tokenizer(string: "$foo").generate()
        
        TestToken(g.next(), kind: .Variable, string: "foo")
        XCTAssert(g.next() == nil, "Unexpected token")
    }
    
    func testDoubleQuotedVariable() {
        let g = Tokenizer(string: "\"foo\"").generate()
        
        TestToken(g.next(), kind: .Variable, string: "foo")
        XCTAssert(g.next() == nil, "Unexpected token")
    }
    
    func testSingleQuotedVariable() {
        let g = Tokenizer(string: "'foo'").generate()
        
        TestToken(g.next(), kind: .Variable, string: "foo")
        XCTAssert(g.next() == nil, "Unexpected token")
    }
    
    func testQuotedAndEscapedVariable() {
        let g = Tokenizer(string: "\"foo\\\"\"").generate()
        
        TestToken(g.next(), kind: .Variable, string: "foo\"")
        XCTAssert(g.next() == nil, "Unexpected token")
    }
    
    func testMissingQuoteVariable() {
        let g = Tokenizer(string: "\"foo").generate()
        
        let t = g.next()
        XCTAssert(t != nil, "Expected non-nil token")
        XCTAssertEqual(t?.hasError, true, "Expected error, but got \(t?.value)")
        
        let error = t?.error
        XCTAssertEqual(error?.kind, .CannotParseQuotedVariable, "Expected variable error")
        
        XCTAssert(g.next() == nil, "Unexpected token")
    }
    
    func testEmptyQuotedVariable() {
        let g = Tokenizer(string: "\"\"").generate()
        
        let t = g.next()
        XCTAssert(t != nil, "Expected non-nil token")
        XCTAssertEqual(t?.hasError, true, "Expected error, but got \(t?.value)")
        
        let error = t?.error
        XCTAssertEqual(error?.kind, .ZeroLengthVariable, "Expected variable error")
        
        XCTAssert(g.next() == nil, "Unexpected token")
    }
    
    func testBadVariable() {
        let g = Tokenizer(string: "$").generate()
        
        let t = g.next()
        XCTAssert(t != nil, "Expected non-nil token")
        XCTAssertEqual(t?.hasError, true, "Expected error, but got \(t?.value)")
        
        let error = t?.error
        XCTAssertEqual(error?.kind, .CannotParseVariable, "Expected variable error")
        
        XCTAssert(g.next() == nil, "Unexpected token")
    }
    
}
