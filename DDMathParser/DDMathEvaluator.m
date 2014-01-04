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

static DDMathEvaluator * _sharedEvaluator = nil;

+ (id)sharedMathEvaluator {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
		_sharedEvaluator = [[DDMathEvaluator alloc] init];
    });
	return _sharedEvaluator;
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

- (void)dealloc {
	if (self == _sharedEvaluator) {
		_sharedEvaluator = nil;
	}
#if !DD_HAS_ARC
    [_functionEvaluator release];
    [_functionMap release];
    [_rewriteRules release];
    [_functionResolver release];
    [_variableResolver release];
	[super dealloc];
#endif
}

#pragma mark - Properties

- (void)setUsesHighPrecisionEvaluation:(BOOL)usesHighPrecisionEvaluation {
    if (usesHighPrecisionEvaluation != _usesHighPrecisionEvaluation) {
        _usesHighPrecisionEvaluation = usesHighPrecisionEvaluation;
        DD_RELEASE(_functionEvaluator);
        
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
    DD_RELEASE(function);
    
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
    DDMathFunction function = [_functionMap objectForKey:functionName];
    
    if (function == nil && _functionResolver != nil) {
        function = _functionResolver(functionName);
        if (function) {
            [self registerFunction:function forName:functionName];
        }
    }
    
    if (function != nil) {
        e = function([functionExpression arguments], [NSDictionary dictionary], self, error);
    }
    
	if (e == nil && error != nil) {
        *error = [NSError errorWithDomain:DDMathParserErrorDomain 
                                     code:DDErrorCodeUnresolvedFunction 
                                 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                           [NSString stringWithFormat:@"unable to resolve function: %@", functionName], NSLocalizedDescriptionKey,
                                           functionName, DDUnknownFunctionKey,
                                           nil]];
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
    DD_RELEASE(function);
    
    return YES;
}

- (void)removeAlias:(NSString *)alias {
    alias = [alias lowercaseString];
    [_functionMap removeObjectForKey:alias];
}

- (void)addRewriteRule:(NSString *)rule forExpressionsMatchingTemplate:(NSString *)template condition:(NSString *)condition {
    [self _registerStandardRewriteRules];
    _DDRewriteRule *rewriteRule = [_DDRewriteRule rewriteRuleWithTemplate:template replacementPattern:rule condition:condition];
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
        variableValue = [self variableWithName:[e variable]];
    }
    
	if ([variableValue isKindOfClass:[DDExpression class]]) {
        return [self evaluateExpression:variableValue withSubstitutions:substitutions error:error];
	}
    if ([variableValue isKindOfClass:[NSString class]]) {
        return [self evaluateString:variableValue withSubstitutions:substitutions error:error];
    }
	if ([variableValue isKindOfClass:[NSNumber class]]) {
		return variableValue;
	}
	if (error != nil) {
        *error = [NSError errorWithDomain:DDMathParserErrorDomain
                                     code:DDErrorCodeUnresolvedVariable
                                 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                           [NSString stringWithFormat:@"unable to resolve variable: %@", e], NSLocalizedDescriptionKey,
                                           [e variable], DDUnknownVariableKey,
                                           nil]];
	}
	return nil;
    
}

- (NSNumber *)_evaluateFunctionExpression:(_DDFunctionExpression *)e withSubstitutions:(NSDictionary *)substitutions error:(NSError **)error {
    
    id result = [_functionEvaluator evaluateFunction:e variables:substitutions error:error];
    
    if (!result) { return nil; }
		
    NSNumber *numberValue = nil;
    if ([result isKindOfClass:[DDExpression class]]) {
        numberValue = [self evaluateExpression:result withSubstitutions:substitutions error:error];
    } else if ([result isKindOfClass:[NSNumber class]]) {
        numberValue = result;
    } else if ([result isKindOfClass:[NSString class]]) {
        numberValue = [self evaluateString:result withSubstitutions:substitutions error:error];
    } else {
        if (error != nil) {
            *error = ERR(DDErrorCodeInvalidFunctionReturnType, @"invalid return type from %@ function", [e function]);
        }
        return nil;
    }
    return numberValue;
}

#pragma mark - Built-In Functions

+ (NSDictionary *)_standardAliases {
    static dispatch_once_t onceToken;
    static NSDictionary *standardAliases = nil;
    dispatch_once(&onceToken, ^{
        standardAliases = [[NSDictionary alloc] initWithObjectsAndKeys:
                           @"average", @"avg",
                           @"average", @"mean",
                           @"floor", @"trunc",
                           @"mod", @"modulo",
                           @"pi", @"\u03C0", // π
                           @"pi", @"tau_2",
                           @"tau", @"\u03C4", // τ
                           @"phi", @"\u03D5", // ϕ
                           
                           @"versin", @"vers",
                           @"versin", @"ver",
                           @"vercosin", @"vercos",
                           @"coversin", @"cvs",
                           @"crd", @"chord",
                           
                           nil];
    });
    return standardAliases;
}

+ (NSDictionary *)_standardRewriteRules {
    static dispatch_once_t onceToken;
    static NSDictionary *rules = nil;
    dispatch_once(&onceToken, ^{
        rules = [[NSDictionary alloc] initWithObjectsAndKeys:
                 //addition
                 @"__exp1", @"0+__exp1",
                 @"__exp1", @"__exp1+0",
                 @"2*__exp1", @"__exp1 + __exp1",
                 
                 //subtraction
                 @"0", @"__exp1 - __exp1",
                 
                 //multiplication
                 @"__exp1", @"1 * __exp1",
                 @"__exp1", @"__exp1 * 1",
                 @"pow(__exp1, 2)", @"__exp1 * __exp1",
                 @"multiply(__var1, __num1)", @"multiply(__num1, __var1)",
                 @"0", @"0 * __exp1",
                 @"0", @"__exp1 * 0",
                 
                 //other stuff
                 @"__exp1", @"--__exp1",
                 @"abs(__exp1)", @"abs(-__exp1)",
                 @"exp(__exp1 + __exp2)", @"exp(__exp1) * exp(__exp2)",
                 @"pow(__exp1 * __exp2, __exp3)", @"pow(__exp1, __exp3) * pow(__exp2, __exp3)",
                 @"1", @"pow(__exp1, 0)",
                 @"__exp1", @"pow(__exp1, 1)",
                 @"abs(__exp1)", @"sqrt(pow(__exp1, 2))",
                 
                 //
                 @"__exp1", @"dtor(rtod(__exp1))",
                 nil];
    });
    return rules;
}

- (void)_registerStandardRewriteRules {
    if (_rewriteRules != nil) { return; }
    
    _rewriteRules = [[NSMutableArray alloc] init];
    
    NSDictionary *templates = [[self class] _standardRewriteRules];
    for (NSString *template in templates) {
        NSString *replacement = [templates objectForKey:template];
        
        [self addRewriteRule:replacement forExpressionsMatchingTemplate:template condition:nil];
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
