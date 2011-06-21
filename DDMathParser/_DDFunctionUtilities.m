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
#import "DDMathParserMacros.h"

#define REQUIRE_N_ARGS(__n) { \
if ([arguments count] != __n) { \
	if (error != nil) { \
		*error = ERR_GENERIC(@"%@ requires %d arguments", NSStringFromSelector(_cmd), __n); \
	} \
	return nil; \
} \
}

#define REQUIRE_GTOE_N_ARGS(__n) { \
if ([arguments count] < __n) { \
	if (error != nil) { \
		*error = ERR_GENERIC(@"%@ requires at least %d arguments", NSStringFromSelector(_cmd), __n); \
	} \
	return nil; \
} \
}

#define RETURN_IF_NIL(_n) if ((_n) == nil) { return nil; }

@implementation _DDFunctionUtilities

+ (DDMathFunction) addFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(2);
		NSNumber * firstValue = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
		RETURN_IF_NIL(firstValue);
		
		NSNumber * secondValue = [[arguments objectAtIndex:1] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
		RETURN_IF_NIL(secondValue);
		
		NSDecimal result;
		NSDecimal lhs = [firstValue decimalValue];
		NSDecimal rhs = [secondValue decimalValue];
		NSDecimalAdd(&result, &lhs, &rhs, NSRoundBankers);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:result]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) subtractFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(2);
		NSNumber * firstValue = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
		RETURN_IF_NIL(firstValue);
		NSNumber * secondValue = [[arguments objectAtIndex:1] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
		RETURN_IF_NIL(secondValue);
		
		NSDecimal result;
		NSDecimal lhs = [firstValue decimalValue];
		NSDecimal rhs = [secondValue decimalValue];
		NSDecimalSubtract(&result, &lhs, &rhs, NSRoundBankers);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:result]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) multiplyFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(2);
		NSNumber * firstValue = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
		RETURN_IF_NIL(firstValue);
		NSNumber * secondValue = [[arguments objectAtIndex:1] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
		RETURN_IF_NIL(secondValue);
		
		NSDecimal result;
		NSDecimal lhs = [firstValue decimalValue];
		NSDecimal rhs = [secondValue decimalValue];
		NSDecimalMultiply(&result, &lhs, &rhs, NSRoundBankers);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:result]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) divideFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(2);
		NSNumber * firstValue = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
		RETURN_IF_NIL(firstValue);
		NSNumber * secondValue = [[arguments objectAtIndex:1] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
		RETURN_IF_NIL(secondValue);
		
		NSDecimal result;
		NSDecimal lhs = [firstValue decimalValue];
		NSDecimal rhs = [secondValue decimalValue];
		NSDecimalDivide(&result, &lhs, &rhs, NSRoundBankers);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:result]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) modFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(2);
		NSNumber * firstValue = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
		RETURN_IF_NIL(firstValue);
		NSNumber * secondValue = [[arguments objectAtIndex:1] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
		RETURN_IF_NIL(secondValue);
		
		NSDecimal result = DDDecimalMod([firstValue decimalValue], [secondValue decimalValue]);
		
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:result]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) negateFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
		NSNumber * firstValue = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
		RETURN_IF_NIL(firstValue);
		
		NSDecimal a = [firstValue decimalValue];
        DDDecimalNegate(&a);
		
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:a]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) factorialFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
		NSNumber * firstValue = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
		RETURN_IF_NIL(firstValue);
		NSNumber * result = [NSDecimalNumber decimalNumberWithDecimal:DDDecimalFactorial([firstValue decimalValue])];
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) powFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(2);
		NSNumber * base = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
		RETURN_IF_NIL(base);
		NSNumber * exponent = [[arguments objectAtIndex:1] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
		RETURN_IF_NIL(exponent);
        NSNumber *result = [NSDecimalNumber decimalNumberWithDecimal:DDDecimalPower([base decimalValue], [exponent decimalValue])];
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) nthrootFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(2);
		NSNumber * base = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
		RETURN_IF_NIL(base);
		NSNumber * root = [[arguments objectAtIndex:1] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
		RETURN_IF_NIL(root);
        NSNumber *result = [NSDecimalNumber decimalNumberWithDecimal:DDDecimalNthRoot([base decimalValue], [root decimalValue])];
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) andFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(2);
		NSNumber * first = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
		RETURN_IF_NIL(first);
		NSNumber * second = [[arguments objectAtIndex:1] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
		RETURN_IF_NIL(second);
		NSNumber * result = [NSNumber numberWithInteger:([first integerValue] & [second integerValue])];
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) orFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(2);
		NSNumber * first = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
		RETURN_IF_NIL(first);
		NSNumber * second = [[arguments objectAtIndex:1] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
		RETURN_IF_NIL(second);
		NSNumber * result = [NSNumber numberWithInteger:([first integerValue] | [second integerValue])];
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) notFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
		NSNumber * first = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
		RETURN_IF_NIL(first);
		NSNumber * result = [NSNumber numberWithInteger:(~[first integerValue])];
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];	
}

