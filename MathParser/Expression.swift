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
        
        public var isNumber: Bool {
            guard case .Number(_) = self else { return false }
            return true
        }
        public var isVariable: Bool {
            guard case .Variable(_) = self else { return false }
            return true
        }
        public var isFunction: Bool {
            guard case .Function(_) = self else { return false }
            return true
        }
    }
    
    public let kind: Kind
    public let range: Range<String.Index>
    
    public init(string: String, operatorSet: OperatorSet = OperatorSet.defaultOperatorSet, options: TokenResolverOptions = TokenResolverOptions.defaultOptions, locale: NSLocale? = nil) throws {
        let tokenizer = Tokenizer(string: string, operatorSet: operatorSet, locale: locale)
        let resolver = TokenResolver(tokenizer: tokenizer, options: options)
        let grouper = TokenGrouper(resolver: resolver)
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
        
        if case let .Function(_, args) = kind {
            args.forEach { $0.parent = self }
        }
    }
    
    internal weak var parent: Expression?
    
    internal init(kind: Kind, range: Range<String.Index>) {
        self.kind = kind
        self.range = range
        
        if case let .Function(_, args) = kind {
            args.forEach { $0.parent = self }
        }
    }
    
    public func simplify(substitutions: Substitutions = [:], evaluator: Evaluator) -> Expression {
        switch kind {
            case .Number(_): return Expression(kind: kind, range: range)
            case .Variable(_):
                if let resolved = try? evaluator.evaluate(self, substitutions: substitutions) {
                    return Expression(kind: .Number(resolved), range: range)
                }
                return Expression(kind: kind, range: range)
            case let .Function(f, args):
                let newArgs = args.map { $0.simplify(substitutions, evaluator: evaluator) }
                let areAllArgsNumbers = newArgs.reduce(true) { $0 && $1.kind.isNumber }
            
                guard areAllArgsNumbers else {
                    return Expression(kind: .Function(f, newArgs), range: range)
                }
            
                guard let value = try? evaluator.evaluate(self) else {
                    return Expression(kind: .Function(f, newArgs), range: range)
                }
            
                return Expression(kind: .Number(value), range: range)
        }
    }
}

extension Expression: CustomStringConvertible {
    
    public var description: String {
        switch kind {
            case .Number(let d): return d.description
            case .Variable(let v):
                if v.containsString(" ") { return "\"\(v)\"" }
                return "$\(v)"
            case .Function(let f, let args):
                let params = args.map { $0.description }
                if let builtIn = BuiltInOperator(rawValue: f) {
                    let op = Operator(builtInOperator: builtIn)
                    guard let token = op.tokens.first else {
                        fatalError("Built-in operator doesn't have any tokens")
                    }
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

extension Expression: Equatable { }

public func ==(lhs: Expression, rhs: Expression) -> Bool {
    switch (lhs.kind, rhs.kind) {
        case (.Number(let l), .Number(let r)): return l == r
        case (.Variable(let l), .Variable(let r)): return l == r
        case (.Function(let lf, let lArg), .Function(let rf, let rArg)): return lf == rf && lArg == rArg
        default: return false
    }
}
