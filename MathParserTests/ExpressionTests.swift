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
        
        guard case .Number(4) = e.kind else {
            XCTFail("Unexpected expression kind: \(e.kind)")
            return
        }
    }
    
    func testVariable() {
        guard let e = XCTAssertNoThrows(try Expression(string: "$foo")) else { return }
        
        guard case .Variable("foo") = e.kind else {
            XCTFail("Unexpected expression kind: \(e.kind)")
            return
        }
    }
    
    func testSimpleFunction() {
        guard let e = XCTAssertNoThrows(try Expression(string: "foo()")) else { return }
        
        guard case let .Function("foo", args) = e.kind else {
            XCTFail("Unexpected expression kind: \(e.kind)")
            return
        }
        
        XCTAssertEqual(args.count, 0)
    }
    
    func testFunctionWithArguments() {
        guard let e = XCTAssertNoThrows(try Expression(string: "foo(1)")) else { return }
        
        guard case let .Function("foo", args) = e.kind else {
            XCTFail("Unexpected expression kind: \(e.kind)")
            return
        }
        
        XCTAssertEqual(args.count, 1)
        
        let arg = args[0]
        guard case .Number(1) = arg.kind else {
            XCTFail("Unexpected argument: \(arg.kind)")
            return
        }
    }

    func testRightUnaryOperator() {
        guard let e = XCTAssertNoThrows(try Expression(string: "-42")) else { return }
        
        guard case let .Function("negate", args) = e.kind else {
            XCTFail("Unexpected expression kind: \(e.kind)")
            return
        }
        
        XCTAssertEqual(args.count, 1)
        
        let arg = args[0]
        guard case .Number(42) = arg.kind else {
            XCTFail("Unexpected argument: \(arg.kind)")
            return
        }
    }
    
    func testRecursiveRightUnaryOperator() {
        guard let e = XCTAssertNoThrows(try Expression(string: "---42")) else { return }
        
        guard case let .Function("negate", args) = e.kind else {
            XCTFail("Unexpected expression kind: \(e.kind)")
            return
        }
        
        XCTAssertEqual(args.count, 1)
        let e2 = args[0]
        guard case let .Function("negate", args2) = e2.kind else {
            XCTFail("Unexpected expression kind: \(e2.kind)")
            return
        }
        
        XCTAssertEqual(args2.count, 1)
        let e3 = args2[0]
        guard case let .Function("negate", args3) = e3.kind else {
            XCTFail("Unexpected expression kind: \(e3.kind)")
            return
        }
        
        XCTAssertEqual(args3.count, 1)
        guard case .Number(42) = args3[0].kind else {
            XCTFail("Unexpected expression kind: \(args3[0].kind)")
            return
        }
    }
    
    func testLeftUnaryOperator() {
        guard let e = XCTAssertNoThrows(try Expression(string: "4!")) else {
            return
        }
        
        guard case let .Function("factorial", args) = e.kind else {
            XCTFail("Unexpected expression kind: \(e.kind)")
            return
        }
        
        XCTAssertEqual(args.count, 1)
        
        let arg = args[0]
        guard case .Number(4) = arg.kind else {
            XCTFail("Unexpected argument: \(arg.kind)")
            return
        }
    }
    
    func testRecursiveLeftUnaryOperator() {
        guard let e = XCTAssertNoThrows(try Expression(string: "4°!")) else {
            return
        }
        
        guard case let .Function("factorial", args) = e.kind else {
            XCTFail("Unexpected expression kind: \(e.kind)")
            return
        }
        
        XCTAssertEqual(args.count, 1)
        
        let arg = args[0]
        guard case let .Function("dtor", args2) = arg.kind else {
            XCTFail("Unexpected expression kind: \(arg.kind)")
            return
        }
        
        XCTAssertEqual(args2.count, 1)
        guard case .Number(4) = args2[0].kind else {
            XCTFail("Unexpected argument: \(args2[0].kind)")
            return
        }
    }
    
    func testMissingLeftOperand() {
        do {
            let _ = try Expression(string: "°")
            XCTFail("Unexpected expression")
        } catch let e {
            guard let error = e as? ExpressionError else {
                XCTFail("Unexpected error: \(e)")
                return
            }
            
            guard case .MissingLeftOperand(_) = error.kind else {
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
            guard let error = e as? ExpressionError else {
                XCTFail("Unexpected error: \(e)")
                return
            }
            
            guard case .MissingRightOperand(_) = error.kind else {
                XCTFail("Unexpected error kind: \(error.kind)")
                return
            }
        }
    }
    
    func testBinaryOperator() {
        guard let e = XCTAssertNoThrows(try Expression(string: "1+2")) else { return }
        
        guard case let .Function("add", args) = e.kind else {
            XCTFail("Unexpected expression kind: \(e.kind)")
            return
        }
        
        XCTAssertEqual(args.count, 2)
        
        guard case .Number(1) = args[0].kind else {
            XCTFail("Unexpected argument: \(args[0].kind)")
            return
        }
        guard case .Number(2) = args[1].kind else {
            XCTFail("Unexpected argument: \(args[1].kind)")
            return
        }
    }
    
    func testBinaryOperatorCollapsingLeftOperands() {
        guard let e = XCTAssertNoThrows(try Expression(string: "2!**2")) else { return }
        
        guard case let .Function("pow", args) = e.kind else {
            XCTFail("Unexpected expression kind: \(e.kind)")
            return
        }
        
        XCTAssertEqual(args.count, 2)
        
        guard case .Function("factorial", _) = args[0].kind else {
            XCTFail("Unexpected argument: \(args[0].kind)")
            return
        }
        guard case .Number(2) = args[1].kind else {
            XCTFail("Unexpected argument: \(args[1].kind)")
            return
        }
    }
    
    func testBinaryOperatorCollapsingRightOperands() {
        guard let e = XCTAssertNoThrows(try Expression(string: "2**-2")) else { return }
        
        guard case let .Function("pow", args) = e.kind else {
            XCTFail("Unexpected expression kind: \(e.kind)")
            return
        }
        
        XCTAssertEqual(args.count, 2)
        
        guard case .Number(2) = args[0].kind else {
            XCTFail("Unexpected argument: \(args[0].kind)")
            return
        }
        guard case .Function("negate", _) = args[1].kind else {
            XCTFail("Unexpected argument: \(args[1].kind)")
            return
        }
    }
    
    func testBinaryOperatorMissingLeftOperand() {
        do {
            let _ = try Expression(string: "**2")
            XCTFail("Unexpected expression")
        } catch let e {
            guard let error = e as? ExpressionError else {
                XCTFail("Unexpected error: \(e)")
                return
            }
            
            guard case .MissingLeftOperand(_) = error.kind else {
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
            guard let error = e as? ExpressionError else {
                XCTFail("Unexpected error: \(e)")
                return
            }
            
            guard case .MissingRightOperand(_) = error.kind else {
                XCTFail("Unexpected error kind: \(error.kind)")
                return
            }
        }
    }
    
    func testGroup() {
        guard let e = XCTAssertNoThrows(try Expression(string: "1+(2+3)")) else { return }
        
        guard case let .Function("add", args) = e.kind else {
            XCTFail("Unexpected expression kind: \(e.kind)")
            return
        }
        
        XCTAssertEqual(args.count, 2)
        
        guard case .Number(1) = args[0].kind else {
            XCTFail("Unexpected argument: \(args[0].kind)")
            return
        }
        guard case .Function("add", _) = args[1].kind else {
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
            guard let error = e as? ExpressionError else {
                XCTFail("Unexpected error: \(e)")
                return
            }
            
            guard case .InvalidFormat = error.kind else {
                XCTFail("Unexpected error kind: \(error.kind)")
                return
            }
        }
    }
    
    func testUnaryPlus() {
        guard let e = XCTAssertNoThrows(try Expression(string: "+1")) else { return }
        
        guard case .Number(1) = e.kind else {
            XCTFail("Unexpected expression: \(e)")
            return
        }
    }
    
}
