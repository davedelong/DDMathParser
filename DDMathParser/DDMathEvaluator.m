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

@interface DDMathEvaluator ()

- (NSSet *) _standardFunctions;
- (NSDictionary *) _standardAliases;
- (void) _registerStandardFunctions;

@end


@implementation DDMathEvaluator

static DDMathEvaluator * _sharedEvaluator = nil;

+ (id) sharedMathEvaluator {
	if (_sharedEvaluator == nil) {
		_sharedEvaluator = [[DDMathEvaluator alloc] init];
	}
	return _sharedEvaluator;
}

- (id) init {
	self = [super init];
	if (self) {
		functions = [[NSMutableDictionary alloc] init];
		[self _registerStandardFunctions];
	}
	return self;
}

- (void) dealloc {
	if (self == _sharedEvaluator) {
		_sharedEvaluator = nil;
	}
	[functions release];
	[super dealloc];
}

- (BOOL) registerFunction:(DDMathFunction)function forName:(NSString *)functionName {
	if ([self functionWithName:functionName] != nil) { return NO; }
	if ([[self _standardFunctions] containsObject:[functionName lowercaseString]]) { return NO; }
	
	function = Block_copy(function);
	[functions setObject:function forKey:[functionName lowercaseString]];
	Block_release(function);
	
	return YES;
}

- (void) unregisterFunctionWithName:(NSString *)functionName {
	//can't unregister built-in functions
	if ([[self _standardFunctions] containsObject:[functionName lowercaseString]]) { return; }
	
	[functions removeObjectForKey:[functionName lowercaseString]];
}

- (DDMathFunction) functionWithName:(NSString *)functionName {
	return [functions objectForKey:[functionName lowercaseString]];
}

- (NSArray *) registeredFunctions {
	return [functions allKeys];
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
	
	function = [self functionWithName:functionName];
	return [self registerFunction:function forName:alias];
}

- (void) removeAlias:(NSString *)alias {
	//you can't unregister a standard alias (like "avg")
	if ([[self _standardAliases] objectForKey:[alias lowercaseString]] != nil) { return; }
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

- (NSSet *) _standardFunctions {
	return [NSSet setWithObjects:
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
			@"sqrt2",
			@"e",
			@"log2e",
			@"log10e",
			@"ln2",
			@"ln10",
			nil];
	
}

- (NSDictionary *) _standardAliases {
	return [NSDictionary dictionaryWithObjectsAndKeys:
			@"average", @"avg",
			@"average", @"mean",
			@"floor", @"trunc",
			nil];
}

- (void) _registerStandardFunctions {
	for (NSString * functionName in [self _standardFunctions]) {
		
		NSString * methodName = [NSString stringWithFormat:@"%@Function", [functionName lowercaseString]];
		SEL methodSelector = NSSelectorFromString(methodName);
		if ([_DDFunctionUtilities respondsToSelector:methodSelector]) {
			DDMathFunction function = [_DDFunctionUtilities performSelector:methodSelector];
			if (function != nil) {
				[functions setObject:function forKey:[functionName lowercaseString]];
			} else {
				NSLog(@"error registering function: %@", functionName);
			}
		}
	}
	
	NSDictionary * aliases = [self _standardAliases];
	for (NSString * alias in aliases) {
		NSString * function = [aliases objectForKey:alias];
		(void)[self addAlias:alias forFunctionName:function];
	}
}

@end
