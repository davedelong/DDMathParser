//
//  Configuration.swift
//  MathParser
//
//  Created by Dave DeLong on 4/18/19.
//

import Foundation

public struct Configuration {
    
    public static let `default` = Configuration()
    
    public var operatorSet: OperatorSet
    public var locale: Locale?
    
    public var allowZeroLengthVariables: Bool
    public var unescapesQuotedVariables: Bool
    
    public var allowArgumentlessFunctions: Bool
    public var allowImplicitMultiplication: Bool
    public var useHighPrecedenceImplicitMultiplication: Bool
    
    public init() {
        operatorSet = OperatorSet.default
        locale = nil
        
        allowZeroLengthVariables = false
        unescapesQuotedVariables = true
        
        allowArgumentlessFunctions = true
        allowImplicitMultiplication = true
        useHighPrecedenceImplicitMultiplication = true
    }
    
}
