//
//  GroupedToken.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/13/15.
//
//

import Foundation

public struct TermError: ErrorType {
    public enum Kind {
        case MissingOpenParenthesis
        case MissingCloseParenthesis
        case EmptyFunctionArgument
    }
}

public indirect enum Term: Equatable {
    
    case Number(ResolvedToken)
    case Variable(ResolvedToken)
    case Operator(ResolvedToken)
    case Function(ResolvedToken, Array<Term>)
    case Group(Array<Term>)
    
    public init(tokens: Array<ResolvedToken>) throws {
        let p = PeekingGenerator(generator: tokens.generate())
        let g = try rootTermFromGenerator(p)
        self = g.stripRedundantGroups()
    }
    
    public init(string: String) throws {
        let tokens = try TokenResolver(string: string).resolve()
        let p = PeekingGenerator(generator: tokens.generate())
        let g = try rootTermFromGenerator(p)
        self = g.stripRedundantGroups()
    }
    
    private func stripRedundantGroups() -> Term {
        switch self {
            case .Function(let f, let terms):
                let stripped = terms.map { $0.stripRedundantGroups() }
                return .Function(f, stripped)
            case .Group(let terms):
                let stripped = terms.map { $0.stripRedundantGroups() }
                if stripped.count == 1 { return stripped[0] }
                return .Group(stripped)
            default:
                return self
        }
    }
}

public func ==(lhs: Term, rhs: Term) -> Bool {
    switch (lhs, rhs) {
        case (.Number(let l), .Number(let r)): return l == r
        case (.Variable(let l), .Variable(let r)): return l == r
        case (.Operator(let l), .Operator(let r)): return l == r
        case (.Function(let lF, let lP), .Function(let rF, let rP)): return lF == rF && lP == rP
        case (.Group(let l), .Group(let r)): return l == r
        default: return false
    }
}

private func rootTermFromGenerator<P: PeekingGeneratorType where P.Element == ResolvedToken>(g: P) throws -> Term {
    
    var parameterTerms = Array<Term>()
    
    while let _ = g.peek() {
        let parameterTerm = try termFromGenerator(g)
        parameterTerms.append(parameterTerm)
    }
    
    if parameterTerms.isEmpty {
        throw TermError() //EmptyFunctionArgument
    }
    
    return .Group(parameterTerms)
}

private func termFromGenerator<P: PeekingGeneratorType where P.Element == ResolvedToken>(var g: P) throws -> Term {
    guard let next = g.next() else {
        throw TermError()
    }
    
    switch next.kind {
        case .Number(_):
            return .Number(next)
        case .Variable(_):
            return .Variable(next)
        case .Identifier(_):
            return try functionTermFromGenerator(next, g)
        case .Operator(let o) where o.builtInOperator == .ParenthesisOpen:
            return try groupTermFromGenerator(g)
        case .Operator(_):
            return .Operator(next)
        
    }
}

private func functionTermFromGenerator<P: PeekingGeneratorType where P.Element == ResolvedToken>(function: ResolvedToken, var _ g: P) throws -> Term {
    guard let open = g.next() else {
        throw TermError() //MissingOpenParenthesis
    }
    guard open.kind.builtInOperator == .ParenthesisOpen else {
        throw TermError() //MissingOpenParenthesis
    }
    
    var parameters = Array<Term>()
    
    while let p = g.peek() where p.kind.builtInOperator != .ParenthesisClose {
        // read out all the arguments
        let parameter = try parameterGroupFromGenerator(g)
        parameters.append(parameter)
    }
    
    if let close = g.next() where close.kind.builtInOperator == .ParenthesisClose {
        return .Function(function, parameters)
    }
    
    throw TermError() // MissingCloseParenthesis
}

private func parameterGroupFromGenerator<P: PeekingGeneratorType where P.Element == ResolvedToken>(var g: P) throws -> Term {
    
    var parameterTerms = Array<Term>()
    
    while let p = g.peek() {
        if p.kind.builtInOperator == .Comma {
            g.next() // consume the comma
            break
        }
        
        if p.kind.builtInOperator == .ParenthesisClose {
            break // don't consume
        }
        
        let parameterTerm = try termFromGenerator(g)
        parameterTerms.append(parameterTerm)
    }
    
    if parameterTerms.isEmpty {
        throw TermError() //EmptyFunctionArgument
    }
    
    return .Group(parameterTerms)
}

private func groupTermFromGenerator<P: PeekingGeneratorType where P.Element == ResolvedToken>(var g: P) throws -> Term {
    var terms = Array<Term>()
    
    while let peek = g.peek() where peek.kind.builtInOperator != .ParenthesisClose {
        
        terms.append(try termFromGenerator(g))
    }
    
    if g.next() == nil {
        throw TermError()
    }
    
    return .Group(terms)
}
