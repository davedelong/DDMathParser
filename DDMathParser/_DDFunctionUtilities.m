//
//  __DDFunctionUtilities.m
//  DDMathParser
//
//  Created by Dave DeLong on 12/21/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "_DDFunctionUtilities.h"
#import "DDExpression.h"

static inline NSDecimal NSDecimalNegativeOne() {
	NSDecimal d = { ._exponent = 0, ._length = 1, ._isNegative = 1, ._isCompact = 1, ._reserved = 0, ._mantissa = {1, 0, 0, 0, 0, 0, 0, 0}};
	return d;
}

static inline NSDecimal NSDecimalOne() {
	NSDecimal d = { ._exponent = 0, ._length = 1, ._isNegative = 0, ._isCompact = 1, ._reserved = 0, ._mantissa = {1, 0, 0, 0, 0, 0, 0, 0}};
	return d;
}

@implementation _DDFunctionUtilities

+ (DDMathFunction) addFunction {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
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
		NSNumber * firstValue = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator];
		
		NSDecimal result;
		NSDecimal a = [firstValue decimalValue];
		NSDecimal nOne = NSDecimalNegativeOne();
		NSDecimalMultiply(&result, &nOne, &a, NSRoundBankers);
		
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:result]];
	};
	return [[function copy] autorelease];
}

+ (DDMathFunction) factorialFunction {
	DDMathFunction function = ^ DDExpression* (NSArray * arguments, NSDictionary * variables, DDMathEvaluator * evaluator) {
		NSDecimal result = NSDecimalOne();
		NSNumber * firstValue = [[arguments objectAtIndex:0] evaluateWithSubstitutions:variables evaluator:evaluator];
		NSUInteger upperBound = [firstValue unsignedIntegerValue];
		for (int i = upperBound; i > 1; --i) {
			
		}
		
		NSDecimal a = [firstValue decimalValue];
		NSDecimal nOne = NSDecimalNegativeOne();
		NSDecimalMultiply(&result, &nOne, &a, NSRoundBankers);
		
		return [DDExpression numberExpressionWithNumber:[NSDecimalNumber decimalNumberWithDecimal:result]];
	};
	return [[function copy] autorelease];
}
+ (DDMathFunction) powFunction;
+ (DDMathFunction) andFunction;
+ (DDMathFunction) orFunction;
+ (DDMathFunction) notFunction;
+ (DDMathFunction) xorFunction;
+ (DDMathFunction) rshiftFunction;
+ (DDMathFunction) lshiftFunction;
+ (DDMathFunction) averageFunction;
+ (DDMathFunction) sumFunction;
+ (DDMathFunction) countFunction;
+ (DDMathFunction) minFunction;
+ (DDMathFunction) maxFunction;
+ (DDMathFunction) medianFunction;
+ (DDMathFunction) modeFunction;
+ (DDMathFunction) stddevFunction;
+ (DDMathFunction) sqrtFunction;
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
