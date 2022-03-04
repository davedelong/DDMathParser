
//
//  RewriteRule+Defaults.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/25/15.
//
//

import Foundation

extension RewriteRule {
    
    public static let defaultRules: Array<RewriteRule> = [
        try! RewriteRule(predicate: "0 + __exp1", template: "__exp1"),
        try! RewriteRule(predicate: "__exp1 + 0", template: "__exp1"),
        try! RewriteRule(predicate: "__exp1 + __exp1", template: "2 * __exp1"),
        try! RewriteRule(predicate: "__exp1 - __exp1", template: "0"),
        try! RewriteRule(predicate: "1 * __exp1", template: "__exp1"),
        try! RewriteRule(predicate: "__exp1 * 1", template: "__exp1"),
        try! RewriteRule(predicate: "__exp1 / 1", template: "__exp1"),
        try! RewriteRule(predicate: "__exp1 * __exp1", template: "__exp1 ** 2"),
        try! RewriteRule(predicate: "__num1 * __var1", template: "__var1 * __num1"),
        try! RewriteRule(predicate: "0 * __exp1", template: "0"),
        try! RewriteRule(predicate: "__exp1 * 0", template: "0"),
        try! RewriteRule(predicate: "--__exp1", template: "__exp1"),
        try! RewriteRule(predicate: "abs(-__exp1)", template: "abs(__exp1)"),
        try! RewriteRule(predicate: "exp(__exp1) * exp(__exp2)", template: "exp(__exp1 + __exp2)"),
        try! RewriteRule(predicate: "(__exp1 ** __exp3) * (__exp2 ** __exp3)", template: "(__exp1 * __exp2) ** __exp3"),
        try! RewriteRule(predicate: "__exp1 ** 0", template: "1"),
        try! RewriteRule(predicate: "__exp1 ** 1", template: "__exp1"),
        try! RewriteRule(predicate: "sqrt(__exp1 ** 2)", template: "abs(__exp1)"),
        try! RewriteRule(predicate: "dtor(rtod(__exp1))", template: "__exp1"),
        try! RewriteRule(predicate: "rtod(dtor(__exp1))", template: "__exp1"),

        
        //division
        try! RewriteRule(predicate: "__exp1 / __exp1", condition: "__exp1 != 0", template: "1"),
        try! RewriteRule(predicate: "(__exp1 * __exp2) / __exp2", condition: "__exp2 != 0", template: "__exp1"),
        try! RewriteRule(predicate: "(__exp2 * __exp1) / __exp2", condition: "__exp2 != 0", template: "__exp1"),
        try! RewriteRule(predicate: "__exp2 / (__exp2 * __exp1)", condition: "__exp2 != 0", template: "1/__exp1"),
        try! RewriteRule(predicate: "__exp2 / (__exp1 * __exp2)", condition: "__exp2 != 0", template: "1/__exp1"),

        
        //exponents and roots
        try! RewriteRule(predicate: "nthroot(__exp1, 1)", template: "__exp1"),
        try! RewriteRule(predicate: "nthroot(pow(__exp1, __exp2), __exp2)", condition: "__exp2 % 2 == 0", template: "abs(__exp1)"),
        try! RewriteRule(predicate: "nthroot(pow(__exp1, __exp2), __exp2)", condition: "__exp2 % 2 == 1", template: "__exp1"),
        try! RewriteRule(predicate: "abs(__exp1)", condition: "__exp1 >= 0", template: "__exp1")
    ]
}
