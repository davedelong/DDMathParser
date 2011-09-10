//
//  __DDFunctionUtilities.m
//  DDMathParser
//
//  Created by Dave DeLong on 12/21/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "_DDFunctionUtilities.h"
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

@implementation _DDFunctionUtilities

+ (DDMathFunction) addFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(2);
		NSNumber * firstValue = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
		RETURN_IF_NIL(firstValue);
		
		NSNumber * secondValue = [[arguments objectAtIndex:1] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
		RETURN_IF_NIL(secondValue);
		
        NSNumber *result = [NSNumber numberWithDouble:[firstValue doubleValue] + [secondValue doubleValue]];
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
		
        NSNumber *result = [NSNumber numberWithDouble:[firstValue doubleValue] - [secondValue doubleValue]];
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
		
        NSNumber *result = [NSNumber numberWithDouble:[firstValue doubleValue] * [secondValue doubleValue]];
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
		
        NSNumber *result = [NSNumber numberWithDouble:[firstValue doubleValue] / [secondValue doubleValue]];
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
		
        NSNumber *result = [NSNumber numberWithDouble:fmod([firstValue doubleValue], [secondValue doubleValue])];
        return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) negateFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
		NSNumber * firstValue = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
		RETURN_IF_NIL(firstValue);
		
        NSNumber *result = [NSNumber numberWithDouble:-1 * [firstValue doubleValue]];
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) factorialFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
		NSNumber * firstValue = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
		RETURN_IF_NIL(firstValue);
        
        NSNumber *result = [NSNumber numberWithDouble:tgamma([firstValue doubleValue]+1)];
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
        
        NSNumber *result = [NSNumber numberWithDouble:pow([base doubleValue], [exponent doubleValue])];
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
        
        NSNumber *result = [NSNumber numberWithDouble:pow([base doubleValue], 1/[root doubleValue])];
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
        
		NSNumber * result = [NSNumber numberWithInteger:[first integerValue] >> [second integerValue]];
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
        
		NSNumber * result = [NSNumber numberWithInteger:[first integerValue] << [second integerValue]];
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
        
        double sum = [[sumExpression number] doubleValue];
        NSNumber *avg = [NSNumber numberWithDouble:sum / [arguments count]];
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
        
        double sum = 0;
        for (NSNumber *value in arguments) {
            sum += [value doubleValue];
        }
        NSNumber *result = [NSNumber numberWithDouble:sum];
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
        NSNumber *result = nil;
		for (NSUInteger index = 0; index < [arguments count]; ++index) {
			DDExpression *obj = [arguments objectAtIndex:index];
			NSNumber *value = [obj evaluateWithSubstitutions:variables evaluator:evaluator error:error];
			RETURN_IF_NIL(value);
            if (index == 0 || [result compare:value] == NSOrderedDescending) {
				//result > value (or is first index)
				//value is smaller
				result = value;
			}
		}
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) maxFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_GTOE_N_ARGS(2);
        NSNumber *result = nil;
		for (NSUInteger index = 0; index < [arguments count]; ++index) {
			DDExpression *obj = [arguments objectAtIndex:index];
			NSNumber *value = [obj evaluateWithSubstitutions:variables evaluator:evaluator error:error];
			RETURN_IF_NIL(value);
            if (index == 0 || [result compare:value] == NSOrderedAscending) {
				//result < value (or is first index)
				//value is larger
				result = value;
			}
		}
		return [DDExpression numberExpressionWithNumber:result];
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
            NSNumber *low = [evaluatedNumbers objectAtIndex:lowIndex];
            NSNumber *high = [evaluatedNumbers objectAtIndex:highIndex];
            median = [NSNumber numberWithDouble:([low doubleValue] + [high doubleValue])/2];
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
        NSNumber *result = [NSNumber numberWithDouble:stddev];
		
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) sqrtFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
		NSNumber * n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
		RETURN_IF_NIL(n);
        
        NSNumber *result = [NSNumber numberWithDouble:sqrt([n doubleValue])];
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
        
        NSNumber *result = [NSNumber numberWithDouble:log10([n doubleValue])];
		return [DDExpression numberExpressionWithNumber:result];
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
        
        NSNumber *result = [NSNumber numberWithDouble:log2([n doubleValue])];
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) expFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
		NSNumber * n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
		RETURN_IF_NIL(n);
        
        NSNumber *result = [NSNumber numberWithDouble:exp([n doubleValue])];
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) ceilFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);

        NSNumber *result = [NSNumber numberWithDouble:ceil([n doubleValue])];
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) absFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        
        NSNumber *result = [NSNumber numberWithLongLong:llabs([n longLongValue])];
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) floorFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        
        NSNumber *result = [NSNumber numberWithDouble:floor([n doubleValue])];
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) sinFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        
        NSNumber *result = [NSNumber numberWithDouble:sin([n doubleValue])];
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) cosFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        
        NSNumber *result = [NSNumber numberWithDouble:cos([n doubleValue])];
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) tanFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        
        NSNumber *result = [NSNumber numberWithDouble:tan([n doubleValue])];
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) asinFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        
        NSNumber *result = [NSNumber numberWithDouble:asin([n doubleValue])];
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) acosFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        
        NSNumber *result = [NSNumber numberWithDouble:acos([n doubleValue])];
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) atanFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        
        NSNumber *result = [NSNumber numberWithDouble:atan([n doubleValue])];
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) sinhFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        
        NSNumber *result = [NSNumber numberWithDouble:sinh([n doubleValue])];
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) coshFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        
        NSNumber *result = [NSNumber numberWithDouble:cosh([n doubleValue])];
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) tanhFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        
        NSNumber *result = [NSNumber numberWithDouble:tanh([n doubleValue])];
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) asinhFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        
        NSNumber *result = [NSNumber numberWithDouble:asinh([n doubleValue])];
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) acoshFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        
        NSNumber *result = [NSNumber numberWithDouble:acosh([n doubleValue])];
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) atanhFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        
        NSNumber *result = [NSNumber numberWithDouble:atanh([n doubleValue])];
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) cscFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        
        NSNumber *result = [NSNumber numberWithDouble:1/sin([n doubleValue])];
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) secFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        
        NSNumber *result = [NSNumber numberWithDouble:1/cos([n doubleValue])];
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) cotanFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        
        NSNumber *result = [NSNumber numberWithDouble:1/tan([n doubleValue])];
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) acscFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        
        NSNumber *result = [NSNumber numberWithDouble:1/asin([n doubleValue])];
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) asecFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        
        NSNumber *result = [NSNumber numberWithDouble:1/acos([n doubleValue])];
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) acotanFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        
        NSNumber *result = [NSNumber numberWithDouble:1/atan([n doubleValue])];
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) cschFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        
        NSNumber *result = [NSNumber numberWithDouble:1/sinh([n doubleValue])];
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) sechFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        
        NSNumber *result = [NSNumber numberWithDouble:1/cosh([n doubleValue])];
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) cotanhFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        
        NSNumber *result = [NSNumber numberWithDouble:1/tanh([n doubleValue])];
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) acschFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        
        NSNumber *result = [NSNumber numberWithDouble:1/sinh([n doubleValue])];
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) asechFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        
        NSNumber *result = [NSNumber numberWithDouble:1/cosh([n doubleValue])];
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) acotanhFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        
        NSNumber *result = [NSNumber numberWithDouble:1/atanh([n doubleValue])];
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) dtorFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        
        NSNumber *result = [NSNumber numberWithDouble:[n doubleValue]/180 * M_PI];
		return [DDExpression numberExpressionWithNumber:result];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) rtodFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
		REQUIRE_N_ARGS(1);
        NSNumber *n = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator error:error];
        RETURN_IF_NIL(n);
        
        NSNumber *result = [NSNumber numberWithDouble:[n doubleValue] / M_PI * 180];
		return [DDExpression numberExpressionWithNumber:result];
		
	};
	return [[function copy] autorelease];
}

