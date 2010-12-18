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

@interface DDParser ()

//- (DDTerm *) parseTerm;
//- (DDTerm *) parseParentheticalTerm;
//- (DDTerm *) parseParentheticalTerm:(BOOL)isRootTerm;

@end


@implementation DDParser

@synthesize bitwiseOrAssociativity;
@synthesize bitwiseXorAssociativity;
@synthesize bitwiseAndAssociativity;
@synthesize bitwiseLeftShiftAssociativity;
@synthesize bitwiseRightShiftAssociativity;
@synthesize subtractionAssociativity;
@synthesize additionAssociativity;
@synthesize divisionAssociativity;
@synthesize multiplicationAssociativity;
@synthesize modAssociativity;
@synthesize powerAssociativity;

+ (id) parserWithString:(NSString *)string {
	return [[[self alloc] initWithString:string] autorelease];
}

- (id) initWithString:(NSString *)string {
	self = [super init];
	if (self) {
		tokenizer = [[DDMathStringTokenizer alloc] initWithString:string];
		
		bitwiseOrAssociativity = DDOperatorAssociativityLeft;
		bitwiseXorAssociativity = DDOperatorAssociativityLeft;
		bitwiseAndAssociativity = DDOperatorAssociativityLeft;
		bitwiseLeftShiftAssociativity = DDOperatorAssociativityLeft;
		bitwiseRightShiftAssociativity = DDOperatorAssociativityLeft;
		subtractionAssociativity = DDOperatorAssociativityLeft;
		additionAssociativity = DDOperatorAssociativityLeft;
		divisionAssociativity = DDOperatorAssociativityLeft;
		multiplicationAssociativity = DDOperatorAssociativityLeft;
		modAssociativity = DDOperatorAssociativityLeft;
		
		//determine what associativity NSPredicate/NSExpression is using
		//mathematically, it should be right associative, but it's usually parsed as left associative
		//rdar://problem/8692313
		NSExpression * powerExpression = [(NSComparisonPredicate *)[NSPredicate predicateWithFormat:@"2 ** 3 ** 2 == 0"] leftExpression];
		NSNumber * powerResult = [powerExpression expressionValueWithObject:nil context:nil];
		if ([powerResult intValue] == 512) {
			powerAssociativity = DDOperatorAssociativityRight;
		} else {
			powerAssociativity = DDOperatorAssociativityLeft;
		}
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
		case DDOperatorMinus: return subtractionAssociativity;
		case DDOperatorAdd: return additionAssociativity;
		case DDOperatorDivide: return divisionAssociativity;
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
	
	NSLog(@"rootTerm: %@", rootTerm);
	
	[rootTerm resolveWithParser:self];
	
	NSLog(@"rootTerm: %@", rootTerm);
	
	DDExpression * expression = [[rootTerm expression] retain];
	
	NSLog(@"expression: %@", expression);
	
	[parserPool drain];
	
	return [expression autorelease];
}

@end
