//
//  TokenizerTests.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/7/15.
//
//

import XCTest
import MathParser

private func TestToken<T: RawToken>(_ raw: RawToken, kind: T.Type, string: String, file: StaticString = #file, line: UInt = #line) {
    XCTAssertTrue(raw is T, "Unexpected token kind", file: file, line: line)
    XCTAssertEqual(raw.string, string, "Unexpected token string", file: file, line: line)
}

class TokenizerTests: XCTestCase {
    
    func testEmpty() {
        guard let tokens = XCTAssertNoThrows(try Tokenizer(string: "").tokenize()) else { return }
        XCTAssertEqual(tokens.count, 0)
    }
    
    func testWhitespace() {
        guard let tokens = XCTAssertNoThrows(try Tokenizer(string: "     ").tokenize()) else { return }
        XCTAssertEqual(tokens.count, 0)
    }
    
    func testWhitespaceBetweenTokens() {
        guard let tokens = XCTAssertNoThrows(try Tokenizer(string: "1 2").tokenize()) else { return }
        
        XCTAssertEqual(tokens.count, 2)
        TestToken(tokens[0], kind: DecimalNumberToken.self, string: "1")
        TestToken(tokens[1], kind: DecimalNumberToken.self, string: "2")
    }
    
    func testHexNumber() {
        guard let tokens = XCTAssertNoThrows(try Tokenizer(string: "0x0123").tokenize()) else { return }
        
        XCTAssertEqual(tokens.count, 1)
        TestToken(tokens[0], kind: HexNumberToken.self, string: "0123")
    }
    
    func testOctalNumber() {
        guard let tokens = XCTAssertNoThrows(try Tokenizer(string: "0o0123").tokenize()) else { return }
        
        XCTAssertEqual(tokens.count, 1)
        TestToken(tokens[0], kind: OctalNumberToken.self, string: "0123")
    }
    
    func testBadHexNumber() {
        // this looks like a bad hex number,
        // but it's really a zero followed by an x
        guard let tokens = XCTAssertNoThrows(try Tokenizer(string: "0x").tokenize()) else { return }
        
        XCTAssertEqual(tokens.count, 2)
        TestToken(tokens[0], kind: DecimalNumberToken.self, string: "0")
        TestToken(tokens[1], kind: IdentifierToken.self, string: "x")
    }
    
    func testNumber() {
        guard let tokens = XCTAssertNoThrows(try Tokenizer(string: "0123").tokenize()) else { return }
        
        XCTAssertEqual(tokens.count, 1)
        TestToken(tokens[0], kind: DecimalNumberToken.self, string: "0123")
    }
    
    func testFloatNumber() {
        guard let tokens = XCTAssertNoThrows(try Tokenizer(string: "1.23").tokenize()) else { return }
        
        XCTAssertEqual(tokens.count, 1)
        TestToken(tokens[0], kind: DecimalNumberToken.self, string: "1.23")
    }
    
    func testENumber() {
        guard let tokens = XCTAssertNoThrows(try Tokenizer(string: "1.23e5").tokenize()) else { return }
        
        XCTAssertEqual(tokens.count, 1)
        TestToken(tokens[0], kind: DecimalNumberToken.self, string: "1.23e5")
    }
    
    func testEPlusNumber() {
        guard let tokens = XCTAssertNoThrows(try Tokenizer(string: "1.23e+5").tokenize()) else { return }
        
        XCTAssertEqual(tokens.count, 1)
        TestToken(tokens[0], kind: DecimalNumberToken.self, string: "1.23e+5")
    }
    
    func testEMinusNumber() {
        guard let tokens = XCTAssertNoThrows(try Tokenizer(string: "1.23e-5").tokenize()) else { return }
        
        XCTAssertEqual(tokens.count, 1)
        TestToken(tokens[0], kind: DecimalNumberToken.self, string: "1.23e-5")
    }
    
    func testSpecialNumbers() {
        let special = ["½", "⅓", "⅔", "¼", "¾", "⅕", "⅖", "⅗", "⅘", "⅙", "⅚", "⅛", "⅜", "⅝", "⅞"]
        
        for string in special {
            guard let tokens = XCTAssertNoThrows(try Tokenizer(string: string).tokenize()) else { return }
            XCTAssertEqual(tokens.count, 1)
            TestToken(tokens[0], kind: FractionNumberToken.self, string: string)
        }
    }
    
    func testExponent() {
        guard let tokens = XCTAssertNoThrows(try Tokenizer(string: "2²").tokenize()) else { return }
        
        XCTAssertEqual(tokens.count, 2)
        TestToken(tokens[0], kind: DecimalNumberToken.self, string: "2")
        TestToken(tokens[1], kind: ExponentToken.self, string: "2")
    }
    
    func testComplexExponent() {
        guard let tokens = XCTAssertNoThrows(try Tokenizer(string: "2⁻⁽²⁺¹⁾⁺⁵").tokenize()) else { return }
        
        XCTAssertEqual(tokens.count, 2)
        TestToken(tokens[0], kind: DecimalNumberToken.self, string: "2")
        TestToken(tokens[1], kind: ExponentToken.self, string: "-(2+1)+5")
    }
    
    func testMissingExponentNumber() {
        guard let tokens = XCTAssertNoThrows(try Tokenizer(string: "1.23e").tokenize()) else { return }
        
        XCTAssertEqual(tokens.count, 2)
        TestToken(tokens[0], kind: DecimalNumberToken.self, string: "1.23")
        TestToken(tokens[1], kind: IdentifierToken.self, string: "e")
    }

