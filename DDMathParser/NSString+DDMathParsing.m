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
	if (error != nil) {
		NSLog(@"error: %@", error);
		return nil;
	}
	return returnValue;
}

- (NSNumber *)numberByEvaluatingStringWithSubstitutions:(NSDictionary *)substitutions error:(NSError **)error {
	DDExpression * e = [DDExpression expressionFromString:self error:error];
	if (error && *error) { return nil; }
	NSNumber *returnValue = [e evaluateWithSubstitutions:substitutions evaluator:nil error:error];
	if (error && *error) { return nil; }
	
	return returnValue;
}

@end
