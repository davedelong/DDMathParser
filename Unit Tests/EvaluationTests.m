//
//  EvaluationTests.m
//  DDMathParser
//
//  Created by Dave DeLong on 11/18/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "UnitTestMacros.h"
#import "EvaluationTests.h"
#import "DDMathParser.h"
#import "NSExpression+EasyParsing.h"

@implementation EvaluationTests

- (void) compareToNSExpression:(NSString *)string compareExpressions:(BOOL)compare {
//	DDExpression * d = [DDExpression expressionFromString:string error:nil];
//	NSExpression * e = [NSExpression expressionWithString:string];
//	
//	NSNumber * dn = [d evaluateWithSubstitutions:nil evaluator:nil error:nil];
//	NSNumber * en = [e expressionValueWithObject:nil context:nil];
//	
//	NSLog(@"--------------------------------");
//	NSLog(@"testing: %@", string);
//	NSLog(@"expecting: %@ => %@", e, en);
//	NSLog(@"given: %@ => %@", d, dn);
//	STAssertEqualObjects(dn, en, @"invalid evalutation.  Expected %@, given %@", en, dn);
//	
//	if (compare) {
//		NSExpression * generatedExpression = [d expressionValue];
//		STAssertEqualObjects(generatedExpression, e, @"invalid generated expression.  expected %@, given %@", e, generatedExpression);	
//	}
}

- (void) compareToNSExpression:(NSString *)string {
	return [self compareToNSExpression:string compareExpressions:YES];
}

- (void) testSimple {
    TEST(@"1", 1);
    TEST(@"1/2", 0.5);
    TEST(@"1+-2", -1);
}

- (void) testAddition {
	[self compareToNSExpression:@"1+1"];
	[self compareToNSExpression:@"1+2"];
	[self compareToNSExpression:@"1+3"];
	[self compareToNSExpression:@"1+4"];
	[self compareToNSExpression:@"1+5"];
	[self compareToNSExpression:@"1+6"];
	[self compareToNSExpression:@"1+7"];
	[self compareToNSExpression:@"1+8"];
	[self compareToNSExpression:@"1+9"];
	
	[self compareToNSExpression:@"1+1+1"];
	[self compareToNSExpression:@"1+2+2"];
	[self compareToNSExpression:@"1+3+3"];
	[self compareToNSExpression:@"1+4+4"];
	[self compareToNSExpression:@"1+5+5"];
	[self compareToNSExpression:@"1+6+6"];
	[self compareToNSExpression:@"1+7+7"];
	[self compareToNSExpression:@"1+8+8"];
	[self compareToNSExpression:@"1+9+9"];
	
	[self compareToNSExpression:@"1+1+1+1+1"];
	[self compareToNSExpression:@"1+2+2+2+2"];
	[self compareToNSExpression:@"1+3+3+3+3"];
	[self compareToNSExpression:@"1+4+4+4+4"];
	[self compareToNSExpression:@"1+5+5+5+5"];
	[self compareToNSExpression:@"1+6+6+6+6"];
	[self compareToNSExpression:@"1+7+7+7+7"];
	[self compareToNSExpression:@"1+8+8+8+8"];
	[self compareToNSExpression:@"1+9+9+9+9"];
}

- (void) testSubtraction {
	[self compareToNSExpression:@"1-1"];
	[self compareToNSExpression:@"1-2"];
	[self compareToNSExpression:@"1-3"];
	[self compareToNSExpression:@"1-4"];
	[self compareToNSExpression:@"1-5"];
	[self compareToNSExpression:@"1-6"];
	[self compareToNSExpression:@"1-7"];
	[self compareToNSExpression:@"1-8"];
	[self compareToNSExpression:@"1-9"];
	
	[self compareToNSExpression:@"1-1-1"];
	[self compareToNSExpression:@"1-2-2"];
	[self compareToNSExpression:@"1-3-3"];
	[self compareToNSExpression:@"1-4-4"];
	[self compareToNSExpression:@"1-5-5"];
	[self compareToNSExpression:@"1-6-6"];
	[self compareToNSExpression:@"1-7-7"];
	[self compareToNSExpression:@"1-8-8"];
	[self compareToNSExpression:@"1-9-9"];
	
	[self compareToNSExpression:@"1-1-1-1-1"];
	[self compareToNSExpression:@"1-2-2-2-2"];
	[self compareToNSExpression:@"1-3-3-3-3"];
	[self compareToNSExpression:@"1-4-4-4-4"];
	[self compareToNSExpression:@"1-5-5-5-5"];
	[self compareToNSExpression:@"1-6-6-6-6"];
	[self compareToNSExpression:@"1-7-7-7-7"];
	[self compareToNSExpression:@"1-8-8-8-8"];
	[self compareToNSExpression:@"1-9-9-9-9"];
}

