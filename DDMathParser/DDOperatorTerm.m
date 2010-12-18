//
//  DDOperatorTerm.m
//  DDMathParser
//
//  Created by Dave DeLong on 12/18/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "DDOperatorTerm.h"


@implementation DDOperatorTerm

- (DDOperator) operatorType {
	if ([[self tokenValue] tokenType] != DDTokenTypeOperator) {
		[NSException raise:NSGenericException format:@"not an operator term"];
	}
	return [[self tokenValue] operatorType];
}

- (DDPrecedence) operatorPrecedence {
	if ([[self tokenValue] tokenType] != DDTokenTypeOperator) {
		[NSException raise:NSGenericException format:@"not an operator term"];
	}
	return [[self tokenValue] operatorPrecedence];
}

@end
