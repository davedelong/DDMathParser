//
//  DDParser.m
//  DDMathParser
//
//  Created by Dave DeLong on 11/24/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "DDParser.h"
#import "DDTerm.h"
#import "DDParserTypes.h"
#import "DDMathStringTokenizer.h"
#import "DDMathStringToken.h"
#import "DDTermResolver.h"
#import "DDExpression.h"

@interface DDParser ()

- (DDTerm *) parseTerm;
- (DDTerm *) parseParentheticalTerm;
- (DDTerm *) parseParentheticalTerm:(BOOL)isRootTerm;

@end


@implementation DDParser

+ (DDPrecedence) precedenceForOperator:(DDMathStringToken *)operator {
	if ([operator tokenType] != DDTokenTypeOperator) { return DDPrecedenceNone; }
	
	switch ([operator operatorType]) {
		case DDOperatorBitwiseOr: return DDPrecedenceBitwiseOr;
		case DDOperatorBitwiseXor: return DDPrecedenceBitwiseXor;
		case DDOperatorBitwiseAnd: return DDPrecedenceBitwiseAnd;
		case DDOperatorLeftShift: return DDPrecedenceLeftShift;
		case DDOperatorRightShift: return DDPrecedenceRightShift;
		case DDOperatorAdd: return DDPrecedenceAddition;
			
		case DDOperatorDivide: return DDPrecedenceDivision;
		case DDOperatorMultiply: return DDPrecedenceMultiplication;
		case DDOperatorModulo: return DDPrecedenceModulo;
		case DDOperatorFactorial: return DDPrecedenceFactorial;
		case DDOperatorPower: return DDPrecedencePower;
		case DDOperatorParenthesisOpen: return DDPrecedenceParentheses;
		case DDOperatorParenthesisClose: return DDPrecedenceParentheses;
			
		case DDOperatorBitwiseNot: return DDPrecedenceUnary;
			
		case DDOperatorMinus: return DDPrecedenceUnknown;
	}
	
	return DDPrecedenceUnknown;
}

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

- (BOOL) isCurrentTokenUnaryNegate {
	DDMathStringToken * previous = [tokenizer previousToken];
	if (previous == nil) { return YES; }
	if ([previous tokenType] == DDTokenTypeOperator && [previous operatorType] != DDOperatorParenthesisClose) {
		return YES;
	}
	return NO;
}

- (DDTerm *) parseTerm {
	DDMathStringToken * t = [tokenizer currentToken];
	DDPrecedence p = [[self class] precedenceForOperator:t];
	if (p == DDPrecedenceUnknown && [t tokenType] == DDTokenTypeOperator) {
		if ([self isCurrentTokenUnaryNegate]) {
			p = DDPrecedenceUnary;
		} else {
			p = DDPrecedenceSubtraction;
		}
	}
	return [DDTerm termWithPrecedence:p tokenValue:t];
}

- (DDTerm *) parseParentheticalTerm {
	return [self parseParentheticalTerm:NO];
}

- (void) groupParametersInTerm:(DDTerm *)term startingAtIndex:(NSUInteger)index {
	NSRange groupingRange = NSMakeRange(index, [[term subTerms] count] - index);
	if (index >= [[term subTerms] count] || groupingRange.length <= 0) {
		[NSException raise:NSGenericException format:@"invalid comma placement"];
		return;
	}
	NSArray * subTerms = [[term subTerms] subarrayWithRange:groupingRange];
	DDTerm * parameterGroup = [DDTerm termWithPrecedence:DDPrecedenceParentheses tokenValue:nil];
	[[parameterGroup subTerms] addObjectsFromArray:subTerms];
	[[term subTerms] replaceObjectsInRange:groupingRange withObjectsFromArray:[NSArray arrayWithObject:parameterGroup]];
}

- (DDTerm *) parseParentheticalTerm:(BOOL)isRootTerm {
	//we don't need to store the actual token for the object value
	DDTerm * parentheticalTerm = [DDTerm termWithPrecedence:DDPrecedenceParentheses tokenValue:nil];
	
	BOOL hadOpeningParenthsis = ([[tokenizer currentToken] operatorType] == DDOperatorParenthesisOpen);
	
	DDMathStringToken * t = nil;
	NSUInteger indexOfFirstUngroupedParameter = 0;
	while ((t = [tokenizer nextToken])) {
		if ([t tokenType] == DDTokenTypeFunction) {
			[tokenizer nextToken]; //consume the (
			DDTerm * functionParams = [self parseParentheticalTerm];
			[functionParams setTokenValue:t]; //the object value is the name of the function
			[[parentheticalTerm subTerms] addObject:functionParams];
		} else if ([t tokenType] == DDTokenTypeOperator && [t operatorType] == DDOperatorParenthesisOpen) {
			//the beginning of another group.  recurse to handle it
			DDTerm * subTerm = [self parseParentheticalTerm];
			[[parentheticalTerm subTerms] addObject:subTerm];
		} else if ([t tokenType] == DDTokenTypeOperator && [t operatorType] == DDOperatorParenthesisClose) {
			//if we grouped a previous parameter, group the last parameter as well
			if (indexOfFirstUngroupedParameter > 0) {
				[self groupParametersInTerm:parentheticalTerm startingAtIndex:indexOfFirstUngroupedParameter];
			}
			if (hadOpeningParenthsis) {
				return parentheticalTerm;
			}
			[NSException raise:NSGenericException format:@"imbalanced parenthesis"];
			return nil;
		} else if ([t tokenType] == DDTokenTypeOperator && [t operatorType] == DDOperatorComma) {
			//a comma indicates a parameter.  group previous (ungrouped) parameters into a logical term group
			[self groupParametersInTerm:parentheticalTerm startingAtIndex:indexOfFirstUngroupedParameter];
			indexOfFirstUngroupedParameter++;
		} else {
			[[parentheticalTerm subTerms] addObject:[self parseTerm]];
		}
	}
	
	if (isRootTerm == NO) {
		[NSException raise:NSGenericException format:@"imbalanced parenthesis"];
		return nil;
	}
	return parentheticalTerm;
}

- (DDExpression *) parsedExpression {
	[tokenizer reset]; //reset the token stream
	
	NSAutoreleasePool * parserPool = [[NSAutoreleasePool alloc] init];
	DDTerm * rootTerm = [self parseParentheticalTerm:YES];
	DDTermResolver * resolver = [DDTermResolver resolverForTerm:rootTerm parser:self];
	DDExpression * expression = [[resolver expressionByResolvingTerm] retain]; //retain the expression so it outlasts the pool
	[parserPool drain];
	
	return [expression autorelease];
}

@end
