//
//  GroupingTests.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/15/15.
//
//

import XCTest
import MathParser

class GroupingTests: XCTestCase {
    
    func testNumber() {
        let g = TokenGrouper(string: "1")
        guard let t = XCTAssertNoThrows(try g.group()) else { return }
        switch t.kind {
            case .Number(1.0): break
            default: XCTFail("Unexpected token kind")
        }
    }
    
    func testVariable() {
        let g = TokenGrouper(string: "$foo")
        guard let t = XCTAssertNoThrows(try g.group()) else { return }
        switch t.kind {
            case .Variable("foo"): break
            default: XCTFail("Unexpected token kind")
        }
    }
    
    func testIdentifier() {
        let g = TokenGrouper(string: "foo")
        guard let t = XCTAssertNoThrows(try g.group()) else { return }
        switch t.kind {
            case .Function("foo", _): break
            default: XCTFail("Unexpected token kind")
        }
    }
    
    func testNumberAndOperator() {
        let g = TokenGrouper(string: "1+1")
        guard let t = XCTAssertNoThrows(try g.group()) else { return }
        switch t.kind {
            case .Group(let tokens):
                XCTAssert(tokens.count == 3)
            default: XCTFail("Unexpected token kind")
        }
    }
    
    func testGroupedNumber() {
        let g = TokenGrouper(string: "(1)")
        guard let t = XCTAssertNoThrows(try g.group()) else { return }
        switch t.kind {
            case .Number(1.0): break
            default: XCTFail("Unexpected token kind")
        }
    }
    
    func testRedundantGroups() {
        let g = TokenGrouper(string: "(((foo())))")
        guard let t = XCTAssertNoThrows(try g.group()) else { return }
        
        switch t.kind {
            case .Function("foo", _): break
            default: XCTFail("Unexpected token kind")
        }
    }
    
    func testEmptyFunctionArgument() {
        let g = TokenGrouper(string: "foo(,1)")
        
        do {
            let _ = try g.group()
            XCTFail("Expected error")
        } catch let other {
            guard let _ = other as? GroupedTokenError else {
                XCTFail("Unexpected error \(other)")
                return
            }
        }
    }
    
    func testFunctionMissingOpenParenthesis() {
        let r = TokenResolver(string: "foo", options: [])
        let g = TokenGrouper(resolver: r)
        
        do {
            let _ = try g.group()
            XCTFail("Expected error")
        } catch let other {
            guard let _ = other as? GroupedTokenError else {
                XCTFail("Unexpected error \(other)")
                return
            }
        }
    }
    
    func testFunctionMissingCloseParenthesis() {
        let r = TokenResolver(string: "foo(", options: [])
        let g = TokenGrouper(resolver: r)
        
        do {
            let _ = try g.group()
            XCTFail("Expected error")
        } catch let other {
            guard let _ = other as? GroupedTokenError else {
                XCTFail("Unexpected error \(other)")
                return
            }
        }
    }
    
    func testGroupMissingCloseParenthesis() {
        let g = TokenGrouper(string: "(4")
        
        do {
            let _ = try g.group()
            XCTFail("Expected error")
        } catch let other {
            guard let _ = other as? GroupedTokenError else {
                XCTFail("Unexpected error \(other)")
                return
            }
        }
    }
    
    func testGroupMissingOpenParenthesis() {
        let g = TokenGrouper(string: "4)")
        
        do {
            let _ = try g.group()
            XCTFail("Expected error")
        } catch let other {
            guard let _ = other as? GroupedTokenError else {
                XCTFail("Unexpected error \(other)")
                return
            }
        }
    }
    
    func testFunctionParameterGrouping() {
        let g = TokenGrouper(string: "foo(1,2+3,-4)")
        guard let t = XCTAssertNoThrows(try g.group()) else { return }
        
        switch t.kind {
            case .Function("foo", let parameters):
                XCTAssertEqual(parameters.count, 3)
                // first parameter
                guard case .Number(1) = parameters[0].kind else { XCTFail("Unexpected parameter 1"); return }
            
                // second parameter
                guard case .Group(let second) = parameters[1].kind else {
                    XCTFail("Unexpected parameter 2"); return
                }
                XCTAssertEqual(second.count, 3)
                guard case .Number(2) = second[0].kind else {
                    XCTFail("Unexpected parameter 2,1"); return
                }
                guard case .Operator(Operator(builtInOperator: .Add)) = second[1].kind else {
                    XCTFail("Unexpected parameter 2,2"); return
                }
                guard case .Number(3) = second[2].kind else {
                    XCTFail("Unexpected parameter 2,3"); return
                }
            
                guard case .Group(let third) = parameters[2].kind else {
                    XCTFail("Unexpected parameter 3"); return
                }
                XCTAssertEqual(third.count, 2)
            
                guard case .Operator(Operator(builtInOperator: .UnaryMinus)) = third[0].kind else {
                    XCTFail("Unexpected parameter 3,1"); return
                }
                guard case .Number(4) = third[1].kind else {
                    XCTFail("Unexpected parameter 3,2"); return
                }
            default:
                XCTFail("Unexpected token kind")
        }
    }
    
    func testEmptyRootGroup() {
        let g = TokenGrouper(string: "")
        
        do {
            let _ = try g.group()
            XCTFail("Expected error")
        } catch let other {
            guard let _ = other as? GroupedTokenError else {
                XCTFail("Unexpected error \(other)")
                return
            }
        }
    }
    
    func testEmptyGroup() {
        let g = TokenGrouper(string: "1+()")
        
        do {
            let _ = try g.group()
            XCTFail("Expected error")
        } catch let other {
            guard let _ = other as? GroupedTokenError else {
                XCTFail("Unexpected error \(other)")
                return
            }
        }
    }

}