+ (DDMathFunction) xorFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(2);
		NSNumber * first = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
		RETURN_IF_NIL(first);
		NSNumber * second = [[arguments objectAtIndex:1] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
		RETURN_IF_NIL(second);
		NSNumber * result = [NSNumber numberWithInteger:([first integerValue] ^ [second integerValue])];
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];	
}

+ (DDMathFunction) rshiftFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(2);
		NSNumber * first = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
		RETURN_IF_NIL(first);
		NSNumber * second = [[arguments objectAtIndex:1] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
		RETURN_IF_NIL(second);
		NSNumber * result = [NSDecimalNumber decimalNumberWithDecimal:DDDecimalRightShift([first decimalValue], [second decimalValue])];
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) lshiftFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(2);
		NSNumber * first = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
		RETURN_IF_NIL(first);
		NSNumber * second = [[arguments objectAtIndex:1] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
		RETURN_IF_NIL(second);
		NSNumber * result = [NSDecimalNumber decimalNumberWithDecimal:DDDecimalLeftShift([first decimalValue], [second decimalValue])];
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) averageFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_GTOE_N_ARGS(2);
		DDMathFunction sumFunction = [_DDFunctionUtilities sumFunction];
		DDExpression * sumExpression = sumFunction(arguments, variables, evaluator, error);
		RETURN_IF_NIL(sumExpression);
		NSDecimalNumber * sum = (NSDecimalNumber *)[sumExpression number];
		NSDecimalNumber * count = [NSDecimalNumber decimalNumberWithMantissa:[arguments count] exponent:0 isNegative:NO];
		NSDecimalNumber * avg = [sum decimalNumberByDividingBy:count];
		return [DDExpression numberExpressionWithNumber:avg];
	};
	return [[function copy] autorelease];	
}

