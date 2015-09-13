//
//  String.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/24/15.
//
//

import Foundation

public extension String {
    
    public func evaluate(substitutions: Substitutions = [:]) throws -> Double {
        let e = try Expression(string: self)
        return try Evaluator.defaultEvaluator.evaluate(e, substitutions: substitutions)
    }
    
}
