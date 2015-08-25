//
//  TokenGrouper.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/15/15.
//
//

import Foundation

private extension GroupedToken {
    
    private var endIndex: String.Index {
        switch self.kind {
            case let .Function(_, parameters):
                return parameters.last?.endIndex ?? range.endIndex
            case let .Group(tokens):
                return tokens.last?.endIndex ?? range.endIndex
            default:
                return range.endIndex
        }
    }
    
}

public struct TokenGrouper {
    private let resolver: TokenResolver
    internal var operatorSet: OperatorSet { return resolver.operatorSet }
    
    public init(resolver: TokenResolver) {
        self.resolver = resolver
    }
    
    public init(string: String) {
        self.resolver = TokenResolver(string: string)
    }
    
    public func group() throws -> GroupedToken {
        let tokens = try resolver.resolve()
        let p = PeekingGenerator(generator: tokens.generate())
        let g = try rootTokenFromGenerator(p)
        return stripRedundantGroups(g)
    }
    
    private func stripRedundantGroups(t: GroupedToken) -> GroupedToken {
        switch t.kind {
            case .Function(let f, let tokens):
                let stripped = tokens.map { stripRedundantGroups($0) }
                return GroupedToken(kind: .Function(f, stripped), range: t.range)
            case .Group(let tokens):
                let stripped = tokens.map { stripRedundantGroups($0) }
                if stripped.count == 1 { return stripped[0] }
                return GroupedToken(kind: .Group(stripped), range: t.range)
            default:
                return t
        }
    }
    
    private func rootTokenFromGenerator<P: PeekingGeneratorType where P.Element == ResolvedToken>(g: P) throws -> GroupedToken {
        
        var rootTokens = Array<GroupedToken>()
        
        while let _ = g.peek() {
            let parameterToken = try tokenFromGenerator(g)
            rootTokens.append(parameterToken)
        }
        
        guard let first = rootTokens.first, let last = rootTokens.last else {
            // cheap way to get an empty range
            let range = "".startIndex ..< "".startIndex
            throw GroupedTokenError(kind: .EmptyGroup, range: range) //EmptyGroup
        }
        let range = first.range.startIndex ..< last.range.endIndex
        
        return GroupedToken(kind: .Group(rootTokens), range: range)
    }
    
    private func tokenFromGenerator<P: PeekingGeneratorType where P.Element == ResolvedToken>(var g: P) throws -> GroupedToken {
        
        guard let peek = g.peek() else {
            fatalError("Implementation flaw")
        }
        
        switch peek.kind {
            case .Number(let d):
                let _ = g.next()
                return GroupedToken(kind: .Number(d), range: peek.range)
            case .Variable(let s):
                let _ = g.next()
                return GroupedToken(kind: .Variable(s), range: peek.range)
            case .Identifier(_):
                return try functionTokenFromGenerator(g)
            case .Operator(let o) where o.builtInOperator == .ParenthesisOpen:
                return try groupTokenFromGenerator(g)
            case .Operator(let o) where o.builtInOperator == .ParenthesisClose:
                // CloseParen, but no OpenParen
                throw GroupedTokenError(kind: .MissingOpenParenthesis, range: peek.range)
            case .Operator(let o):
                let _ = g.next()
                return GroupedToken(kind: .Operator(o), range: peek.range)
            
        }
    }
    
    private func functionTokenFromGenerator<P: PeekingGeneratorType where P.Element == ResolvedToken>(var g: P) throws -> GroupedToken {
        guard let function = g.next() else {
            fatalError("Implementation flaw")
        }
        
        guard let open = g.next() where open.kind.builtInOperator == .ParenthesisOpen else {
            throw GroupedTokenError(kind: .MissingOpenParenthesis, range: function.range.endIndex ..< function.range.endIndex)
        }
        
        var parameters = Array<GroupedToken>()
        
        while let p = g.peek() where p.kind.builtInOperator != .ParenthesisClose {
            // read out all the arguments
            let parameter = try parameterGroupFromGenerator(g, parameterIndex: p.range.startIndex)
            parameters.append(parameter)
        }
        
        guard let close = g.next() where close.kind.builtInOperator == .ParenthesisClose else {
            let indexForMissingParen = parameters.last?.endIndex ?? open.range.endIndex
            throw GroupedTokenError(kind: .MissingCloseParenthesis, range: indexForMissingParen ..< indexForMissingParen)
        }
        
        let range = function.range.startIndex ..< close.range.endIndex
        return GroupedToken(kind: .Function(function.string, parameters), range: range)
    }
    
    private func parameterGroupFromGenerator<P: PeekingGeneratorType where P.Element == ResolvedToken>(var g: P, parameterIndex: String.Index) throws -> GroupedToken {
        
        var parameterTokens = Array<GroupedToken>()
        
        while let p = g.peek() {
            if p.kind.builtInOperator == .Comma {
                let _ = g.next() // consume the comma
                break
            }
            
            if p.kind.builtInOperator == .ParenthesisClose {
                break // don't consume
            }
            
            let parameterToken = try tokenFromGenerator(g)
            parameterTokens.append(parameterToken)
        }
        
        guard let first = parameterTokens.first, let last = parameterTokens.last else {
            throw GroupedTokenError(kind: .EmptyFunctionArgument, range: parameterIndex ..< parameterIndex) // EmptyFunctionArgument
        }
        
        let range = first.range.startIndex ..< last.range.endIndex
        return GroupedToken(kind: .Group(parameterTokens), range: range)
    }
    
    private func groupTokenFromGenerator<P: PeekingGeneratorType where P.Element == ResolvedToken>(var g: P) throws -> GroupedToken {
        guard let open = g.next() where open.kind.builtInOperator == .ParenthesisOpen else {
            fatalError("Implementation flaw")
        }
        
        var tokens = Array<GroupedToken>()
        
        while let peek = g.peek() where peek.kind.builtInOperator != .ParenthesisClose {
            
            tokens.append(try tokenFromGenerator(g))
        }
        
        guard let close = g.next() where close.kind.builtInOperator == .ParenthesisClose else {
            let indexForMissingParen = tokens.last?.endIndex ?? open.range.endIndex
            throw GroupedTokenError(kind: .MissingCloseParenthesis, range: indexForMissingParen ..< indexForMissingParen)
        }
        
        let range = open.range.startIndex ..< close.range.endIndex
        
        guard tokens.isEmpty == false else {
            throw GroupedTokenError(kind: .EmptyGroup, range: range) // Empty Group
        }
        
        return GroupedToken(kind: .Group(tokens), range: range)
    }
    
}
