//
//  ResolverTests.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/13/15.
//
//

import XCTest
import MathParser

class TokenResolverTests: XCTestCase {
    
    func testNumber() {
        let r = TokenResolver(string: "1")
        let tokens = XCTAssertNoThrows(try r.resolve())
        
        XCTAssertEqual(tokens?.count, 1)
        TestToken(tokens?[0], kind: ResolvedTokenKind.Number(1), string: "1")
    }
    
    func testHexNumber() {
        let r = TokenResolver(string: "0x10")
        let tokens = XCTAssertNoThrows(try r.resolve())
        
        XCTAssertEqual(tokens?.count, 1)
        TestToken(tokens?[0], kind: ResolvedTokenKind.Number(16), string: "10")
    }
    
    func testVariable() {
        let r = TokenResolver(string: "$foo")
        let tokens = XCTAssertNoThrows(try r.resolve())
        
        XCTAssertEqual(tokens?.count, 1)
        TestToken(tokens?[0], kind: ResolvedTokenKind.Variable("foo"), string: "foo")
    }
    
    func testIdentifier() {
        let r = TokenResolver(string: "foo")
        let tokens = XCTAssertNoThrows(try r.resolve())
        
        XCTAssertEqual(tokens?.count, 1)
        TestToken(tokens?[0], kind: ResolvedTokenKind.Identifier("foo"), string: "foo")
    }

}