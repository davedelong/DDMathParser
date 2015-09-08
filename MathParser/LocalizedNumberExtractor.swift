//
//  LocalizedNumberExtractor.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/31/15.
//
//

import Foundation

import Foundation

internal struct LocalizedNumberExtractor: TokenExtractor {
    
    private let decimalNumberFormatter = NSNumberFormatter()
    
    internal init(locale: NSLocale) {
        decimalNumberFormatter.locale = locale
        decimalNumberFormatter.numberStyle = .DecimalStyle
    }
    
    func matchesPreconditions(buffer: TokenCharacterBuffer) -> Bool {
        return buffer.peekNext() != nil
    }
    
    func extract(buffer: TokenCharacterBuffer) -> TokenGenerator.Element {
        let start = buffer.currentIndex
        var indexBeforeDecimal: String.Index?
        
        var soFar = ""
        while let peek = buffer.peekNext() where peek.isWhitespace == false {
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
        
        if let indexBeforeDecimal = indexBeforeDecimal where soFar.hasSuffix(decimalNumberFormatter.decimalSeparator) {
            buffer.resetTo(indexBeforeDecimal)
            soFar = buffer[start ..< indexBeforeDecimal]
        }
        
        let indexAfterNumber = buffer.currentIndex
        let range = start ..< indexAfterNumber
        
        guard start.distanceTo(indexAfterNumber) > 0 else {
            let error = TokenizerError(kind: .CannotParseNumber, sourceRange: range)
            return .Error(error)
        }
        
        let token = RawToken(kind: .LocalizedNumber, string: soFar, range: range)
        return .Value(token)
    }
    
    private func canParseString(string: String) -> Bool {
        guard let _ = decimalNumberFormatter.numberFromString(string) else { return false }
        return true
    }

}
