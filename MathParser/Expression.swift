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
        
        public var isNumber: Bool {
            guard case .number(_) = self else { return false }
            return true
        }
        public var isVariable: Bool {
            guard case .variable(_) = self else { return false }
            return true
        }
        public var isFunction: Bool {
            guard case .function(_) = self else { return false }
            return true
        }
    }
    
    public let kind: Kind
    public let range: Range<Int>
    
    public init(string: String, operatorSet: OperatorSet = OperatorSet.default, options: TokenResolverOptions = TokenResolverOptions.default, locale: Locale? = nil) throws {
        let tokenizer = Tokenizer(string: string, operatorSet: operatorSet, locale: locale)
        let resolver = TokenResolver(tokenizer: tokenizer, options: options)
        let grouper = TokenGrouper(resolver: resolver)
        let expressionizer = Expressionizer(grouper: grouper)
        
        let e = try expressionizer.expression()
        self.kind = e.kind
        self.range = e.range
        
        if case let .function(_, args) = kind {
            args.forEach { $0.parent = self }
        }
    }
    
    internal weak var parent: Expression?
    
    internal init(kind: Kind, range: Range<Int>) {
        self.kind = kind
        self.range = range
        
        if case let .function(_, args) = kind {
            args.forEach { $0.parent = self }
        }
    }
    
    public func simplify(_ substitutions: Substitutions = [:], evaluator: Evaluator) -> Expression {
        switch kind {
            case .number(_): return Expression(kind: kind, range: range)
            case .variable(_):
                if let resolved = try? evaluator.evaluate(self, substitutions: substitutions) {
                    return Expression(kind: .number(resolved), range: range)
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
                    switch (op.arity, op.associativity) {
                        case (.binary, _):
                            return "\(params[0]) \(token) \(params[1])"
                        case (.unary, .left):
                            return "\(params[0])\(token)"
                        case (.unary, .right):
                            return "\(token)\(params[0])"
                    }
                } else {
                    let joined = params.joined(separator: ", ")
                    return "\(f)(\(joined))"
                }
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
