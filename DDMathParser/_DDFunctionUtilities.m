//
//  __DDFunctionUtilities.m
//  DDMathParser
//
//  Created by Dave DeLong on 12/21/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "_DDFunctionUtilities.h"
#import "DDExpression.h"

static inline NSDecimal DDDecimalNegativeOne() {
	NSDecimal d = { ._exponent = 0, ._length = 1, ._isNegative = 1, ._isCompact = 1, ._reserved = 0, ._mantissa = {1, 0, 0, 0, 0, 0, 0, 0}};
	return d;
}

static inline NSDecimal DDDecimalZero() {
	return [[NSDecimalNumber zero] decimalValue];
}

static inline NSDecimal DDDecimalOne() {
	NSDecimal d = { ._exponent = 0, ._length = 1, ._isNegative = 0, ._isCompact = 1, ._reserved = 0, ._mantissa = {1, 0, 0, 0, 0, 0, 0, 0}};
	return d;
}

static inline NSDecimal DDDecimalTwo() {
	NSDecimal d = { ._exponent = 0, ._length = 1, ._isNegative = 0, ._isCompact = 1, ._reserved = 0, ._mantissa = {2, 0, 0, 0, 0, 0, 0, 0}};
	return d;
}

static inline BOOL DDDecimalIsNegative(NSDecimal d) {
	NSDecimal z = DDDecimalZero();
	return (NSDecimalCompare(&d, &z) == NSOrderedAscending); //d < z
}

static inline NSDecimal DDDecimalAverage2(NSDecimal a, NSDecimal b) {
	NSDecimal r;
	NSDecimalAdd(&r, &a, &b, NSRoundBankers);
	NSDecimal t = DDDecimalTwo();
	NSDecimalDivide(&r, &r, &t, NSRoundBankers);
	return r;
}

static inline void DDDecimalAbsoluteValue(NSDecimal * a) {
	if (DDDecimalIsNegative(*a)) {
		a->_isNegative = 0;
	}
}

static inline BOOL DDDecimalLessThanEpsilon(NSDecimal a, NSDecimal b) {
	NSDecimal epsilon = DDDecimalOne();
	NSDecimalMultiplyByPowerOf10(&epsilon, &epsilon, -64, NSRoundBankers);
	
	NSDecimal diff;
	NSDecimalSubtract(&diff, &a, &b, NSRoundBankers);
	DDDecimalAbsoluteValue(&diff);
	return (NSDecimalCompare(&diff, &epsilon) == NSOrderedAscending);
}

#define REQUIRE_N_ARGS(__n) { \
if ([arguments count] != __n) { \
	[NSException raise:NSGenericException format:@"%@ requires %d arguments", NSStringFromSelector(_cmd), __n]; \
	return nil; \
} \
}

#define REQUIRE_GTOE_N_ARGS(__n) { \
if ([arguments count] < __n) { \
	[NSException raise:NSGenericException format:@"%@ requires at least %d arguments", NSStringFromSelector(_cmd), __n]; \
	return nil; \
} \
}

@implementation _DDFunctionUtilities

