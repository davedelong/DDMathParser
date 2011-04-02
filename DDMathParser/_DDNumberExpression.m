//
//  _DDNumberExpression.m
//  DDMathParser
//
//  Created by Dave DeLong on 11/18/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "_DDNumberExpression.h"


@implementation _DDNumberExpression

- (id) initWithNumber:(NSNumber *)n {
	self = [super init];
	if (self) {
		number = [n retain];
	}
	return self;
}
- (void) dealloc {
	[number release];
	[super dealloc];
}

- (DDExpressionType) expressionType { return DDExpressionTypeNumber; }

- (DDExpression *) simplifiedExpressionWithEvaluator:(DDMathEvaluator *)evaluator {
	return self;
}

- (NSNumber *) evaluateWithSubstitutions:(NSDictionary *)substitutions evaluator:(DDMathEvaluator *)evaluator error:(NSError **)error { return [self number]; }

- (NSNumber *) number { return number; }

- (NSExpression *) expressionValueForEvaluator:(DDMathEvaluator *)evaluator {
	return [NSExpression expressionForConstantValue:[self number]];
}

- (NSString *) description {
	return [[self number] description];
}

@end
