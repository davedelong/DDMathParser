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
#import "DDMathEvaluator.h"

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

#define HIGH_PRECISION ([evaluator usesHighPrecisionFunctions])

@implementation _DDFunctionUtilities

+ (DDMathFunction) addFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(2);
		NSNumber * firstValue = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
		RETURN_IF_NIL(firstValue);
		
		NSNumber * secondValue = [[arguments objectAtIndex:1] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
		RETURN_IF_NIL(secondValue);
		
        NSNumber *result = nil;
        if (HIGH_PRECISION) {
            NSDecimal r;
            NSDecimal lhs = [firstValue decimalValue];
            NSDecimal rhs = [secondValue decimalValue];
            NSDecimalAdd(&r, &lhs, &rhs, NSRoundBankers);
            result = [NSDecimalNumber decimalNumberWithDecimal:r];
        } else {
            result = [NSNumber numberWithDouble:[firstValue doubleValue] + [secondValue doubleValue]];
        }
        return [DDExpression numberExpressionWithNumber:result];
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
		
        NSNumber *result = nil;
        if (HIGH_PRECISION) {
            NSDecimal r;
            NSDecimal lhs = [firstValue decimalValue];
            NSDecimal rhs = [secondValue decimalValue];
            NSDecimalSubtract(&r, &lhs, &rhs, NSRoundBankers);
            result = [NSDecimalNumber decimalNumberWithDecimal:r];
        } else {
            result = [NSNumber numberWithDouble:[firstValue doubleValue] - [secondValue doubleValue]];
        }
		return [DDExpression numberExpressionWithNumber:result];
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
		
        NSNumber *result = nil;
        if (HIGH_PRECISION) {
            NSDecimal r;
            NSDecimal lhs = [firstValue decimalValue];
            NSDecimal rhs = [secondValue decimalValue];
            NSDecimalMultiply(&r, &lhs, &rhs, NSRoundBankers);
            result = [NSDecimalNumber decimalNumberWithDecimal:r];
        } else {
            result = [NSNumber numberWithDouble:[firstValue doubleValue] * [secondValue doubleValue]];
        }
		return [DDExpression numberExpressionWithNumber:result];
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
		
        NSNumber *result = nil;
        if (HIGH_PRECISION) {
            NSDecimal r;
            NSDecimal lhs = [firstValue decimalValue];
            NSDecimal rhs = [secondValue decimalValue];
            NSDecimalDivide(&r, &lhs, &rhs, NSRoundBankers);
            result = [NSDecimalNumber decimalNumberWithDecimal:r];
        } else {
            result = [NSNumber numberWithDouble:[firstValue doubleValue] / [secondValue doubleValue]];
        }
		return [DDExpression numberExpressionWithNumber:result];
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
		
        NSNumber *result = nil;
        if (HIGH_PRECISION) {
            NSDecimal r = DDDecimalMod([firstValue decimalValue], [secondValue decimalValue]);
            result = [NSDecimalNumber decimalNumberWithDecimal:r];
        } else {
            result = [NSNumber numberWithDouble:fmod([firstValue doubleValue], [secondValue doubleValue])];
        }
        return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) negateFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
		NSNumber * firstValue = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
		RETURN_IF_NIL(firstValue);
		
        NSNumber *result = nil;
        if (HIGH_PRECISION) {
            NSDecimal a = [firstValue decimalValue];
            DDDecimalNegate(&a);
            result = [NSDecimalNumber decimalNumberWithDecimal:a];
        } else {
            result = [NSNumber numberWithDouble:-1 * [firstValue doubleValue]];
        }
		
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) factorialFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
		NSNumber * firstValue = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
		RETURN_IF_NIL(firstValue);
        
        NSNumber *result = nil;
        if (HIGH_PRECISION) {
            result = [NSDecimalNumber decimalNumberWithDecimal:DDDecimalFactorial([firstValue decimalValue])];
            return [DDExpression numberExpressionWithNumber:result];
        } else {
            result = [NSNumber numberWithDouble:tgamma([firstValue doubleValue]+1)];
        }
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
        
        NSNumber *result = nil;
        if (HIGH_PRECISION) {
            result = [NSDecimalNumber decimalNumberWithDecimal:DDDecimalPower([base decimalValue], [exponent decimalValue])];
        } else {
            result = [NSNumber numberWithDouble:pow([base doubleValue], [exponent doubleValue])];
        }
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
        
        NSNumber *result = nil;
        if (HIGH_PRECISION) {
            result = [NSDecimalNumber decimalNumberWithDecimal:DDDecimalNthRoot([base decimalValue], [root decimalValue])];
        } else {
            result = [NSNumber numberWithDouble:pow([base doubleValue], 1/[root doubleValue])];
        }
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
        
		NSNumber * result = nil;
        if (HIGH_PRECISION) {
            result = [NSDecimalNumber decimalNumberWithDecimal:DDDecimalRightShift([first decimalValue], [second decimalValue])];
        } else {
            result = [NSNumber numberWithInteger:[first integerValue] >> [second integerValue]];
        }
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
        
		NSNumber * result = nil;
        if (HIGH_PRECISION) {
            result = [NSDecimalNumber decimalNumberWithDecimal:DDDecimalLeftShift([first decimalValue], [second decimalValue])];
        } else {
            result = [NSNumber numberWithInteger:[first integerValue] << [second integerValue]];
        }
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
        
        NSNumber *avg = nil;
        if (HIGH_PRECISION) {
            NSDecimalNumber * sum = (NSDecimalNumber *)[sumExpression number];
            NSDecimalNumber * count = [NSDecimalNumber decimalNumberWithMantissa:[arguments count] exponent:0 isNegative:NO];
            avg = [sum decimalNumberByDividingBy:count];
        } else {
            double sum = [[sumExpression number] doubleValue];
            avg = [NSNumber numberWithDouble:sum / [arguments count]];
        }
		return [DDExpression numberExpressionWithNumber:avg];
	};
	return [[function copy] autorelease];	
}

