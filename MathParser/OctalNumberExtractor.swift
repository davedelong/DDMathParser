//
//  OctalNumberExtractor.swift
//  DDMathParser
//
//  Created by Dave DeLong on 3/3/16.
//
//

import Foundation

public class OctalNumberToken: RawToken {
    
    public override func resolve(options: TokenResolverOptions, locale: Locale, operators: OperatorSet, previousToken: ResolvedToken? = nil) throws -> Array<ResolvedToken> {
        guard let value = UInt(string, radix: 8) else { throw MathParserError(kind: .cannotParseHexNumber, range: range) }
        return [ResolvedToken(kind: .number(Double(value)), string: string, range: range)]
    }
    
}

internal struct OctalNumberExtractor: TokenExtractor {
    
    func matchesPreconditions(_ buffer: TokenCharacterBuffer) -> Bool {
        return buffer.peekNext() == "0" && buffer.peekNext(1, lowercase: true) == "o"
    }
    
    func extract(_ buffer: TokenCharacterBuffer) -> Tokenizer.Result {
        let start = buffer.currentIndex
        
        guard buffer.peekNext() == "0" && buffer.peekNext(1, lowercase: true) == "o" else {
            let error = MathParserError(kind: .cannotParseHexNumber, range: start ..< start)
            return .error(error)
        }
        
        
        buffer.consume(2) // 0o
        
        let indexBeforeOctalNumbers = buffer.currentIndex
        while buffer.peekNext()?.isOctalDigit == true {
            buffer.consume()
        }
        
        if buffer.currentIndex == indexBeforeOctalNumbers {
            // there wasn't anything after 0[oO]
            buffer.resetTo(start)
        }
        
        let result: Tokenizer.Result
        
        if buffer.currentIndex - start > 0 {
            let range: Range<Int> = indexBeforeOctalNumbers ..< buffer.currentIndex
            let raw = buffer[range]
            result = .value(OctalNumberToken(string: raw, range: range))
        } else {
            let range: Range<Int> = start ..< buffer.currentIndex
            let error = MathParserError(kind: .cannotParseOctalNumber, range: range)
            result = .error(error)
        }
        
        return result
    }
    
}