+ (DDMathFunction) addFunction {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		REQUIRE_N_ARGS(2);
		NSNumber * firstValue = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator];
		NSNumber * secondValue = [[arguments objectAtIndex:1] evaluateWithSubstitutions:variables evaluator:evaluator];
		
		NSDecimal result;
		NSDecimal lhs = [firstValue decimalValue];
		NSDecimal rhs = [secondValue decimalValue];
		NSDecimalAdd(&result, &lhs, &rhs, NSRoundBankers);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:result]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) subtractFunction {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		REQUIRE_N_ARGS(2);
		NSNumber * firstValue = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator];
		NSNumber * secondValue = [[arguments objectAtIndex:1] evaluateWithSubstitutions:variables evaluator:evaluator];
		
		NSDecimal result;
		NSDecimal lhs = [firstValue decimalValue];
		NSDecimal rhs = [secondValue decimalValue];
		NSDecimalSubtract(&result, &lhs, &rhs, NSRoundBankers);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:result]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) multiplyFunction {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		REQUIRE_N_ARGS(2);
		NSNumber * firstValue = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator];
		NSNumber * secondValue = [[arguments objectAtIndex:1] evaluateWithSubstitutions:variables evaluator:evaluator];
		
		NSDecimal result;
		NSDecimal lhs = [firstValue decimalValue];
		NSDecimal rhs = [secondValue decimalValue];
		NSDecimalMultiply(&result, &lhs, &rhs, NSRoundBankers);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:result]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) divideFunction {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		REQUIRE_N_ARGS(2);
		NSNumber * firstValue = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator];
		NSNumber * secondValue = [[arguments objectAtIndex:1] evaluateWithSubstitutions:variables evaluator:evaluator];
		
		NSDecimal result;
		NSDecimal lhs = [firstValue decimalValue];
		NSDecimal rhs = [secondValue decimalValue];
		NSDecimalDivide(&result, &lhs, &rhs, NSRoundBankers);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:result]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) modFunction {
	//a % n == a - (n * floor(a / n))
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		REQUIRE_N_ARGS(2);
		NSNumber * firstValue = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator];
		NSNumber * secondValue = [[arguments objectAtIndex:1] evaluateWithSubstitutions:variables evaluator:evaluator];
		
		NSDecimal result;
		NSDecimal a = [firstValue decimalValue];
		NSDecimal n = [secondValue decimalValue];
		
		NSDecimalDivide(&result, &a, &n, NSRoundBankers);
		NSDecimalRound(&result, &result, 0, NSRoundDown);
		NSDecimalMultiply(&result, &n, &result, NSRoundBankers);
		NSDecimalSubtract(&result, &a, &result, NSRoundBankers);
		
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:result]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) negateFunction {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		REQUIRE_N_ARGS(1);
		NSNumber * firstValue = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator];
		
		NSDecimal result;
		NSDecimal a = [firstValue decimalValue];
		NSDecimal nOne = DDDecimalNegativeOne();
		NSDecimalMultiply(&result, &nOne, &a, NSRoundBankers);
		
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:result]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) factorialFunction {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		REQUIRE_N_ARGS(1);
		NSNumber * firstValue = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator];
		NSNumber * result = [NSNumber numberWithDouble:tgamma([firstValue doubleValue]+1)];
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) powFunction {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		REQUIRE_N_ARGS(2);
		NSNumber * base = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator];
		NSNumber * exponent = [[arguments objectAtIndex:1] evaluateWithSubstitutions:variables evaluator:evaluator];
		NSNumber * power = [NSNumber numberWithDouble:pow([base doubleValue], [exponent doubleValue])];
		return [DDExpression numberExpressionWithNumber:power];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) andFunction {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		REQUIRE_N_ARGS(2);
		NSNumber * first = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator];
		NSNumber * second = [[arguments objectAtIndex:1] evaluateWithSubstitutions:variables evaluator:evaluator];
		NSNumber * result = [NSNumber numberWithInteger:([first integerValue] & [second integerValue])];
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) orFunction {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		REQUIRE_N_ARGS(2);
		NSNumber * first = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator];
		NSNumber * second = [[arguments objectAtIndex:1] evaluateWithSubstitutions:variables evaluator:evaluator];
		NSNumber * result = [NSNumber numberWithInteger:([first integerValue] | [second integerValue])];
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) notFunction {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		REQUIRE_N_ARGS(1);
		NSNumber * first = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator];
		NSNumber * result = [NSNumber numberWithInteger:(~[first integerValue])];
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];	
}

+ (DDMathFunction) xorFunction {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		REQUIRE_N_ARGS(2);
		NSNumber * first = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator];
		NSNumber * second = [[arguments objectAtIndex:1] evaluateWithSubstitutions:variables evaluator:evaluator];
		NSNumber * result = [NSNumber numberWithInteger:([first integerValue] ^ [second integerValue])];
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];	
}

+ (DDMathFunction) rshiftFunction {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		REQUIRE_N_ARGS(2);
		NSNumber * first = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator];
		NSNumber * second = [[arguments objectAtIndex:1] evaluateWithSubstitutions:variables evaluator:evaluator];
		NSNumber * result = [NSNumber numberWithInteger:([first integerValue] >> [second integerValue])];
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) lshiftFunction {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		REQUIRE_N_ARGS(2);
		NSNumber * first = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator];
		NSNumber * second = [[arguments objectAtIndex:1] evaluateWithSubstitutions:variables evaluator:evaluator];
		NSNumber * result = [NSNumber numberWithInteger:([first integerValue] << [second integerValue])];
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) averageFunction {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		REQUIRE_GTOE_N_ARGS(1);
		DDMathFunction sumFunction = [_DDFunctionUtilities sumFunction];
		DDExpression * sumExpression = sumFunction(arguments, variables, evaluator);
		NSDecimalNumber * sum = (NSDecimalNumber *)[sumExpression number];
		NSDecimalNumber * count = [NSDecimalNumber decimalNumberWithMantissa:[arguments count] exponent:0 isNegative:NO];
		NSDecimalNumber * avg = [sum decimalNumberByDividingBy:count];
		return [DDExpression numberExpressionWithNumber:avg];
	};
	return [[function copy] autorelease];	
}

