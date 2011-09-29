//
//  DDMathEvaluator.m
//  DDMathParser
//
//  Created by Dave DeLong on 11/17/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "DDMathEvaluator.h"
#import "DDMathEvaluator+Private.h"
#import "DDParser.h"
#import "DDMathParserMacros.h"
#import "DDExpression.h"
#import "_DDFunctionUtilities.h"
#import "_DDFunctionContainer.h"
#import "_DDRewriteRule.h"

@interface DDMathEvaluator ()

+ (NSSet *) _standardFunctions;
+ (NSDictionary *) _standardAliases;
+ (NSSet *)_standardNames;
- (void) _registerStandardFunctions;
- (void)_registerStandardRewriteRules;
- (_DDFunctionContainer *)functionContainerWithName:(NSString *)functionName;

@end


@implementation DDMathEvaluator

static DDMathEvaluator * _sharedEvaluator = nil;

+ (id) sharedMathEvaluator {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
		_sharedEvaluator = [[DDMathEvaluator alloc] init];
    });
	return _sharedEvaluator;
}

- (id) init {
	self = [super init];
	if (self) {
		functions = [[NSMutableArray alloc] init];
        functionMap = [[NSMutableDictionary alloc] init];
        rewriteRules = [[NSMutableArray alloc] init];
        
		[self _registerStandardFunctions];
        [self _registerStandardRewriteRules];
	}
	return self;
}

- (void) dealloc {
	if (self == _sharedEvaluator) {
		_sharedEvaluator = nil;
	}
#if !HAS_ARC
	[functions release];
    [functionMap release];
    [rewriteRules release];
	[super dealloc];
#endif
}

#pragma mark - Functions

- (BOOL) registerFunction:(DDMathFunction)function forName:(NSString *)functionName {
    NSString *name = [_DDFunctionContainer normalizedAlias:functionName];
    
	if ([self functionWithName:functionName] != nil) { return NO; }
	if ([[[self class] _standardNames] containsObject:name]) { return NO; }
    
    _DDFunctionContainer *container = [[_DDFunctionContainer alloc] initWithFunction:function name:name];
    [functions addObject:container];
    [functionMap setObject:container forKey:name];
    RELEASE(container);
	
	return YES;
}

- (void) unregisterFunctionWithName:(NSString *)functionName {
    NSString *name = [_DDFunctionContainer normalizedAlias:functionName];
	//can't unregister built-in functions
	if ([[[self class] _standardNames] containsObject:name]) { return; }
	
    _DDFunctionContainer *container = [self functionContainerWithName:functionName];
    for (NSString *alias in [container aliases]) {
        [functionMap removeObjectForKey:name];
    }
    [functions removeObject:container];
}

- (_DDFunctionContainer *)functionContainerWithName:(NSString *)functionName {
    NSString *name = [_DDFunctionContainer normalizedAlias:functionName];
    _DDFunctionContainer *container = [functionMap objectForKey:name];
    return container;
}

- (DDMathFunction) functionWithName:(NSString *)functionName {
    _DDFunctionContainer *container = [self functionContainerWithName:functionName];
    return [container function];
}

- (NSArray *) registeredFunctions {
	return [functionMap allKeys];
}

- (BOOL) functionExpressionFailedToResolve:(_DDFunctionExpression *)functionExpression error:(NSError **)error {
    NSString *functionName = [functionExpression function];
	if (error) {
        *error = ERR_FUNCTION(functionName, @"unable to resolve function: %@", functionName);
	} else {
		NSLog(@"unable to resolve function: %@", functionName);
	}
	return NO;
}

- (BOOL) addAlias:(NSString *)alias forFunctionName:(NSString *)functionName {
	//we can't add an alias for a function that already exists
	DDMathFunction function = [self functionWithName:alias];
	if (function != nil) { return NO; }
    
    _DDFunctionContainer *container = [self functionContainerWithName:functionName];
    alias = [_DDFunctionContainer normalizedAlias:alias];
    [container addAlias:alias];
    [functionMap setObject:container forKey:alias];
    
    return YES;
}

- (void) removeAlias:(NSString *)alias {
    alias = [_DDFunctionContainer normalizedAlias:alias];
	//you can't unregister a standard alias (like "avg")
	if ([[[self class] _standardNames] containsObject:alias]) { return; }
    [self unregisterFunctionWithName:alias];
}

- (void)addRewriteRule:(NSString *)rule forExpressionsMatchingTemplate:(NSString *)template {
    _DDRewriteRule *rewriteRule = [_DDRewriteRule rewriteRuleWithTemplate:template replacementPattern:rule];
    [rewriteRules addObject:rewriteRule];
}

#pragma mark Evaluation

- (NSNumber *) evaluateString:(NSString *)expressionString withSubstitutions:(NSDictionary *)substitutions {
	NSError *error = nil;
	NSNumber *returnValue = [self evaluateString:expressionString withSubstitutions:substitutions error:&error];
	if (!returnValue) {
		NSLog(@"error: %@", error);
	}
	return returnValue;
}

- (NSNumber *) evaluateString:(NSString *)expressionString withSubstitutions:(NSDictionary *)substitutions error:(NSError **)error {
	DDParser * parser = [DDParser parserWithString:expressionString error:error];
	if (!parser) {
		return nil;
	}
	DDExpression * parsedExpression = [parser parsedExpressionWithError:error];
	if (!parsedExpression) {
		return nil;
	}
	return [parsedExpression evaluateWithSubstitutions:substitutions evaluator:self error:error];
}

#pragma mark Built-In Functions

