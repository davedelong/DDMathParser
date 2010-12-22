//
//  NSExpression+DDMathParsing.m
//  DDMathParser
//
//  Created by Dave DeLong on 11/23/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "NSExpression+DDMathParsing.h"
#import "DDExpression.h"
#import "DDMathEvaluator.h"
#import "DDMathFunctionContainer.h"

@implementation NSExpression (DDMathParsing)

- (DDExpression *) ddexpressionValue {
	[NSException raise:NSGenericException format:@"%s is not yet implemented", __PRETTY_FUNCTION__];
	return nil;
	
	/**
	if ([self expressionType] == NSVariableExpressionType) {
		return [DDExpression variableExpressionWithVariable:[self variable]];
	}
	if ([self expressionType] == NSConstantValueExpressionType) {
		id constantValue = [self constantValue];
		if ([constantValue isKindOfClass:[NSNumber class]]) {
			return [DDExpression numberExpressionWithNumber:constantValue];
		}
		[NSException raise:NSInvalidArgumentException format:@"invalid constant value: %@", constantValue];
		return nil;
	}
	if ([self expressionType] == NSFunctionExpressionType) {
		NSExpression * operand = [self operand];
		if ([[operand constantValue] isKindOfClass:[DDMathEvaluator class]]) {
			NSArray * arguments = [self arguments];
			NSExpression * argumentsExpression = [[self arguments] objectAtIndex:0];
			arguments = [argumentsExpression constantValue];
			//the first argument is a string with the function name
			//the rest of the arguments are the parameters to the function
			NSString * functionName = [[arguments objectAtIndex:0] constantValue];
			NSMutableArray * newArguments = [NSMutableArray array];
			for (int i = 1; i < [arguments count]; ++i) {
				NSExpression * argument = [arguments objectAtIndex:i];
				[newArguments addObject:[argument ddexpressionValue]];
			}
			return [DDExpression functionExpressionWithFunction:functionName arguments:newArguments];
		} else {
			//one of the built-in functions
			NSString * functionName = [self function];
			NSString * ddfunctionName = [[DDMathFunctionContainer functionsForNSExpressionFunctions] objectForKey:functionName];
		}
	}
	 **/
}

@end
