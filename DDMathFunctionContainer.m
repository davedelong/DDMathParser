//
//  DDMathFunctionContainer.m
//  DDMathParser
//
//  Created by Dave DeLong on 11/18/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "DDMathFunctionContainer.h"

#import "DDExpression.h"

@implementation DDMathFunctionContainer
@synthesize function;
@synthesize name;
@synthesize numberOfArguments;

+ (NSDictionary *) nsexpressionFunctions {
	static NSDictionary * functions = nil;
	if (functions == nil) {
		functions = [[NSDictionary alloc] initWithObjectsAndKeys:
					 @"add:to:", @"add",
					 @"from:subtract:", @"subtract",
					 @"multiply:by:", @"multiply",
					 @"divide:by:", @"divide",
					 @"modulus:by:", @"mod",
					 @"raise:toPower:", @"pow",
					 @"bitwiseAnd:with:", @"and",
					 @"bitwiseOr:with:", @"or",
					 @"bitwiseXor:with:", @"xor",
					 @"rightshift:by:", @"rshift",
					 @"leftshift:by:", @"lshift",
					 @"average:", @"average",
					 @"sum:", @"sum",
					 @"count:", @"count",
					 @"min:", @"min",
					 @"max:", @"max",
					 @"median:", @"median",
					 @"mode:", @"mode", 
					 @"stddev:", @"stddev",
					 @"sqrt:", @"sqrt",
					 @"log:", @"log",
					 @"ln:", @"ln",
					 @"exp:", @"exp",
					 @"ceiling:", @"ceil",
					 @"abs:", @"abs",
					 @"trunc:", @"trunc",
					 @"floor:", @"floor",
					 @"onesComplement:", @"onescomplement",
					 nil];
	}
	return functions;
}

+ (DDMathFunction) oneArgumentFunctionForMethod:(NSString *)method {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		NSNumber * firstValue = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator];
		
		NSArray * parameters = [NSArray arrayWithObject:[NSExpression expressionForConstantValue:firstValue]];
		
		NSExpression * e = [NSExpression expressionForFunction:method arguments:parameters];
		NSNumber * value = [e expressionValueWithObject:nil context:nil];
		return [DDExpression numberExpressionWithNumber:value];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) twoArgumentFunctionForMethod:(NSString *)method {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		NSNumber * firstValue = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator];
		NSNumber * secondValue = [[arguments objectAtIndex:1] evaluateWithSubstitutions:variables evaluator:evaluator];
		
		NSArray * parameters = [NSArray arrayWithObjects:
								[NSExpression expressionForConstantValue:firstValue],
								[NSExpression expressionForConstantValue:secondValue],
								nil];
		
		NSExpression * add = [NSExpression expressionForFunction:method arguments:parameters];
		NSNumber * value = [add expressionValueWithObject:nil context:nil];
		return [DDExpression numberExpressionWithNumber:value];
	};
	return [[function copy] autorelease];
}

+ (id) nArgumentFunctionForMethod:(NSString *)method {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		NSMutableArray * parameters = [NSMutableArray array];
		for (DDExpression * argument in arguments) {
			NSNumber * value = [argument evaluateWithSubstitutions:variables evaluator:evaluator];
			[parameters addObject:[NSExpression expressionForConstantValue:value]];
		}
		
		NSExpression * e = [NSExpression expressionForFunction:method arguments:parameters];
		NSNumber * value = [e expressionValueWithObject:nil context:nil];
		return [DDExpression numberExpressionWithNumber:value];
	};
	return [[function copy] autorelease];	
}

+ (id) _addFunctionContainer {
	DDMathFunction function = [self twoArgumentFunctionForMethod:@"add:to:"];
	return [self mathFunctionWithName:@"add" function:function numberOfArguments:2];
}

+ (id) _subtractFunctionContainer { 
	DDMathFunction function = [self twoArgumentFunctionForMethod:@"from:subtract:"];
	return [self mathFunctionWithName:@"subtract" function:function numberOfArguments:2];
}

