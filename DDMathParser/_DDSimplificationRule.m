//
//  _DDSimplificationRule.m
//  DDMathParser
//
//  Created by Dave DeLong on 9/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "_DDSimplificationRule.h"
#import "DDExpression.h"

NSString * const DDRuleTemplateAnyNumber = @"__num__()";
NSString * const DDRuleTemplateAnyFunction = @"__func__()";
NSString * const DDRuleTemplateAnyVariable = @"__var__()";
NSString * const DDRuleTemplateAnyExpression = @"__exp__()";

@interface _DDSimplificationRule ()

- (id)initWithTemplate:(NSString *)string replacementPattern:(NSString *)pattern;

@end

@implementation _DDSimplificationRule

+ (_DDSimplificationRule *)simplicationRuleWithTemplate:(NSString *)string replacementPattern:(NSString *)replacement {
    return [[[self alloc] initWithTemplate:string replacementPattern:replacement] autorelease];
}

- (id)initWithTemplate:(NSString *)string replacementPattern:(NSString *)pattern {
    self = [super init];
    if (self) {
        NSError *error = nil;
        predicate = [[DDExpression expressionFromString:string error:&error] retain];
        replacement = [[DDExpression expressionFromString:pattern error:&error] retain];
        
        if (!predicate || !replacement) {
            NSLog(@"error creating rule: %@", error);
            [self release];
            return nil;
        }
    }
    return self;
}

- (void)dealloc {
    [predicate release];
    [replacement release];
    [super dealloc];
}

- (BOOL)_ruleExpression:(DDExpression *)rule matchesExpression:(DDExpression *)target {
    if ([rule expressionType] == DDExpressionTypeNumber || [rule expressionType] == DDExpressionTypeVariable) {
        return [target isEqual:rule];
    }
    
    NSString *function = [rule function];
    
    if ([function isEqual:DDRuleTemplateAnyExpression]) { return YES; }
    
    if ([function isEqual:DDRuleTemplateAnyNumber] && [target expressionType] == DDExpressionTypeNumber) {
        return YES;
    }
    
    if ([function isEqual:DDRuleTemplateAnyVariable] && [target expressionType] == DDExpressionTypeVariable) {
        return YES;
    }
    
    if ([function isEqual:DDRuleTemplateAnyFunction] && [target expressionType] == DDExpressionTypeFunction) {
        return YES;
    }
    
    if (![function isEqual:[target function]]) { return NO; }
    NSArray *ruleArgs = [rule arguments];
    NSArray *targetArgs = [target arguments];
    
    if ([ruleArgs count] != [targetArgs count]) { return NO; }
    
    BOOL argsMatch = YES;
    for (NSUInteger i = 0; i < [ruleArgs count]; ++i) {
        DDExpression *ruleArg = [ruleArgs objectAtIndex:i];
        DDExpression *targetArg = [targetArgs objectAtIndex:i];
        
        argsMatch &= [self _ruleExpression:ruleArg matchesExpression:targetArg];
        
        if (!argsMatch) { break; }
    }    
    
    return argsMatch;
}

- (BOOL)matchesExpression:(DDExpression *)target {
    return [self _ruleExpression:predicate matchesExpression:target];
}

@end
