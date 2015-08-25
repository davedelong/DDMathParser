//
//  Expression.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/17/15.
//
//

import Foundation

public struct ExpressionError: ErrorType {
    public enum Kind {
        case InvalidFormat
        case MissingLeftOperand(Operator)
        case MissingRightOperand(Operator)
    }
    
    public let kind: Kind
    public let range: Range<String.Index>
}

public class Expression {
    public enum Kind {
        case Number(Double)
        case Variable(String)
        case Function(String, Array<Expression>)
    }
    
    public let kind: Kind
    public let range: Range<String.Index>
    
    public init(string: String) throws {
        let grouper = TokenGrouper(string: string)
        let expressionizer = Expressionizer(grouper: grouper)
        
        let e: Expression
        do {
            e = try expressionizer.expression()
        } catch let error {
            self.kind = .Variable("fake")
            self.range = string.startIndex ..< string.endIndex
            throw error
        }
        
        self.kind = e.kind
        self.range = e.range
        resolveToParent(nil)
    }
    
    internal weak var parent: Expression?
    
    internal init(kind: Kind, range: Range<String.Index>) {
        self.kind = kind
        self.range = range
    }
    
    internal func resolveToParent(parent: Expression?) {
        self.parent = parent
        guard case let .Function(_, children) = kind else { return }
        children.forEach { $0.resolveToParent(self) }
    }
}

public extension Expression: CustomStringConvertible {
    
    public var description: String {
        switch kind {
            case .Number(let d): return d.description
            case .Variable(let v):
                if v.containsString(" "): return "\"\(v)\""
                return "$\(v)"
            case .Function(let f, let args):
                let params = args.map { $0.description }
                if let builtIn = BuiltInOperator(rawValue: f) {
                    let op = Operator(builtInOperator: builtIn)
                    let token = op.tokens.first!
                    switch (op.arity, op.associativity) {
                        case (.Binary, _):
                            return "\(params[0]) \(token) \(params[1])"
                        case (.Unary, .Left):
                            return "\(params[0])\(token)"
                        case (.Unary, .Right):
                            return "\(token)\(params[0])"
                    }
                } else {
                    let joined = params.joinWithSeparator(", ")
                    return "\(f)(\(joined))"
                }
        }
    }
    
}
