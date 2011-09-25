//
//  _DDSimplificationRule.m
//  DDMathParser
//
//  Created by Dave DeLong on 9/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "_DDSimplificationRule.h"
#import "DDExpression.h"

@interface _DDSimplificationRule ()

- (id)initWithTemplate:(NSString *)string replacementPattern:(NSString *)pattern;

@end

@implementation _DDSimplificationRule

+ (_DDSimplificationRule *)simplicationRuleWithTemplate:(NSString *)string replacementPattern:(NSString *)replacement {
    return [[[self alloc] initWithTemplate:string replacementPattern:replacement] autorelease];
}

- (id)initWithTemplate:(NSString *)string replacementPattern:(NSString *)patternFormat {
    self = [super init];
    if (self) {
        NSError *error = nil;
        predicate = [[DDExpression expressionFromString:string error:&error] retain];
        pattern = [[DDExpression expressionFromString:patternFormat error:&error] retain];
        replacements = [[NSMutableDictionary alloc] init];
        
        if (!predicate || !pattern || [predicate expressionType] != DDExpressionTypeFunction) {
            NSLog(@"error creating rule: %@", error);
            [self release];
            return nil;
        }
    }
    return self;
}

- (void)dealloc {
    [predicate release];
    [pattern release];
    [replacements release];
    [super dealloc];
}

- (BOOL)_ruleExpression:(DDExpression *)rule matchesExpression:(DDExpression *)target  {
    if ([rule expressionType] == DDExpressionTypeNumber || [rule expressionType] == DDExpressionTypeVariable) {
        return [target isEqual:rule];
    }
    
    NSString *function = [rule function];
    
    if ([function hasPrefix:DDRuleTemplateAnyExpression]) {
        DDExpression *seenBefore = [replacements objectForKey:function];
        if (seenBefore != nil) {
            return [seenBefore isEqual:target];
        }
        [replacements setObject:target forKey:function];
        return YES;
    }
    
    if ([function hasPrefix:DDRuleTemplateAnyNumber] && [target expressionType] == DDExpressionTypeNumber) {
        DDExpression *seenBefore = [replacements objectForKey:function];
        if (seenBefore != nil) {
            return [seenBefore isEqual:target];
        }
        [replacements setObject:target forKey:function];
        return YES;
    }
    
    if ([function hasPrefix:DDRuleTemplateAnyVariable] && [target expressionType] == DDExpressionTypeVariable) {
        DDExpression *seenBefore = [replacements objectForKey:function];
        if (seenBefore != nil) {
            return [seenBefore isEqual:target];
        }
        [replacements setObject:target forKey:function];
        return YES;
    }
    
    if ([function hasPrefix:DDRuleTemplateAnyFunction] && [target expressionType] == DDExpressionTypeFunction) {
        DDExpression *seenBefore = [replacements objectForKey:function];
        if (seenBefore != nil) {
            return [seenBefore isEqual:target];
        }
        [replacements setObject:target forKey:function];
        return YES;        
    }
    
    if ([rule expressionType] != [target expressionType]) { return NO; }
    
    // the target is a function
    // first match all the arguments
    // then we'll see about matching the functions
    
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
    
    if (![function isEqual:[target function]]) { return NO; }
    
    return argsMatch;
}

- (BOOL)ruleMatchesExpression:(DDExpression *)target {
    // clear out the replacements we'd seen before
    [replacements removeAllObjects];
    
    return [self _ruleExpression:predicate matchesExpression:target];
}

- (DDExpression *)_expressionByApplyingReplacementsToPattern:(DDExpression *)p {
    if ([p expressionType] == DDExpressionTypeVariable) { return p; }
    if ([p expressionType] == DDExpressionTypeNumber) { return p; }
    
    NSString *pFunction = [p function];
    
    DDExpression *functionReplacement = [replacements objectForKey:pFunction];
    if (functionReplacement) {
        return functionReplacement;
    }
    
    NSMutableArray *replacedArguments = [NSMutableArray array];
    for (DDExpression *patternArgument in [p arguments]) {
        DDExpression *replacementArgument = [self _expressionByApplyingReplacementsToPattern:patternArgument];
        [replacedArguments addObject:replacementArgument];
    }
    
    return [DDExpression functionExpressionWithFunction:pFunction arguments:replacedArguments error:nil];
}

- (DDExpression *)expressionByApplyingReplacmentsToExpression:(DDExpression *)target {
    if (![self ruleMatchesExpression:target]) { return nil; }
    return [self _expressionByApplyingReplacementsToPattern:pattern];
}

@end