- (void) testMultiplication {
	[self compareToNSExpression:@"1*1"];
	[self compareToNSExpression:@"1*2"];
	[self compareToNSExpression:@"1*3"];
	[self compareToNSExpression:@"1*4"];
	[self compareToNSExpression:@"1*5"];
	[self compareToNSExpression:@"1*6"];
	[self compareToNSExpression:@"1*7"];
	[self compareToNSExpression:@"1*8"];
	[self compareToNSExpression:@"1*9"];
	
	[self compareToNSExpression:@"1*1*1"];
	[self compareToNSExpression:@"1*2*2"];
	[self compareToNSExpression:@"1*3*3"];
	[self compareToNSExpression:@"1*4*4"];
	[self compareToNSExpression:@"1*5*5"];
	[self compareToNSExpression:@"1*6*6"];
	[self compareToNSExpression:@"1*7*7"];
	[self compareToNSExpression:@"1*8*8"];
	[self compareToNSExpression:@"1*9*9"];
	
	[self compareToNSExpression:@"1*1*1*1*1"];
	[self compareToNSExpression:@"1*2*2*2*2"];
	[self compareToNSExpression:@"1*3*3*3*3"];
	[self compareToNSExpression:@"1*4*4*4*4"];
	[self compareToNSExpression:@"1*5*5*5*5"];
	[self compareToNSExpression:@"1*6*6*6*6"];
	[self compareToNSExpression:@"1*7*7*7*7"];
	[self compareToNSExpression:@"1*8*8*8*8"];
	[self compareToNSExpression:@"1*9*9*9*9"];
}

- (void) testDivision {
	[self compareToNSExpression:@"1.0/1"];
	[self compareToNSExpression:@"1.0/2"];
	[self compareToNSExpression:@"1.0/3"];
	[self compareToNSExpression:@"1.0/4"];
	[self compareToNSExpression:@"1.0/5"];
	[self compareToNSExpression:@"1.0/6"];
	[self compareToNSExpression:@"1.0/7"];
	[self compareToNSExpression:@"1.0/8"];
	[self compareToNSExpression:@"1.0/9"];
	
	[self compareToNSExpression:@"1.0/1/1"];
	[self compareToNSExpression:@"1.0/2/2"];
	[self compareToNSExpression:@"1.0/3/3"];
	[self compareToNSExpression:@"1.0/4/4"];
	[self compareToNSExpression:@"1.0/5/5"];
	[self compareToNSExpression:@"1.0/6/6"];
	[self compareToNSExpression:@"1.0/7/7"];
	[self compareToNSExpression:@"1.0/8/8"];
	[self compareToNSExpression:@"1.0/9/9"];
	
	[self compareToNSExpression:@"1.0/1/1/1/1"];
	[self compareToNSExpression:@"1.0/2/2/2/2"];
	[self compareToNSExpression:@"1.0/3/3/3/3"];
	[self compareToNSExpression:@"1.0/4/4/4/4"];
	[self compareToNSExpression:@"1.0/5/5/5/5"];
	[self compareToNSExpression:@"1.0/6/6/6/6"];
	[self compareToNSExpression:@"1.0/7/7/7/7"];
	[self compareToNSExpression:@"1.0/8/8/8/8"];
	[self compareToNSExpression:@"1.0/9/9/9/9"];
}

