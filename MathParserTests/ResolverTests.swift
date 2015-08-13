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
        TestToken(tokens?[0], kind: .Number(1), string: "1")
    }
    
    func testHexNumber() {
        let r = TokenResolver(string: "0x10")
        let tokens = XCTAssertNoThrows(try r.resolve())
        
        XCTAssertEqual(tokens?.count, 1)
        TestToken(tokens?[0], kind: .Number(16), string: "10")
    }
    
    func testVariable() {
        let r = TokenResolver(string: "$foo")
        let tokens = XCTAssertNoThrows(try r.resolve())
        
        XCTAssertEqual(tokens?.count, 1)
        TestToken(tokens?[0], kind: .Variable("foo"), string: "foo")
    }
    
    func testIdentifier() {
        let r = TokenResolver(string: "foo")
        let tokens = XCTAssertNoThrows(try r.resolve())
        
        XCTAssertEqual(tokens?.count, 1)
        TestToken(tokens?[0], kind: .Identifier("foo"), string: "foo")
    }
    
    func testSimpleOperator() {
        let r = TokenResolver(string: "+")
        let tokens = XCTAssertNoThrows(try r.resolve())
        
        XCTAssertEqual(tokens?.count, 1)
        
        let op = Operator(builtInOperator: .UnaryPlus)
        TestToken(tokens?[0], kind: .Operator(op), string: "+")
    }
    
    func testUnambiguousOperator() {
        let r = TokenResolver(string: "^")
        let tokens = XCTAssertNoThrows(try r.resolve())
        
        XCTAssertEqual(tokens?.count, 1)
        
        let op = Operator(builtInOperator: .BitwiseXor)
        TestToken(tokens?[0], kind: .Operator(op), string: "^")
    }
    
    func testOperatorDisambiguation1() {
        let r = TokenResolver(string: "++")
        let tokens = XCTAssertNoThrows(try r.resolve())
        
        XCTAssertEqual(tokens?.count, 2)
        
        let op = Operator(builtInOperator: .UnaryPlus)
        TestToken(tokens?[0], kind: .Operator(op), string: "+")
        TestToken(tokens?[1], kind: .Operator(op), string: "+")
    }
    
    func testOperatorDisambiguation2() {
        let r = TokenResolver(string: "1+")
        let tokens = XCTAssertNoThrows(try r.resolve())
        
        XCTAssertEqual(tokens?.count, 2)
        
        let op = Operator(builtInOperator: .Add)
        TestToken(tokens?[0], kind: .Number(1), string: "1")
        TestToken(tokens?[1], kind: .Operator(op), string: "+")
    }
    
    func testOperatorDisambiguation3() {
        let r = TokenResolver(string: "1 2 !", options: [])
        let tokens = XCTAssertNoThrows(try r.resolve())
        
        XCTAssertEqual(tokens?.count, 3)
        
        TestToken(tokens?[0], kind: .Number(1), string: "1")
        TestToken(tokens?[1], kind: .Number(2), string: "2")
        
        let fac = Operator(builtInOperator: .Factorial)
        TestToken(tokens?[2], kind: .Operator(fac), string: "!")
    }
    
    func testOperatorDisambiguation4() {
        let r = TokenResolver(string: "1°!")
        let tokens = XCTAssertNoThrows(try r.resolve())
        
        XCTAssertEqual(tokens?.count, 3)
        
        TestToken(tokens?[0], kind: .Number(1), string: "1")
        
        let deg = Operator(builtInOperator: .Degree)
        TestToken(tokens?[1], kind: .Operator(deg), string: "°")
        
        let fac = Operator(builtInOperator: .Factorial)
        TestToken(tokens?[2], kind: .Operator(fac), string: "!")
    }
    
    func testOperatorDisambiguation5() {
        let r = TokenResolver(string: "1°+")
        let tokens = XCTAssertNoThrows(try r.resolve())
        
        XCTAssertEqual(tokens?.count, 3)
        
        TestToken(tokens?[0], kind: .Number(1), string: "1")
        
        let deg = Operator(builtInOperator: .Degree)
        TestToken(tokens?[1], kind: .Operator(deg), string: "°")
        
        let fac = Operator(builtInOperator: .Add)
        TestToken(tokens?[2], kind: .Operator(fac), string: "+")
    }

}