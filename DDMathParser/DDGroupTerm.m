//
//  DDGroupTerm.m
//  DDMathParser
//
//  Created by Dave DeLong on 12/18/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "DDGroupTerm.h"
#import "DDFunctionTerm.h"
#import "DDOperatorTerm.h"

@interface DDMathStringToken ()

- (id) initWithToken:(DDMathStringToken *)token;

@end


@interface DDFunctionTerm (DDGroupResolving)

+ (id) functionTermWithName:(NSString *)function;

@end

@implementation DDFunctionTerm (DDGroupResolving)

+ (id) functionTermWithName:(NSString *)function {
	DDMathStringToken * token = [DDMathStringToken mathStringTokenWithToken:function type:DDTokenTypeFunction];
	DDFunctionTerm * f = [DDFunctionTerm groupTermWithSubTerms:[NSArray array]];
	[f setTokenValue:token];
	return f;
}

@end


@implementation DDGroupTerm
@synthesize subTerms;

+ (id) rootTermWithTokenizer:(DDMathStringTokenizer *)tokenizer {
	DDGroupTerm * g = [DDGroupTerm termWithTokenizer:nil];
	
	DDMathStringToken * t = nil;
	while ((t = [tokenizer peekNextToken])) {
		[[g subTerms] addObject:[DDTerm termForTokenType:[t tokenType] withTokenizer:tokenizer]];
	}
	
	return g;
}

+ (id) groupTermWithSubTerms:(NSArray *)sub {
	DDGroupTerm * g = [[self alloc] initWithTokenizer:nil];
	[[g subTerms] addObjectsFromArray:sub];
	return [g autorelease];
}

- (id) initWithTokenizer:(DDMathStringTokenizer *)tokenizer {
	self = [super initWithTokenizer:tokenizer];
	if (self) {
		subTerms = [[NSMutableArray alloc] init];
		
		if (tokenizer != nil && [self isMemberOfClass:[DDGroupTerm class]]) {
			//TODO: find all the terms in this group
			DDMathStringToken * next = nil;
			while ((next = [tokenizer peekNextToken])) {
				if ([next operatorType] == DDOperatorParenthesisClose) { break; }
				
				[[self subTerms] addObject:[DDTerm termForTokenType:[next tokenType] withTokenizer:tokenizer]];
			}
			
			next = [tokenizer nextToken];
			if ([next operatorType] != DDOperatorParenthesisClose) {
				[NSException raise:NSGenericException format:@"imbalanced parentheses"];
			}
			
		}
	}
	return self;
}

- (void) dealloc {
	[subTerms release];
	[super dealloc];
}

#pragma mark Resolving

- (NSIndexSet *) indicesOfOperatorsWithHighestPrecedence {
	NSMutableIndexSet * indices = [NSMutableIndexSet indexSet];
	DDPrecedence currentPrecedence = DDPrecedenceUnknown;
	for (NSUInteger i = 0; i < [[self subTerms] count]; ++i) {
		DDTerm * thisTerm = [[self subTerms] objectAtIndex:i];
		if ([[thisTerm tokenValue] tokenType] == DDTokenTypeOperator) {
			DDPrecedence thisPrecedence = [[thisTerm tokenValue] operatorPrecedence];
			
			if (thisPrecedence > currentPrecedence) {
				currentPrecedence = thisPrecedence;
				[indices removeAllIndexes];
				[indices addIndex:i];
			} else if (thisPrecedence == currentPrecedence) {
				[indices addIndex:i];
			}
		}
	}
	return indices;
}

