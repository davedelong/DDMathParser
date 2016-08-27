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
        case (.number(let l), .number(let r)): XCTAssertEqual(l, r, "Unexpected number value", file: file, line: line)
        case (.variable(let l), .variable(let r)): XCTAssertEqual(l, r, "Unexpected variable value", file: file, line: line)
        case (.identifier(let l), .identifier(let r)): XCTAssertEqual(l, r, "Unexpected identifier", file: file, line: line)
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
        TestToken(tokens[0], kind: .number(1), string: "1")
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
            TestToken(tokens[0], kind: .number(value), string: string)
        }
    }
    
    func testHexNumber() {
        let r = TokenResolver(string: "0x10")
        guard let tokens = XCTAssertNoThrows(try r.resolve()) else { return }
        
        XCTAssertEqual(tokens.count, 1)
        TestToken(tokens[0], kind: .number(16), string: "10")
    }
    
    func testOctalNumber() {
        let r = TokenResolver(string: "0o10")
        guard let tokens = XCTAssertNoThrows(try r.resolve()) else { return }
        
        XCTAssertEqual(tokens.count, 1)
        TestToken(tokens[0], kind: .number(8), string: "10")
    }
    
    func testExponent() {
        guard let tokens = XCTAssertNoThrows(try TokenResolver(string: "2²").resolve()) else { return }
        
        XCTAssertEqual(tokens.count, 5)
        TestToken(tokens[0], kind: .number(2), string: "2")
        TestToken(tokens[1], kind: .operator(Operator(builtInOperator: .power)), string: "**")
        TestToken(tokens[2], kind: .operator(Operator(builtInOperator: .parenthesisOpen)), string: "(")
        TestToken(tokens[3], kind: .number(2), string: "2")
        TestToken(tokens[4], kind: .operator(Operator(builtInOperator: .parenthesisClose)), string: ")")
    }
    
    func testNegatedExponent() {
        guard let tokens = XCTAssertNoThrows(try TokenResolver(string: "2⁻²").resolve()) else { return }
        
        XCTAssertEqual(tokens.count, 6)
        TestToken(tokens[0], kind: .number(2), string: "2")
        TestToken(tokens[1], kind: .operator(Operator(builtInOperator: .power)), string: "**")
        TestToken(tokens[2], kind: .operator(Operator(builtInOperator: .parenthesisOpen)), string: "(")
        TestToken(tokens[3], kind: .operator(Operator(builtInOperator: .unaryMinus)), string: "-")
        TestToken(tokens[4], kind: .number(2), string: "2")
        TestToken(tokens[5], kind: .operator(Operator(builtInOperator: .parenthesisClose)), string: ")")
    }
    
    func testComplexExponent() {
        guard let tokens = XCTAssertNoThrows(try TokenResolver(string: "2⁻⁽²⁺¹⁾⁺⁵").resolve()) else { return }
        
        XCTAssertEqual(tokens.count, 12)
        TestToken(tokens[0], kind: .number(2), string: "2")
        TestToken(tokens[1], kind: .operator(Operator(builtInOperator: .power)), string: "**")
        TestToken(tokens[2], kind: .operator(Operator(builtInOperator: .parenthesisOpen)), string: "(")
        TestToken(tokens[3], kind: .operator(Operator(builtInOperator: .unaryMinus)), string: "-")
        TestToken(tokens[4], kind: .operator(Operator(builtInOperator: .parenthesisOpen)), string: "(")
        TestToken(tokens[5], kind: .number(2), string: "2")
        TestToken(tokens[6], kind: .operator(Operator(builtInOperator: .add)), string: "+")
        TestToken(tokens[7], kind: .number(1), string: "1")
        TestToken(tokens[8], kind: .operator(Operator(builtInOperator: .parenthesisClose)), string: ")")
        TestToken(tokens[9], kind: .operator(Operator(builtInOperator: .add)), string: "+")
        TestToken(tokens[10], kind: .number(5), string: "5")
        TestToken(tokens[11], kind: .operator(Operator(builtInOperator: .parenthesisClose)), string: ")")
    }
    
    func testVariable() {
        let r = TokenResolver(string: "$foo")
        guard let tokens = XCTAssertNoThrows(try r.resolve()) else { return }
        
        XCTAssertEqual(tokens.count, 1)
        TestToken(tokens[0], kind: .variable("foo"), string: "foo")
    }
    
    func testIdentifier() {
        let r = TokenResolver(string: "foo", options: [])
        guard let tokens = XCTAssertNoThrows(try r.resolve()) else { return }
        
        XCTAssertEqual(tokens.count, 1)
        TestToken(tokens[0], kind: .identifier("foo"), string: "foo")
    }
    
    func testSimpleOperator() {
        let r = TokenResolver(string: "+")
        guard let tokens = XCTAssertNoThrows(try r.resolve()) else { return }
        
        XCTAssertEqual(tokens.count, 1)
        
        let op = Operator(builtInOperator: .unaryPlus)
        TestToken(tokens[0], kind: .operator(op), string: "+")
    }
    
    func testUnambiguousOperator() {
        let r = TokenResolver(string: "^")
        guard let tokens = XCTAssertNoThrows(try r.resolve()) else { return }
        
        XCTAssertEqual(tokens.count, 1)
        
        let op = Operator(builtInOperator: .bitwiseXor)
        TestToken(tokens[0], kind: .operator(op), string: "^")
    }
    
    func testCustomOperatorTokens() {
        let ops = OperatorSet()
        
        let tests: Dictionary<String, BuiltInOperator> = [
            "is": .logicalEqual,
            "equals": .logicalEqual,
            "is not": .logicalNotEqual,
            "isn't": .logicalNotEqual,
            "doesn't equal": .logicalNotEqual,
            "is less than": .logicalLessThan,
            "is or is less than": .logicalLessThanOrEqual,
            "is less than or equal to": .logicalLessThanOrEqual,
            "is greater than": .logicalGreaterThan,
            "is or is greater than": .logicalGreaterThanOrEqual,
            "is greater than or equal to": .logicalGreaterThanOrEqual,
            "is not less than": .logicalGreaterThanOrEqual
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
        
        let op = Operator(builtInOperator: .unaryPlus)
        TestToken(tokens[0], kind: .operator(op), string: "+")
        TestToken(tokens[1], kind: .operator(op), string: "+")
    }
    
    func testOperatorDisambiguation2() {
        let r = TokenResolver(string: "1+")
        guard let tokens = XCTAssertNoThrows(try r.resolve()) else { return }
        
        XCTAssertEqual(tokens.count, 2)
        
        let op = Operator(builtInOperator: .add)
        TestToken(tokens[0], kind: .number(1), string: "1")
        TestToken(tokens[1], kind: .operator(op), string: "+")
    }
    
    func testOperatorDisambiguation3() {
        let r = TokenResolver(string: "1 2 !", options: [])
        guard let tokens = XCTAssertNoThrows(try r.resolve()) else { return }
        
        XCTAssertEqual(tokens.count, 3)
        
        TestToken(tokens[0], kind: .number(1), string: "1")
        TestToken(tokens[1], kind: .number(2), string: "2")
        
        let fac = Operator(builtInOperator: .factorial)
        TestToken(tokens[2], kind: .operator(fac), string: "!")
    }
    
    func testOperatorDisambiguation4() {
        let r = TokenResolver(string: "1°!")
        guard let tokens = XCTAssertNoThrows(try r.resolve()) else { return }
        
        XCTAssertEqual(tokens.count, 3)
        
        TestToken(tokens[0], kind: .number(1), string: "1")
        
        let deg = Operator(builtInOperator: .degree)
        TestToken(tokens[1], kind: .operator(deg), string: "°")
        
        let fac = Operator(builtInOperator: .factorial)
        TestToken(tokens[2], kind: .operator(fac), string: "!")
    }
    
    func testOperatorDisambiguation5() {
        let r = TokenResolver(string: "1°+")
        guard let tokens = XCTAssertNoThrows(try r.resolve()) else { return }
        
        XCTAssertEqual(tokens.count, 3)
        
        TestToken(tokens[0], kind: .number(1), string: "1")
        
        let deg = Operator(builtInOperator: .degree)
        TestToken(tokens[1], kind: .operator(deg), string: "°")
        
        let fac = Operator(builtInOperator: .add)
        TestToken(tokens[2], kind: .operator(fac), string: "+")
    }
    
    func testArgumentlessFunction() {
        let r = TokenResolver(string: "foo")
        guard let tokens = XCTAssertNoThrows(try r.resolve()) else { return }
        
        XCTAssertEqual(tokens.count, 3)
        
        TestToken(tokens[0], kind: .identifier("foo"), string: "foo")
        
        let open = Operator(builtInOperator: .parenthesisOpen)
        TestToken(tokens[1], kind: .operator(open), string: "(")
        
        let close = Operator(builtInOperator: .parenthesisClose)
        TestToken(tokens[2], kind: .operator(close), string: ")")
    }
    
    func testArgumentlessFunction1() {
        let r = TokenResolver(string: "foo+")
        guard let tokens = XCTAssertNoThrows(try r.resolve()) else { return }
        
        XCTAssertEqual(tokens.count, 4)
        
        TestToken(tokens[0], kind: .identifier("foo"), string: "foo")
        
        let open = Operator(builtInOperator: .parenthesisOpen)
        TestToken(tokens[1], kind: .operator(open), string: "(")
        
        let close = Operator(builtInOperator: .parenthesisClose)
        TestToken(tokens[2], kind: .operator(close), string: ")")
        
        let add = Operator(builtInOperator: .add)
        TestToken(tokens[3], kind: .operator(add), string: "+")
    }
    
    func testArgumentlessFunction2() {
        let r = TokenResolver(string: "foo()")
        guard let tokens = XCTAssertNoThrows(try r.resolve()) else { return }
        
        XCTAssertEqual(tokens.count, 3)
        
        TestToken(tokens[0], kind: .identifier("foo"), string: "foo")
        
        let open = Operator(builtInOperator: .parenthesisOpen)
        TestToken(tokens[1], kind: .operator(open), string: "(")
        
        let close = Operator(builtInOperator: .parenthesisClose)
        TestToken(tokens[2], kind: .operator(close), string: ")")
    }
    
    func testImplicitMultiplication() {
        let r = TokenResolver(string: "1 2")
        guard let tokens = XCTAssertNoThrows(try r.resolve()) else { return }
        
        XCTAssertEqual(tokens.count, 3)
        TestToken(tokens[0], kind: .number(1), string: "1")
        
        let op = Operator(builtInOperator: .implicitMultiply)
        TestToken(tokens[1], kind: .operator(op), string: "*")
        TestToken(tokens[2], kind: .number(2), string: "2")
        
    }
    
    func testLowPrecedenceImplicitMultiplication() {
        let options = TokenResolverOptions.default.subtracting(.useHighPrecedenceImplicitMultiplication)
        let r = TokenResolver(string: "1 2", options: options)
        guard let tokens = XCTAssertNoThrows(try r.resolve()) else { return }
        
        XCTAssertEqual(tokens.count, 3)
        TestToken(tokens[0], kind: .number(1), string: "1")
        
        let op = Operator(builtInOperator: .multiply)
        TestToken(tokens[1], kind: .operator(op), string: "*")
        TestToken(tokens[2], kind: .number(2), string: "2")
        
    }
    
    func testUnaryPlus() {
        guard let tokens = XCTAssertNoThrows(try TokenResolver(string: "+1").resolve()) else { return }
        
        XCTAssertEqual(tokens.count, 2)
        let unaryPlus = Operator(builtInOperator: .unaryPlus)
        TestToken(tokens[0], kind: .operator(unaryPlus), string: "+")
        TestToken(tokens[1], kind: .number(1), string: "1")
    }
    
    func testLocalizedNumber() {
        let l = Locale(identifier: "fr_FR")
        guard let tokens = XCTAssertNoThrows(try TokenResolver(string: "1,23", locale: l).resolve()) else { return }
        
        XCTAssertEqual(tokens.count, 1)
        TestToken(tokens[0], kind: .number(1.23), string: "1,23")
    }
    
    func testLocalizedNumbers() {
        let l = Locale(identifier: "fr_FR")
        guard let tokens = XCTAssertNoThrows(try TokenResolver(string: "sum(1,2, 34, 5,6,7,8,9)", locale: l).resolve()) else { return }
        
        XCTAssertEqual(tokens.count, 12)
        let comma = Operator(builtInOperator: .comma)
        
        TestToken(tokens[0], kind: .identifier("sum"), string: "sum")
        TestToken(tokens[1], kind: .operator(Operator(builtInOperator: .parenthesisOpen)), string: "(")
        TestToken(tokens[2], kind: .number(1.2), string: "1,2")
        TestToken(tokens[3], kind: .operator(comma), string: ",")
        TestToken(tokens[4], kind: .number(34), string: "34")
        TestToken(tokens[5], kind: .operator(comma), string: ",")
        TestToken(tokens[6], kind: .number(5.6), string: "5,6")
        TestToken(tokens[7], kind: .operator(comma), string: ",")
        TestToken(tokens[8], kind: .number(7.8), string: "7,8")
        TestToken(tokens[9], kind: .operator(comma), string: ",")
        TestToken(tokens[10], kind: .number(9), string: "9")
        TestToken(tokens[11], kind: .operator(Operator(builtInOperator: .parenthesisClose)), string: ")")
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
            
            TestToken(tokens[0], kind: .number(Double(n)), string: s)
            TestToken(tokens[1], kind: .operator(Operator(builtInOperator: .add)), string: "+")
            TestToken(tokens[2], kind: .number(Double(n)), string: s)
        }
    }

}
