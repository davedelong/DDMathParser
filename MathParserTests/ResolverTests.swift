//
//  ResolverTests.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/13/15.
//
//

import XCTest
import MathParser

private func TestToken(raw: ResolvedToken?, kind: ResolvedToken.Kind, string: String, file: String = __FILE__, line: UInt = __LINE__) {
    guard let t = raw else {
        XCTFail("Missing token", file: file, line: line)
        return
    }
    
    XCTAssert(t.kind == kind, "Unexpected token kind", file: file, line: line)
    
    XCTAssertEqual(t.string, string, "Unexpected token string", file: file, line: line)
}

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
        let r = TokenResolver(string: "foo", options: [])
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
    
    func testArgumentlessFunction() {
        let r = TokenResolver(string: "foo")
        let tokens = XCTAssertNoThrows(try r.resolve())
        
        XCTAssertEqual(tokens?.count, 3)
        
        TestToken(tokens?[0], kind: .Identifier("foo"), string: "foo")
        
        let open = Operator(builtInOperator: .ParenthesisOpen)
        TestToken(tokens?[1], kind: .Operator(open), string: "(")
        
        let close = Operator(builtInOperator: .ParenthesisClose)
        TestToken(tokens?[2], kind: .Operator(close), string: ")")
    }
    
    func testArgumentlessFunction1() {
        let r = TokenResolver(string: "foo+")
        let tokens = XCTAssertNoThrows(try r.resolve())
        
        XCTAssertEqual(tokens?.count, 4)
        
        TestToken(tokens?[0], kind: .Identifier("foo"), string: "foo")
        
        let open = Operator(builtInOperator: .ParenthesisOpen)
        TestToken(tokens?[1], kind: .Operator(open), string: "(")
        
        let close = Operator(builtInOperator: .ParenthesisClose)
        TestToken(tokens?[2], kind: .Operator(close), string: ")")
        
        let add = Operator(builtInOperator: .Add)
        TestToken(tokens?[3], kind: .Operator(add), string: "+")
    }
    
    func testArgumentlessFunction2() {
        let r = TokenResolver(string: "foo()")
        let tokens = XCTAssertNoThrows(try r.resolve())
        
        XCTAssertEqual(tokens?.count, 3)
        
        TestToken(tokens?[0], kind: .Identifier("foo"), string: "foo")
        
        let open = Operator(builtInOperator: .ParenthesisOpen)
        TestToken(tokens?[1], kind: .Operator(open), string: "(")
        
        let close = Operator(builtInOperator: .ParenthesisClose)
        TestToken(tokens?[2], kind: .Operator(close), string: ")")
    }
    
    func testImplicitMultiplication() {
        let r = TokenResolver(string: "1 2")
        let tokens = XCTAssertNoThrows(try r.resolve())
        
        XCTAssertEqual(tokens?.count, 3)
        TestToken(tokens?[0], kind: .Number(1), string: "1")
        
        let op = Operator(builtInOperator: .Multiply)
        TestToken(tokens?[1], kind: .Operator(op), string: "*")
        TestToken(tokens?[2], kind: .Number(2), string: "2")
        
    }
    
    func testHighPrecedenceImplicitMultiplication() {
        let options = TokenResolverOptions.DefaultOptions.union(.UseHighPrecedenceImplicitMultiplication)
        let r = TokenResolver(string: "1 2", options: options)
        let tokens = XCTAssertNoThrows(try r.resolve())
        
        XCTAssertEqual(tokens?.count, 3)
        TestToken(tokens?[0], kind: .Number(1), string: "1")
        
        let op = Operator(builtInOperator: .ImplicitMultiply)
        TestToken(tokens?[1], kind: .Operator(op), string: "*")
        TestToken(tokens?[2], kind: .Number(2), string: "2")
        
    }

}