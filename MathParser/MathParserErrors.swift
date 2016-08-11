//
//  MathParserErrors.swift
//  DDMathParser
//
//  Created by Dave DeLong on 5/6/16.
//
//

import Foundation

public struct MathParserError: Error {
    
    public enum Kind {
        // Tokenization Errors
        case cannotParseNumber
        case cannotParseHexNumber // can also occur during Resolution
        case cannotParseOctalNumber // can also occur during Resolution
        case cannotParseExponent
        case cannotParseIdentifier
        case cannotParseVariable
        case cannotParseQuotedVariable
        case cannotParseOperator
        case zeroLengthVariable
        
        // Resolution Errors
        case cannotParseLocalizedNumber
        case unknownOperator
        case ambiguousOperator
        
        // Grouping Errors
        case missingOpenParenthesis
        case missingCloseParenthesis
        case emptyFunctionArgument
        case emptyGroup
        
        // Expression Errors
        case invalidFormat
        case missingLeftOperand(Operator)
        case missingRightOperand(Operator)
        
        // Evaluation Errors
        case unknownFunction(String)
        case unknownVariable(String)
        case divideByZero
        case invalidArguments
    }
    
    public let kind: Kind
    
    // the location within the original source string where the error was found
    public let range: Range<Int>
}

extension MathParserError.Kind: Equatable { }

public func ==(lhs: MathParserError.Kind, rhs: MathParserError.Kind) -> Bool {
    switch (lhs, rhs) {
        case (.cannotParseNumber, .cannotParseNumber): return true
        case (.cannotParseHexNumber, .cannotParseHexNumber): return true
        case (.cannotParseOctalNumber, .cannotParseOctalNumber): return true
        case (.cannotParseExponent, .cannotParseExponent): return true
        case (.cannotParseIdentifier, .cannotParseIdentifier): return true
        case (.cannotParseVariable, .cannotParseVariable): return true
        case (.cannotParseQuotedVariable, .cannotParseQuotedVariable): return true
        case (.cannotParseOperator, .cannotParseOperator): return true
        case (.zeroLengthVariable, .zeroLengthVariable): return true
            
        // Resolution Errors
        case (.cannotParseLocalizedNumber, .cannotParseLocalizedNumber): return true
        case (.unknownOperator, .unknownOperator): return true
        case (.ambiguousOperator, .ambiguousOperator): return true
            
        // Grouping Errors
        case (.missingOpenParenthesis, .missingOpenParenthesis): return true
        case (.missingCloseParenthesis, .missingCloseParenthesis): return true
        case (.emptyFunctionArgument, .emptyFunctionArgument): return true
        case (.emptyGroup, .emptyGroup): return true
            
        // Expression Errors
        case (.invalidFormat, .invalidFormat): return true
        case (.missingLeftOperand(let leftOp), .missingLeftOperand(let rightOp)): return leftOp == rightOp
        case (.missingRightOperand(let leftOp), .missingRightOperand(let rightOp)): return leftOp == rightOp
            
        // Evaluation Errors
        case (.unknownFunction(let leftString), .unknownFunction(let rightString)): return leftString == rightString
        case (.unknownVariable(let leftString), .unknownVariable(let rightString)): return leftString == rightString
        case (.divideByZero, .divideByZero): return true
        case (.invalidArguments, .invalidArguments): return true
        
        default: return false
    }
}

