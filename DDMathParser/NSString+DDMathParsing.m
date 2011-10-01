//
//  NSString+DDMathParsing.m
//  DDMathParser
//
//  Created by Dave DeLong on 11/21/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "NSString+DDMathParsing.h"
#import "DDExpression.h"

@implementation NSString (DDMathParsing)

- (NSNumber *) numberByEvaluatingString {
	return [self numberByEvaluatingStringWithSubstitutions:nil];
}

- (NSNumber *) numberByEvaluatingStringWithSubstitutions:(NSDictionary *)substitutions {
	NSError *error = nil;
	NSNumber *returnValue = [self numberByEvaluatingStringWithSubstitutions:substitutions error:&error];
	if (returnValue == nil) {
		NSLog(@"error: %@", error);
	}
	return returnValue;
}

- (NSNumber *)numberByEvaluatingStringWithSubstitutions:(NSDictionary *)substitutions error:(NSError **)error {
	DDExpression * e = [DDExpression expressionFromString:self error:error];
	return [e evaluateWithSubstitutions:substitutions evaluator:nil error:error];
}

@end
