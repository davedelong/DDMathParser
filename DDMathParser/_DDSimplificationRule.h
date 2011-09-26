//
//  _DDSimplificationRule.h
//  DDMathParser
//
//  Created by Dave DeLong on 9/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DDExpression;

#ifndef __DDRuleTemplates__
#define __DDRuleTemplates__

#define DDRuleTemplateAnyNumber @"__num"
#define DDRuleTemplateAnyFunction @"__func"
#define DDRuleTemplateAnyVariable @"__var"
#define DDRuleTemplateAnyExpression @"__exp"

#endif

@interface _DDSimplificationRule : NSObject {
    DDExpression *predicate;
    DDExpression *pattern;
}

+ (_DDSimplificationRule *)simplicationRuleWithTemplate:(NSString *)string replacementPattern:(NSString *)replacement;

- (BOOL)ruleMatchesExpression:(DDExpression *)target;

// returns nil if the rule does not match the target expression
- (DDExpression *)expressionByApplyingReplacmentsToExpression:(DDExpression *)target;

@end
