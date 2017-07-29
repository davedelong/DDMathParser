//
//  String.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/24/15.
//
//

import Foundation

public extension String {
    
    public func evaluate(using evaluator: Evaluator = .default, _ substitutions: Substitutions = [:]) throws -> Double {
        let e = try Expression(string: self)
        return try evaluator.evaluate(e, substitutions: substitutions)
    }
    
}
