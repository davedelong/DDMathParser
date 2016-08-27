//
//  TokenGrouper.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/15/15.
//
//

import Foundation

private extension GroupedToken {
    
    private var endIndex: Int {
        switch self.kind {
            case let .function(_, parameters):
                return parameters.last?.range.upperBound ?? range.upperBound
            case let .group(tokens):
                return tokens.last?.range.upperBound ?? range.upperBound
            default:
                return range.upperBound
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
        let p = PeekingIterator(generator: tokens.makeIterator())
        let g = try rootTokenFromGenerator(p)
        return stripRedundantGroups(g)
    }
    
    private func stripRedundantGroups(_ t: GroupedToken) -> GroupedToken {
        switch t.kind {
            case .function(let f, let tokens):
                let stripped = tokens.map { stripRedundantGroups($0) }
                return GroupedToken(kind: .function(f, stripped), range: t.range)
            case .group(let tokens):
                let stripped = tokens.map { stripRedundantGroups($0) }
                if stripped.count == 1 { return stripped[0] }
                return GroupedToken(kind: .group(stripped), range: t.range)
            default:
                return t
        }
    }
    
    private func rootTokenFromGenerator<P: PeekingIteratorType>(_ g: P) throws -> GroupedToken where P.Element == ResolvedToken {
        
        var rootTokens = Array<GroupedToken>()
        
        while let _ = g.peek() {
            let parameterToken = try tokenFromGenerator(g)
            rootTokens.append(parameterToken)
        }
        
        guard let first = rootTokens.first, let last = rootTokens.last else {
            throw MathParserError(kind: .emptyGroup, range: 0 ..< 0) //EmptyGroup
        }
        let range: Range<Int> = first.range.lowerBound ..< last.range.upperBound
        
        return GroupedToken(kind: .group(rootTokens), range: range)
    }
    
    private func tokenFromGenerator<P: PeekingIteratorType>(_ generator: P) throws -> GroupedToken where P.Element == ResolvedToken {
        var g = generator
        
        guard let peek = g.peek() else {
            fatalError("Implementation flaw")
        }
        
        switch peek.kind {
            case .number(let d):
                let _ = g.next()
                return GroupedToken(kind: .number(d), range: peek.range)
            case .variable(let s):
                let _ = g.next()
                return GroupedToken(kind: .variable(s), range: peek.range)
            case .identifier(_):
                return try functionTokenFromGenerator(g)
            case .operator(let o) where o.builtInOperator == .parenthesisOpen:
                return try groupTokenFromGenerator(g)
            case .operator(let o) where o.builtInOperator == .parenthesisClose:
                // CloseParen, but no OpenParen
                throw MathParserError(kind: .missingOpenParenthesis, range: peek.range)
            case .operator(let o):
                let _ = g.next()
                return GroupedToken(kind: .operator(o), range: peek.range)
            
        }
    }
    
    private func functionTokenFromGenerator<P: PeekingIteratorType>(_ generator: P) throws -> GroupedToken where P.Element == ResolvedToken {
        var g = generator
        guard let function = g.next() else {
            fatalError("Implementation flaw")
        }
        
        guard let open = g.next(), open.kind.builtInOperator == .parenthesisOpen else {
            throw MathParserError(kind: .missingOpenParenthesis, range: function.range.upperBound ..< function.range.upperBound)
        }
        
        var parameters = Array<GroupedToken>()
        
        while let p = g.peek(), p.kind.builtInOperator != .parenthesisClose {
            // read out all the arguments
            let parameter = try parameterGroupFromGenerator(g, parameterIndex: p.range.lowerBound)
            parameters.append(parameter)
        }
        
        guard let close = g.next(), close.kind.builtInOperator == .parenthesisClose else {
            let indexForMissingParen = parameters.last?.range.upperBound ?? open.range.upperBound
            throw MathParserError(kind: .missingCloseParenthesis, range: indexForMissingParen ..< indexForMissingParen)
        }
        
        let range: Range<Int> = function.range.lowerBound ..< close.range.upperBound
        return GroupedToken(kind: .function(function.string, parameters), range: range)
    }
    
    private func parameterGroupFromGenerator<P: PeekingIteratorType>(_ generator: P, parameterIndex: Int) throws -> GroupedToken where P.Element == ResolvedToken {
        var g = generator
        
        var parameterTokens = Array<GroupedToken>()
        
        while let p = g.peek() {
            if p.kind.builtInOperator == .comma {
                let _ = g.next() // consume the comma
                break
            }
            
            if p.kind.builtInOperator == .parenthesisClose {
                break // don't consume
            }
            
            let parameterToken = try tokenFromGenerator(g)
            parameterTokens.append(parameterToken)
        }
        
        guard let first = parameterTokens.first, let last = parameterTokens.last else {
            throw MathParserError(kind: .emptyFunctionArgument, range: parameterIndex ..< parameterIndex) // EmptyFunctionArgument
        }
        
        let range: Range<Int> = first.range.lowerBound ..< last.range.upperBound
        return GroupedToken(kind: .group(parameterTokens), range: range)
    }
    
    private func groupTokenFromGenerator<P: PeekingIteratorType>(_ generator: P) throws -> GroupedToken where P.Element == ResolvedToken {
        var g = generator
        guard let open = g.next(), open.kind.builtInOperator == .parenthesisOpen else {
            fatalError("Implementation flaw")
        }
        
        var tokens = Array<GroupedToken>()
        
        while let peek = g.peek(), peek.kind.builtInOperator != .parenthesisClose {
            
            tokens.append(try tokenFromGenerator(g))
        }
        
        guard let close = g.next(), close.kind.builtInOperator == .parenthesisClose else {
            let indexForMissingParen = tokens.last?.range.upperBound ?? open.range.upperBound
            throw MathParserError(kind: .missingCloseParenthesis, range: indexForMissingParen ..< indexForMissingParen)
        }
        
        let range: Range<Int> = open.range.lowerBound ..< close.range.upperBound
        
        guard tokens.isEmpty == false else {
            throw MathParserError(kind: .emptyGroup, range: range) // Empty Group
        }
        
        return GroupedToken(kind: .group(tokens), range: range)
    }
    
}
