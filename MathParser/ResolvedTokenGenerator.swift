//
//  ResolvedTokenGenerator.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/8/15.
//
//

import Foundation

public struct ResolvedTokenGenerator: GeneratorType {
    public typealias Element = Either<ResolvedToken, TokenizerError>
    
    private var generator: TokenGenerator
    private var tokensSoFar = Array<ResolvedToken>()
    private var hasFinished = false
    
    public init(generator: TokenGenerator) {
        self.generator = generator
    }
    
    public mutating func next() -> Element? {
        guard hasFinished == false else { return nil }
        guard let next = generator.next() else { return nil }
        
        if let error = next.error {
            hasFinished = true
            return .Error(error)
        }
        
        guard let token = next.value else { return nil }
        
        let element: Element
        
        switch token.kind {
            
            case .HexNumber:
                if let number = UInt(token.string, radix: 16) {
                    let token = ResolvedToken(kind: .Number(number), string: token.string, sourceRange: token.sourceRange)
                    element = .Value(token)
                } else {
                    element = .Error(TokenizerError(kind: .CannotParseHexNumber, sourceRange: token.sourceRange))
                }
            
            case .Number:
                let number = NSDecimalNumber(string: token.string)
                let token = ResolvedToken(kind: .Number(number.unsignedLongValue), string: token.string, sourceRange: token.sourceRange)
                element = .Value(token)
                
            case .Variable:
                let token = ResolvedToken(kind: .Variable(token.string), string: token.string, sourceRange: token.sourceRange)
                element = .Value(token)
            
            case .Identifier:
                let token = ResolvedToken(kind: .Identifier(token.string), string: token.string, sourceRange: token.sourceRange)
                element = .Value(token)
            
            default:

                return nil
            
        }
        
        switch element {
            case .Error(_): hasFinished = true
            case .Value(let t): tokensSoFar.append(t)
        }
        
        return element
    }
    
}
