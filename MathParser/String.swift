//
//  String.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/24/15.
//
//

import Foundation

extension String {
    public func evaluate(using evaluator: Evaluator = .default, _ substitutions: Substitutions = [:]) throws -> Double {
        return try evaluator.evaluate(Expression(string: self), substitutions: substitutions)
    }
}