    func testVariable() {
        guard let tokens = XCTAssertNoThrows(try Tokenizer(string: "$foo").tokenize()) else { return }
        
        XCTAssertEqual(tokens.count, 1)
        TestToken(tokens[0], kind: VariableToken.self, string: "foo")
    }
    
    func testDoubleQuotedVariable() {
        guard let tokens = XCTAssertNoThrows(try Tokenizer(string: "\"foo\"").tokenize()) else { return }
        
        XCTAssertEqual(tokens.count, 1)
        TestToken(tokens[0], kind: VariableToken.self, string: "foo")
    }
    
    func testSingleQuotedVariable() {
        guard let tokens = XCTAssertNoThrows(try Tokenizer(string: "'foo'").tokenize()) else { return }
        
        XCTAssertEqual(tokens.count, 1)
        TestToken(tokens[0], kind: VariableToken.self, string: "foo")
    }
    
    func testQuotedAndEscapedVariable() {
        guard let tokens = XCTAssertNoThrows(try Tokenizer(string: "\"foo\\\"\"").tokenize()) else { return }
        
        XCTAssertEqual(tokens.count, 1)
        TestToken(tokens[0], kind: VariableToken.self, string: "foo\"")
    }
    
    func testMissingQuoteVariable() {
        do {
            let _ = try Tokenizer(string: "\"foo").tokenize()
            XCTFail("Expected thrown error")
        } catch let e as MathParserError {
            XCTAssert(e.kind == .cannotParseQuotedVariable, "Expected variable error")
        } catch let other {
            XCTFail("Unexpected error: \(other)")
        }
    }
    
    func testEmptyQuotedVariable() {
        do {
            let _ = try Tokenizer(string: "\"\"").tokenize()
            XCTFail("Expected thrown error")
        } catch let e as MathParserError {
            XCTAssert(e.kind == .zeroLengthVariable, "Expected zero-length variable error")
        } catch let other {
            XCTFail("Unexpected error: \(other)")
        }
    }
    
    func testBadVariable() {
        do {
            let _ = try Tokenizer(string: "$").tokenize()
            XCTFail("Expected thrown error")
        } catch let e as MathParserError {
            XCTAssert(e.kind == .cannotParseVariable, "Expected variable error")
        } catch let other {
            XCTFail("Unexpected error: \(other)")
        }
    }
    
    func testBasicOperator() {
        guard let tokens = XCTAssertNoThrows(try Tokenizer(string: "+").tokenize()) else { return }
        
        XCTAssertEqual(tokens.count, 1)
        TestToken(tokens[0], kind: OperatorToken.self, string: "+")
    }
    
    func testGreedyOperator() {
        guard let tokens = XCTAssertNoThrows(try Tokenizer(string: "***").tokenize()) else { return }
        
        XCTAssertEqual(tokens.count, 2)
        TestToken(tokens[0], kind: OperatorToken.self, string: "**")
        TestToken(tokens[1], kind: OperatorToken.self, string: "*")
    }
    
    func testConsecutiveOperators() {
        guard let tokens = XCTAssertNoThrows(try Tokenizer(string: "+-*/").tokenize()) else { return }
        
        XCTAssertEqual(tokens.count, 4)
        TestToken(tokens[0], kind: OperatorToken.self, string: "+")
        TestToken(tokens[1], kind: OperatorToken.self, string: "-")
        TestToken(tokens[2], kind: OperatorToken.self, string: "*")
        TestToken(tokens[3], kind: OperatorToken.self, string: "/")
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
            ops.addTokens([token], forOperator: Operator(builtInOperator: builtInOperator))
            
            let string = "1 \(token) 2"
            guard let tokens = XCTAssertNoThrows(try Tokenizer(string: string, operatorSet: ops).tokenize()) else { return }
            XCTAssertEqual(tokens.count, 3)
            TestToken(tokens[1], kind: OperatorToken.self, string: token)
        }
    }
    
    func testUnaryPlus() {
        guard let tokens = XCTAssertNoThrows(try Tokenizer(string: "+1").tokenize()) else { return }
        
        XCTAssertEqual(tokens.count, 2)
        TestToken(tokens[0], kind: OperatorToken.self, string: "+")
        TestToken(tokens[1], kind: DecimalNumberToken.self, string: "1")
    }
    
    func testLocalizedNumber() {
        let l = Locale(identifier: "fr_FR")
        guard let tokens = XCTAssertNoThrows(try Tokenizer(string: "1,23", locale: l).tokenize()) else { return }
        
        XCTAssertEqual(tokens.count, 1)
        TestToken(tokens[0], kind: LocalizedNumberToken.self, string: "1,23")
    }
    
    func testLocalizedNumbers() {
        let l = Locale(identifier: "fr_FR")
        guard let tokens = XCTAssertNoThrows(try Tokenizer(string: "sum(1,2, 3,4, 5,6,7,8)", locale: l).tokenize()) else { return }
        
        XCTAssertEqual(tokens.count, 10)
        TestToken(tokens[0], kind: IdentifierToken.self, string: "sum")
        TestToken(tokens[1], kind: OperatorToken.self, string: "(")
        TestToken(tokens[2], kind: LocalizedNumberToken.self, string: "1,2")
        TestToken(tokens[3], kind: OperatorToken.self, string: ",")
        TestToken(tokens[4], kind: LocalizedNumberToken.self, string: "3,4")
        TestToken(tokens[5], kind: OperatorToken.self, string: ",")
        TestToken(tokens[6], kind: LocalizedNumberToken.self, string: "5,6")
        TestToken(tokens[7], kind: OperatorToken.self, string: ",")
        TestToken(tokens[8], kind: LocalizedNumberToken.self, string: "7,8")
        TestToken(tokens[9], kind: OperatorToken.self, string: ")")
    }
}
