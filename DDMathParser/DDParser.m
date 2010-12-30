//
//  DDParser.m
//  DDMathParser
//
//  Created by Dave DeLong on 11/24/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "DDParser.h"
#import "DDTerm.h"
#import "DDGroupTerm.h"
#import "DDParserTypes.h"
#import "DDMathStringTokenizer.h"
#import "DDMathStringToken.h"
#import "DDExpression.h"

static DDOperatorAssociativity defaultBitwiseOrAssociativity = DDOperatorAssociativityLeft;
static DDOperatorAssociativity defaultBitwiseXorAssociativity = DDOperatorAssociativityLeft;
static DDOperatorAssociativity defaultBitwiseAndAssociativity = DDOperatorAssociativityLeft;
static DDOperatorAssociativity defaultBitwiseLeftShiftAssociativity = DDOperatorAssociativityLeft;
static DDOperatorAssociativity defaultBitwiseRightShiftAssociativity = DDOperatorAssociativityLeft;
static DDOperatorAssociativity defaultAdditionAssociativity = DDOperatorAssociativityLeft;
static DDOperatorAssociativity defaultMultiplicationAssociativity = DDOperatorAssociativityLeft;
static DDOperatorAssociativity defaultModAssociativity = DDOperatorAssociativityLeft;
static DDOperatorAssociativity defaultPowerAssociativity = DDOperatorAssociativityLeft;

@implementation DDParser

@synthesize bitwiseOrAssociativity;
@synthesize bitwiseXorAssociativity;
@synthesize bitwiseAndAssociativity;
@synthesize bitwiseLeftShiftAssociativity;
@synthesize bitwiseRightShiftAssociativity;
@synthesize additionAssociativity;
@synthesize multiplicationAssociativity;
@synthesize modAssociativity;
@synthesize powerAssociativity;

+ (void) initialize {
	if (self == [DDParser class]) {
		//determine what associativity NSPredicate/NSExpression is using
		//mathematically, it should be right associative, but it's usually parsed as left associative
		//rdar://problem/8692313
		NSExpression * powerExpression = [(NSComparisonPredicate *)[NSPredicate predicateWithFormat:@"2 ** 3 ** 2 == 0"] leftExpression];
		NSNumber * powerResult = [powerExpression expressionValueWithObject:nil context:nil];
		if ([powerResult intValue] == 512) {
			[self setDefaultPowerAssociativity:DDOperatorAssociativityRight];
		}
	}
}

+ (DDOperatorAssociativity) defaultBitwiseOrAssociativity { return defaultBitwiseOrAssociativity; }
+ (void) setDefaultBitwiseOrAssociativity:(DDOperatorAssociativity)newAssociativity { defaultBitwiseOrAssociativity = newAssociativity; }

+ (DDOperatorAssociativity) defaultBitwiseXorAssociativity { return defaultBitwiseXorAssociativity; }
+ (void) setDefaultBitwiseXorAssociativity:(DDOperatorAssociativity)newAssociativity { defaultBitwiseXorAssociativity = newAssociativity; }

+ (DDOperatorAssociativity) defaultBitwiseAndAssociativity { return defaultBitwiseAndAssociativity; }
+ (void) setDefaultBitwiseAndAssociativity:(DDOperatorAssociativity)newAssociativity { defaultBitwiseAndAssociativity = newAssociativity; }

+ (DDOperatorAssociativity) defaultBitwiseLeftShiftAssociativity { return defaultBitwiseLeftShiftAssociativity; }
+ (void) setDefaultBitwiseLeftShiftAssociativity:(DDOperatorAssociativity)newAssociativity { defaultBitwiseLeftShiftAssociativity = newAssociativity; }

+ (DDOperatorAssociativity) defaultBitwiseRightShiftAssociativity { return defaultBitwiseRightShiftAssociativity; }
+ (void) setDefaultBitwiseRightShiftAssociativity:(DDOperatorAssociativity)newAssociativity { defaultBitwiseRightShiftAssociativity = newAssociativity; }

+ (DDOperatorAssociativity) defaultAdditionAssociativity { return defaultAdditionAssociativity; }
+ (void) setDefaultAdditionAssociativity:(DDOperatorAssociativity)newAssociativity { defaultAdditionAssociativity = newAssociativity; }

+ (DDOperatorAssociativity) defaultMultiplicationAssociativity { return defaultMultiplicationAssociativity; }
+ (void) setDefaultMultiplicationAssociativity:(DDOperatorAssociativity)newAssociativity { defaultMultiplicationAssociativity = newAssociativity; }

+ (DDOperatorAssociativity) defaultModAssociativity { return defaultModAssociativity; }
+ (void) setDefaultModAssociativity:(DDOperatorAssociativity)newAssociativity { defaultModAssociativity = newAssociativity; }

+ (DDOperatorAssociativity) defaultPowerAssociativity { return defaultPowerAssociativity; }
+ (void) setDefaultPowerAssociativity:(DDOperatorAssociativity)newAssociativity { defaultPowerAssociativity = newAssociativity; }

+ (id) parserWithString:(NSString *)string {
	return [[[self alloc] initWithString:string] autorelease];
}

- (id) initWithString:(NSString *)string {
	self = [super init];
	if (self) {
		tokenizer = [[DDMathStringTokenizer alloc] initWithString:string];
		
		bitwiseOrAssociativity = [[self class] defaultBitwiseOrAssociativity];
		bitwiseXorAssociativity = [[self class] defaultBitwiseXorAssociativity];
		bitwiseAndAssociativity = [[self class] defaultBitwiseAndAssociativity];
		bitwiseLeftShiftAssociativity = [[self class] defaultBitwiseLeftShiftAssociativity];
		bitwiseRightShiftAssociativity = [[self class] defaultBitwiseRightShiftAssociativity];
		additionAssociativity = [[self class] defaultAdditionAssociativity];
		multiplicationAssociativity = [[self class] defaultMultiplicationAssociativity];
		modAssociativity = [[self class] defaultModAssociativity];
		powerAssociativity = [[self class] defaultPowerAssociativity];
	}
	return self;
}

- (void) dealloc {
	[tokenizer release];
	[super dealloc];
}

- (DDOperatorAssociativity) associativityForOperator:(DDOperator)operatorType {
	switch (operatorType) {
		case DDOperatorBitwiseOr: return bitwiseOrAssociativity;
		case DDOperatorBitwiseXor: return bitwiseXorAssociativity;
		case DDOperatorBitwiseAnd: return bitwiseAndAssociativity;
		case DDOperatorLeftShift: return bitwiseLeftShiftAssociativity;
		case DDOperatorRightShift: return bitwiseRightShiftAssociativity;
		case DDOperatorMinus:
		case DDOperatorAdd: return additionAssociativity;
		case DDOperatorDivide:
		case DDOperatorMultiply: return multiplicationAssociativity;
		case DDOperatorModulo: return modAssociativity;
		case DDOperatorPower: return powerAssociativity;
			
			//unary operators are right associative (factorial doesn't really count)
		case DDOperatorBitwiseNot: return DDOperatorAssociativityRight;
	}
	return DDOperatorAssociativityLeft;
}

- (DDExpression *) parsedExpression {
	[tokenizer reset]; //reset the token stream
	
	NSAutoreleasePool * parserPool = [[NSAutoreleasePool alloc] init];
	DDTerm * rootTerm = [DDGroupTerm rootTermWithTokenizer:tokenizer];
	
	[rootTerm resolveWithParser:self];
	DDExpression * expression = [[rootTerm expression] retain];
	[parserPool drain];
	
	return [expression autorelease];
}

@end