+ (id) _multiplyFunctionContainer { 
	return [self mathFunctionWithName:@"multiply" function:[self twoArgumentFunctionForMethod:@"multiply:by:"] numberOfArguments:2];
}
+ (id) _divideFunctionContainer {
	return [self mathFunctionWithName:@"divide" function:[self twoArgumentFunctionForMethod:@"divide:by:"] numberOfArguments:2];
}
+ (id) _modFunctionContainer { 
	return [self mathFunctionWithName:@"mod" function:[self twoArgumentFunctionForMethod:@"modulus:by:"] numberOfArguments:2];
}
+ (id) _negateFunctionContainer {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		NSNumber * firstValue = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator];
		NSNumber * secondValue = [NSNumber numberWithInt:-1];
		
		NSArray * parameters = [NSArray arrayWithObjects:
								[NSExpression expressionForConstantValue:firstValue],
								[NSExpression expressionForConstantValue:secondValue],
								nil];
		
		NSExpression * add = [NSExpression expressionForFunction:@"multiply:by:" arguments:parameters];
		NSNumber * value = [add expressionValueWithObject:nil context:nil];
		return [DDExpression numberExpressionWithNumber:value];
	};
	return [self mathFunctionWithName:@"negate" function:function numberOfArguments:1];
}
+ (id) _factorialFunctionContainer {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		if ([arguments count] != 1) {
			[NSException raise:NSInvalidArgumentException format:@"invalid number of arguments: %ld", [arguments count]];
			return nil;
		}
		
		NSNumber * firstValue = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator];
		NSInteger intValue = [firstValue integerValue];
		NSInteger total = 1;
		while (intValue > 1) {
			total *= intValue;
			intValue--;
		}
		NSNumber * result = [NSNumber numberWithInteger:total];
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [self mathFunctionWithName:@"factorial" function:function numberOfArguments:1];
}
+ (id) _powFunctionContainer { 
	return [self mathFunctionWithName:@"pow" function:[self twoArgumentFunctionForMethod:@"raise:toPower:"] numberOfArguments:2];
}

+ (id) _andFunctionContainer { 
	return [self mathFunctionWithName:@"and" function:[self twoArgumentFunctionForMethod:@"bitwiseAnd:with:"] numberOfArguments:2];
}
+ (id) _orFunctionContainer { 
	return [self mathFunctionWithName:@"or" function:[self twoArgumentFunctionForMethod:@"bitwiseOr:with:"] numberOfArguments:2];
}
+ (id) _notFunctionContainer {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		NSNumber * firstValue = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator];
		NSInteger intValue = [firstValue integerValue];
		intValue = ~intValue;
		NSNumber * value = [NSNumber numberWithInteger:intValue];
		return [DDExpression numberExpressionWithNumber:value];
	};
	return [self mathFunctionWithName:@"not" function:function numberOfArguments:1];
}
+ (id) _xorFunctionContainer { 
	return [self mathFunctionWithName:@"xor" function:[self twoArgumentFunctionForMethod:@"bitwiseXor:with:"] numberOfArguments:2];
}
+ (id) _rshiftFunctionContainer { 
	return [self mathFunctionWithName:@"rshift" function:[self twoArgumentFunctionForMethod:@"rightshift:by:"] numberOfArguments:2];
}
+ (id) _lshiftFunctionContainer { 
	return [self mathFunctionWithName:@"lshift" function:[self twoArgumentFunctionForMethod:@"leftshift:by:"] numberOfArguments:2];
}

#pragma mark NSExpression parity

+ (id) _averageFunctionContainer {
	return [self mathFunctionWithName:@"average" function:[self nArgumentFunctionForMethod:@"average:"] numberOfArguments:DDMathFunctionUnlimitedArguments];
}

+ (id) _sumFunctionContainer {
	return [self mathFunctionWithName:@"sum" function:[self nArgumentFunctionForMethod:@"sum:"] numberOfArguments:DDMathFunctionUnlimitedArguments];
}

+ (id) _countFunctionContainer {
	return [self mathFunctionWithName:@"count" function:[self nArgumentFunctionForMethod:@"count:"] numberOfArguments:DDMathFunctionUnlimitedArguments];
}

+ (id) _minFunctionContainer {
	return [self mathFunctionWithName:@"min" function:[self nArgumentFunctionForMethod:@"min:"] numberOfArguments:DDMathFunctionUnlimitedArguments];
}

+ (id) _maxFunctionContainer {
	return [self mathFunctionWithName:@"max" function:[self nArgumentFunctionForMethod:@"max:"] numberOfArguments:DDMathFunctionUnlimitedArguments];
}

+ (id) _medianFunctionContainer {
	return [self mathFunctionWithName:@"median" function:[self nArgumentFunctionForMethod:@"median:"] numberOfArguments:DDMathFunctionUnlimitedArguments];
}

