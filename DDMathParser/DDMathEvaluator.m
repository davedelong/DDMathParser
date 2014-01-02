//
//  DDMathEvaluator.m
//  DDMathParser
//
//  Created by Dave DeLong on 11/17/10.
//  Copyright 2010 Home. All rights reserved.
//
#import "DDMathParser.h"
#import "DDMathEvaluator.h"
#import "DDMathEvaluator+Private.h"
#import "DDParser.h"
#import "DDMathParserMacros.h"
#import "DDExpression.h"
#import "_DDFunctionEvaluator.h"
#import "_DDPrecisionFunctionEvaluator.h"
#import "_DDRewriteRule.h"
#import <objc/runtime.h>


@implementation DDMathEvaluator {
	NSMutableDictionary * _functionMap;
    NSMutableArray *_rewriteRules;
    _DDFunctionEvaluator *_functionEvaluator;
}


+ (id)sharedMathEvaluator {
    return [self defaultMathEvaluator];
}

+ (instancetype)defaultMathEvaluator {
    static DDMathEvaluator * _defaultEvaluator = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
		_defaultEvaluator = [[DDMathEvaluator alloc] init];
    });
	return _defaultEvaluator;
}

- (id)init {
	self = [super init];
	if (self) {
        _functionMap = [[NSMutableDictionary alloc] init];
        _angleMeasurementMode = DDAngleMeasurementModeRadians;
        _functionEvaluator = [[_DDFunctionEvaluator alloc] initWithMathEvaluator:self];
        
        NSDictionary *aliases = [[self class] _standardAliases];
        for (NSString *alias in aliases) {
            NSString *function = [aliases objectForKey:alias];
            [self addAlias:alias forFunctionName:function];
        }
	}
	return self;
}

#pragma mark - Properties

- (void)setUsesHighPrecisionEvaluation:(BOOL)usesHighPrecisionEvaluation {
    if (usesHighPrecisionEvaluation != _usesHighPrecisionEvaluation) {
        _usesHighPrecisionEvaluation = usesHighPrecisionEvaluation;
        
        if (_usesHighPrecisionEvaluation) {
            _functionEvaluator = [[_DDPrecisionFunctionEvaluator alloc] initWithMathEvaluator:self];
        } else {
            _functionEvaluator = [[_DDFunctionEvaluator alloc] initWithMathEvaluator:self];
        }
    }
}

#pragma mark - Functions

- (BOOL)registerFunction:(DDMathFunction)function forName:(NSString *)functionName {
    functionName = [functionName lowercaseString];
    
    // we cannot re-register a standard function
    if ([_DDFunctionEvaluator isStandardFunction:functionName]) {
        return NO;
    }
    
    // we cannot register something that is already registered
    if ([_functionMap objectForKey:functionName] != nil) {
        return NO;
    }
    
    function = [function copy];
    [_functionMap setObject:function forKey:functionName];
    
    return YES;
}

- (void)unregisterFunctionWithName:(NSString *)functionName {
    functionName = [functionName lowercaseString];
    [_functionMap removeObjectForKey:functionName];
}

- (NSArray *)registeredFunctions {
    NSMutableArray *array = [NSMutableArray array];
    
    [array addObjectsFromArray:[[_DDFunctionEvaluator standardFunctions] array]];
    [array addObjectsFromArray:[_functionMap allKeys]];
    
    [array sortUsingSelector:@selector(compare:)];
    
    return array;
}

#pragma mark - Lazy Resolution

