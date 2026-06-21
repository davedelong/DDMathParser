//
//  Expression.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/17/15.
//
//

import Foundation

public struct Expression {
    
    public enum Kind {
        case number(Double)
        case variable(String)
        case function(String, Array<Expression>)
    }
    
    public let kind: Kind
    public let range: Range<String.Index>
    
    public var isNumber: Bool { return number != nil }
    public var isVariable: Bool { return variable != nil }
    public var isFunction: Bool { return functionName != nil }
    
    public var number: Double? {
        guard case .number(let d) = kind else { return nil }
        return d
    }
    
    public var variable: String? {
        guard case .variable(let v) = kind else { return nil }
        return v
    }
    
    public var functionName: String? {
        guard case .function(let name, _) = kind else { return nil }
        return name
    }
    
    public var functionArguments: Array<Expression>? {
        guard case .function(_, let args) = kind else { return nil }
        return args
    }
    
    public init(kind: Kind, range: Range<String.Index>) {
        self.kind = kind
        self.range = range
    }
    
    public init(string: String, configuration: Configuration = .default) throws {
        let tokenizer = Tokenizer(string: string, configuration: configuration)
        let resolver = TokenResolver(tokenizer: tokenizer)
        let grouper = TokenGrouper(resolver: resolver)
        let expressionizer = Expressionizer(grouper: grouper)
        
        let e = try expressionizer.expression()
        self.init(kind: e.kind, range: e.range)
    }
    
    public func rewrite(_ substitutions: Substitutions = [:], rewriter: ExpressionRewriter = .default, evaluator: Evaluator = .default) -> Expression {
        return rewriter.rewriteExpression(self, substitutions: substitutions, evaluator: evaluator)
    }
}

extension Expression: CustomStringConvertible {
    
    public var description: String {
        switch kind {
            case .number(let d):
                return d.description
            case .variable(let v):
                if v.contains(" ") { return "\"\(v)\"" }
                return "$\(v)"
            case .function(let f, let args):
                let params = args.map { $0.description }
                if let op = Operator.builtinOperator(f) {
                    guard let token = op.tokens.first else {
                        fatalError("Built-in operator doesn't have any tokens")
                    }
                    
                    if op.arity.argumentCount == params.count {
                        switch (op.arity, op.associativity) {
                            case (.binary, _):
                                return "\(params[0]) \(token) \(params[1])"
                            case (.unary, .left):
                                return "\(params[0])\(token)"
                            case (.unary, .right):
                                return "\(token)\(params[0])"
                        }
                    }
                }
                let joined = params.joined(separator: ", ")
                return "\(f)(\(joined))"
        }
    }
    
}

extension Expression: Equatable {

    public static func ==(lhs: Expression, rhs: Expression) -> Bool {
        switch (lhs.kind, rhs.kind) {
            case (.number(let l), .number(let r)):
                return l == r
            case (.variable(let l), .variable(let r)):
                return l == r
            case (.function(let lf, let lArg), .function(let rf, let rArg)):
                return lf == rf && lArg == rArg
            default:
                return false
        }
    }

}
