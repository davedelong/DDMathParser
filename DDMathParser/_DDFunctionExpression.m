//
//  _DDFunctionExpression.m
//  DDMathParser
//
//  Created by Dave DeLong on 11/18/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "_DDFunctionExpression.h"
#import "DDMathEvaluator.h"
#import "DDMathEvaluator+Private.h"
#import "_DDNumberExpression.h"
#import "_DDVariableExpression.h"

@implementation _DDFunctionExpression

- (id) initWithFunction:(NSString *)f arguments:(NSArray *)a {
	self = [super init];
	if (self) {
		for (id arg in a) {
			if ([arg isKindOfClass:[DDExpression class]] == NO) {
				[NSException raise:NSInvalidArgumentException format:@"function arguments must be DDExpression objects"];
				[self release];
				return nil;
			}
		}
		
		function = [f copy];
		arguments = [a copy];
	}
	return self;
}
- (void) dealloc {
	[function release];
	[arguments release];
	[super dealloc];
}
- (DDExpressionType) expressionType { return DDExpressionTypeFunction; }

- (NSString *) function { return [function lowercaseString]; }
- (NSArray *) arguments { return arguments; }

- (NSNumber *) evaluateWithSubstitutions:(NSDictionary *)substitutions evaluator:(DDMathEvaluator *)evaluator {
	if (evaluator == nil) { evaluator = [DDMathEvaluator sharedMathEvaluator]; }
	
	NSInteger numberOfAllowedArguments = [evaluator numberOfArgumentsForFunction:[self function]];
	if (numberOfAllowedArguments != DDMathFunctionUnlimitedArguments) {
		if (numberOfAllowedArguments != [[self arguments] count]) {
			[NSException raise:NSInvalidArgumentException format:@"invalid number of arguments to %@ function.  %ld required", [self function], numberOfAllowedArguments];
			return nil;
		}
	}
	
	DDMathFunction mathFunction = [evaluator functionWithName:[self function]];
	
	id result = mathFunction([self arguments], substitutions, evaluator);
	
	while ([result isKindOfClass:[_DDVariableExpression class]]) {
		result = [result evaluateWithSubstitutions:substitutions evaluator:evaluator];
	}
	
	NSNumber * numberValue = nil;
	if ([result isKindOfClass:[_DDNumberExpression class]]) {
		numberValue = [result number];
	} else if ([result isKindOfClass:[NSNumber class]]) {
		numberValue = result;
	} else {
		[NSException raise:NSInvalidArgumentException format:@"invalid return type from %@ function", [self function]];
		return nil;
	}
	return numberValue;

}

- (NSExpression *) expressionValueForEvaluator:(DDMathEvaluator *)evaluator {
	NSString * nsexpressionFunction = [evaluator nsexpressionFunctionWithName:[self function]];
	NSMutableArray * expressionArguments = [NSMutableArray array];
	for (DDExpression * argument in [self arguments]) {
		[expressionArguments addObject:[argument expressionValueForEvaluator:evaluator]];
	}
	
	if (nsexpressionFunction != nil) {
		return [NSExpression expressionForFunction:nsexpressionFunction arguments:expressionArguments];
	} else {
		NSExpression * target = [NSExpression expressionForConstantValue:evaluator];
		NSExpression * functionExpression = [NSExpression expressionForConstantValue:[self function]];
		[expressionArguments insertObject:functionExpression atIndex:0];
		
		NSExpression * argumentsExpression = [NSExpression expressionForConstantValue:expressionArguments];
		return [NSExpression expressionForFunction:target selectorName:@"performFunction:" arguments:[NSArray arrayWithObject:argumentsExpression]];
	}
}

- (NSString *) description {
	return [NSString stringWithFormat:@"%@(%@)", [self function], [[[self arguments] valueForKey:@"description"] componentsJoinedByString:@","]];
}

@end
