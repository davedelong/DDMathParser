//
//  _DDSimplificationRule.m
//  DDMathParser
//
//  Created by Dave DeLong on 9/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "_DDSimplificationRule.h"
#import "DDExpression.h"

NSMutableDictionary* _DDRule_ExtractExpressionsMatchingTemplates(DDExpression *rule, DDExpression *target) {
    NSMutableDictionary *d = [NSMutableDictionary dictionary];
    NSString *ruleFunction = [rule function];
    if ([ruleFunction hasPrefix:DDRuleTemplateAnyExpression]) {
        [d setObject:target forKey:ruleFunction];
    } else if ([ruleFunction hasPrefix:DDRuleTemplateAnyFunction] && [target expressionType] == DDExpressionTypeFunction) {
        [d setObject:target forKey:ruleFunction];
    } else if ([ruleFunction hasPrefix:DDRuleTemplateAnyNumber] && [target expressionType] == DDExpressionTypeNumber) {
        [d setObject:target forKey:ruleFunction];
    } else if ([ruleFunction hasPrefix:DDRuleTemplateAnyVariable] && [target expressionType] == DDExpressionTypeVariable) {
        [d setObject:target forKey:ruleFunction];
    } else if ([ruleFunction isEqualToString:[target function]]) {
        NSArray *ruleArgs = [rule arguments];
        NSArray *targetArgs = [target arguments];
        
        for (NSUInteger i = 0; i < [ruleArgs count]; ++i) {
            DDExpression *ruleArg = [ruleArgs objectAtIndex:i];
            DDExpression *targetArg = [targetArgs objectAtIndex:i];
            
            [d addEntriesFromDictionary:_DDRule_ExtractExpressionsMatchingTemplates(ruleArg, targetArg)];
        }
    }
    
    return d;
}

@interface _DDSimplificationRule ()

- (id)initWithTemplate:(NSString *)string replacementPattern:(NSString *)pattern;
- (DDExpression *)_recursivelyApplyReplacements:(NSDictionary *)replacements usingPattern:(DDExpression *)pattern;

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
        
        if (!predicate || !replacement || [predicate expressionType] != DDExpressionTypeFunction) {
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
    
    if ([function hasPrefix:DDRuleTemplateAnyExpression]) { return YES; }
    
    if ([function hasPrefix:DDRuleTemplateAnyNumber] && [target expressionType] == DDExpressionTypeNumber) {
        return YES;
    }
    
    if ([function hasPrefix:DDRuleTemplateAnyVariable] && [target expressionType] == DDExpressionTypeVariable) {
        return YES;
    }
    
    if ([function hasPrefix:DDRuleTemplateAnyFunction] && [target expressionType] == DDExpressionTypeFunction) {
        return YES;
    }
    
    if ([rule expressionType] != [target expressionType]) { return NO; }
    
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

- (BOOL)ruleMatchesExpression:(DDExpression *)target {
    return [self _ruleExpression:predicate matchesExpression:target];
}

- (DDExpression *)expressionByApplyingReplacmentsToExpression:(DDExpression *)target {
    NSDictionary *replacements = _DDRule_ExtractExpressionsMatchingTemplates(predicate, target);
    return [self _recursivelyApplyReplacements:replacements usingPattern:replacement];
}

- (DDExpression *)_recursivelyApplyReplacements:(NSDictionary *)replacements usingPattern:(DDExpression *)pattern {
    if ([pattern expressionType] == DDExpressionTypeVariable) { return pattern; }
    if ([pattern expressionType] == DDExpressionTypeNumber) { return pattern; }
    
    NSString *pFunction = [pattern function];
    
    DDExpression *functionReplacement = [replacements objectForKey:pFunction];
    if (functionReplacement) {
        if ([functionReplacement expressionType] != DDExpressionTypeFunction) {
            // replacing with either a number or variable
            return functionReplacement;
        } else {
            pFunction = [functionReplacement function];
        }
    }
    
    NSMutableArray *replacedArguments = [NSMutableArray array];
    for (DDExpression *patternArgument in [pattern arguments]) {
        DDExpression *replacementArgument = [self _recursivelyApplyReplacements:replacements usingPattern:patternArgument];
        [replacedArguments addObject:replacementArgument];
    }
    
    return [DDExpression functionExpressionWithFunction:pFunction arguments:replacedArguments error:nil];
}

@end
