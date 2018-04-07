//
//  LocalizedNumberExtractor.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/31/15.
//
//

import Foundation

internal struct LocalizedNumberExtractor: TokenExtractor {
    
    private let decimalNumberFormatter = NumberFormatter()
    
    internal init(locale: Locale) {
        decimalNumberFormatter.locale = locale
        decimalNumberFormatter.numberStyle = .decimal
    }
    
    func matchesPreconditions(_ buffer: TokenCharacterBuffer) -> Bool {
        return buffer.peekNext() != nil
    }
    
    func extract(_ buffer: TokenCharacterBuffer) -> Tokenizer.Result {
        let start = buffer.currentIndex
        var indexBeforeDecimal: Int?
        
        var soFar = ""
        while let peek = buffer.peekNext(), peek.isWhitespace == false {
            let test = soFar + String(peek)
            
            if indexBeforeDecimal == nil && test.hasSuffix(decimalNumberFormatter.decimalSeparator) {
                indexBeforeDecimal = buffer.currentIndex
            }
            
            if canParseString(test) {
                soFar = test
                buffer.consume()
            } else {
                break
            }
        }
        
        if let indexBeforeDecimal = indexBeforeDecimal, soFar.hasSuffix(decimalNumberFormatter.decimalSeparator) {
            buffer.resetTo(indexBeforeDecimal)
            soFar = buffer[start ..< indexBeforeDecimal]
        }
        
        let indexAfterNumber = buffer.currentIndex
        let range: Range<Int> = start ..< indexAfterNumber
        
        guard indexAfterNumber - start > 0 else {
            let error = MathParserError(kind: .cannotParseNumber, range: range)
            return .error(error)
        }
        
        let token = LocalizedNumberToken(string: soFar, range: range)
        return .value(token)
    }
    
    private func canParseString(_ string: String) -> Bool {
        guard let _ = decimalNumberFormatter.number(from: string) else { return false }
        return true
    }

}