+ (NSSet *) _standardFunctions {
    static dispatch_once_t onceToken;
    static NSSet *standardFunctions = nil;
    dispatch_once(&onceToken, ^{
        standardFunctions = [[NSSet alloc] initWithObjects:
                             //arithmetic functions (2 parameters)
                             @"add",
                             @"subtract",
                             @"multiply",
                             @"divide",
                             @"mod",
                             @"factorial",
                             @"pow",
                             @"nthroot",
                             
                             //bitwise functions (2 parameters)
                             @"and",
                             @"or",
                             @"xor",
                             @"rshift",
                             @"lshift",
                             
                             //functions that take > 0 parameters
                             @"average",
                             @"sum",
                             @"count",
                             @"min",
                             @"max",
                             @"median",
                             @"stddev",
                             @"random",
                             
                             //functions that take 1 parameter
                             @"negate",
                             @"not",
                             @"sqrt",
                             @"log",
                             @"ln",
                             @"log2",
                             @"exp",
                             @"ceil",
                             @"trunc",
                             @"floor",
                             @"abs",
                             
                             //trig functions
                             @"sin",
                             @"cos",
                             @"tan",
                             @"asin",
                             @"acos",
                             @"atan",
                             @"dtor",
                             @"rtod",
                             @"sinh",
                             @"cosh",
                             @"tanh",
                             @"asinh",
                             @"acosh",
                             @"atanh",
                             
                             //trig inverse functions
                             @"csc",
                             @"sec",
                             @"cotan",
                             @"acsc",
                             @"asec",
                             @"acotan",
                             @"csch",
                             @"sech",
                             @"cotanh",
                             @"acsch",
                             @"asech",
                             @"acotanh",
                             
                             //more trig functions
                             @"versin",
                             @"vercosin",
                             @"coversin",
                             @"covercosin",
                             @"haversin",
                             @"havercosin",
                             @"hacoversin",
                             @"hacovercosin",
                             @"exsec",
                             @"excsc",
                             @"crd",
                             
                             //functions that take 0 parameters
                             @"pi",
                             @"pi_2",
                             @"pi_4",
                             @"tau",
                             @"phi",
                             @"sqrt2",
                             @"e",
                             @"log2e",
                             @"log10e",
                             @"ln2",
                             @"ln10",
                             nil];
    });
	return standardFunctions;
}

+ (NSDictionary *) _standardAliases {
    static dispatch_once_t onceToken;
    static NSDictionary *standardAliases = nil;
    dispatch_once(&onceToken, ^{
        standardAliases = [[NSDictionary alloc] initWithObjectsAndKeys:
                           @"average", @"avg",
                           @"average", @"mean",
                           @"floor", @"trunc",
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

+ (NSSet *)_standardNames {
    static dispatch_once_t onceToken;
    static NSSet *names = nil;
    dispatch_once(&onceToken, ^{
        NSSet *functions = [self _standardFunctions];
        NSDictionary *aliases = [self _standardAliases];
        NSMutableSet *both = [NSMutableSet setWithSet:functions];
        [both addObjectsFromArray:[aliases allKeys]];
        names = [both copy];
    });
    return names;
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
                 
                 //division
                 @"1", @"__exp1 / __exp1",
                 @"__exp1", @"__exp2 * __exp1 / __exp2",
                 @"1/__exp1", @"__exp2 / (__exp2 * __exp1)",
                 @"1/__exp1", @"__exp2 / (__exp1 * __exp2)",
                 
                 //other stuff
                 @"__exp1", @"--__exp1",
                 @"exp(__exp1 + __exp2)", @"exp(__exp1) * exp(__exp2)",
                 @"pow(__exp1 * __exp2, __exp3)", @"pow(__exp1, __exp3) * pow(__exp2, __exp3)",
                 @"1", @"pow(__exp1, 0)",
                 @"__exp1", @"pow(__exp1, 1)",
                 @"abs(__exp1)", @"sqrt(pow(__exp1, 2))",
                 @"abs(__exp1)", @"nthroot(pow(__exp1, __exp2), __exp2)",
                 
                 //
                 @"__exp1", @"dtor(rtod(__exp1))",
                 nil];
    });
    return rules;
}

- (void) _registerStandardFunctions {
	for (NSString *functionName in [[self class] _standardFunctions]) {
		
		NSString *methodName = [NSString stringWithFormat:@"%@Function", functionName];
		SEL methodSelector = NSSelectorFromString(methodName);
		if ([_DDFunctionUtilities respondsToSelector:methodSelector]) {
			DDMathFunction function = [_DDFunctionUtilities performSelector:methodSelector];
			if (function != nil) {
                _DDFunctionContainer *container = [[_DDFunctionContainer alloc] initWithFunction:function name:functionName];
                [functions addObject:container];
                [functionMap setObject:container forKey:functionName];
                RELEASE(container);
			} else {
				NSLog(@"error registering function: %@", functionName);
			}
		}
	}
	
	NSDictionary *aliases = [[self class] _standardAliases];
	for (NSString *alias in aliases) {
		NSString *function = [aliases objectForKey:alias];
		(void)[self addAlias:alias forFunctionName:function];
	}
}

- (void)_registerStandardRewriteRules {
    NSDictionary *templates = [[self class] _standardRewriteRules];
    for (NSString *template in templates) {
        NSString *replacement = [templates objectForKey:template];
        
        [self addRewriteRule:replacement forExpressionsMatchingTemplate:template];
    }
}

- (DDExpression *)_rewriteExpression:(DDExpression *)expression usingRule:(_DDRewriteRule *)rule {
    DDExpression *rewritten = [rule expressionByRewritingExpression:expression];
    
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
    DDExpression *tmp = expression;
    NSUInteger iterationCount = 0;
    
    do {
        expression = tmp;
        BOOL changed = NO;
        
        for (_DDRewriteRule *rule in rewriteRules) {
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
