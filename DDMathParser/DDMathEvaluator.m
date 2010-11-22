//
//  DDMathEvaluator.m
//  DDMathParser
//
//  Created by Dave DeLong on 11/17/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "DDMathEvaluator.h"
#import "DDMathEvaluator+Private.h"
#import "DDMathParser.h"
#import "DDExpression.h"
#import "DDMathFunctionContainer.h"

@interface DDMathEvaluator ()

- (NSSet *) _standardFunctions;
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

- (BOOL) registerFunction:(DDMathFunction)function forName:(NSString *)functionName numberOfArguments:(NSInteger)argCount {
	if ([self functionWithName:functionName] != nil) { return NO; }
	if ([[self _standardFunctions] containsObject:[functionName lowercaseString]]) { return NO; }
	
	DDMathFunctionContainer * c = [DDMathFunctionContainer mathFunctionWithName:[functionName lowercaseString] function:function numberOfArguments:argCount];
	if (c != nil) {
		[functions setObject:c forKey:[c name]];
		return YES;
	}
	return NO;
}

- (void) unregisterFunctionWithName:(NSString *)functionName {
	//can't unregister built-in functions
	if ([[self _standardFunctions] containsObject:[functionName lowercaseString]]) { return; }
	
	[functions removeObjectForKey:[functionName lowercaseString]];
}

- (DDMathFunction) functionWithName:(NSString *)functionName {
	DDMathFunctionContainer * c = [functions objectForKey:[functionName lowercaseString]];
	return [c function];
}

- (NSInteger) numberOfArgumentsForFunction:(NSString *)functionName {
	DDMathFunctionContainer * c = [functions objectForKey:[functionName lowercaseString]];
	return [c numberOfArguments];
}

- (NSArray *) registeredFunctions {
	return [functions allKeys];
}

- (NSString *) nsexpressionFunctionWithName:(NSString *)functionName {
	NSDictionary * map = [DDMathFunctionContainer nsexpressionFunctions];
	NSString * function = [map objectForKey:[functionName lowercaseString]];
	return function;
}

#pragma mark Evaluation

- (NSNumber *) evaluateString:(NSString *)expressionString withSubstitutions:(NSDictionary *)variables {
	NSNumber * returnValue = nil;
	@try {
		DDMathParser * parser = [DDMathParser mathParserWithString:expressionString];
		DDExpression * parsedExpression = [parser parsedExpression];
		returnValue = [parsedExpression evaluateWithSubstitutions:variables evaluator:self];
	}
	@catch (NSException * e) {
		NSLog(@"caught exception: %@", e);
		returnValue = nil;
	}
	@finally {
		return returnValue;
	}
}

- (NSNumber *) evaluateFunction:(DDExpression *)expression withSubstitutions:(NSDictionary *)variables {
	DDMathFunction function = [self functionWithName:[expression function]];
	if (function == nil) {
		[NSException raise:NSInvalidArgumentException format:@"unrecognized function: %@", [expression function]];
		return nil;
	}
	
	DDExpression * evaluatedValue = function([expression arguments], variables, self);
	if (evaluatedValue != nil && [evaluatedValue expressionType] == DDExpressionTypeNumber) {
		return [evaluatedValue number];
	}
	
	[NSException raise:NSInvalidArgumentException format:@"invalid function response: %@", evaluatedValue];
	return nil;
}

- (id) performFunction:(NSArray *)parameters {
	NSMutableArray * mutableParameters = [parameters mutableCopy];
	NSString * functionName = [[mutableParameters objectAtIndex:0] constantValue];
	[mutableParameters removeObjectAtIndex:0];
	NSLog(@"stuff to %@: %@", functionName, mutableParameters);
	[mutableParameters release];
	return [NSNumber numberWithInt:0];
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
			
			//bitwise functions (2 parameters)
			@"and",
			@"or",
			@"xor",
			@"rshift",
			@"lshift",
			
			//functions that take n parameters
			@"average",
			@"sum",
			@"count",
			@"min",
			@"max",
			@"median",
			@"mode",
			@"stddev",
			
			//functions that take 1 parameter
			@"negate",
			@"not",
			@"sqrt",
			@"log",
			@"ln",
			@"exp",
			@"ceil",
			@"trunc",
			@"floor",
			@"onescomplement",
			
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

- (void) _registerStandardFunctions {
	for (NSString * functionName in [self _standardFunctions]) {
		
		NSString * methodName = [NSString stringWithFormat:@"_%@FunctionContainer", [functionName lowercaseString]];
		
		DDMathFunctionContainer * container = [DDMathFunctionContainer performSelector:NSSelectorFromString(methodName)];
		if (container != nil) {
			[functions setObject:container forKey:[functionName lowercaseString]];
		} else {
			NSLog(@"error registering function: %@", functionName);
		}
	}
}

@end
