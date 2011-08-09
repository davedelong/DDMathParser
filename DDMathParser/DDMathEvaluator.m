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

@interface DDMathEvaluator ()

+ (NSSet *) _standardFunctions;
+ (NSDictionary *) _standardAliases;
+ (NSSet *)_standardNames;
- (void) _registerStandardFunctions;

@end


@implementation DDMathEvaluator

NSMutableArray *functions;
NSMutableDictionary * functionMap;

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
		[self _registerStandardFunctions];
	}
	return self;
}

- (void) dealloc {
	if (self == _sharedEvaluator) {
		_sharedEvaluator = nil;
	}
	[functions release];
    [functionMap release];
	[super dealloc];
}

#pragma mark - Functions

- (BOOL) registerFunction:(DDMathFunction)function forName:(NSString *)functionName {
    NSString *name = [_DDFunctionContainer normalizedAlias:functionName];
    
	if ([self functionWithName:functionName] != nil) { return NO; }
	if ([[[self class] _standardNames] containsObject:name]) { return NO; }
    
    _DDFunctionContainer *container = [[_DDFunctionContainer alloc] initWithFunction:function name:name];
    [functions addObject:container];
    [functionMap setObject:container forKey:name];
    [container release];
	
	return YES;
}

- (void) unregisterFunctionWithName:(NSString *)functionName {
    NSString *name = [_DDFunctionContainer normalizedAlias:functionName];
	//can't unregister built-in functions
	if ([[[self class] _standardNames] containsObject:name]) { return; }
	
    _DDFunctionContainer *container = [[_DDFunctionContainer alloc] initWithFunction:[self functionWithName:functionName] name:functionName];
    for (NSString *alias in [container aliases]) {
        [functionMap removeObjectForKey:name];
    }
    [functions removeObject:container];
    [container release];
}

- (DDMathFunction) functionWithName:(NSString *)functionName {
    NSString *name = [_DDFunctionContainer normalizedAlias:functionName];
    _DDFunctionContainer *container = [functionMap objectForKey:name];
    return [container function];
}

- (NSArray *) registeredFunctions {
	return [functionMap allKeys];
}

- (BOOL) functionExpressionFailedToResolve:(_DDFunctionExpression *)functionExpression error:(NSError **)error {
	if (error) {
		*error = ERR_GENERIC(@"unable to resolve function: %@", [functionExpression function]);
	} else {
		NSLog(@"unable to resolve function: %@", [functionExpression function]);
	}
	return NO;
}

- (BOOL) addAlias:(NSString *)alias forFunctionName:(NSString *)functionName {
	//we can't add an alias for a function that already exists
	DDMathFunction function = [self functionWithName:alias];
	if (function != nil) { return NO; }
    
    NSString *name = [_DDFunctionContainer normalizedAlias:functionName];
    _DDFunctionContainer *container = [functionMap objectForKey:name];
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
			
			//functions that take 0 parameters
			@"pi",
			@"pi_2",
			@"pi_4",
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
            @"phi", @"\u03D5", // ϕ
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
                [container release];
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

@end
