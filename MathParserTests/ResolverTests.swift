//
//  ResolverTests.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/13/15.
//
//

import XCTest
import MathParser

private func TestToken(raw: ResolvedToken, kind: ResolvedToken.Kind, string: String, file: String = __FILE__, line: UInt = __LINE__) {
    
    switch (raw.kind, kind) {
        case (.Number(let l), .Number(let r)): XCTAssertEqual(l, r, "Unexpected number value", file: file, line: line)
        case (.Variable(let l), .Variable(let r)): XCTAssertEqual(l, r, "Unexpected variable value", file: file, line: line)
        case (.Identifier(let l), .Identifier(let r)): XCTAssertEqual(l, r, "Unexpected identifier", file: file, line: line)
        case (.Operator(let l), .Operator(let r)): XCTAssertEqual(l, r, "Unexpected operator", file: file, line: line)
        default: XCTFail("Unexpected token", file: file, line: line)
    }
    
    XCTAssertEqual(raw.string, string, "Unexpected token string", file: file, line: line)
}

class TokenResolverTests: XCTestCase {
    
    func testNumber() {
        let r = TokenResolver(string: "1")
        guard let tokens = XCTAssertNoThrows(try r.resolve()) else { return }
        
        XCTAssertEqual(tokens.count, 1)
        TestToken(tokens[0], kind: .Number(1), string: "1")
    }
    
    func testSpecialNumbers() {
        let specialNumbers: Dictionary<String, Double> = [
            "½": 1.0/2,
            "⅓": 1.0/3,
            "⅔": 2.0/3,
            "¼": 1.0/4,
            "¾": 3.0/4,
            "⅕": 1.0/5,
            "⅖": 2.0/5,
            "⅗": 3.0/5,
            "⅘": 4.0/5,
            "⅙": 1.0/6,
            "⅚": 5.0/6,
            "⅛": 1.0/8,
            "⅜": 3.0/8,
            "⅝": 5.0/8,
            "⅞": 7.0/8
        ]
            
        for (string, value) in specialNumbers {
            guard let tokens = XCTAssertNoThrows(try TokenResolver(string: string).resolve()) else { return }
            XCTAssertEqual(tokens.count, 1)
            TestToken(tokens[0], kind: .Number(value), string: string)
        }
    }
    
    func testHexNumber() {
        let r = TokenResolver(string: "0x10")
        guard let tokens = XCTAssertNoThrows(try r.resolve()) else { return }
        
        XCTAssertEqual(tokens.count, 1)
        TestToken(tokens[0], kind: .Number(16), string: "10")
    }
    
    func testExponent() {
        guard let tokens = XCTAssertNoThrows(try TokenResolver(string: "2²").resolve()) else { return }
        
        XCTAssertEqual(tokens.count, 3)
        TestToken(tokens[0], kind: .Number(2), string: "2")
        
        let op = Operator(builtInOperator: .Power)
        TestToken(tokens[1], kind: .Operator(op), string: "**")
        TestToken(tokens[2], kind: .Number(2), string: "2")
    }
    
    func testVariable() {
        let r = TokenResolver(string: "$foo")
        guard let tokens = XCTAssertNoThrows(try r.resolve()) else { return }
        
        XCTAssertEqual(tokens.count, 1)
        TestToken(tokens[0], kind: .Variable("foo"), string: "foo")
    }
    
    func testIdentifier() {
        let r = TokenResolver(string: "foo", options: [])
        guard let tokens = XCTAssertNoThrows(try r.resolve()) else { return }
        
        XCTAssertEqual(tokens.count, 1)
        TestToken(tokens[0], kind: .Identifier("foo"), string: "foo")
    }
    
    func testSimpleOperator() {
        let r = TokenResolver(string: "+")
        guard let tokens = XCTAssertNoThrows(try r.resolve()) else { return }
        
        XCTAssertEqual(tokens.count, 1)
        
        let op = Operator(builtInOperator: .UnaryPlus)
        TestToken(tokens[0], kind: .Operator(op), string: "+")
    }
    
    func testUnambiguousOperator() {
        let r = TokenResolver(string: "^")
        guard let tokens = XCTAssertNoThrows(try r.resolve()) else { return }
        
        XCTAssertEqual(tokens.count, 1)
        
        let op = Operator(builtInOperator: .BitwiseXor)
        TestToken(tokens[0], kind: .Operator(op), string: "^")
    }
    
    func testOperatorDisambiguation1() {
        let r = TokenResolver(string: "++")
        guard let tokens = XCTAssertNoThrows(try r.resolve()) else { return }
        
        XCTAssertEqual(tokens.count, 2)
        
        let op = Operator(builtInOperator: .UnaryPlus)
        TestToken(tokens[0], kind: .Operator(op), string: "+")
        TestToken(tokens[1], kind: .Operator(op), string: "+")
    }
    
    func testOperatorDisambiguation2() {
        let r = TokenResolver(string: "1+")
        guard let tokens = XCTAssertNoThrows(try r.resolve()) else { return }
        
        XCTAssertEqual(tokens.count, 2)
        
        let op = Operator(builtInOperator: .Add)
        TestToken(tokens[0], kind: .Number(1), string: "1")
        TestToken(tokens[1], kind: .Operator(op), string: "+")
    }
    
