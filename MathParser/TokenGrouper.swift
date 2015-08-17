//
//  TokenGrouper.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/15/15.
//
//

import Foundation

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
        
        let range: Range<String.Index>
        if let first = rootTokens.first, let last = rootTokens.last {
            range = first.range.startIndex ..< last.range.endIndex
        } else {
            throw GroupedTokenError() //EmptyFunctionArgument
        }
        
        return GroupedToken(kind: .Group(rootTokens), range: range)
    }
    
    private func tokenFromGenerator<P: PeekingGeneratorType where P.Element == ResolvedToken>(var g: P) throws -> GroupedToken {
        guard let peek = g.peek() else { throw GroupedTokenError() }
        
        switch peek.kind {
            case .Number(let d):
                g.next()
                return GroupedToken(kind: .Number(d), range: peek.range)
            case .Variable(let s):
                g.next()
                return GroupedToken(kind: .Variable(s), range: peek.range)
            case .Identifier(_):
                return try functionTokenFromGenerator(g)
            case .Operator(let o) where o.builtInOperator == .ParenthesisOpen:
                return try groupTokenFromGenerator(g)
            case .Operator(let o) where o.builtInOperator == .ParenthesisClose:
                throw GroupedTokenError() // CloseParen, but no OpenParen
            case .Operator(let o):
                g.next()
                return GroupedToken(kind: .Operator(o), range: peek.range)
            
        }
    }
    
    private func functionTokenFromGenerator<P: PeekingGeneratorType where P.Element == ResolvedToken>(var g: P) throws -> GroupedToken {
        guard let function = g.next() else {
            // this should never happen
            throw GroupedTokenError() //ImplementationFlaw
        }
        
        guard let open = g.next() where open.kind.builtInOperator == .ParenthesisOpen else {
            throw GroupedTokenError() //MissingOpenParenthesis
        }
        
        var parameters = Array<GroupedToken>()
        
        while let p = g.peek() where p.kind.builtInOperator != .ParenthesisClose {
            // read out all the arguments
            let parameter = try parameterGroupFromGenerator(g)
            parameters.append(parameter)
        }
        
        guard let close = g.next() where close.kind.builtInOperator == .ParenthesisClose else {
            throw GroupedTokenError() // MissingCloseParenthesis
        }
        
        let range = function.range.startIndex ..< close.range.endIndex
        return GroupedToken(kind: .Function(function.string, parameters), range: range)
    }
    
    private func parameterGroupFromGenerator<P: PeekingGeneratorType where P.Element == ResolvedToken>(var g: P) throws -> GroupedToken {
        
        var parameterTokens = Array<GroupedToken>()
        
        while let p = g.peek() {
            if p.kind.builtInOperator == .Comma {
                g.next() // consume the comma
                break
            }
            
            if p.kind.builtInOperator == .ParenthesisClose {
                break // don't consume
            }
            
            let parameterToken = try tokenFromGenerator(g)
            parameterTokens.append(parameterToken)
        }
        
        guard let first = parameterTokens.first, let last = parameterTokens.last else {
            throw GroupedTokenError() // EmptyFunctionArgument
        }
        
        let range = first.range.startIndex ..< last.range.endIndex
        return GroupedToken(kind: .Group(parameterTokens), range: range)
    }
    
    private func groupTokenFromGenerator<P: PeekingGeneratorType where P.Element == ResolvedToken>(var g: P) throws -> GroupedToken {
        guard let open = g.next() where open.kind.builtInOperator == .ParenthesisOpen else {
            // This should never happen
            throw GroupedTokenError() // MissingOpenParenthesis
        }
        
        var tokens = Array<GroupedToken>()
        
        while let peek = g.peek() where peek.kind.builtInOperator != .ParenthesisClose {
            
            tokens.append(try tokenFromGenerator(g))
        }
        
        guard let close = g.next() where close.kind.builtInOperator == .ParenthesisClose else {
            throw GroupedTokenError() // MissingCloseParenthesis
        }
        
        let range = open.range.startIndex ..< close.range.endIndex
        return GroupedToken(kind: .Group(tokens), range: range)
    }
    
}