- (DDExpression *)resolveFunction:(_DDFunctionExpression *)functionExpression variables:(NSDictionary *)variables error:(NSError **)error {
    NSString *functionName = [functionExpression function];
    
    DDExpression *e = nil;
    
    if ([self resolvesFunctionsAsVariables]) {
        // see if we have a variable value with the same name as the function
        id variableValue = [variables objectForKey:functionName];
        NSNumber *n = [self _evaluateValue:variableValue withSubstitutions:variables error:error];
        if (n != nil) {
            e = [DDExpression numberExpressionWithNumber:n];
        }
    }
    
    DDMathFunction function = [_functionMap objectForKey:functionName];
    if (e == nil && function == nil && _functionResolver != nil) {
        function = _functionResolver(functionName);
        if (function) {
            [self registerFunction:function forName:functionName];
        }
    }
    
    if (e == nil && function != nil) {
        e = function([functionExpression arguments], variables, self, error);
    }
    
	if (e == nil && error != nil) {
        *error = [NSError errorWithDomain:DDMathParserErrorDomain
                                     code:DDErrorCodeUnresolvedFunction
                                 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"unable to resolve function: %@", functionName],
                                            DDUnknownFunctionKey: functionName}];
	}
	return e;
}

- (id)variableWithName:(NSString *)variableName {
    id value = nil;
    if (_variableResolver != nil) {
        value = _variableResolver(variableName);
    }
    return value;
}

#pragma mark - Aliases

- (BOOL)addAlias:(NSString *)alias forFunctionName:(NSString *)functionName {
    alias = [alias lowercaseString];
    
	//we can't add an alias for a function that already exists
    if ([_DDFunctionEvaluator isStandardFunction:alias]) {
        return NO;
    }
    
    if ([_functionMap objectForKey:alias] != nil) {
        return NO;
    }
    
    DDMathFunction function = ^DDExpression* (NSArray *args, NSDictionary *vars, DDMathEvaluator *eval, NSError **error) {
        DDExpression *e = [DDExpression functionExpressionWithFunction:functionName arguments:args error:error];
        NSNumber *n = [eval evaluateExpression:e withSubstitutions:vars error:error];
        return [DDExpression numberExpressionWithNumber:n];
    };
    
    function = [function copy];
    [_functionMap setObject:function forKey:alias];
    
    return YES;
}

- (void)removeAlias:(NSString *)alias {
    alias = [alias lowercaseString];
    [_functionMap removeObjectForKey:alias];
}

- (void)addRewriteRule:(NSString *)rule forExpressionsMatchingTemplate:(NSString *)templateString condition:(NSString *)condition {
    [self _registerStandardRewriteRules];
    _DDRewriteRule *rewriteRule = [_DDRewriteRule rewriteRuleWithTemplate:templateString replacementPattern:rule condition:condition];
    [_rewriteRules addObject:rewriteRule];
}

#pragma mark - Evaluation

- (NSNumber *)evaluateString:(NSString *)expressionString withSubstitutions:(NSDictionary *)substitutions {
	NSError *error = nil;
	NSNumber *returnValue = [self evaluateString:expressionString withSubstitutions:substitutions error:&error];
	if (!returnValue) {
		NSLog(@"error: %@", error);
	}
	return returnValue;
}

- (NSNumber *)evaluateString:(NSString *)expressionString withSubstitutions:(NSDictionary *)substitutions error:(NSError **)error {
    DDExpression *expression = [DDExpression expressionFromString:expressionString error:error];
	if (!expression) {
		return nil;
	}
    return [self evaluateExpression:expression withSubstitutions:substitutions error:error];
}

- (NSNumber *)evaluateExpression:(DDExpression *)expression withSubstitutions:(NSDictionary *)substitutions error:(NSError **)error {
    if ([expression expressionType] == DDExpressionTypeNumber) {
        return [expression number];
    } else if ([expression expressionType] == DDExpressionTypeVariable) {
        return [self _evaluateVariableExpression:expression withSubstitutions:substitutions error:error];
    } else if ([expression expressionType] == DDExpressionTypeFunction) {
        return [self _evaluateFunctionExpression:(_DDFunctionExpression *)expression withSubstitutions:substitutions error:error];
    }
    return nil;
}