+ (DDMathFunction) sumFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_GTOE_N_ARGS(1);
		NSDecimal result = [[NSDecimalNumber zero] decimalValue];
		for (DDExpression * argument in arguments) {
			NSNumber * value = [argument evaluateWithSubstitutions:variables evaluator:evaluator error:error];
			RETURN_IF_NIL(value);
			NSDecimal number = [value decimalValue];
			NSDecimalAdd(&result, &result, &number, NSRoundBankers);
		}
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:result]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) countFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
#pragma unused(variables, evaluator)
		REQUIRE_GTOE_N_ARGS(1);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithMantissa:[arguments count] exponent:0 isNegative:NO]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) minFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_GTOE_N_ARGS(2);
		NSDecimal result = DDDecimalZero();
		for (NSUInteger index = 0; index < [arguments count]; ++index) {
			DDExpression *obj = [arguments objectAtIndex:index];
			NSNumber *value = [obj evaluateWithSubstitutions:variables evaluator:evaluator error:error];
			RETURN_IF_NIL(value);
			NSDecimal decimalValue = [value decimalValue];
			if (index == 0 || NSDecimalCompare(&result, &decimalValue) == NSOrderedDescending) {
				//result > decimalValue (or is first index)
				//decimalValue is smaller
				result = decimalValue;
			}
		}
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:result]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) maxFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_GTOE_N_ARGS(2);
		NSDecimal result = DDDecimalZero();
		for (NSUInteger index = 0; index < [arguments count]; ++index) {
			DDExpression *obj = [arguments objectAtIndex:index];
			NSNumber * value = [obj evaluateWithSubstitutions:variables evaluator:evaluator error:error];
			RETURN_IF_NIL(value);
			NSDecimal decimalValue = [value decimalValue];
			if (index == 0 || NSDecimalCompare(&result, &decimalValue) == NSOrderedAscending) {
				//result < decimalValue (or is first index)
				//decimalValue is larger
				result = decimalValue;
			}
		}
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:result]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) medianFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_GTOE_N_ARGS(2);
		NSMutableArray * evaluatedNumbers = [NSMutableArray array];
		for (DDExpression * e in arguments) {
            NSNumber *n = [e evaluateWithSubstitutions:variables evaluator:evaluator error:error];
            RETURN_IF_NIL(n);
			[evaluatedNumbers addObject:n];
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
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_GTOE_N_ARGS(2);
		DDMathFunction avgFunction = [_DDFunctionUtilities averageFunction];
		DDExpression * avgExpression = avgFunction(arguments, variables, evaluator, error);
		RETURN_IF_NIL(avgExpression);
		NSDecimal avg = [[avgExpression number] decimalValue];
		NSDecimal stddev = DDDecimalZero();
		for (DDExpression * arg in arguments) {
            NSNumber *argValue = [arg evaluateWithSubstitutions:variables evaluator:evaluator error:error];
            RETURN_IF_NIL(argValue);
			NSDecimal n = [argValue decimalValue];
			NSDecimal diff;
			NSDecimalSubtract(&diff, &avg, &n, NSRoundBankers);
			NSDecimalMultiply(&diff, &diff, &diff, NSRoundBankers);
			NSDecimalAdd(&stddev, &stddev, &diff, NSRoundBankers);
		}
		NSDecimal count = DDDecimalFromInteger([arguments count]);
		NSDecimalDivide(&stddev, &stddev, &count, NSRoundBankers);
		stddev = DDDecimalSqrt(stddev);
		
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:stddev]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) sqrtFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
		NSNumber * n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
		RETURN_IF_NIL(n);
		NSDecimal number = [n decimalValue];
		NSDecimal s = DDDecimalSqrt(number);
		
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:s]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) randomFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		if ([arguments count] > 2) {
			if (error != nil) {
				*error = ERR_GENERIC(@"random() may only have up to 2 arguments");
			}
			return nil;
		}
		
		NSMutableArray * params = [NSMutableArray array];
		for (DDExpression * argument in arguments) {
			NSNumber * value = [argument evaluateWithSubstitutions:variables evaluator:evaluator error:error];
			RETURN_IF_NIL(value);
			[params addObject:value];
		}
		
		NSInteger random = arc4random();
		
		if ([params count] == 1) {
			NSNumber * lowerBound = [params objectAtIndex:0];
			while (random < [lowerBound integerValue]) {
				random += [lowerBound integerValue];
			}
		} else if ([params count] == 2) {
			NSNumber * lowerBound = [params objectAtIndex:0];
			NSNumber * upperBound = [params objectAtIndex:1];
			
			if ([upperBound integerValue] <= [lowerBound integerValue]) {
				if (error != nil) {
					*error = ERR_GENERIC(@"upper bound (%ld) of random() must be larger than lower bound (%ld)", [upperBound integerValue], [lowerBound integerValue]);
				}
				return nil;
			}
			
			long long range = llabs(([upperBound longLongValue] - [lowerBound longLongValue]) + 1);
			random = random % range;
			random += [lowerBound longLongValue];
		}
		
		return [DDExpression numberExpressionWithNumber:[NSNumber numberWithLongLong:random]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) logFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
		NSNumber * n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
		RETURN_IF_NIL(n);
		return [DDExpression numberExpressionWithNumber:[NSNumber numberWithDouble:log10([n doubleValue])]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) lnFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
		NSNumber * n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
		RETURN_IF_NIL(n);
		return [DDExpression numberExpressionWithNumber:[NSNumber numberWithDouble:log([n doubleValue])]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) log2Function {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
		NSNumber * n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
		RETURN_IF_NIL(n);
		return [DDExpression numberExpressionWithNumber:[NSNumber numberWithDouble:log2([n doubleValue])]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) expFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
		NSNumber * n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
		RETURN_IF_NIL(n);
        NSDecimal e = DDDecimalE();
        NSDecimalPower(&e, &e, [n unsignedIntegerValue], NSRoundBankers);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:e]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) ceilFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        NSDecimal ceil = [n decimalValue];
		NSDecimalRound(&ceil, &ceil, 0, NSRoundUp);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:ceil]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) absFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
		NSDecimal abs = [n decimalValue];
		abs = DDDecimalAbsoluteValue(abs);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:abs]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) floorFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        NSDecimal num = [n decimalValue];
		NSDecimalRound(&num, &num, 0, NSRoundDown);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:num]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) sinFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        NSDecimal num = [n decimalValue];
		num = DDDecimalSin(num);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:num]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) cosFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        NSDecimal num = [n decimalValue];
		num = DDDecimalCos(num);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:num]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) tanFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        NSDecimal num = [n decimalValue];
		num = DDDecimalTan(num);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:num]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) asinFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        NSDecimal num = [n decimalValue];
		num = DDDecimalAsin(num);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:num]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) acosFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        NSDecimal num = [n decimalValue];
		num = DDDecimalAcos(num);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:num]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) atanFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        NSDecimal num = [n decimalValue];
		num = DDDecimalAtan(num);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:num]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) sinhFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        NSDecimal num = [n decimalValue];
		num = DDDecimalSinh(num);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:num]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) coshFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        NSDecimal num = [n decimalValue];
		num = DDDecimalCosh(num);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:num]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) tanhFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        NSDecimal num = [n decimalValue];
		num = DDDecimalTanh(num);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:num]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) asinhFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        NSDecimal num = [n decimalValue];
		num = DDDecimalAsinh(num);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:num]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) acoshFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        NSDecimal num = [n decimalValue];
		num = DDDecimalAcosh(num);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:num]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) atanhFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        NSDecimal num = [n decimalValue];
		num = DDDecimalAtanh(num);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:num]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) cscFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        NSDecimal num = [n decimalValue];
		num = DDDecimalCsc(num);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:num]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) secFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        NSDecimal num = [n decimalValue];
		num = DDDecimalSec(num);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:num]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) cotanFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        NSDecimal num = [n decimalValue];
		num = DDDecimalCot(num);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:num]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) acscFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        NSDecimal num = [n decimalValue];
		num = DDDecimalAcsc(num);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:num]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) asecFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        NSDecimal num = [n decimalValue];
		num = DDDecimalAsec(num);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:num]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) acotanFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        NSDecimal num = [n decimalValue];
		num = DDDecimalAcot(num);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:num]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) cschFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        NSDecimal num = [n decimalValue];
		num = DDDecimalSinh(num);
		num = DDDecimalInverse(num);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:num]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) sechFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        NSDecimal num = [n decimalValue];
		num = DDDecimalCosh(num);
		num = DDDecimalInverse(num);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:num]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) cotanhFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        NSDecimal num = [n decimalValue];
		num = DDDecimalTanh(num);
		num = DDDecimalInverse(num);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:num]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) acschFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        NSDecimal num = [n decimalValue];
		num = DDDecimalAsinh(num);
		num = DDDecimalInverse(num);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:num]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) asechFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        NSDecimal num = [n decimalValue];
		num = DDDecimalAcosh(num);
		num = DDDecimalInverse(num);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:num]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) acotanhFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        NSDecimal num = [n decimalValue];
		num = DDDecimalAtanh(num);
		num = DDDecimalInverse(num);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:num]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) dtorFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        NSDecimal num = [n decimalValue];
		NSDecimal tsz = DDDecimalFromInteger(360);
		NSDecimal tpi = DDDecimal2Pi();
		
		num = DDDecimalMod(num, tsz);
		NSDecimal r;
		NSDecimalDivide(&r, &num, &tsz, NSRoundBankers);
		NSDecimalMultiply(&r, &r, &tpi, NSRoundBankers);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:r]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) rtodFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        NSDecimal num = [n decimalValue];
		NSDecimal tsz = DDDecimalFromInteger(360);
		NSDecimal tpi = DDDecimal2Pi();
		
		num = DDDecimalMod2Pi(num);
		NSDecimal r;
		NSDecimalDivide(&r, &num, &tpi, NSRoundBankers);
		NSDecimalMultiply(&r, &r, &tsz, NSRoundBankers);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:r]];
		
	};
	return [[function copy] autorelease];
}

