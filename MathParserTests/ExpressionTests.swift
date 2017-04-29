//
//  ExpressionTests.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/20/15.
//
//

import XCTest
import MathParser

class ExpressionTests: XCTestCase {
    
    func testNumber() {
        guard let e = XCTAssertNoThrows(try Expression(string: "4")) else { return }
        
        guard case .number(4) = e.kind else {
            XCTFail("Unexpected expression kind: \(e.kind)")
            return
        }
    }
    
    func testVariable() {
        guard let e = XCTAssertNoThrows(try Expression(string: "$foo")) else { return }
        
        guard case .variable("foo") = e.kind else {
            XCTFail("Unexpected expression kind: \(e.kind)")
            return
        }
    }
    
    func testSimpleFunction() {
        guard let e = XCTAssertNoThrows(try Expression(string: "foo()")) else { return }
        
        guard case let .function("foo", args) = e.kind else {
            XCTFail("Unexpected expression kind: \(e.kind)")
            return
        }
        
        XCTAssertEqual(args.count, 0)
    }
    
    func testFunctionWithArguments() {
        guard let e = XCTAssertNoThrows(try Expression(string: "foo(1)")) else { return }
        
        guard case let .function("foo", args) = e.kind else {
            XCTFail("Unexpected expression kind: \(e.kind)")
            return
        }
        
        XCTAssertEqual(args.count, 1)
        
        let arg = args[0]
        guard case .number(1) = arg.kind else {
            XCTFail("Unexpected argument: \(arg.kind)")
            return
        }
    }

    func testRightUnaryOperator() {
        guard let e = XCTAssertNoThrows(try Expression(string: "-42")) else { return }
        
        guard case let .function("negate", args) = e.kind else {
            XCTFail("Unexpected expression kind: \(e.kind)")
            return
        }
        
        XCTAssertEqual(args.count, 1)
        
        let arg = args[0]
        guard case .number(42) = arg.kind else {
            XCTFail("Unexpected argument: \(arg.kind)")
            return
        }
    }
    
    func testRecursiveRightUnaryOperator() {
        guard let e = XCTAssertNoThrows(try Expression(string: "---42")) else { return }
        
        guard case let .function("negate", args) = e.kind else {
            XCTFail("Unexpected expression kind: \(e.kind)")
            return
        }
        
        XCTAssertEqual(args.count, 1)
        let e2 = args[0]
        guard case let .function("negate", args2) = e2.kind else {
            XCTFail("Unexpected expression kind: \(e2.kind)")
            return
        }
        
        XCTAssertEqual(args2.count, 1)
        let e3 = args2[0]
        guard case let .function("negate", args3) = e3.kind else {
            XCTFail("Unexpected expression kind: \(e3.kind)")
            return
        }
        
        XCTAssertEqual(args3.count, 1)
        guard case .number(42) = args3[0].kind else {
            XCTFail("Unexpected expression kind: \(args3[0].kind)")
            return
        }
    }
    
    func testLeftUnaryOperator() {
        guard let e = XCTAssertNoThrows(try Expression(string: "4!")) else {
            return
        }
        
        guard case let .function("factorial", args) = e.kind else {
            XCTFail("Unexpected expression kind: \(e.kind)")
            return
        }
        
        XCTAssertEqual(args.count, 1)
        
        let arg = args[0]
        guard case .number(4) = arg.kind else {
            XCTFail("Unexpected argument: \(arg.kind)")
            return
        }
    }
    
    func testRecursiveLeftUnaryOperator() {
        guard let e = XCTAssertNoThrows(try Expression(string: "4°!")) else {
            return
        }
        
        guard case let .function("factorial", args) = e.kind else {
            XCTFail("Unexpected expression kind: \(e.kind)")
            return
        }
        
        XCTAssertEqual(args.count, 1)
        
        let arg = args[0]
        guard case let .function("dtor", args2) = arg.kind else {
            XCTFail("Unexpected expression kind: \(arg.kind)")
            return
        }
        
        XCTAssertEqual(args2.count, 1)
        guard case .number(4) = args2[0].kind else {
            XCTFail("Unexpected argument: \(args2[0].kind)")
            return
        }
    }
    
    func testMissingLeftOperand() {
        do {
            let _ = try Expression(string: "°")
            XCTFail("Unexpected expression")
        } catch let e {
            guard let error = e as? MathParserError else {
                XCTFail("Unexpected error: \(e)")
                return
            }
            
            guard case .missingLeftOperand(_) = error.kind else {
                XCTFail("Unexpected error kind: \(error.kind)")
                return
            }
        }
    }
    
    func testMissingRightOperand() {
        do {
            let _ = try Expression(string: "-")
            XCTFail("Unexpected expression")
        } catch let e {
            guard let error = e as? MathParserError else {
                XCTFail("Unexpected error: \(e)")
                return
            }
            
            guard case .missingRightOperand(_) = error.kind else {
                XCTFail("Unexpected error kind: \(error.kind)")
                return
            }
        }
    }
    
