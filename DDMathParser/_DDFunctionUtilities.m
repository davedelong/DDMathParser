//
//  __DDFunctionUtilities.m
//  DDMathParser
//
//  Created by Dave DeLong on 12/21/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "_DDFunctionUtilities.h"
#import "_DDDecimalFunctions.h"
#import "DDExpression.h"

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
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		REQUIRE_N_ARGS(2);
		NSNumber * firstValue = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator];
		NSNumber * secondValue = [[arguments objectAtIndex:1] evaluateWithSubstitutions:variables evaluator:evaluator];
		
		NSDecimal result = DDDecimalMod([firstValue decimalValue], [secondValue decimalValue]);
		
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
			NSDecimal result = DDDecimalAverage2(lowDecimal, highDecimal);
			median = [NSDecimalNumber decimalNumberWithDecimal:result];
		}
		return [DDExpression numberExpressionWithNumber:median];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) stddevFunction {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		REQUIRE_GTOE_N_ARGS(1);
		DDMathFunction avgFunction = [_DDFunctionUtilities averageFunction];
		DDExpression * avgExpression = avgFunction(arguments, variables, evaluator);
		NSDecimal avg = [[avgExpression number] decimalValue];
		NSDecimal stddev = DDDecimalZero();
		for (DDExpression * arg in arguments) {
			NSDecimal n = [[arg evaluateWithSubstitutions:variables evaluator:evaluator] decimalValue];
			NSDecimal diff;
			NSDecimalSubtract(&diff, &avg, &n, NSRoundBankers);
			NSDecimalMultiply(&diff, &diff, &diff, NSRoundBankers);
			NSDecimalAdd(&stddev, &stddev, &diff, NSRoundBankers);
		}
		NSDecimal count = DDDecimalFromInteger([arguments count]);
		NSDecimalDivide(&stddev, &stddev, &count, NSRoundBankers);
		stddev = DDDecimalSqrt(&stddev);
		
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:stddev]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) sqrtFunction {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		REQUIRE_N_ARGS(1);
		NSNumber * n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator];
		NSDecimal number = [n decimalValue];
		NSDecimal s = DDDecimalSqrt(&number);
		
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:s]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) logFunction {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		REQUIRE_N_ARGS(1);
		NSNumber * n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator];
		return [DDExpression numberExpressionWithNumber:[NSNumber numberWithDouble:log10([n doubleValue])]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) lnFunction {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		REQUIRE_N_ARGS(1);
		NSNumber * n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator];
		return [DDExpression numberExpressionWithNumber:[NSNumber numberWithDouble:log([n doubleValue])]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) log2Function {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		REQUIRE_N_ARGS(1);
		NSNumber * n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator];
		return [DDExpression numberExpressionWithNumber:[NSNumber numberWithDouble:log2([n doubleValue])]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) expFunction {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		REQUIRE_N_ARGS(1);
		NSNumber * n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator];
		return [DDExpression numberExpressionWithNumber:[NSNumber numberWithDouble:exp([n doubleValue])]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) ceilFunction {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		REQUIRE_N_ARGS(1);
		NSDecimal ceil = [[[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator] decimalValue];
		NSDecimalRound(&ceil, &ceil, 0, NSRoundUp);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:ceil]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) absFunction {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		REQUIRE_N_ARGS(1);
		NSDecimal abs = [[[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator] decimalValue];
		abs = DDDecimalAbsoluteValue(abs);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:abs]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) floorFunction {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		REQUIRE_N_ARGS(1);
		NSDecimal n = [[[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator] decimalValue];
		NSDecimalRound(&n, &n, 0, NSRoundDown);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:n]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) sinFunction {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		REQUIRE_N_ARGS(1);
		NSDecimal num = [[[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator] decimalValue];
		num = DDDecimalSin(num);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:num]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) cosFunction {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		REQUIRE_N_ARGS(1);
		NSDecimal num = [[[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator] decimalValue];
		num = DDDecimalCos(num);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:num]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) tanFunction {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		REQUIRE_N_ARGS(1);
		NSDecimal num = [[[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator] decimalValue];
		num = DDDecimalTan(num);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:num]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) asinFunction {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		REQUIRE_N_ARGS(1);
		NSDecimal num = [[[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator] decimalValue];
		num = DDDecimalAsin(num);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:num]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) acosFunction {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		REQUIRE_N_ARGS(1);
		NSDecimal num = [[[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator] decimalValue];
		num = DDDecimalAcos(num);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:num]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) atanFunction {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		REQUIRE_N_ARGS(1);
		NSDecimal num = [[[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator] decimalValue];
		num = DDDecimalAtan(num);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:num]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) sinhFunction {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		REQUIRE_N_ARGS(1);
		NSDecimal num = [[[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator] decimalValue];
		num = DDDecimalSinh(num);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:num]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) coshFunction {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		REQUIRE_N_ARGS(1);
		NSDecimal num = [[[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator] decimalValue];
		num = DDDecimalCosh(num);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:num]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) tanhFunction {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		REQUIRE_N_ARGS(1);
		NSDecimal num = [[[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator] decimalValue];
		num = DDDecimalTanh(num);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:num]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) asinhFunction {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		REQUIRE_N_ARGS(1);
		NSDecimal num = [[[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator] decimalValue];
		num = DDDecimalAsinh(num);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:num]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) acoshFunction {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		REQUIRE_N_ARGS(1);
		NSDecimal num = [[[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator] decimalValue];
		num = DDDecimalAcosh(num);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:num]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) atanhFunction {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		REQUIRE_N_ARGS(1);
		NSDecimal num = [[[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator] decimalValue];
		num = DDDecimalAtanh(num);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:num]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) cscFunction {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		REQUIRE_N_ARGS(1);
		NSDecimal num = [[[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator] decimalValue];
		num = DDDecimalSin(num);
		num = DDDecimalInverse(num);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:num]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) secFunction {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		REQUIRE_N_ARGS(1);
		NSDecimal num = [[[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator] decimalValue];
		num = DDDecimalCos(num);
		num = DDDecimalInverse(num);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:num]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) cotanFunction {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		REQUIRE_N_ARGS(1);
		NSDecimal num = [[[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator] decimalValue];
		num = DDDecimalTan(num);
		num = DDDecimalInverse(num);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:num]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) acscFunction {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		REQUIRE_N_ARGS(1);
		NSDecimal num = [[[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator] decimalValue];
		num = DDDecimalAsin(num);
		num = DDDecimalInverse(num);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:num]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) asecFunction {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		REQUIRE_N_ARGS(1);
		NSDecimal num = [[[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator] decimalValue];
		num = DDDecimalAcos(num);
		num = DDDecimalInverse(num);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:num]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) acotanFunction {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		REQUIRE_N_ARGS(1);
		NSDecimal num = [[[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator] decimalValue];
		num = DDDecimalAtan(num);
		num = DDDecimalInverse(num);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:num]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) cschFunction {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		REQUIRE_N_ARGS(1);
		NSDecimal num = [[[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator] decimalValue];
		num = DDDecimalSinh(num);
		num = DDDecimalInverse(num);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:num]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) sechFunction {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		REQUIRE_N_ARGS(1);
		NSDecimal num = [[[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator] decimalValue];
		num = DDDecimalCosh(num);
		num = DDDecimalInverse(num);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:num]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) cotanhFunction {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		REQUIRE_N_ARGS(1);
		NSDecimal num = [[[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator] decimalValue];
		num = DDDecimalTanh(num);
		num = DDDecimalInverse(num);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:num]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) acschFunction {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		REQUIRE_N_ARGS(1);
		NSDecimal num = [[[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator] decimalValue];
		num = DDDecimalAsinh(num);
		num = DDDecimalInverse(num);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:num]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) asechFunction {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		REQUIRE_N_ARGS(1);
		NSDecimal num = [[[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator] decimalValue];
		num = DDDecimalAcosh(num);
		num = DDDecimalInverse(num);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:num]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) acotanhFunction {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		REQUIRE_N_ARGS(1);
		NSDecimal num = [[[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator] decimalValue];
		num = DDDecimalAtanh(num);
		num = DDDecimalInverse(num);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:num]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) dtorFunction {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		REQUIRE_N_ARGS(1);
		NSDecimal n = [[[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator] decimalValue];
		NSDecimal tsz = DDDecimalFromInteger(360);
		NSDecimal tpi = DDDecimal2Pi();
		
		n = DDDecimalMod(n, tsz);
		NSDecimal r;
		NSDecimalDivide(&r, &n, &tsz, NSRoundBankers);
		NSDecimalMultiply(&r, &r, &tpi, NSRoundBankers);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:r]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) rtodFunction {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		REQUIRE_N_ARGS(1);
		NSDecimal n = [[[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator] decimalValue];
		NSDecimal tsz = DDDecimalFromInteger(360);
		NSDecimal tpi = DDDecimal2Pi();
		
		n = DDDecimalMod2Pi(n);
		NSDecimal r;
		NSDecimalDivide(&r, &n, &tpi, NSRoundBankers);
		NSDecimalMultiply(&r, &r, &tsz, NSRoundBankers);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:r]];
		
	};
	return [[function copy] autorelease];
}

#pragma mark Constant Functions

+ (DDMathFunction) piFunction {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		REQUIRE_N_ARGS(0);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:DDDecimalPi()]];
		
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) pi_2Function {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		REQUIRE_N_ARGS(0);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:DDDecimalPi_2()]];
		
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) pi_4Function {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		REQUIRE_N_ARGS(0);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:DDDecimalPi_4()]];
		
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) sqrt2Function {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		REQUIRE_N_ARGS(0);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:DDDecimalSqrt2()]];
		
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) eFunction {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		REQUIRE_N_ARGS(0);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:DDDecimalE()]];
		
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) log2eFunction {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		REQUIRE_N_ARGS(0);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:DDDecimalLog2e()]];
		
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) log10eFunction {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		REQUIRE_N_ARGS(0);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:DDDecimalLog10e()]];
		
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) ln2Function {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		REQUIRE_N_ARGS(0);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:DDDecimalLn2()]];
		
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) ln10Function {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		REQUIRE_N_ARGS(0);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:DDDecimalLn10()]];
		
	};
	return [[function copy] autorelease];
}

@end