#pragma mark Constant Functions

+ (DDMathFunction) piFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
#pragma unused(variables, evaluator)
		REQUIRE_N_ARGS(0);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:DDDecimalPi()]];
		
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) pi_2Function {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
#pragma unused(variables, evaluator)
		REQUIRE_N_ARGS(0);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:DDDecimalPi_2()]];
		
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) pi_4Function {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
#pragma unused(variables, evaluator)
		REQUIRE_N_ARGS(0);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:DDDecimalPi_4()]];
		
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) sqrt2Function {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
#pragma unused(variables, evaluator)
		REQUIRE_N_ARGS(0);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:DDDecimalSqrt2()]];
		
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) eFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
#pragma unused(variables, evaluator)
		REQUIRE_N_ARGS(0);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:DDDecimalE()]];
		
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) log2eFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
#pragma unused(variables, evaluator)
		REQUIRE_N_ARGS(0);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:DDDecimalLog2e()]];
		
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) log10eFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
#pragma unused(variables, evaluator)
		REQUIRE_N_ARGS(0);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:DDDecimalLog10e()]];
		
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) ln2Function {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
#pragma unused(variables, evaluator)
		REQUIRE_N_ARGS(0);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:DDDecimalLn2()]];
		
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) ln10Function {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
#pragma unused(variables, evaluator)
		REQUIRE_N_ARGS(0);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:DDDecimalLn10()]];
		
	};
	return [[function copy] autorelease];
}

@end
