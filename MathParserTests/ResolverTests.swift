//
//  ResolverTests.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/13/15.
//
//

import XCTest
import MathParser

private func TestToken(_ raw: ResolvedToken, kind: ResolvedToken.Kind, string: String, file: StaticString = #file, line: UInt = #line) {
    
    switch (raw.kind, kind) {
        case (.Number(let l), .Number(let r)): XCTAssertEqual(l, r, "Unexpected number value", file: file, line: line)
        case (.Variable(let l), .Variable(let r)): XCTAssertEqual(l, r, "Unexpected variable value", file: file, line: line)
        case (.Identifier(let l), .Identifier(let r)): XCTAssertEqual(l, r, "Unexpected identifier", file: file, line: line)
        case (.operator(let l), .operator(let r)): XCTAssertEqual(l, r, "Unexpected operator", file: file, line: line)
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
            "½": 0.5,
            "⅓": 0.3333333,
            "⅔": 0.6666666,
            "¼": 0.25,
            "¾": 0.75,
            "⅕": 0.2,
            "⅖": 0.4,
            "⅗": 0.6,
            "⅘": 0.8,
            "⅙": 0.1666666,
            "⅚": 0.8333333,
            "⅛": 0.125,
            "⅜": 0.375,
            "⅝": 0.625,
            "⅞": 0.875
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
    
    func testOctalNumber() {
        let r = TokenResolver(string: "0o10")
        guard let tokens = XCTAssertNoThrows(try r.resolve()) else { return }
        
        XCTAssertEqual(tokens.count, 1)
        TestToken(tokens[0], kind: .Number(8), string: "10")
    }
    
    func testExponent() {
        guard let tokens = XCTAssertNoThrows(try TokenResolver(string: "2²").resolve()) else { return }
        
        XCTAssertEqual(tokens.count, 5)
        TestToken(tokens[0], kind: .Number(2), string: "2")
        TestToken(tokens[1], kind: .operator(Operator(builtInOperator: .Power)), string: "**")
        TestToken(tokens[2], kind: .operator(Operator(builtInOperator: .ParenthesisOpen)), string: "(")
        TestToken(tokens[3], kind: .Number(2), string: "2")
        TestToken(tokens[4], kind: .operator(Operator(builtInOperator: .ParenthesisClose)), string: ")")
    }
    
    func testNegatedExponent() {
        guard let tokens = XCTAssertNoThrows(try TokenResolver(string: "2⁻²").resolve()) else { return }
        
        XCTAssertEqual(tokens.count, 6)
        TestToken(tokens[0], kind: .Number(2), string: "2")
        TestToken(tokens[1], kind: .operator(Operator(builtInOperator: .Power)), string: "**")
        TestToken(tokens[2], kind: .operator(Operator(builtInOperator: .ParenthesisOpen)), string: "(")
        TestToken(tokens[3], kind: .operator(Operator(builtInOperator: .UnaryMinus)), string: "-")
        TestToken(tokens[4], kind: .Number(2), string: "2")
        TestToken(tokens[5], kind: .operator(Operator(builtInOperator: .ParenthesisClose)), string: ")")
    }
    
    func testComplexExponent() {
        guard let tokens = XCTAssertNoThrows(try TokenResolver(string: "2⁻⁽²⁺¹⁾⁺⁵").resolve()) else { return }
        
        XCTAssertEqual(tokens.count, 12)
        TestToken(tokens[0], kind: .Number(2), string: "2")
        TestToken(tokens[1], kind: .operator(Operator(builtInOperator: .Power)), string: "**")
        TestToken(tokens[2], kind: .operator(Operator(builtInOperator: .ParenthesisOpen)), string: "(")
        TestToken(tokens[3], kind: .operator(Operator(builtInOperator: .UnaryMinus)), string: "-")
        TestToken(tokens[4], kind: .operator(Operator(builtInOperator: .ParenthesisOpen)), string: "(")
        TestToken(tokens[5], kind: .Number(2), string: "2")
        TestToken(tokens[6], kind: .operator(Operator(builtInOperator: .Add)), string: "+")
        TestToken(tokens[7], kind: .Number(1), string: "1")
        TestToken(tokens[8], kind: .operator(Operator(builtInOperator: .ParenthesisClose)), string: ")")
        TestToken(tokens[9], kind: .operator(Operator(builtInOperator: .Add)), string: "+")
        TestToken(tokens[10], kind: .Number(5), string: "5")
        TestToken(tokens[11], kind: .operator(Operator(builtInOperator: .ParenthesisClose)), string: ")")
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
        TestToken(tokens[0], kind: .operator(op), string: "+")
    }
    
    func testUnambiguousOperator() {
        let r = TokenResolver(string: "^")
        guard let tokens = XCTAssertNoThrows(try r.resolve()) else { return }
        
        XCTAssertEqual(tokens.count, 1)
        
        let op = Operator(builtInOperator: .BitwiseXor)
        TestToken(tokens[0], kind: .operator(op), string: "^")
    }
    
    func testCustomOperatorTokens() {
        let ops = OperatorSet()
        
        let tests: Dictionary<String, BuiltInOperator> = [
            "is": .LogicalEqual,
            "equals": .LogicalEqual,
            "is not": .LogicalNotEqual,
            "isn't": .LogicalNotEqual,
            "doesn't equal": .LogicalNotEqual,
            "is less than": .LogicalLessThan,
            "is or is less than": .LogicalLessThanOrEqual,
            "is less than or equal to": .LogicalLessThanOrEqual,
            "is greater than": .LogicalGreaterThan,
            "is or is greater than": .LogicalGreaterThanOrEqual,
            "is greater than or equal to": .LogicalGreaterThanOrEqual,
            "is not less than": .LogicalGreaterThanOrEqual
        ]
        
        for (token, builtInOperator) in tests {
            let op = Operator(builtInOperator: builtInOperator)
            ops.addTokens([token], forOperator: op)
            
            let string = "1 \(token) 2"
            guard let tokens = XCTAssertNoThrows(try TokenResolver(string: string, operatorSet: ops).resolve()) else { return }
            XCTAssertEqual(tokens.count, 3)
            TestToken(tokens[1], kind: .operator(op), string: token)
        }
    }
    
    func testOperatorDisambiguation1() {
        let r = TokenResolver(string: "++")
        guard let tokens = XCTAssertNoThrows(try r.resolve()) else { return }
        
        XCTAssertEqual(tokens.count, 2)
        
        let op = Operator(builtInOperator: .UnaryPlus)
        TestToken(tokens[0], kind: .operator(op), string: "+")
        TestToken(tokens[1], kind: .operator(op), string: "+")
    }
    
    func testOperatorDisambiguation2() {
        let r = TokenResolver(string: "1+")
        guard let tokens = XCTAssertNoThrows(try r.resolve()) else { return }
        
        XCTAssertEqual(tokens.count, 2)
        
        let op = Operator(builtInOperator: .Add)
        TestToken(tokens[0], kind: .Number(1), string: "1")
        TestToken(tokens[1], kind: .operator(op), string: "+")
    }
    
    func testOperatorDisambiguation3() {
        let r = TokenResolver(string: "1 2 !", options: [])
        guard let tokens = XCTAssertNoThrows(try r.resolve()) else { return }
        
        XCTAssertEqual(tokens.count, 3)
        
        TestToken(tokens[0], kind: .Number(1), string: "1")
        TestToken(tokens[1], kind: .Number(2), string: "2")
        
        let fac = Operator(builtInOperator: .Factorial)
        TestToken(tokens[2], kind: .operator(fac), string: "!")
    }
    
    func testOperatorDisambiguation4() {
        let r = TokenResolver(string: "1°!")
        guard let tokens = XCTAssertNoThrows(try r.resolve()) else { return }
        
        XCTAssertEqual(tokens.count, 3)
        
        TestToken(tokens[0], kind: .Number(1), string: "1")
        
        let deg = Operator(builtInOperator: .Degree)
        TestToken(tokens[1], kind: .operator(deg), string: "°")
        
        let fac = Operator(builtInOperator: .Factorial)
        TestToken(tokens[2], kind: .operator(fac), string: "!")
    }
    
    func testOperatorDisambiguation5() {
        let r = TokenResolver(string: "1°+")
        guard let tokens = XCTAssertNoThrows(try r.resolve()) else { return }
        
        XCTAssertEqual(tokens.count, 3)
        
        TestToken(tokens[0], kind: .Number(1), string: "1")
        
        let deg = Operator(builtInOperator: .Degree)
        TestToken(tokens[1], kind: .operator(deg), string: "°")
        
        let fac = Operator(builtInOperator: .Add)
        TestToken(tokens[2], kind: .operator(fac), string: "+")
    }
    
    func testArgumentlessFunction() {
        let r = TokenResolver(string: "foo")
        guard let tokens = XCTAssertNoThrows(try r.resolve()) else { return }
        
        XCTAssertEqual(tokens.count, 3)
        
        TestToken(tokens[0], kind: .Identifier("foo"), string: "foo")
        
        let open = Operator(builtInOperator: .ParenthesisOpen)
        TestToken(tokens[1], kind: .operator(open), string: "(")
        
        let close = Operator(builtInOperator: .ParenthesisClose)
        TestToken(tokens[2], kind: .operator(close), string: ")")
    }
    
    func testArgumentlessFunction1() {
        let r = TokenResolver(string: "foo+")
        guard let tokens = XCTAssertNoThrows(try r.resolve()) else { return }
        
        XCTAssertEqual(tokens.count, 4)
        
        TestToken(tokens[0], kind: .Identifier("foo"), string: "foo")
        
        let open = Operator(builtInOperator: .ParenthesisOpen)
        TestToken(tokens[1], kind: .operator(open), string: "(")
        
        let close = Operator(builtInOperator: .ParenthesisClose)
        TestToken(tokens[2], kind: .operator(close), string: ")")
        
        let add = Operator(builtInOperator: .Add)
        TestToken(tokens[3], kind: .operator(add), string: "+")
    }
    
    func testArgumentlessFunction2() {
        let r = TokenResolver(string: "foo()")
        guard let tokens = XCTAssertNoThrows(try r.resolve()) else { return }
        
        XCTAssertEqual(tokens.count, 3)
        
        TestToken(tokens[0], kind: .Identifier("foo"), string: "foo")
        
        let open = Operator(builtInOperator: .ParenthesisOpen)
        TestToken(tokens[1], kind: .operator(open), string: "(")
        
        let close = Operator(builtInOperator: .ParenthesisClose)
        TestToken(tokens[2], kind: .operator(close), string: ")")
    }
    
    func testImplicitMultiplication() {
        let r = TokenResolver(string: "1 2")
        guard let tokens = XCTAssertNoThrows(try r.resolve()) else { return }
        
        XCTAssertEqual(tokens.count, 3)
        TestToken(tokens[0], kind: .Number(1), string: "1")
        
        let op = Operator(builtInOperator: .ImplicitMultiply)
        TestToken(tokens[1], kind: .operator(op), string: "*")
        TestToken(tokens[2], kind: .Number(2), string: "2")
        
    }
    
    func testLowPrecedenceImplicitMultiplication() {
        let options = TokenResolverOptions.defaultOptions.subtracting(.useHighPrecedenceImplicitMultiplication)
        let r = TokenResolver(string: "1 2", options: options)
        guard let tokens = XCTAssertNoThrows(try r.resolve()) else { return }
        
        XCTAssertEqual(tokens.count, 3)
        TestToken(tokens[0], kind: .Number(1), string: "1")
        
        let op = Operator(builtInOperator: .Multiply)
        TestToken(tokens[1], kind: .operator(op), string: "*")
        TestToken(tokens[2], kind: .Number(2), string: "2")
        
    }
    
    func testUnaryPlus() {
        guard let tokens = XCTAssertNoThrows(try TokenResolver(string: "+1").resolve()) else { return }
        
        XCTAssertEqual(tokens.count, 2)
        let unaryPlus = Operator(builtInOperator: .UnaryPlus)
        TestToken(tokens[0], kind: .operator(unaryPlus), string: "+")
        TestToken(tokens[1], kind: .Number(1), string: "1")
    }
    
    func testLocalizedNumber() {
        let l = Locale(identifier: "fr_FR")
        guard let tokens = XCTAssertNoThrows(try TokenResolver(string: "1,23", locale: l).resolve()) else { return }
        
        XCTAssertEqual(tokens.count, 1)
        TestToken(tokens[0], kind: .Number(1.23), string: "1,23")
    }
    
    func testLocalizedNumbers() {
        let l = Locale(identifier: "fr_FR")
        guard let tokens = XCTAssertNoThrows(try TokenResolver(string: "sum(1,2, 34, 5,6,7,8,9)", locale: l).resolve()) else { return }
        
        XCTAssertEqual(tokens.count, 12)
        let comma = Operator(builtInOperator: .Comma)
        
        TestToken(tokens[0], kind: .Identifier("sum"), string: "sum")
        TestToken(tokens[1], kind: .operator(Operator(builtInOperator: .ParenthesisOpen)), string: "(")
        TestToken(tokens[2], kind: .Number(1.2), string: "1,2")
        TestToken(tokens[3], kind: .operator(comma), string: ",")
        TestToken(tokens[4], kind: .Number(34), string: "34")
        TestToken(tokens[5], kind: .operator(comma), string: ",")
        TestToken(tokens[6], kind: .Number(5.6), string: "5,6")
        TestToken(tokens[7], kind: .operator(comma), string: ",")
        TestToken(tokens[8], kind: .Number(7.8), string: "7,8")
        TestToken(tokens[9], kind: .operator(comma), string: ",")
        TestToken(tokens[10], kind: .Number(9), string: "9")
        TestToken(tokens[11], kind: .operator(Operator(builtInOperator: .ParenthesisClose)), string: ")")
    }
    
    func testLocalizedNumbersForEveryLocale() {
        let locales = Locale.availableIdentifiers.map { Locale(identifier: $0) }
        
        for locale in locales {
            let n = arc4random()
            let f = NumberFormatter()
            f.numberStyle = .decimal
            f.usesGroupingSeparator = false
            f.locale = locale
            
            let s = f.string(from: NSNumber(value: n))!
            let string = "\(s) + \(s)"
            
            guard let tokens = XCTAssertNoThrows(try TokenResolver(string: string, locale: locale).resolve()) else { return }
            XCTAssertEqual(tokens.count, 3)
            
            TestToken(tokens[0], kind: .Number(Double(n)), string: s)
            TestToken(tokens[1], kind: .operator(Operator(builtInOperator: .Add)), string: "+")
            TestToken(tokens[2], kind: .Number(Double(n)), string: s)
        }
    }

}