+ (id) _modeFunctionContainer {
	return [self mathFunctionWithName:@"mode" function:[self nArgumentFunctionForMethod:@"mode:"] numberOfArguments:DDMathFunctionUnlimitedArguments];
}

+ (id) _stddevFunctionContainer {
	return [self mathFunctionWithName:@"stddev" function:[self nArgumentFunctionForMethod:@"stddev:"] numberOfArguments:DDMathFunctionUnlimitedArguments];
}

+ (id) _sqrtFunctionContainer {
	return [self mathFunctionWithName:@"sqrt" function:[self oneArgumentFunctionForMethod:@"sqrt:"] numberOfArguments:1];
}

+ (id) _logFunctionContainer {
	return [self mathFunctionWithName:@"log" function:[self oneArgumentFunctionForMethod:@"log:"] numberOfArguments:1];
}

+ (id) _lnFunctionContainer {
	return [self mathFunctionWithName:@"ln" function:[self oneArgumentFunctionForMethod:@"ln:"] numberOfArguments:1];
}

+ (id) _expFunctionContainer {
	return [self mathFunctionWithName:@"exp" function:[self oneArgumentFunctionForMethod:@"exp:"] numberOfArguments:1];
}

+ (id) _ceilFunctionContainer {
	return [self mathFunctionWithName:@"ceil" function:[self oneArgumentFunctionForMethod:@"ceiling:"] numberOfArguments:1];
}

+ (id) _absFunctionContainer {
	return [self mathFunctionWithName:@"abs" function:[self oneArgumentFunctionForMethod:@"abs:"] numberOfArguments:1];
}

+ (id) _truncFunctionContainer {
	return [self mathFunctionWithName:@"trunc" function:[self oneArgumentFunctionForMethod:@"trunc:"] numberOfArguments:1];
}

+ (id) _floorFunctionContainer {
	return [self mathFunctionWithName:@"floor" function:[self oneArgumentFunctionForMethod:@"floor:"] numberOfArguments:1];
}

+ (id) _onescomplementFunctionContainer {
	return [self mathFunctionWithName:@"onescomplement" function:[self oneArgumentFunctionForMethod:@"onesComplement:"] numberOfArguments:1];
}

#pragma mark "Constant" functions

+ (id) _piFunctionContainer {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		return [DDExpression numberExpressionWithNumber:[NSNumber numberWithDouble:M_PI]];
	};
	return [self mathFunctionWithName:@"pi" function:function numberOfArguments:0];
}

+ (id) _pi_2FunctionContainer {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		return [DDExpression numberExpressionWithNumber:[NSNumber numberWithDouble:M_PI_2]];
	};
	return [self mathFunctionWithName:@"pi_2" function:function numberOfArguments:0];
}

+ (id) _pi_4FunctionContainer {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		return [DDExpression numberExpressionWithNumber:[NSNumber numberWithDouble:M_PI_4]];
	};
	return [self mathFunctionWithName:@"pi_4" function:function numberOfArguments:0];
}

+ (id) _sqrt2FunctionContainer {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		return [DDExpression numberExpressionWithNumber:[NSNumber numberWithDouble:M_SQRT2]];
	};
	return [self mathFunctionWithName:@"sqrt2" function:function numberOfArguments:0];
}

+ (id) _eFunctionContainer {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		return [DDExpression numberExpressionWithNumber:[NSNumber numberWithDouble:M_E]];
	};
	return [self mathFunctionWithName:@"e" function:function numberOfArguments:0];
}

+ (id) _log2eFunctionContainer {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		return [DDExpression numberExpressionWithNumber:[NSNumber numberWithDouble:M_LOG2E]];
	};
	return [self mathFunctionWithName:@"log2e" function:function numberOfArguments:0];
}

+ (id) _log10eFunctionContainer {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		return [DDExpression numberExpressionWithNumber:[NSNumber numberWithDouble:M_LOG10E]];
	};
	return [self mathFunctionWithName:@"log10e" function:function numberOfArguments:0];
}

+ (id) _ln2FunctionContainer {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		return [DDExpression numberExpressionWithNumber:[NSNumber numberWithDouble:M_LN2]];
	};
	return [self mathFunctionWithName:@"ln2" function:function numberOfArguments:0];
}

+ (id) _ln10FunctionContainer {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		return [DDExpression numberExpressionWithNumber:[NSNumber numberWithDouble:M_LN10]];
	};
	return [self mathFunctionWithName:@"ln10" function:function numberOfArguments:0];
}

