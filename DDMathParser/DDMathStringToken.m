//
//  DDMathStringToken.m
//  DDMathParser
//
//  Created by Dave DeLong on 11/16/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "DDMathStringToken.h"


@implementation DDMathStringToken
@synthesize token, tokenType, operatorType, operatorPrecedence;

- (void) dealloc {
	[token release];
	[super dealloc];
}

- (id) initWithToken:(NSString *)t type:(DDTokenType)type {
	self = [super init];
	if (self) {
		token = [t copy];
		tokenType = type;
		operatorType = DDOperatorInvalid;
		operatorPrecedence = DDPrecedenceNone;
		
		if (tokenType == DDTokenTypeOperator) {
			if ([token isEqual:@"|"]) {
				operatorType = DDOperatorBitwiseOr;
				operatorPrecedence = DDPrecedenceBitwiseOr;
			}
			if ([token isEqual:@"^"]) {
				operatorType = DDOperatorBitwiseXor; 
				operatorPrecedence = DDPrecedenceBitwiseXor;
			}
			if ([token isEqual:@"&"]) {
				operatorType = DDOperatorBitwiseAnd;
				operatorPrecedence = DDPrecedenceBitwiseAnd;
			}
			if ([token isEqual:@"<<"]) {
				operatorType = DDOperatorLeftShift;
				operatorPrecedence = DDPrecedenceLeftShift;
			}
			if ([token isEqual:@">>"]) {
				operatorType = DDOperatorRightShift;
				operatorPrecedence = DDPrecedenceRightShift;
			}
			if ([token isEqual:@"-"]) {
				operatorType = DDOperatorMinus;
				operatorPrecedence = DDPrecedenceUnknown;
			}
			if ([token isEqual:@"+"]) {
				operatorType = DDOperatorAdd;
				operatorPrecedence = DDPrecedenceUnknown;
			}
			if ([token isEqual:@"/"]) {
				operatorType = DDOperatorDivide;
				operatorPrecedence = DDPrecedenceDivision;
			}
			if ([token isEqual:@"*"]) {
				operatorType = DDOperatorMultiply;
				operatorPrecedence = DDPrecedenceMultiplication;
			}
			if ([token isEqual:@"%"]) {
				operatorType = DDOperatorModulo;
				operatorPrecedence = DDPrecedenceModulo;
			}
			if ([token isEqual:@"~"]) {
				operatorType = DDOperatorBitwiseNot;
				operatorPrecedence = DDPrecedenceUnary;
			}
			if ([token isEqual:@"!"]) {
				operatorType = DDOperatorFactorial;
				operatorPrecedence = DDPrecedenceFactorial;
			}
			if ([token isEqual:@"**"]) {
				operatorType = DDOperatorPower;
				operatorPrecedence = DDPrecedencePower;
			}
			if ([token isEqual:@"("]) {
				operatorType = DDOperatorParenthesisOpen;
				operatorPrecedence = DDPrecedenceParentheses;
			}
			if ([token isEqual:@")"]) {
				operatorType = DDOperatorParenthesisClose;
				operatorPrecedence = DDPrecedenceParentheses;
			}
			
			if ([token isEqual:@","]) {
				operatorType = DDOperatorComma;
			}
		}
	}
	return self;
}

+ (id) mathStringTokenWithToken:(NSString *)t type:(DDTokenType)type {
	return [[[self alloc] initWithToken:t type:type] autorelease];
}

- (NSNumber *) numberValue {
	if ([self tokenType] != DDTokenTypeNumber) { return nil; }
	
	NSNumberFormatter * f = [[[NSNumberFormatter alloc] init] autorelease];
	for (int style = NSNumberFormatterNoStyle; style < NSNumberFormatterSpellOutStyle; ++style) {
		[f setNumberStyle:style];
		NSNumber * n = [f numberFromString:[self token]];
		if (n != nil) { return n; }
	}
	
	NSLog(@"supposedly invalid number: %@", [self token]);
	return [NSNumber numberWithInt:0];
}

- (NSString *) description {
	NSMutableString * d = [NSMutableString string];
	if (tokenType == DDTokenTypeVariable) {
		[d appendString:@"$"];
	}
	[d appendString:token];
	return d;
}

- (DDOperator) operatorType {
	if (operatorPrecedence == DDPrecedenceUnary) {
		if (operatorType == DDOperatorAdd) { return DDOperatorUnaryPlus; }
		if (operatorType == DDOperatorMinus) { return DDOperatorUnaryMinus; }
	}
	return operatorType;
}

@end