+ (DDMathFunction) sumFunction {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		REQUIRE_GTOE_N_ARGS(1);
		NSDecimal result = [[NSDecimalNumber zero] decimalValue];
		for (DDExpression * argument in arguments) {
			NSNumber * value = [argument evaluateWithSubstitutions:variables evaluator:evaluator];
			NSDecimal number = [value decimalValue];
			NSDecimalAdd(&result, &result, &number, NSRoundBankers);
		}
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:result]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) countFunction {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		REQUIRE_GTOE_N_ARGS(0);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithMantissa:[arguments count] exponent:0 isNegative:NO]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) minFunction {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		REQUIRE_GTOE_N_ARGS(1);
		__block NSDecimal result;
		[arguments enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL * stop) {
			NSNumber * value = [obj evaluateWithSubstitutions:variables evaluator:evaluator];
			NSDecimal decimalValue = [value decimalValue];
			if (index == 0 || NSDecimalCompare(&result, &decimalValue) == NSOrderedDescending) {
				//result > decimalValue (or is first index)
				//decimalValue is smaller
				result = decimalValue;
			}
		}];
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:result]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) maxFunction {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		REQUIRE_GTOE_N_ARGS(1);
		__block NSDecimal result;
		[arguments enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL * stop) {
			NSNumber * value = [obj evaluateWithSubstitutions:variables evaluator:evaluator];
			NSDecimal decimalValue = [value decimalValue];
			if (index == 0 || NSDecimalCompare(&result, &decimalValue) == NSOrderedAscending) {
				//result < decimalValue (or is first index)
				//decimalValue is larger
				result = decimalValue;
			}
		}];
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:result]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) medianFunction {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		REQUIRE_GTOE_N_ARGS(1);
		NSMutableArray * evaluatedNumbers = [NSMutableArray array];
		for (DDExpression * e in arguments) {
			[evaluatedNumbers addObject:[e evaluateWithSubstitutions:variables evaluator:evaluator]];
		}
		[evaluatedNumbers sortUsingSelector:@selector(compare:)];
		
		NSNumber * median = nil;
		if (([evaluatedNumbers count] % 2) == 1) {
			NSUInteger index = floor([evaluatedNumbers count] / 2);
			median = [evaluatedNumbers objectAtIndex:index];
		} else {
			NSUInteger lowIndex = floor([evaluatedNumbers count] / 2);
			NSUInteger highIndex = floor([evaluatedNumbers count] / 2);
			NSDecimal lowDecimal = [[evaluatedNumbers objectAtIndex:lowIndex] decimalValue];
			NSDecimal highDecimal = [[evaluatedNumbers objectAtIndex:highIndex] decimalValue];
			NSDecimal two = DDDecimalTwo();
			NSDecimal result;
			NSDecimalAdd(&result, &lowDecimal, &highDecimal, NSRoundBankers);
			NSDecimalDivide(&result, &result, &two, NSRoundBankers);
			median = [NSDecimalNumber decimalNumberWithDecimal:result];
		}
		return [DDExpression numberExpressionWithNumber:median];
	};
	return [[function copy] autorelease];
}

//+ (DDMathFunction) modeFunction;
//+ (DDMathFunction) stddevFunction;

+ (DDMathFunction) sqrtFunction {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		REQUIRE_N_ARGS(1);
		NSNumber * n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator];
		NSDecimal number = [n decimalValue];
		NSDecimal s;
		NSDecimal two = DDDecimalTwo();
		NSDecimalDivide(&s, &number, &two, NSRoundBankers);
		for (NSUInteger iterationCount = 0; iterationCount < 50; ++iterationCount) {
			NSDecimal low;
			NSDecimalDivide(&low, &number, &s, NSRoundBankers);
			s = DDDecimalAverage2(low, s);
			
			NSDecimal square;
			NSDecimalMultiply(&square, &s, &s, NSRoundBankers);
			if (DDDecimalLessThanEpsilon(square, number)) { break; }
		};
		
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:s]];
	};
	return [[function copy] autorelease];
}

/**
+ (DDMathFunction) logFunction;
+ (DDMathFunction) lnFunction;
+ (DDMathFunction) expFunction;
+ (DDMathFunction) ceilFunction;
+ (DDMathFunction) absFunction;
+ (DDMathFunction) truncFunction;
+ (DDMathFunction) floorFunction;
+ (DDMathFunction) onescomplementFunction;

+ (DDMathFunction) sinFunction;
+ (DDMathFunction) cosFunction;
+ (DDMathFunction) tanFunction;
+ (DDMathFunction) asinFunction;
+ (DDMathFunction) acosFunction;
+ (DDMathFunction) atanFunction;
+ (DDMathFunction) sinhFunction;
+ (DDMathFunction) coshFunction;
+ (DDMathFunction) tanhFunction;
+ (DDMathFunction) asinhFunction;
+ (DDMathFunction) acoshFunction;
+ (DDMathFunction) atanhFunction;

+ (DDMathFunction) cscFunction;
+ (DDMathFunction) secFunction;
+ (DDMathFunction) cotanFunction;
+ (DDMathFunction) acscFunction;
+ (DDMathFunction) asecFunction;
+ (DDMathFunction) acotanFunction;
+ (DDMathFunction) cschFunction;
+ (DDMathFunction) sechFunction;
+ (DDMathFunction) cotanhFunction;
+ (DDMathFunction) acschFunction;
+ (DDMathFunction) asechFunction;
+ (DDMathFunction) acotanhFunction;

+ (DDMathFunction) dtorFunction;
+ (DDMathFunction) rtodFunction;

+ (DDMathFunction) piFunction;
+ (DDMathFunction) pi_2Function;
+ (DDMathFunction) pi_4Function;
+ (DDMathFunction) sqrt2Function;
+ (DDMathFunction) eFunction;
+ (DDMathFunction) log2eFunction;
+ (DDMathFunction) log10eFunction;
+ (DDMathFunction) ln2Function;
+ (DDMathFunction) ln10Function;
 **/
@end