#pragma mark Trig functions

+ (id) _sinFunctionContainer {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		DDExpression * argument = [arguments objectAtIndex:0];
		NSNumber * n = [argument evaluateWithSubstitutions:variables evaluator:evaluator];
		NSNumber * r = [NSNumber numberWithDouble:sin([n doubleValue])];
		return [DDExpression numberExpressionWithNumber:r];
	};
	return [self mathFunctionWithName:@"sin" function:function numberOfArguments:1];
}

+ (id) _cosFunctionContainer {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		DDExpression * argument = [arguments objectAtIndex:0];
		NSNumber * n = [argument evaluateWithSubstitutions:variables evaluator:evaluator];
		NSNumber * r = [NSNumber numberWithDouble:cos([n doubleValue])];
		return [DDExpression numberExpressionWithNumber:r];
	};
	return [self mathFunctionWithName:@"cos" function:function numberOfArguments:1];
}

+ (id) _tanFunctionContainer {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		DDExpression * argument = [arguments objectAtIndex:0];
		NSNumber * n = [argument evaluateWithSubstitutions:variables evaluator:evaluator];
		NSNumber * r = [NSNumber numberWithDouble:tan([n doubleValue])];
		return [DDExpression numberExpressionWithNumber:r];
	};
	return [self mathFunctionWithName:@"tan" function:function numberOfArguments:1];
}

+ (id) _asinFunctionContainer {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		DDExpression * argument = [arguments objectAtIndex:0];
		NSNumber * n = [argument evaluateWithSubstitutions:variables evaluator:evaluator];
		NSNumber * r = [NSNumber numberWithDouble:asin([n doubleValue])];
		return [DDExpression numberExpressionWithNumber:r];
	};
	return [self mathFunctionWithName:@"asin" function:function numberOfArguments:1];
}

+ (id) _acosFunctionContainer {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		DDExpression * argument = [arguments objectAtIndex:0];
		NSNumber * n = [argument evaluateWithSubstitutions:variables evaluator:evaluator];
		NSNumber * r = [NSNumber numberWithDouble:acos([n doubleValue])];
		return [DDExpression numberExpressionWithNumber:r];
	};
	return [self mathFunctionWithName:@"acos" function:function numberOfArguments:1];
}

+ (id) _atanFunctionContainer {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		DDExpression * argument = [arguments objectAtIndex:0];
		NSNumber * n = [argument evaluateWithSubstitutions:variables evaluator:evaluator];
		NSNumber * r = [NSNumber numberWithDouble:atanf([n doubleValue])];
		return [DDExpression numberExpressionWithNumber:r];
	};
	return [self mathFunctionWithName:@"atan" function:function numberOfArguments:1];
}

+ (id) _dtorFunctionContainer {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		DDExpression * argument = [arguments objectAtIndex:0];
		NSNumber * n = [argument evaluateWithSubstitutions:variables evaluator:evaluator];
		double radians = ([n doubleValue] / 180.0f) * M_PI;
		NSNumber * r = [NSNumber numberWithDouble:radians];
		return [DDExpression numberExpressionWithNumber:r];
	};
	return [self mathFunctionWithName:@"dtor" function:function numberOfArguments:1];
}

+ (id) _rtodFunctionContainer {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		DDExpression * argument = [arguments objectAtIndex:0];
		NSNumber * n = [argument evaluateWithSubstitutions:variables evaluator:evaluator];
		double degrees = ([n doubleValue] / M_PI) * 180.0f;
		NSNumber * r = [NSNumber numberWithDouble:degrees];
		return [DDExpression numberExpressionWithNumber:r];
	};
	return [self mathFunctionWithName:@"rtod" function:function numberOfArguments:1];
}

#pragma mark Container methods

+ (id) mathFunctionWithName:(NSString *)name function:(DDMathFunction)function numberOfArguments:(NSInteger)numberOfArguments {
	if (name == nil) { return nil; }
	if (function == nil) { return nil; }
	
	if (numberOfArguments < 0) { numberOfArguments = DDMathFunctionUnlimitedArguments; }
	
	DDMathFunctionContainer * c = [[self alloc] init];
	[c setName:name];
	[c setFunction:function];
	[c setNumberOfArguments:numberOfArguments];
	return [c autorelease];
}

- (void) dealloc {
	[name release];
	[function release];
	[super dealloc];
}

@end