- (void) testPower {
	[self compareToNSExpression:@"2**3**2"];
	
	[self compareToNSExpression:@"1**1"];
	[self compareToNSExpression:@"1**2"];
	[self compareToNSExpression:@"1**3"];
	[self compareToNSExpression:@"1**4"];
	[self compareToNSExpression:@"1**5"];
	[self compareToNSExpression:@"1**6"];
	[self compareToNSExpression:@"1**7"];
	[self compareToNSExpression:@"1**8"];
	[self compareToNSExpression:@"1**9"];
	
	[self compareToNSExpression:@"1**1**1"];
	[self compareToNSExpression:@"1**2**2"];
	[self compareToNSExpression:@"1**3**3"];
	[self compareToNSExpression:@"1**4**4"];
	[self compareToNSExpression:@"1**5**5"];
	[self compareToNSExpression:@"1**6**6"];
	[self compareToNSExpression:@"1**7**7"];
	[self compareToNSExpression:@"1**8**8"];
	[self compareToNSExpression:@"1**9**9"];
	
	[self compareToNSExpression:@"1**1**1**1**1"];
	[self compareToNSExpression:@"1**2**2**2**2"];
	[self compareToNSExpression:@"1**3**3**3**3"];
	[self compareToNSExpression:@"1**4**4**4**4"];
	[self compareToNSExpression:@"1**5**5**5**5"];
	[self compareToNSExpression:@"1**6**6**6**6"];
	[self compareToNSExpression:@"1**7**7**7**7"];
	[self compareToNSExpression:@"1**8**8**8**8"];
	[self compareToNSExpression:@"1**9**9**9**9"];
}

- (void) testNegation {
	[self compareToNSExpression:@"-1" compareExpressions:NO];
	[self compareToNSExpression:@"-(1)" compareExpressions:NO];
	[self compareToNSExpression:@"-1+1" compareExpressions:NO];
	[self compareToNSExpression:@"-1-1" compareExpressions:NO];
	[self compareToNSExpression:@"-(1+1)" compareExpressions:NO];
}

- (void) testFactorial {
	DDExpression * d = [DDExpression expressionFromString:@"4!" error:nil];
	NSNumber * n = [d evaluateWithSubstitutions:nil evaluator:nil error:nil];
	STAssertEqualObjects(n, [NSNumber numberWithInteger:24], @"invalid evaluation.  given: %@", n);
	
	d = [DDExpression expressionFromString:@"4.2!" error:nil];
	n = [d evaluateWithSubstitutions:nil evaluator:nil error:nil];
	STAssertEqualObjects(n, [NSNumber numberWithInteger:24], @"invalid evaluation.  given: %@", n);
	
	d = [DDExpression expressionFromString:@"-4!" error:nil];
	n = [d evaluateWithSubstitutions:nil evaluator:nil error:nil];
	STAssertEqualObjects(n, [NSNumber numberWithInteger:-24], @"invalid evaluation.  given: %@", n);
	
	d = [DDExpression expressionFromString:@"(5-1)!" error:nil];
	n = [d evaluateWithSubstitutions:nil evaluator:nil error:nil];
	STAssertEqualObjects(n, [NSNumber numberWithInteger:24], @"invalid evaluation.  given: %@", n);
	
	d = [DDExpression expressionFromString:@"-(5-1)!" error:nil];
	n = [d evaluateWithSubstitutions:nil evaluator:nil error:nil];
	STAssertEqualObjects(n, [NSNumber numberWithInteger:-24], @"invalid evaluation.  given: %@", n);
	
	d = [DDExpression expressionFromString:@"3!!" error:nil];
	n = [d evaluateWithSubstitutions:nil evaluator:nil error:nil];
	STAssertEqualObjects(n, [NSNumber numberWithInteger:720], @"invalid evaluation.  given: %@", n);
	
	d = [DDExpression expressionFromString:@"2!!!!!!!" error:nil];
	n = [d evaluateWithSubstitutions:nil evaluator:nil error:nil];
	STAssertEqualObjects(n, [NSNumber numberWithInteger:2], @"invalid evaluation.  given: %@", n);
}

- (void) testSimplification {
	DDExpression * d = [[DDExpression expressionFromString:@"1 + 2 + 3" error:nil] simplifiedExpression];
	DDExpression * t = [DDExpression expressionFromString:@"6" error:nil];
	
	STAssertEqualObjects(d, t, @"simplification failed");
}

@end