#pragma mark Constant Functions

+ (DDMathFunction) phiFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
#pragma unused(variables, evaluator)
		REQUIRE_N_ARGS(0);
		return [DDExpression numberExpressionWithNumber:[NSNumber numberWithDouble:1.6180339887498948]];
		
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) piFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
#pragma unused(variables, evaluator)
		REQUIRE_N_ARGS(0);
        return [DDExpression numberExpressionWithNumber:[NSNumber numberWithDouble:M_PI]];
		
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) pi_2Function {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
#pragma unused(variables, evaluator)
		REQUIRE_N_ARGS(0);
		return [DDExpression numberExpressionWithNumber:[NSNumber numberWithDouble:M_PI_2]];
		
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) pi_4Function {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
#pragma unused(variables, evaluator)
		REQUIRE_N_ARGS(0);
		return [DDExpression numberExpressionWithNumber:[NSNumber numberWithDouble:M_PI_4]];
		
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) tauFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
#pragma unused(variables, evaluator)
		REQUIRE_N_ARGS(0);
		return [DDExpression numberExpressionWithNumber:[NSNumber numberWithDouble:M_2_PI]];
		
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) sqrt2Function {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
#pragma unused(variables, evaluator)
		REQUIRE_N_ARGS(0);
		return [DDExpression numberExpressionWithNumber:[NSNumber numberWithDouble:M_SQRT2]];
		
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) eFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
#pragma unused(variables, evaluator)
		REQUIRE_N_ARGS(0);
        return [DDExpression numberExpressionWithNumber:[NSNumber numberWithDouble:M_E]];
		
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) log2eFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
#pragma unused(variables, evaluator)
		REQUIRE_N_ARGS(0);
		return [DDExpression numberExpressionWithNumber:[NSNumber numberWithDouble:M_LOG2E]];
		
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) log10eFunction {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
#pragma unused(variables, evaluator)
		REQUIRE_N_ARGS(0);
		return [DDExpression numberExpressionWithNumber:[NSNumber numberWithDouble:M_LOG10E]];
		
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) ln2Function {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
#pragma unused(variables, evaluator)
		REQUIRE_N_ARGS(0);
		return [DDExpression numberExpressionWithNumber:[NSNumber numberWithDouble:M_LN2]];
		
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) ln10Function {
	DDMathFunction function = ^ DDExpression* (NSArray *arguments, NSDictionary *variables, DDMathEvaluator *evaluator, NSError **error) {
#pragma unused(variables, evaluator)
		REQUIRE_N_ARGS(0);
		return [DDExpression numberExpressionWithNumber:[NSNumber numberWithDouble:M_LN10]];
		
	};
	return [[function copy] autorelease];
}

@end
