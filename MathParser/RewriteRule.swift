//
//  RewriteRule.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/25/15.
//
//

import Foundation

public enum RuleTemplate {
    public static let anyExpression = "__exp"
    public static let anyNumber = "__num"
    public static let anyVariable = "__var"
    public static let anyFunction = "__func"
}

public struct RewriteRule {
    
    public let predicate: Expression
    public let condition: Expression?
    
    public let template: Expression
    
    public init(predicate: Expression, condition: Expression? = nil, template: Expression) {
        self.predicate = predicate
        self.condition = condition
        self.template = template
    }
    
    public init(predicate: String, condition: String? = nil, template: String) throws {
        self.predicate = try Expression(string: predicate)
        self.template = try Expression(string: template)
        
        if let condition = condition {
            self.condition = try Expression(string: condition)
        } else {
            self.condition = nil
        }
    }
    
    public func rewrite(_ expression: Expression, substitutions: Substitutions, evaluator: Evaluator) -> Expression {
        
        guard let replacements = expression.match(for: predicate) else {
            // the expression doesn't match the predicate
            return expression
        }
        
        if let condition = condition {
            
            // see if the expression matches the condition
            let matchingCondition = applyReplacements(replacements, toExpression: condition)
            
            // if there's an error evaluating the condition, then we don't match
            guard let result = try? evaluator.evaluate(matchingCondition, substitutions: substitutions) else {
                return expression
            }
            
            // a "zero" result value is interpreted as "false", which means we don't match
            if result == 0 { return expression }
        }
        
        // if we get here, then the expression matches the predicate and either:
        // 1. we don't have a condition or
        // 2. we have a condition, and the condition is satisfied
        return applyReplacements(replacements, toExpression: template)
    }
    
    private func applyReplacements(_ replacements: Dictionary<String, Expression>, toExpression expression: Expression) -> Expression {
        
        switch expression.kind {
            case .function(let f, let args):
                if let replacement = replacements[f] {
                    return Expression(kind: replacement.kind, range: replacement.range)
                }
            
                let newArgs = args.map { applyReplacements(replacements, toExpression: $0) }
                return Expression(kind: .function(f, newArgs), range: expression.range)
            
            default:
                return Expression(kind: expression.kind, range: expression.range)
        }
    }
}