- (void) reduceTermsAroundOperatorAtIndex:(NSUInteger)index {
	NSMutableArray * terms = [self subTerms];
	
	DDOperatorTerm * operator = [terms objectAtIndex:index];
	
	NSRange replacementRange = NSMakeRange(0, 0);
	DDGroupTerm * replacement = nil;
	
	//let's handle the simple stuff first:
	if ([operator operatorPrecedence] == DDPrecedenceFactorial) {
		replacementRange.location = index - 1;
		replacementRange.length = 2;
		replacement = [DDFunctionTerm functionTermWithName:@"factorial"];
		[[replacement subTerms] addObject:[terms objectAtIndex:index-1]];
	} else if ([operator operatorPrecedence] == DDPrecedenceUnary) {
		replacementRange.location = index;
		replacementRange.length = 2;
		if ([[[operator tokenValue] token] isEqual:@"+"]) {
			//in other words, the unary + is a worthless operator:
			replacement = [terms objectAtIndex:index+1];
		} else {
			NSString * function = ([[[operator tokenValue] token] isEqual:@"~"] ? @"not" : @"negate");
			replacement = [DDFunctionTerm functionTermWithName:function];
			[[replacement subTerms] addObject:[terms objectAtIndex:index+1]];
		}
	} else {
		replacementRange.location = index - 1;
		replacementRange.length = 3;
		NSString * function = DDOperatorNames[[operator operatorPrecedence]];
		replacement = [DDFunctionTerm functionTermWithName:function];
		[[replacement subTerms] addObject:[terms objectAtIndex:index-1]];
		
		//special edge case where the right term of the power operator has 1+ unary operators
		//those should be evaluated before the power, even though unary has lower precedence overall
		
		NSRange rightTermRange = NSMakeRange(index+1, 1);
		DDTerm * rightTerm = [terms objectAtIndex:index+1];
		while ([[rightTerm tokenValue] operatorPrecedence] == DDPrecedenceUnary) {
			rightTermRange.length++;
			//-1 because the end of the range points to the term *after* the unary operator
			rightTerm = [terms objectAtIndex:(rightTermRange.location + rightTermRange.length - 1)];
		}
		if (rightTermRange.length > 1) {
			//the right term has unary operators
			NSArray * unaryExpressionTerms = [terms subarrayWithRange:rightTermRange];
			rightTerm = [DDGroupTerm groupTermWithSubTerms:unaryExpressionTerms];
			//replace the unary expression with the new term (so that replacementRange is still valid)
			[terms replaceObjectsInRange:rightTermRange withObjectsFromArray:[NSArray arrayWithObject:rightTerm]];
		}
		
		[[replacement subTerms] addObject:rightTerm];
	}
	
	if (replacement != nil) {
		[terms replaceObjectsInRange:replacementRange withObjectsFromArray:[NSArray arrayWithObject:replacement]];
	}
}

- (void) resolveWithParser:(DDParser *)parser {
	while ([[self subTerms] count] > 1) {
		/**
		 steps:
		 1. find the indexes of the operators with the highest precedence
		 2. if there are multiple, use [self parser] to determine which one (rightmost or leftmost)
		 3. 
		 **/
		NSIndexSet * indices = [self indicesOfOperatorsWithHighestPrecedence];
		if ([indices count] > 0) {
			NSUInteger index = [indices firstIndex];
			if ([indices count] > 1) {
				//there's more than one. do we use the rightmost or leftmost operator?
				DDOperatorTerm * operatorTerm = [[self subTerms] objectAtIndex:index];
				DDOperatorAssociativity associativity = [parser associativityForOperator:[[operatorTerm tokenValue] operatorType]];
				
				DDPrecedence operatorPrecedence = [operatorTerm operatorPrecedence];
				if (operatorPrecedence == DDPrecedenceUnary) {
					associativity = DDOperatorAssociativityRight;
				}
				if (associativity == DDOperatorAssociativityRight) {
					index = [indices lastIndex];
				}
			}
			
			//we have our operator!
			[self reduceTermsAroundOperatorAtIndex:index];
		} else {
			//there are no more operators
			//but there are 2 terms?
			//BARF!
			[NSException raise:NSGenericException format:@"invalid format: %@", [self subTerms]];
		}
	}
	[[self subTerms] makeObjectsPerformSelector:_cmd withObject:parser];
}

- (NSString *) description {
	NSArray * elementDescriptions = [[self subTerms] valueForKey:@"description"];
	return [NSString stringWithFormat:@"(%@)", [elementDescriptions componentsJoinedByString:@", "]];
}

- (DDExpression *) expression {
	if ([[self subTerms] count] == 0) { return nil; }
	
	return [[[self subTerms] objectAtIndex:0] expression];
}

@end
