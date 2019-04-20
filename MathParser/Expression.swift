//
//  Expression.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/17/15.
//
//

import Foundation

public final class Expression {
    public enum Kind {
        case number(Double)
        case variable(String)
        case function(String, Array<Expression>)
        
        public var isNumber: Bool { return number != nil }
        public var isVariable: Bool { return variable != nil }
        public var isFunction: Bool { return functionName != nil }
        
        public var number: Double? {
            guard case .number(let d) = self else { return nil }
            return d
        }
        
        public var variable: String? {
            guard case .variable(let v) = self else { return nil }
            return v
        }
        
        public var functionName: String? {
            guard case .function(let name, _) = self else { return nil }
            return name
        }
        
        public var functionArguments: Array<Expression>? {
            guard case .function(_, let args) = self else { return nil }
            return args
        }
    }
    
    public let kind: Kind
    public let range: Range<Int>
    
    internal weak var parent: Expression?
    
    public init(kind: Kind, range: Range<Int>) {
        self.kind = kind
        self.range = range
        
        if case let .function(_, args) = kind {
            args.forEach { $0.parent = self }
        }
    }
    
    public convenience init(string: String, configuration: Configuration = .default) throws {
        let tokenizer = Tokenizer(string: string, configuration: configuration)
        let resolver = TokenResolver(tokenizer: tokenizer)
        let grouper = TokenGrouper(resolver: resolver)
        let expressionizer = Expressionizer(grouper: grouper)
        
        let e = try expressionizer.expression()
        self.init(kind: e.kind, range: e.range)
    }
    
    public func simplify(_ substitutions: Substitutions = [:], evaluator: Evaluator) -> Expression {
        switch kind {
            case .number(_): return Expression(kind: kind, range: range)
            case .variable(let varName):
                if let resolved = try? evaluator.evaluate(self, substitutions: substitutions) {
                    return Expression(kind: .number(resolved), range: range)
                }
                if let exp = substitutions[varName]?.simplified(using: evaluator, substitutions: substitutions) as? Expression {
                    return Expression(kind: exp.kind, range: range)
                }
                return Expression(kind: kind, range: range)
            case let .function(f, args):
                let newArgs = args.map { $0.simplify(substitutions, evaluator: evaluator) }
                let areAllArgsNumbers = newArgs.reduce(true) { $0 && $1.kind.isNumber }
            
                guard areAllArgsNumbers else {
                    return Expression(kind: .function(f, newArgs), range: range)
                }
            
                guard let value = try? evaluator.evaluate(self) else {
                    return Expression(kind: .function(f, newArgs), range: range)
                }
            
                return Expression(kind: .number(value), range: range)
        }
    }
    
    public func rewrite(_ substitutions: Substitutions = [:], rewriter: ExpressionRewriter = .default, evaluator: Evaluator = .default) -> Expression {
        return rewriter.rewriteExpression(self, substitutions: substitutions, evaluator: evaluator)
    }
}

extension Expression: Substitution {
    public func substitutionValue(using evaluator: Evaluator, substitutions: Substitutions) throws -> Double {
        return try evaluator.evaluate(self, substitutions: substitutions)
    }
    
    public func simplified(using evaluator: Evaluator, substitutions: Substitutions) -> Substitution {
        return simplify(substitutions, evaluator: evaluator)
    }
}

extension Expression: CustomStringConvertible {
    
    public var description: String {
        switch kind {
            case .number(let d): return d.description
            case .variable(let v):
                if v.contains(" ") { return "\"\(v)\"" }
                return "$\(v)"
            case .function(let f, let args):
                let params = args.map { $0.description }
                if let builtIn = BuiltInOperator(rawValue: f) {
                    let op = Operator(builtInOperator: builtIn)
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

extension Expression: Equatable { }

public func ==(lhs: Expression, rhs: Expression) -> Bool {
    switch (lhs.kind, rhs.kind) {
        case (.number(let l), .number(let r)): return l == r
        case (.variable(let l), .variable(let r)): return l == r
        case (.function(let lf, let lArg), .function(let rf, let rArg)): return lf == rf && lArg == rArg
        default: return false
    }
}