    func testOperatorDisambiguation3() {
        let r = TokenResolver(string: "1 2 !", options: [])
        guard let tokens = XCTAssertNoThrows(try r.resolve()) else { return }
        
        XCTAssertEqual(tokens.count, 3)
        
        TestToken(tokens[0], kind: .Number(1), string: "1")
        TestToken(tokens[1], kind: .Number(2), string: "2")
        
        let fac = Operator(builtInOperator: .Factorial)
        TestToken(tokens[2], kind: .Operator(fac), string: "!")
    }
    
    func testOperatorDisambiguation4() {
        let r = TokenResolver(string: "1°!")
        guard let tokens = XCTAssertNoThrows(try r.resolve()) else { return }
        
        XCTAssertEqual(tokens.count, 3)
        
        TestToken(tokens[0], kind: .Number(1), string: "1")
        
        let deg = Operator(builtInOperator: .Degree)
        TestToken(tokens[1], kind: .Operator(deg), string: "°")
        
        let fac = Operator(builtInOperator: .Factorial)
        TestToken(tokens[2], kind: .Operator(fac), string: "!")
    }
    
    func testOperatorDisambiguation5() {
        let r = TokenResolver(string: "1°+")
        guard let tokens = XCTAssertNoThrows(try r.resolve()) else { return }
        
        XCTAssertEqual(tokens.count, 3)
        
        TestToken(tokens[0], kind: .Number(1), string: "1")
        
        let deg = Operator(builtInOperator: .Degree)
        TestToken(tokens[1], kind: .Operator(deg), string: "°")
        
        let fac = Operator(builtInOperator: .Add)
        TestToken(tokens[2], kind: .Operator(fac), string: "+")
    }
    
    func testArgumentlessFunction() {
        let r = TokenResolver(string: "foo")
        guard let tokens = XCTAssertNoThrows(try r.resolve()) else { return }
        
        XCTAssertEqual(tokens.count, 3)
        
        TestToken(tokens[0], kind: .Identifier("foo"), string: "foo")
        
        let open = Operator(builtInOperator: .ParenthesisOpen)
        TestToken(tokens[1], kind: .Operator(open), string: "(")
        
        let close = Operator(builtInOperator: .ParenthesisClose)
        TestToken(tokens[2], kind: .Operator(close), string: ")")
    }
    
    func testArgumentlessFunction1() {
        let r = TokenResolver(string: "foo+")
        guard let tokens = XCTAssertNoThrows(try r.resolve()) else { return }
        
        XCTAssertEqual(tokens.count, 4)
        
        TestToken(tokens[0], kind: .Identifier("foo"), string: "foo")
        
        let open = Operator(builtInOperator: .ParenthesisOpen)
        TestToken(tokens[1], kind: .Operator(open), string: "(")
        
        let close = Operator(builtInOperator: .ParenthesisClose)
        TestToken(tokens[2], kind: .Operator(close), string: ")")
        
        let add = Operator(builtInOperator: .Add)
        TestToken(tokens[3], kind: .Operator(add), string: "+")
    }
    
    func testArgumentlessFunction2() {
        let r = TokenResolver(string: "foo()")
        guard let tokens = XCTAssertNoThrows(try r.resolve()) else { return }
        
        XCTAssertEqual(tokens.count, 3)
        
        TestToken(tokens[0], kind: .Identifier("foo"), string: "foo")
        
        let open = Operator(builtInOperator: .ParenthesisOpen)
        TestToken(tokens[1], kind: .Operator(open), string: "(")
        
        let close = Operator(builtInOperator: .ParenthesisClose)
        TestToken(tokens[2], kind: .Operator(close), string: ")")
    }
    
    func testImplicitMultiplication() {
        let r = TokenResolver(string: "1 2")
        guard let tokens = XCTAssertNoThrows(try r.resolve()) else { return }
        
        XCTAssertEqual(tokens.count, 3)
        TestToken(tokens[0], kind: .Number(1), string: "1")
        
        let op = Operator(builtInOperator: .ImplicitMultiply)
        TestToken(tokens[1], kind: .Operator(op), string: "*")
        TestToken(tokens[2], kind: .Number(2), string: "2")
        
    }
    
    func testLowPrecedenceImplicitMultiplication() {
        let options = TokenResolverOptions.defaultOptions.subtract(.UseHighPrecedenceImplicitMultiplication)
        let r = TokenResolver(string: "1 2", options: options)
        guard let tokens = XCTAssertNoThrows(try r.resolve()) else { return }
        
        XCTAssertEqual(tokens.count, 3)
        TestToken(tokens[0], kind: .Number(1), string: "1")
        
        let op = Operator(builtInOperator: .Multiply)
        TestToken(tokens[1], kind: .Operator(op), string: "*")
        TestToken(tokens[2], kind: .Number(2), string: "2")
        
    }
    
    func testUnaryPlus() {
        guard let tokens = XCTAssertNoThrows(try TokenResolver(string: "+1").resolve()) else { return }
        
        XCTAssertEqual(tokens.count, 2)
        let unaryPlus = Operator(builtInOperator: .UnaryPlus)
        guard case .Operator(unaryPlus) = tokens[0].kind else {
            XCTFail("Unexpected token kind: \(tokens[0].kind)")
            return
        }
        
        guard case .Number(1) = tokens[1].kind else {
            XCTFail("Unexpected token kind: \(tokens[1].kind)")
            return
        }
    }

}