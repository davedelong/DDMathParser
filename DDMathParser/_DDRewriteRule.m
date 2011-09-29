//
//  _DDRewriteRule.m
//  DDMathParser
//
//  Created by Dave DeLong on 9/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DDMathParser.h"
#import "_DDRewriteRule.h"
#import "DDExpression.h"

@interface _DDRewriteRule ()

- (id)initWithTemplate:(NSString *)string replacementPattern:(NSString *)pattern;

@end

@implementation _DDRewriteRule

+ (_DDRewriteRule *)rewriteRuleWithTemplate:(NSString *)string replacementPattern:(NSString *)replacement {
    return DD_AUTORELEASE([[self alloc] initWithTemplate:string replacementPattern:replacement]);
}

- (id)initWithTemplate:(NSString *)string replacementPattern:(NSString *)patternFormat {
    self = [super init];
    if (self) {
        NSError *error = nil;
        predicate = DD_RETAIN([DDExpression expressionFromString:string error:&error]);
        pattern = DD_RETAIN([DDExpression expressionFromString:patternFormat error:&error]);
        
        if (!predicate || !pattern || [predicate expressionType] != DDExpressionTypeFunction) {
            NSLog(@"error creating rule: %@", error);
            DD_RELEASE(self);
            return nil;
        }
    }
    return self;
}

#if !DD_HAS_ARC
- (void)dealloc {
    [predicate release];
    [pattern release];
    [super dealloc];
}
#endif

- (BOOL)_ruleExpression:(DDExpression *)rule matchesExpression:(DDExpression *)target withReplacements:(NSMutableDictionary *)replacements {
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
    
    if (![function isEqual:[target function]]) { return NO; }
    
    BOOL argsMatch = YES;
    for (NSUInteger i = 0; i < [ruleArgs count]; ++i) {
        DDExpression *ruleArg = [ruleArgs objectAtIndex:i];
        DDExpression *targetArg = [targetArgs objectAtIndex:i];
        
        argsMatch &= [self _ruleExpression:ruleArg matchesExpression:targetArg withReplacements:replacements];
        
        if (!argsMatch) { break; }
    }
    
    return argsMatch;
}

- (BOOL)ruleMatchesExpression:(DDExpression *)target {
    return [self _ruleExpression:predicate matchesExpression:target withReplacements:[NSMutableDictionary dictionary]];
}

- (DDExpression *)_expressionByApplyingReplacements:(NSDictionary *)replacements toPattern:(DDExpression *)p {
    if ([p expressionType] == DDExpressionTypeVariable) { return p; }
    if ([p expressionType] == DDExpressionTypeNumber) { return p; }
    
    NSString *pFunction = [p function];
    
    DDExpression *functionReplacement = [replacements objectForKey:pFunction];
    if (functionReplacement) {
        return functionReplacement;
    }
    
    NSMutableArray *replacedArguments = [NSMutableArray array];
    for (DDExpression *patternArgument in [p arguments]) {
        DDExpression *replacementArgument = [self _expressionByApplyingReplacements:replacements toPattern:patternArgument];
        [replacedArguments addObject:replacementArgument];
    }
    
    return [DDExpression functionExpressionWithFunction:pFunction arguments:replacedArguments error:nil];
}

- (DDExpression *)expressionByRewritingExpression:(DDExpression *)target {
    NSMutableDictionary *replacements = [NSMutableDictionary dictionary];
    if (![self _ruleExpression:predicate matchesExpression:target withReplacements:replacements]) { return target; }
    
    return [self _expressionByApplyingReplacements:replacements toPattern:pattern];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ (%@ => %@)", [super description], predicate, pattern];
}

@end
