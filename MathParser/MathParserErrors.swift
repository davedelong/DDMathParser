//
//  MathParserErrors.swift
//  DDMathParser
//
//  Created by Dave DeLong on 5/6/16.
//
//

import Foundation

public struct MathParserError: ErrorType {
    
    public enum Kind {
        // Tokenization Errors
        case CannotParseNumber
        case CannotParseHexNumber // can also occur during Resolution
        case CannotParseOctalNumber // can also occur during Resolution
        case CannotParseExponent
        case CannotParseIdentifier
        case CannotParseVariable
        case CannotParseQuotedVariable
        case CannotParseOperator
        case ZeroLengthVariable
        
        // Resolution Errors
        case CannotParseLocalizedNumber
        case UnknownOperator
        case AmbiguousOperator
        
        // Grouping Errors
        case MissingOpenParenthesis
        case MissingCloseParenthesis
        case EmptyFunctionArgument
        case EmptyGroup
        
        // Expression Errors
        case InvalidFormat
        case MissingLeftOperand(Operator)
        case MissingRightOperand(Operator)
        
        // Evaluation Errors
        case UnknownFunction(String)
        case UnknownVariable(String)
        case DivideByZero
        case InvalidArguments
    }
    
    public let kind: Kind
    
    // the location within the original source string where the error was found
    public let range: Range<String.Index>
}

extension MathParserError.Kind: Equatable { }

public func ==(lhs: MathParserError.Kind, rhs: MathParserError.Kind) -> Bool {
    switch (lhs, rhs) {
        case (.CannotParseNumber, .CannotParseNumber): return true
        case (.CannotParseHexNumber, .CannotParseHexNumber): return true
        case (.CannotParseOctalNumber, .CannotParseOctalNumber): return true
        case (.CannotParseExponent, .CannotParseExponent): return true
        case (.CannotParseIdentifier, .CannotParseIdentifier): return true
        case (.CannotParseVariable, .CannotParseVariable): return true
        case (.CannotParseQuotedVariable, .CannotParseQuotedVariable): return true
        case (.CannotParseOperator, .CannotParseOperator): return true
        case (.ZeroLengthVariable, .ZeroLengthVariable): return true
            
        // Resolution Errors
        case (.CannotParseLocalizedNumber, .CannotParseLocalizedNumber): return true
        case (.UnknownOperator, .UnknownOperator): return true
        case (.AmbiguousOperator, .AmbiguousOperator): return true
            
        // Grouping Errors
        case (.MissingOpenParenthesis, .MissingOpenParenthesis): return true
        case (.MissingCloseParenthesis, .MissingCloseParenthesis): return true
        case (.EmptyFunctionArgument, .EmptyFunctionArgument): return true
        case (.EmptyGroup, .EmptyGroup): return true
            
        // Expression Errors
        case (.InvalidFormat, .InvalidFormat): return true
        case (.MissingLeftOperand(let leftOp), .MissingLeftOperand(let rightOp)): return leftOp == rightOp
        case (.MissingRightOperand(let leftOp), .MissingRightOperand(let rightOp)): return leftOp == rightOp
            
        // Evaluation Errors
        case (.UnknownFunction(let leftString), .UnknownFunction(let rightString)): return leftString == rightString
        case (.UnknownVariable(let leftString), .UnknownVariable(let rightString)): return leftString == rightString
        case (.DivideByZero, .DivideByZero): return true
        case (.InvalidArguments, .InvalidArguments): return true
        
        default: return false
    }
}

