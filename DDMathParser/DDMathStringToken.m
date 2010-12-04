//
//  DDMathStringToken.m
//  DDMathParser
//
//  Created by Dave DeLong on 11/16/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "DDMathStringToken.h"


@implementation DDMathStringToken
@synthesize token, tokenType, operatorType;

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
		
		if (tokenType == DDTokenTypeOperator) {
			if ([token isEqual:@"|"]) { operatorType = DDOperatorBitwiseOr; }
			if ([token isEqual:@"^"]) { operatorType = DDOperatorBitwiseXor; }
			if ([token isEqual:@"&"]) { operatorType = DDOperatorBitwiseAnd; }
			if ([token isEqual:@"<<"]) { operatorType = DDOperatorLeftShift; }
			if ([token isEqual:@">>"]) { operatorType = DDOperatorRightShift; }
			if ([token isEqual:@"-"]) { operatorType = DDOperatorMinus; }
			if ([token isEqual:@"+"]) { operatorType = DDOperatorAdd; }
			if ([token isEqual:@"/"]) { operatorType = DDOperatorDivide; }
			if ([token isEqual:@"*"]) { operatorType = DDOperatorMultiply; }
			if ([token isEqual:@"%"]) { operatorType = DDOperatorModulo; }
			if ([token isEqual:@"~"]) { operatorType = DDOperatorBitwiseNot; }
			if ([token isEqual:@"!"]) { operatorType = DDOperatorFactorial; }
			if ([token isEqual:@"**"]) { operatorType = DDOperatorPower; }
			if ([token isEqual:@"("]) { operatorType = DDOperatorParenthesisOpen; }
			if ([token isEqual:@")"]) { operatorType = DDOperatorParenthesisClose; }
			
			if ([token isEqual:@","]) { operatorType = DDOperatorComma; }
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

@end
