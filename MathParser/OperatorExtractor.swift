//
//  OperatorExtractor.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/7/15.
//
//

import Foundation

public class OperatorToken: RawToken {
    
    public override func resolve(options: TokenResolverOptions, locale: Locale, operators: OperatorSet, previousToken: ResolvedToken? = nil) throws -> Array<ResolvedToken> {
        let matches = operators.operatorForToken(string)
        
        if matches.isEmpty {
            throw MathParserError(kind: .unknownOperator, range: range)
        }
        
        if matches.count == 1 {
            let op = matches[0]
            return [ResolvedToken(kind: .operator(op), string: string, range: range)]
        }
        
        // more than one operator has this token
        
        var resolvedOperator: Operator? = nil
        
        if let previous = previousToken {
            switch previous.kind {
                case .operator(let o):
                    
                    switch (o.arity, o.associativity) {
                        case (.unary, .left):
                            // a left-assoc unary operator can be followed by either:
                            // another left-assoc unary operator
                            // or a binary operator
                            resolvedOperator = operators.operatorForToken(string, arity: .unary, associativity: .left).first
                            
                            if resolvedOperator == nil {
                                resolvedOperator = operators.operatorForToken(string, arity: .binary).first
                            }
                        
                        
                        default:
                            // either a binary operator or a right-assoc unary operator
                            
                            // a binary operator can only be followed by a right-assoc unary operator
                            //a right-assoc operator can only be followed by a right-assoc unary operator
                            resolvedOperator = operators.operatorForToken(string, arity: .unary, associativity: .right).first
                        
                    }
                
                default:
                    // a number/variable can be followed by:
                    // a left-assoc unary operator,
                    // a binary operator,
                    // or a right-assoc unary operator (assuming implicit multiplication)
                    // we'll prefer them from left-to-right:
                    // left-assoc unary, binary, right-assoc unary
                    // TODO: is this correct?? should we be looking at precedence instead?
                    resolvedOperator = operators.operatorForToken(string, arity: .unary, associativity: .left).first
                    
                    if resolvedOperator == nil {
                        resolvedOperator = operators.operatorForToken(string, arity: .binary).first
                    }
                    
                    if resolvedOperator == nil {
                        resolvedOperator = operators.operatorForToken(string, arity: .unary, associativity: .right).first
                    }
            }
            
        } else {
            // no previous token, so this must be a right-assoc unary operator
            resolvedOperator = operators.operatorForToken(string, arity: .unary, associativity: .right).first
        }
        
        if let resolved = resolvedOperator {
            return [ResolvedToken(kind: .operator(resolved), string: string, range: range)]
        } else {
            throw MathParserError(kind: .ambiguousOperator, range: range)
        }
    }
    
}

internal struct OperatorExtractor: TokenExtractor {
    let operatorTokens: OperatorTokenSet
    
    init(operatorTokens: OperatorTokenSet) {
        self.operatorTokens = operatorTokens
    }
    
    func matchesPreconditions(_ buffer: TokenCharacterBuffer) -> Bool {
        guard let peek = buffer.peekNext() else { return false }
        return operatorTokens.hasOperatorWithPrefix(String(peek))
    }
    
    func extract(_ buffer: TokenCharacterBuffer) -> Tokenizer.Result {
        let start = buffer.currentIndex
        
        var lastGoodIndex = start
        var current = ""
        
        while let next = buffer.peekNext(lowercase: true) {
            current.append(next)
            if operatorTokens.hasOperatorWithPrefix(current) {
                buffer.consume()
                
                if operatorTokens.isOperatorToken(current) {
                    lastGoodIndex = buffer.currentIndex
                }
            } else {
                break
            }
        }
        
        buffer.resetTo(lastGoodIndex)
        
        let range: Range<Int> = start ..< buffer.currentIndex
        let result: Tokenizer.Result
        
        if buffer[start].isAlphabetic && buffer.peekNext()?.isAlphabetic == true {
            // This operator starts with an alphabetic character and
            // the next character after it is also alphabetic, and not whitespace.
            // This *probably* isn't an operator, but is instead the beginning
            // of an identifier that happens to have the same prefix as an operator token.
            buffer.resetTo(start)
        }
        
        if buffer.currentIndex - start > 0 {
            let raw = buffer[range]
            result = .value(OperatorToken(string: raw, range: range))
        } else {
            let error = MathParserError(kind: .cannotParseOperator, range: range)
            result = .error(error)
        }
        
        return result
    }
}
