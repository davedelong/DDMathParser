//
//  Expression+Matching.swift
//  MathParser
//
//  Created by Dave DeLong on 4/22/19.
//

import Foundation

public extension Expression {
    
    typealias Matches = Dictionary<String, Expression>
    
    func match(for target: Expression, matchedSoFar: Matches? = nil) -> Matches? {
        var replacements = matchedSoFar ?? [:]
        
        switch target.kind {
            // we're looking for a specific number; return the replacements if we match that number
            case .number(_): return self == target ? replacements : nil
                
            // we're looking for a specific variable; return the replacements if we match
            case .variable(_): return self == target ? replacements : nil
                
            // we're looking for something else
            case .function(let f, let args):
                
                // we're looking for anything
                if f.hasPrefix(RuleTemplate.anyExpression) {
                    // is this a matcher ("__exp42") we've seen before?
                    // if it is, only return replacements if it's the same expression
                    // as what has already been matched
                    if let seenBefore = replacements[f] {
                        return seenBefore == self ? replacements : nil
                    }
                    
                    // otherwise remember this one and return the new replacements
                    replacements[f] = self
                    return replacements
                }
                
                // we're looking for any number
                if f.hasPrefix(RuleTemplate.anyNumber) && kind.isNumber {
                    if let seenBefore = replacements[f] {
                        return seenBefore == self ? replacements : nil
                    }
                    replacements[f] = self
                    return replacements
                }
                
                // we're looking for any variable
                if f.hasPrefix(RuleTemplate.anyVariable) && kind.isVariable {
                    if let seenBefore = replacements[f] {
                        return seenBefore == self ? replacements : nil
                    }
                    replacements[f] = self
                    return replacements
                }
                
                // we're looking for any function
                if f.hasPrefix(RuleTemplate.anyFunction) && kind.isFunction {
                    if let seenBefore = replacements[f] {
                        return seenBefore == self ? replacements : nil
                    }
                    replacements[f] = self
                    return replacements
                }
                
                // if we make it this far, we're looking for a specific function
                // make sure the expression we're matching against is also a function
                guard case let .function(expressionF, expressionArgs) = kind else { return nil }
                // make sure the functions have the same name
                guard expressionF == f else { return nil }
                // make sure the functions have the same number of arguments
                guard expressionArgs.count == args.count else { return nil }
                
                // make sure each argument matches
                for (expressionArg, targetArg) in zip(expressionArgs, args) {
                    // if this argument doesn't match, return nil
                    guard let argReplacements = expressionArg.match(for: targetArg, matchedSoFar: replacements) else { return nil }
                    replacements = argReplacements
                }
                
                return replacements
        }
    }
    
    func matches(_ expression: Expression) -> Bool {
        return match(for: expression) != nil
    }
    
}
