//
//  RewriteRule.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/25/15.
//
//

import Foundation

public enum RuleTemplate: Sendable {
    public static let anyExpression = "__exp"
    public static let anyNumber = "__num"
    public static let anyVariable = "__var"
    public static let anyFunction = "__func"
}

public struct RewriteRule: Sendable {
    
    internal typealias Matches = Dictionary<String, Expression>
    
    public let predicate: Expression
    public let condition: Expression?
    
    public let template: Expression
    
    public init(predicate: Expression, condition: Expression? = nil, template: Expression) {
        self.predicate = predicate
        self.condition = condition
        self.template = template
    }
    
    public init(predicate: String, condition: String? = nil, template: String) throws(MathParserError) {
        self.predicate = try Expression(string: predicate)
        self.template = try Expression(string: template)
        
        if let condition = condition {
            self.condition = try Expression(string: condition)
        } else {
            self.condition = nil
        }
    }
    
    public func rewrite(_ expression: Expression, variables: Variables, evaluator: Evaluator) -> Expression {
        
        guard let replacements = match(expression: expression, against: predicate) else {
            // the expression doesn't match the predicate
            return expression
        }
        
        if let condition = condition {
            
            // see if the expression matches the condition
            let matchingCondition = applyReplacements(replacements, toExpression: condition)
            
            // if there's an error evaluating the condition, then we don't match
            guard let result = try? evaluator.evaluate(matchingCondition, variables: variables) else {
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
    
    public func matches(_ expression: Expression) -> Bool {
        return match(expression: expression, against: predicate) != nil
    }
    
    private func match(expression: Expression, against target: Expression, matchedSoFar: Matches? = nil) -> Matches? {
        var replacements = matchedSoFar ?? [:]
        
        switch target.kind {
            // we're looking for a specific number; return the replacements if we match that number
            case .number(_): return expression == target ? replacements : nil
                
            // we're looking for a specific variable; return the replacements if we match
            case .variable(_): return expression == target ? replacements : nil
                
            // we're looking for something else
            case .function(let f, let args):
                
                // we're looking for anything
                if f.hasPrefix(RuleTemplate.anyExpression) {
                    // is this a matcher ("__exp42") we've seen before?
                    // if it is, only return replacements if it's the same expression
                    // as what has already been matched
                    if let seenBefore = replacements[f] {
                        return seenBefore == expression ? replacements : nil
                    }
                    
                    // otherwise remember this one and return the new replacements
                    replacements[f] = expression
                    return replacements
                }
                
                // we're looking for any number
                if f.hasPrefix(RuleTemplate.anyNumber) && expression.isNumber {
                    if let seenBefore = replacements[f] {
                        return seenBefore == expression ? replacements : nil
                    }
                    replacements[f] = expression
                    return replacements
                }
                
                // we're looking for any variable
                if f.hasPrefix(RuleTemplate.anyVariable) && expression.isVariable {
                    if let seenBefore = replacements[f] {
                        return seenBefore == expression ? replacements : nil
                    }
                    replacements[f] = expression
                    return replacements
                }
                
                // we're looking for any function
                if f.hasPrefix(RuleTemplate.anyFunction) && expression.isFunction {
                    if let seenBefore = replacements[f] {
                        return seenBefore == expression ? replacements : nil
                    }
                    replacements[f] = expression
                    return replacements
                }
                
                // if we make it this far, we're looking for a specific function
                // make sure the expression we're matching against is also a function
                guard case let .function(expressionF, expressionArgs) = expression.kind else { return nil }
                // make sure the functions have the same name
                guard expressionF == f else { return nil }
                // make sure the functions have the same number of arguments
                guard expressionArgs.count == args.count else { return nil }
                
                // make sure each argument matches
                for (expressionArg, targetArg) in zip(expressionArgs, args) {
                    // if this argument doesn't match, return nil
                    guard let argReplacements = self.match(expression: expressionArg, against: targetArg, matchedSoFar: replacements) else { return nil }
                    replacements = argReplacements
                }
                
                return replacements
        }
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
