//
//  _DDRewriteRule.h
//  DDMathParser
//
//  Created by Dave DeLong on 9/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DDExpression;

@interface _DDRewriteRule : NSObject {
    DDExpression *predicate;
    DDExpression *pattern;
}

+ (_DDRewriteRule *)rewriteRuleWithTemplate:(NSString *)string replacementPattern:(NSString *)replacement;

- (BOOL)ruleMatchesExpression:(DDExpression *)target;

// returns nil if the rule does not match the target expression
- (DDExpression *)expressionByRewritingExpression:(DDExpression *)target;

@end
