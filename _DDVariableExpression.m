//
//  _DDVariableExpression.m
//  DDMathParser
//
//  Created by Dave DeLong on 11/18/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "_DDVariableExpression.h"
#import "DDMathEvaluator.h"
#import "DDMathEvaluator+Private.h"


@implementation _DDVariableExpression

- (id) initWithVariable:(NSString *)v {
	self = [super init];
	if (self) {
		variable = [v copy];
	}
	return self;
}

- (void) dealloc {
	[variable release];
	[super dealloc];
}

- (DDExpressionType) expressionType { return DDExpressionTypeVariable; }

- (NSString *) variable { return variable; }

- (NSNumber *) evaluateWithSubstitutions:(NSDictionary *)substitutions evaluator:(DDMathEvaluator *)evaluator {
	if (evaluator == nil) { evaluator = [DDMathEvaluator sharedMathEvaluator]; }
	
	id variableValue = [substitutions objectForKey:[self variable]];
	if ([variableValue isKindOfClass:[DDExpression class]]) {
		return [variableValue evaluateWithSubstitutions:substitutions evaluator:evaluator];
	}
	if ([variableValue isKindOfClass:[NSNumber class]]) {
		return variableValue;
	}
	[NSException raise:NSInvalidArgumentException format:@"invalid variable value: $%@ => %@", [self variable], variableValue];
	return nil;
}

- (NSExpression *) expressionValueForEvaluator:(DDMathEvaluator *)evaluator {
	return [NSExpression expressionForVariable:[self variable]];
}

- (NSString *) description {
	return [NSString stringWithFormat:@"$%@", [self variable]];
}

@end