- (NSNumber *)_evaluateVariableExpression:(DDExpression *)e withSubstitutions:(NSDictionary *)substitutions error:(NSError **)error {
	id variableValue = [substitutions objectForKey:[e variable]];
    
    if (variableValue == nil) {
        // the substitutions dictionary was insufficient
        // use the variable resolver (if available)
        variableValue = [self variableWithName:[e variable]];
    }
    
    NSNumber *numberValue = [self _evaluateValue:variableValue withSubstitutions:substitutions error:error];
    if (numberValue == nil && error != nil && *error == nil) {
        *error = [NSError errorWithDomain:DDMathParserErrorDomain
                                     code:DDErrorCodeUnresolvedVariable
                                 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"unable to resolve variable: %@", e],
                                            DDUnknownVariableKey: [e variable]}];
	}
	return numberValue;
    
}

- (NSNumber *)_evaluateFunctionExpression:(_DDFunctionExpression *)e withSubstitutions:(NSDictionary *)substitutions error:(NSError **)error {
    
    id result = [_functionEvaluator evaluateFunction:e variables:substitutions error:error];
    
    if (!result) { return nil; }
    
    NSNumber *numberValue = [self _evaluateValue:result withSubstitutions:substitutions error:error];
    if (numberValue == nil && error != nil && *error == nil) {
        *error = ERR(DDErrorCodeInvalidFunctionReturnType, @"invalid return type from %@ function", [e function]);
    }
    return numberValue;
}

- (NSNumber *)_evaluateValue:(id)value withSubstitutions:(NSDictionary *)substitutions error:(NSError **)error {
    // given an object of unknown type, this evaluates it as best as it can
    if ([value isKindOfClass:[DDExpression class]]) {
        return [self evaluateExpression:value withSubstitutions:substitutions error:error];
    } else if ([value isKindOfClass:[NSString class]]) {
        return [self evaluateString:value withSubstitutions:substitutions error:error];
    } else if ([value isKindOfClass:[NSNumber class]]) {
        return value;
    }
    return nil;
}

#pragma mark - Built-In Functions

+ (NSDictionary *)_standardAliases {
    static dispatch_once_t onceToken;
    static NSDictionary *standardAliases = nil;
    dispatch_once(&onceToken, ^{
        standardAliases = @{@"avg": @"average",
                            @"mean": @"average",
                            @"trunc": @"floor",
                            @"modulo": @"mod",
                            @"\u03C0": @"pi", // π
                            @"tau_2": @"pi",
                            @"\u03C4": @"tau", // τ
                            @"\u03D5": @"phi", // ϕ
                            
                            @"vers": @"versin",
                            @"ver": @"versin",
                            @"vercos": @"vercosin",
                            @"cvs": @"coversin",
                            @"chord": @"crd"};
    });
    return standardAliases;
}

+ (NSDictionary *)_standardRewriteRules {
    static dispatch_once_t onceToken;
    static NSDictionary *rules = nil;
    dispatch_once(&onceToken, ^{
        rules = @{@"0+__exp1": @"__exp1",
                  @"__exp1+0": @"__exp1",
                  @"__exp1 + __exp1": @"2*__exp1",
                  
                  //subtraction
                  @"__exp1 - __exp1": @"0",
                  
                  //multiplication
                  @"1 * __exp1": @"__exp1",
                  @"__exp1 * 1": @"__exp1",
                  @"__exp1 * __exp1": @"pow(__exp1, 2)",
                  @"multiply(__num1, __var1)": @"multiply(__var1, __num1)",
                  @"0 * __exp1": @"0",
                  @"__exp1 * 0": @"0",
                  
                  //other stuff
                  @"--__exp1": @"__exp1",
                  @"abs(-__exp1)": @"abs(__exp1)",
                  @"exp(__exp1) * exp(__exp2)": @"exp(__exp1 + __exp2)",
                  @"pow(__exp1, __exp3) * pow(__exp2, __exp3)": @"pow(__exp1 * __exp2, __exp3)",
                  @"pow(__exp1, 0)": @"1",
                  @"pow(__exp1, 1)": @"__exp1",
                  @"sqrt(pow(__exp1, 2))": @"abs(__exp1)",
                  
                  //
                  @"dtor(rtod(__exp1))": @"__exp1"};
    });
    return rules;
}