+ (DDMathFunction) sumFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_GTOE_N_ARGS(1);
		NSMutableArray * evaluatedNumbers = [NSMutableArray array];
		for (DDExpression * e in arguments) {
            NSNumber *n = [e evaluateWithSubstitutions:variables evaluator:evaluator error:error];
            RETURN_IF_NIL(n);
			[evaluatedNumbers addObject:n];
		}
        
        NSNumber *result = nil;
        if (HIGH_PRECISION) {
            NSDecimal r = [[NSDecimalNumber zero] decimalValue];
            for (NSNumber *value in arguments) {
                NSDecimal number = [value decimalValue];
                NSDecimalAdd(&r, &r, &number, NSRoundBankers);
            }
            result = [NSDecimalNumber decimalNumberWithDecimal:r];
        } else {
            double sum = 0;
            for (NSNumber *value in arguments) {
                sum += [value doubleValue];
            }
            result = [NSNumber numberWithDouble:sum];
        }
		return [DDExpression numberExpressionWithNumber:result];
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
			NSUInteger highIndex = ceil([evaluatedNumbers count] / 2);
            if (HIGH_PRECISION) {
                NSDecimal lowDecimal = [[evaluatedNumbers objectAtIndex:lowIndex] decimalValue];
                NSDecimal highDecimal = [[evaluatedNumbers objectAtIndex:highIndex] decimalValue];
                NSDecimal result = DDDecimalAverage2(lowDecimal, highDecimal);
                median = [NSDecimalNumber decimalNumberWithDecimal:result];
            } else {
                NSNumber *low = [evaluatedNumbers objectAtIndex:lowIndex];
                NSNumber *high = [evaluatedNumbers objectAtIndex:highIndex];
                median = [NSNumber numberWithDouble:([low doubleValue] + [high doubleValue])/2];
            }
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
        
        NSNumber *result = nil;
        if (HIGH_PRECISION) {
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
            result = [NSDecimalNumber decimalNumberWithDecimal:stddev];
        } else {
            double avg = [[avgExpression number] doubleValue];
            double stddev = 0;
            for (DDExpression *arg in arguments) {
                NSNumber *argValue = [arg evaluateWithSubstitutions:variables evaluator:evaluator error:error];
                RETURN_IF_NIL(argValue);
                double diff = avg - [argValue doubleValue];
                diff = diff * diff;
                stddev += diff;
            }
            stddev /= [arguments count];
            stddev = sqrt(stddev);
            result = [NSNumber numberWithDouble:stddev];
        }
		
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) sqrtFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
		NSNumber * n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
		RETURN_IF_NIL(n);
        
        NSNumber *result = nil;
        if (HIGH_PRECISION) {
            NSDecimal number = [n decimalValue];
            NSDecimal s = DDDecimalSqrt(number);
            result = [NSDecimalNumber decimalNumberWithDecimal:s];
        } else {
            result = [NSNumber numberWithDouble:sqrt([n doubleValue])];
        }
		
		return [DDExpression numberExpressionWithNumber:result];
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
        
        NSNumber *result = nil;
        if (HIGH_PRECISION) {
            NSDecimal e = DDDecimalE();
            NSDecimal r = DDDecimalPower(e, [n decimalValue]);
            result = [NSDecimalNumber decimalNumberWithDecimal:r];
        } else {
            result = [NSNumber numberWithDouble:exp([n doubleValue])];
        }
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) ceilFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);

        NSNumber *result = nil;
        if (HIGH_PRECISION) {
            NSDecimal ceil = [n decimalValue];
            NSDecimalRound(&ceil, &ceil, 0, NSRoundUp);
            result = [NSDecimalNumber decimalNumberWithDecimal:ceil];
        } else {
            result = [NSNumber numberWithDouble:ceil([n doubleValue])];
        }
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) absFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        
        NSNumber *result = nil;
        if (HIGH_PRECISION) {
            NSDecimal abs = [n decimalValue];
            abs = DDDecimalAbsoluteValue(abs);
            result = [NSDecimalNumber decimalNumberWithDecimal:abs];
        } else {
            result = [NSNumber numberWithLongLong:llabs([n longLongValue])];
        }
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) floorFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        
        NSNumber *result = nil;
        if (HIGH_PRECISION) {
            NSDecimal num = [n decimalValue];
            NSDecimalRound(&num, &num, 0, NSRoundDown);
            result = [NSDecimalNumber decimalNumberWithDecimal:num];
        } else {
            result = [NSNumber numberWithDouble:floor([n doubleValue])];
        }
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) sinFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        
        NSNumber *result = nil;
        if (HIGH_PRECISION) {
            NSDecimal num = [n decimalValue];
            num = DDDecimalSin(num);
            result = [NSDecimalNumber decimalNumberWithDecimal:num];
        } else {
            result = [NSNumber numberWithDouble:sin([n doubleValue])];
        }
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) cosFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        
        NSNumber *result = nil;
        if (HIGH_PRECISION) {
            NSDecimal num = [n decimalValue];
            num = DDDecimalCos(num);
            result = [NSDecimalNumber decimalNumberWithDecimal:num];
        } else {
            result = [NSNumber numberWithDouble:cos([n doubleValue])];
        }
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) tanFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        
        NSNumber *result = nil;
        if (HIGH_PRECISION) {
            NSDecimal num = [n decimalValue];
            num = DDDecimalTan(num);
            result = [NSDecimalNumber decimalNumberWithDecimal:num];
        } else {
            result = [NSNumber numberWithDouble:tan([n doubleValue])];
        }
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) asinFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        
        NSNumber *result = nil;
        if (HIGH_PRECISION) {
            NSDecimal num = [n decimalValue];
            num = DDDecimalAsin(num);
            result = [NSDecimalNumber decimalNumberWithDecimal:num];
        } else {
            result = [NSNumber numberWithDouble:asin([n doubleValue])];
        }
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) acosFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        
        NSNumber *result = nil;
        if (HIGH_PRECISION) {
            NSDecimal num = [n decimalValue];
            num = DDDecimalAcos(num);
            result = [NSDecimalNumber decimalNumberWithDecimal:num];
        } else {
            result = [NSNumber numberWithDouble:acos([n doubleValue])];
        }
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) atanFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        
        NSNumber *result = nil;
        if (HIGH_PRECISION) {
            NSDecimal num = [n decimalValue];
            num = DDDecimalAtan(num);
            result = [NSDecimalNumber decimalNumberWithDecimal:num];
        } else {
            result = [NSNumber numberWithDouble:atan([n doubleValue])];
        }
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) sinhFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        
        NSNumber *result = nil;
        if (HIGH_PRECISION) {
            NSDecimal num = [n decimalValue];
            num = DDDecimalSinh(num);
            result = [NSDecimalNumber decimalNumberWithDecimal:num];
        } else {
            result = [NSNumber numberWithDouble:sinh([n doubleValue])];
        }
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) coshFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        
        NSNumber *result = nil;
        if (HIGH_PRECISION) {
            NSDecimal num = [n decimalValue];
            num = DDDecimalCosh(num);
            result = [NSDecimalNumber decimalNumberWithDecimal:num];
        } else {
            result = [NSNumber numberWithDouble:cosh([n doubleValue])];
        }
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) tanhFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        
        NSNumber *result = nil;
        if (HIGH_PRECISION) {
            NSDecimal num = [n decimalValue];
            num = DDDecimalTanh(num);
            result = [NSDecimalNumber decimalNumberWithDecimal:num];
        } else {
            result = [NSNumber numberWithDouble:tanh([n doubleValue])];
        }
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) asinhFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        
        NSNumber *result = nil;
        if (HIGH_PRECISION) {
            NSDecimal num = [n decimalValue];
            num = DDDecimalAsinh(num);
            result = [NSDecimalNumber decimalNumberWithDecimal:num];
        } else {
            result = [NSNumber numberWithDouble:asinh([n doubleValue])];
        }
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) acoshFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        
        NSNumber *result = nil;
        if (HIGH_PRECISION) {
            NSDecimal num = [n decimalValue];
            num = DDDecimalAcosh(num);
            result = [NSDecimalNumber decimalNumberWithDecimal:num];
        } else {
            result = [NSNumber numberWithDouble:acosh([n doubleValue])];
        }
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) atanhFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        
        NSNumber *result = nil;
        if (HIGH_PRECISION) {
            NSDecimal num = [n decimalValue];
            num = DDDecimalAtanh(num);
            result = [NSDecimalNumber decimalNumberWithDecimal:num];
        } else {
            result = [NSNumber numberWithDouble:atanh([n doubleValue])];
        }
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) cscFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        
        NSNumber *result = nil;
        if (HIGH_PRECISION) {
            NSDecimal num = [n decimalValue];
            num = DDDecimalCsc(num);
            result = [NSDecimalNumber decimalNumberWithDecimal:num];
        } else {
            result = [NSNumber numberWithDouble:1/sin([n doubleValue])];
        }
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) secFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        
        NSNumber *result = nil;
        if (HIGH_PRECISION) {
            NSDecimal num = [n decimalValue];
            num = DDDecimalSec(num);
            result = [NSDecimalNumber decimalNumberWithDecimal:num];
        } else {
            result = [NSNumber numberWithDouble:1/cos([n doubleValue])];
        }
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) cotanFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        
        NSNumber *result = nil;
        if (HIGH_PRECISION) {
            NSDecimal num = [n decimalValue];
            num = DDDecimalCot(num);
            result = [NSDecimalNumber decimalNumberWithDecimal:num];
        } else {
            result = [NSNumber numberWithDouble:1/tan([n doubleValue])];
        }
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) acscFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        
        NSNumber *result = nil;
        if (HIGH_PRECISION) {
            NSDecimal num = [n decimalValue];
            num = DDDecimalAcsc(num);
            result = [NSDecimalNumber decimalNumberWithDecimal:num];
        } else {
            result = [NSNumber numberWithDouble:1/asin([n doubleValue])];
        }
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) asecFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        
        NSNumber *result = nil;
        if (HIGH_PRECISION) {
            NSDecimal num = [n decimalValue];
            num = DDDecimalAsec(num);
            result = [NSDecimalNumber decimalNumberWithDecimal:num];
        } else {
            result = [NSNumber numberWithDouble:1/acos([n doubleValue])];
        }
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) acotanFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        
        NSNumber *result = nil;
        if (HIGH_PRECISION) {
            NSDecimal num = [n decimalValue];
            num = DDDecimalAcot(num);
            result = [NSDecimalNumber decimalNumberWithDecimal:num];
        } else {
            result = [NSNumber numberWithDouble:1/atan([n doubleValue])];
        }
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) cschFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        
        NSNumber *result = nil;
        if (HIGH_PRECISION) {
            NSDecimal num = [n decimalValue];
            num = DDDecimalCsch(num);
            result = [NSDecimalNumber decimalNumberWithDecimal:num];
        } else {
            result = [NSNumber numberWithDouble:1/sinh([n doubleValue])];
        }
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) sechFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        
        NSNumber *result = nil;
        if (HIGH_PRECISION) {
            NSDecimal num = [n decimalValue];
            num = DDDecimalSech(num);
            result = [NSDecimalNumber decimalNumberWithDecimal:num];
        } else {
            result = [NSNumber numberWithDouble:1/cosh([n doubleValue])];
        }
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) cotanhFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        
        NSNumber *result = nil;
        if (HIGH_PRECISION) {
            NSDecimal num = [n decimalValue];
            num = DDDecimalCoth(num);
            result = [NSDecimalNumber decimalNumberWithDecimal:num];
        } else {
            result = [NSNumber numberWithDouble:1/tanh([n doubleValue])];
        }
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) acschFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        
        NSNumber *result = nil;
        if (HIGH_PRECISION) {
            NSDecimal num = [n decimalValue];
            num = DDDecimalAsinh(num);
            num = DDDecimalInverse(num);
            result = [NSDecimalNumber decimalNumberWithDecimal:num];
        } else {
            result = [NSNumber numberWithDouble:1/sinh([n doubleValue])];
        }
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) asechFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        
        NSNumber *result = nil;
        if (HIGH_PRECISION) {
            NSDecimal num = [n decimalValue];
            num = DDDecimalAcosh(num);
            num = DDDecimalInverse(num);
            result = [NSDecimalNumber decimalNumberWithDecimal:num];
        } else {
            result = [NSNumber numberWithDouble:1/cosh([n doubleValue])];
        }
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) acotanhFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        
        NSNumber *result = nil;
        if (HIGH_PRECISION) {
            NSDecimal num = [n decimalValue];
            num = DDDecimalAtanh(num);
            num = DDDecimalInverse(num);
            result = [NSDecimalNumber decimalNumberWithDecimal:num];
        } else {
            result = [NSNumber numberWithDouble:1/atanh([n doubleValue])];
        }
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) dtorFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        
        NSNumber *result = nil;
        if (HIGH_PRECISION) {
            NSDecimal num = [n decimalValue];
            NSDecimal tsz = DDDecimalFromInteger(360);
            NSDecimal tpi = DDDecimal2Pi();
            
            num = DDDecimalMod(num, tsz);
            NSDecimal r;
            NSDecimalDivide(&r, &num, &tsz, NSRoundBankers);
            NSDecimalMultiply(&r, &r, &tpi, NSRoundBankers);
            result = [NSDecimalNumber decimalNumberWithDecimal:r];
        } else {
            result = [NSNumber numberWithDouble:[n doubleValue]/180 * M_PI];
        }
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) rtodFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        
        NSNumber *result = nil;
        if (HIGH_PRECISION) {
            NSDecimal num = [n decimalValue];
            NSDecimal tsz = DDDecimalFromInteger(360);
            NSDecimal tpi = DDDecimal2Pi();
            
            num = DDDecimalMod2Pi(num);
            NSDecimal r;
            NSDecimalDivide(&r, &num, &tpi, NSRoundBankers);
            NSDecimalMultiply(&r, &r, &tsz, NSRoundBankers);
            result = [NSDecimalNumber decimalNumberWithDecimal:r];
        } else {
            result = [NSNumber numberWithDouble:[n doubleValue] / M_PI * 180];
        }
		return [DDExpression numberExpressionWithNumber:result];
		
	};
	return [[function copy] autorelease];
}

#pragma mark Constant Functions

+ (DDMathFunction) phiFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
#pragma unused(variables, evaluator)
		REQUIRE_N_ARGS(0);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:DDDecimalPhi()]];
		
	};
	return [[function copy] autorelease];
}

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

+ (DDMathFunction) tauFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
#pragma unused(variables, evaluator)
		REQUIRE_N_ARGS(0);
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:DDDecimal2Pi()]];
		
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
