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
        
        switch token.kind {
            
            case .HexNumber:
                if let number = UInt(token.string, radix: 16) {
                    return .Value(.Number(number))
                } else {
                    hasFinished = true
                    return .Error(TokenizerError(kind: .CannotParseHexNumber, sourceRange: token.sourceRange))
                }
            
            case .Number:
                let number = NSDecimalNumber(string: token.string)
                return .Value(.Number(number.unsignedLongValue))
                
            case .Variable:
                return .Value(.Variable(token.string))
            
            case .Identifier:
                return .Value(.Identifier(token.string))
            
            default:
                // TODO: resolve operators
                hasFinished = true
                return nil
            
        }
    }
    
}