- (void)_registerStandardRewriteRules {
    if (_rewriteRules != nil) { return; }
    
    _rewriteRules = [[NSMutableArray alloc] init];
    
    NSDictionary *templates = [[self class] _standardRewriteRules];
    for (NSString *templateString in templates) {
        NSString *replacement = [templates objectForKey:templateString];
        
        [self addRewriteRule:replacement forExpressionsMatchingTemplate:templateString condition:nil];
    }
    
    //division
    [self addRewriteRule:@"1" forExpressionsMatchingTemplate:@"__exp1 / __exp1" condition:@"__exp1 != 0"];
    [self addRewriteRule:@"__exp1" forExpressionsMatchingTemplate:@"(__exp1 * __exp2) / __exp2" condition:@"__exp2 != 0"];
    [self addRewriteRule:@"__exp1" forExpressionsMatchingTemplate:@"(__exp2 * __exp1) / __exp2" condition:@"__exp2 != 0"];
    [self addRewriteRule:@"1/__exp1" forExpressionsMatchingTemplate:@"__exp2 / (__exp2 * __exp1)" condition:@"__exp2 != 0"];
    [self addRewriteRule:@"1/__exp1" forExpressionsMatchingTemplate:@"__exp2 / (__exp1 * __exp2)" condition:@"__exp2 != 0"];
    
    //exponents and roots
    [self addRewriteRule:@"abs(__exp1)" forExpressionsMatchingTemplate:@"nthroot(pow(__exp1, __exp2), __exp2)" condition:@"__exp2 % 2 == 0"];
    [self addRewriteRule:@"__exp1" forExpressionsMatchingTemplate:@"nthroot(pow(__exp1, __exp2), __exp2)" condition:@"__exp2 % 2 == 1"];
    [self addRewriteRule:@"__exp1" forExpressionsMatchingTemplate:@"abs(__exp1)" condition:@"__exp1 >= 0"];
}

- (DDExpression *)_rewriteExpression:(DDExpression *)expression usingRule:(_DDRewriteRule *)rule {
    DDExpression *rewritten = [rule expressionByRewritingExpression:expression withEvaluator:self];
    
    // if the rule did not match, return the expression
    if (rewritten == expression && [expression expressionType] == DDExpressionTypeFunction) {
        NSMutableArray *newArguments = [NSMutableArray array];
        BOOL argsChanged = NO;
        for (DDExpression *arg in [expression arguments]) {
            DDExpression *newArg = [self _rewriteExpression:arg usingRule:rule];
            argsChanged |= (newArg != arg);
            [newArguments addObject:newArg];
        }
        
        if (argsChanged) {
            rewritten = [_DDFunctionExpression functionExpressionWithFunction:[expression function] arguments:newArguments error:nil];
        }
    }
    
    return rewritten;
}

- (DDExpression *)expressionByRewritingExpression:(DDExpression *)expression {
    [self _registerStandardRewriteRules];
    DDExpression *tmp = expression;
    NSUInteger iterationCount = 0;
    
    do {
        expression = tmp;
        BOOL changed = NO;
        
        for (_DDRewriteRule *rule in _rewriteRules) {
            DDExpression *rewritten = [self _rewriteExpression:tmp usingRule:rule];
            if (rewritten != tmp) {
                tmp = rewritten;
                changed = YES;
            }
        }
        
        // we applied all the rules and nothing changed
        if (!changed) { break; }
        iterationCount++;
    } while (tmp != nil && iterationCount < 256);
    
    if (iterationCount >= 256) {
        NSLog(@"ABORT: replacement limit reached");
    }
    
    return expression;
}

@end