    func testBinaryOperator() {
        guard let e = XCTAssertNoThrows(try Expression(string: "1+2")) else { return }
        
        guard case let .function("add", args) = e.kind else {
            XCTFail("Unexpected expression kind: \(e.kind)")
            return
        }
        
        XCTAssertEqual(args.count, 2)
        
        guard case .number(1) = args[0].kind else {
            XCTFail("Unexpected argument: \(args[0].kind)")
            return
        }
        guard case .number(2) = args[1].kind else {
            XCTFail("Unexpected argument: \(args[1].kind)")
            return
        }
    }
    
    func testBinaryOperatorCollapsingLeftOperands() {
        guard let e = XCTAssertNoThrows(try Expression(string: "2!**2")) else { return }
        
        guard case let .function("pow", args) = e.kind else {
            XCTFail("Unexpected expression kind: \(e.kind)")
            return
        }
        
        XCTAssertEqual(args.count, 2)
        
        guard case .function("factorial", _) = args[0].kind else {
            XCTFail("Unexpected argument: \(args[0].kind)")
            return
        }
        guard case .number(2) = args[1].kind else {
            XCTFail("Unexpected argument: \(args[1].kind)")
            return
        }
    }
    
    func testBinaryOperatorCollapsingRightOperands() {
        guard let e = XCTAssertNoThrows(try Expression(string: "2**-2")) else { return }
        
        guard case let .function("pow", args) = e.kind else {
            XCTFail("Unexpected expression kind: \(e.kind)")
            return
        }
        
        XCTAssertEqual(args.count, 2)
        
        guard case .number(2) = args[0].kind else {
            XCTFail("Unexpected argument: \(args[0].kind)")
            return
        }
        guard case .function("negate", _) = args[1].kind else {
            XCTFail("Unexpected argument: \(args[1].kind)")
            return
        }
    }
    
    func testBinaryOperatorMissingLeftOperand() {
        do {
            let _ = try Expression(string: "**2")
            XCTFail("Unexpected expression")
        } catch let e {
            guard let error = e as? MathParserError else {
                XCTFail("Unexpected error: \(e)")
                return
            }
            
            guard case .missingLeftOperand(_) = error.kind else {
                XCTFail("Unexpected error kind: \(error.kind)")
                return
            }
        }
    }
    
    func testBinaryOperatorMissingRightOperand() {
        do {
            let _ = try Expression(string: "2**")
            XCTFail("Unexpected expression")
        } catch let e {
            guard let error = e as? MathParserError else {
                XCTFail("Unexpected error: \(e)")
                return
            }
            
            guard case .missingRightOperand(_) = error.kind else {
                XCTFail("Unexpected error kind: \(error.kind)")
                return
            }
        }
    }
    
    func testGroup() {
        guard let e = XCTAssertNoThrows(try Expression(string: "1+(2+3)")) else { return }
        
        guard case let .function("add", args) = e.kind else {
            XCTFail("Unexpected expression kind: \(e.kind)")
            return
        }
        
        XCTAssertEqual(args.count, 2)
        
        guard case .number(1) = args[0].kind else {
            XCTFail("Unexpected argument: \(args[0].kind)")
            return
        }
        guard case .function("add", _) = args[1].kind else {
            XCTFail("Unexpected argument: \(args[1].kind)")
            return
        }
    }
    
    func testMissingOperator() {
        do {
            let tokenizer = Tokenizer(string: "1 2")
            let resolver = TokenResolver(tokenizer: tokenizer, options: [])
            let grouper = TokenGrouper(resolver: resolver)
            let expressionizer = Expressionizer(grouper: grouper)
            let _ = try expressionizer.expression()
            XCTFail("Unexpected expression")
        } catch let e {
            guard let error = e as? MathParserError else {
                XCTFail("Unexpected error: \(e)")
                return
            }
            
            guard case .invalidFormat = error.kind else {
                XCTFail("Unexpected error kind: \(error.kind)")
                return
            }
        }
    }
    
    func testUnaryPlus() {
        guard let e = XCTAssertNoThrows(try Expression(string: "+1")) else { return }
        
        guard case .number(1) = e.kind else {
            XCTFail("Unexpected expression: \(e)")
            return
        }
    }
    
    func testSimplifyWithNestedExpressions() {
        guard let e = XCTAssertNoThrows(try Expression(string: "$foo * 2 + $bar")) else { return }
        guard let foo = XCTAssertNoThrows(try Expression(string: "$bar + 2")) else { return }
        
        let simplified = e.simplify(["foo": foo], evaluator: .default)
        guard let expectedResult = XCTAssertNoThrows(try Expression(string: "($bar + 2) * 2 + $bar")) else { return }
        XCTAssertEqual(simplified, expectedResult)
    }
    
}
