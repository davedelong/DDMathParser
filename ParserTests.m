//
//  ParserTests.m
//  DDMathParser
//
//  Created by Dave DeLong on 11/11/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "ParserTests.h"

#import "DDExpression.h"

@implementation ParserTests

- (void) testSimpleParsing {
	
	NSLog(@"%@", [DDExpression expressionFromString:@"1" error:nil]);
	NSLog(@"%@", [DDExpression expressionFromString:@"1 + 2" error:nil]);
	NSLog(@"%@", [DDExpression expressionFromString:@"1 + 2 + 3" error:nil]);
	NSLog(@"%@", [DDExpression expressionFromString:@"1 + 2 - 3 + 4" error:nil]);
	NSLog(@"%@", [DDExpression expressionFromString:@"-1 + 2 - 3 + 4" error:nil]);
	NSLog(@"%@", [DDExpression expressionFromString:@"SUBTRACT(ADD(NEGATE(1),2),ADD(3,4))" error:nil]);
	NSLog(@"%@", [DDExpression expressionFromString:@"1 + $a" error:nil]);
	NSLog(@"%@", [DDExpression expressionFromString:@"2 ** 3 ** 2" error:nil]);
	NSLog(@"%@", [DDExpression expressionFromString:@"ADD(1,2,3,$a)" error:nil]);
	
}

@end
