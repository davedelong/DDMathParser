//
//  DDMathStringToken.m
//  DDMathParser
//
//  Created by Dave DeLong on 11/16/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "DDMathParser.h"
#import "DDMathStringToken.h"

@implementation DDMathStringToken
@synthesize token, tokenType, operatorType, operatorPrecedence, operatorArity;

#if !DD_HAS_ARC
- (void) dealloc {
	[token release];
    [numberValue release];
	[super dealloc];
}
#endif

- (id) initWithToken:(NSString *)t type:(DDTokenType)type {
	self = [super init];
	if (self) {
		token = [t copy];
		tokenType = type;
		operatorType = DDOperatorInvalid;
		operatorPrecedence = DDPrecedenceNone;
        operatorArity = DDOperatorArityUnknown;
		
		if (tokenType == DDTokenTypeOperator) {
			if ([token isEqual:@"|"]) {
				operatorType = DDOperatorBitwiseOr;
				operatorPrecedence = DDPrecedenceBitwiseOr;
                operatorArity = DDOperatorArityBinary;
			}
			if ([token isEqual:@"^"]) {
				operatorType = DDOperatorBitwiseXor; 
				operatorPrecedence = DDPrecedenceBitwiseXor;
                operatorArity = DDOperatorArityBinary;
			}
			if ([token isEqual:@"&"]) {
				operatorType = DDOperatorBitwiseAnd;
				operatorPrecedence = DDPrecedenceBitwiseAnd;
                operatorArity = DDOperatorArityBinary;
			}
			if ([token isEqual:@"<<"]) {
				operatorType = DDOperatorLeftShift;
				operatorPrecedence = DDPrecedenceLeftShift;
                operatorArity = DDOperatorArityBinary;
			}
			if ([token isEqual:@">>"]) {
				operatorType = DDOperatorRightShift;
				operatorPrecedence = DDPrecedenceRightShift;
                operatorArity = DDOperatorArityBinary;
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
                operatorArity = DDOperatorArityBinary;
			}
			if ([token isEqual:@"*"]) {
				operatorType = DDOperatorMultiply;
				operatorPrecedence = DDPrecedenceMultiplication;
                operatorArity = DDOperatorArityBinary;
			}
			if ([token isEqual:@"%"]) {
				operatorType = DDOperatorModulo;
				operatorPrecedence = DDPrecedenceModulo;
                operatorArity = DDOperatorArityBinary;
			}
			if ([token isEqual:@"~"]) {
				operatorType = DDOperatorBitwiseNot;
				operatorPrecedence = DDPrecedenceUnary;
                operatorArity = DDOperatorArityUnary;
			}
			if ([token isEqual:@"!"]) {
				operatorType = DDOperatorFactorial;
				operatorPrecedence = DDPrecedenceFactorial;
                operatorArity = DDOperatorArityUnary;
			}
			if ([token isEqual:@"**"]) {
				operatorType = DDOperatorPower;
				operatorPrecedence = DDPrecedencePower;
                operatorArity = DDOperatorArityBinary;
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
	return DD_AUTORELEASE([[self alloc] initWithToken:t type:type]);
}

- (NSNumber *) numberValue {
	if ([self tokenType] != DDTokenTypeNumber) { return nil; }
	if (numberValue == nil) {
        numberValue = [[NSDecimalNumber alloc] initWithString:[self token]];
        if (numberValue == nil) {
            NSLog(@"supposedly invalid number: %@", [self token]);
            numberValue = [[NSNumber alloc] initWithInt:0];
        }
    }
	return numberValue;
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

- (void)setOperatorPrecedence:(DDPrecedence)precedence {
    if (operatorArity == DDOperatorArityUnknown) {
        if (precedence == DDPrecedenceUnary || precedence == DDPrecedenceFactorial) {
            operatorArity = DDOperatorArityUnary;
        } else if (precedence != DDPrecedenceNone) {
            operatorArity = DDOperatorArityBinary;
        }
    }
    operatorPrecedence = precedence;
}

@end
