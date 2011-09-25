//
//  _DDSimplificationRule.h
//  DDMathParser
//
//  Created by Dave DeLong on 9/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DDExpression;

extern NSString * const DDRuleTemplateAnyNumber;
extern NSString * const DDRuleTemplateAnyFunction;
extern NSString * const DDRuleTemplateAnyVariable;
extern NSString * const DDRuleTemplateAnyExpression;

@interface _DDSimplificationRule : NSObject {
    DDExpression *predicate;
    DDExpression *replacement;
}

+ (_DDSimplificationRule *)simplicationRuleWithTemplate:(NSString *)string replacementPattern:(NSString *)replacement;

@end
