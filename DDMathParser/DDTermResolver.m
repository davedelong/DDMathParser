//
//  DDTermResolver.m
//  DDMathParser
//
//  Created by Dave DeLong on 12/3/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "DDTermResolver.h"
#import "DDTerm.h"
#import "DDExpression.h"
#import "DDMathStringToken.h"
#import "DDParser.h"

@interface DDTerm (DDTermResolver)

+ (id) termWithFunctionName:(NSString *)function;

@end

@implementation DDTerm (DDTermResolver)

+ (id) termWithFunctionName:(NSString *)function {
	DDMathStringToken * token = [DDMathStringToken mathStringTokenWithToken:function type:DDTokenTypeFunction];
	return [DDTerm termWithPrecedence:DDPrecedenceParentheses tokenValue:token];
}

@end



@interface DDTermResolver ()

- (DDExpression *) _resolveFunctionTerm;
- (DDExpression *) _resolveGroupedTerm;
- (DDExpression *) _resolveSimpleTerm;

@end


@implementation DDTermResolver
@synthesize term, parser;

- (void) dealloc {
	//parser is "assign"
	[term release];
	[super dealloc];
}

+ (id) resolverForTerm:(DDTerm *)term parser:(DDParser *)parser {
	DDTermResolver * r = [[DDTermResolver alloc] init];
	[r setTerm:term];
	[r setParser:parser];
	return [r autorelease];
}

- (DDTerm *) resolvedTerm {
	(void)[self expressionByResolvingTerm];
	return [self term];
}

- (DDExpression *) expressionByResolvingTerm {
	if (resolved == NO) {
		DDExpression * e = nil;
		if ([term tokenValue] != nil) {
			if ([[term tokenValue] tokenType] == DDTokenTypeFunction) {
				e = [self _resolveFunctionTerm];
			} else {
				e = [self _resolveSimpleTerm];
			}
		} else {
			e = [self _resolveGroupedTerm];
		}
		
		[resolvedExpression release];
		resolvedExpression = [e retain];
		resolved = YES;
	}
	
	return resolvedExpression;
}

- (DDExpression *) _resolveFunctionTerm {
	NSMutableArray * arguments = [NSMutableArray array];
	for (DDTerm * subTerm in [term subTerms]) {
		DDTermResolver * r = [DDTermResolver resolverForTerm:subTerm parser:[self parser]];
		DDExpression * e = [r expressionByResolvingTerm];
		if (e != nil) {
			[arguments addObject:e];
		}
	}
	NSString * function = [[term tokenValue] token];
	return [DDExpression functionExpressionWithFunction:function arguments:arguments];
}

- (DDExpression *) _resolveSimpleTerm {
	DDMathStringToken * t = [term tokenValue];
	
	//this would be encountered if the user enters "()"
	if (t == nil) { return nil; }
	
	if ([t tokenType] == DDTokenTypeVariable) {
		return [DDExpression variableExpressionWithVariable:[t token]];
	}
	if ([t tokenType] == DDTokenTypeNumber) {
		return [DDExpression numberExpressionWithNumber:[t numberValue]];
	}
	[NSException raise:NSGenericException format:@"unknown simple term: %@", term];
	return nil;
}

#pragma mark Group resolution

- (NSIndexSet *) indicesOfOperatorsWithHighestPrecedenceInArray:(NSArray *)a {
	NSMutableIndexSet * indices = [NSMutableIndexSet indexSet];
	DDPrecedence currentPrecedence = DDPrecedenceUnknown;
	for (NSUInteger i = 0; i < [a count]; ++i) {
		DDTerm * thisTerm = [a objectAtIndex:i];
		if ([[thisTerm tokenValue] tokenType] == DDTokenTypeOperator) {
			DDPrecedence thisPrecedence = [thisTerm precedence];
			
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

- (void) reduceTermsInArray:(NSMutableArray *)terms aroundOperatorAtIndex:(NSUInteger)index {
	DDTerm * operator = [terms objectAtIndex:index];
	
	NSRange replacementRange = NSMakeRange(0, 0);
	DDTerm * replacement = nil;
	
	//let's handle the simple stuff first:
	if ([operator precedence] == DDPrecedenceFactorial) {
		replacementRange.location = index - 1;
		replacementRange.length = 2;
		replacement = [DDTerm termWithFunctionName:@"factorial"];
		[[replacement subTerms] addObject:[terms objectAtIndex:index-1]];
	} else if ([operator precedence] == DDPrecedenceUnary) {
		replacementRange.location = index;
		replacementRange.length = 2;
		NSString * function = ([[[operator tokenValue] token] isEqual:@"~"] ? @"not" : @"negate");
		replacement = [DDTerm termWithFunctionName:function];
		[[replacement subTerms] addObject:[terms objectAtIndex:index+1]];
	} else if ([operator precedence] == DDPrecedencePower) {
		replacementRange.location = index - 1;
		replacementRange.length = 3;
		NSString * function = DDOperatorNames[[operator precedence]];
		replacement = [DDTerm termWithFunctionName:function];
		[[replacement subTerms] addObject:[terms objectAtIndex:index-1]];
		
		//special edge case where the right term of the power operator has 1+ unary operators
		//those should be evaluated before the power, even though unary has lower precedence overall
		
		NSRange rightTermRange = NSMakeRange(index+1, 1);
		DDTerm * rightTerm = [terms objectAtIndex:index+1];
		while ([rightTerm precedence] == DDPrecedenceUnary) {
			rightTermRange.length++;
			//-1 because the end of the range points to the term *after* the unary operator
			rightTerm = [terms objectAtIndex:(rightTermRange.location + rightTermRange.length - 1)];
		}
		if (rightTermRange.length > 1) {
			//the right term has unary operators
			NSArray * unaryExpressionTerms = [terms subarrayWithRange:rightTermRange];
			rightTerm = [DDTerm termWithPrecedence:DDPrecedenceParentheses tokenValue:nil];
			[[rightTerm subTerms] addObjectsFromArray:unaryExpressionTerms];
			//replace the unary expression with the new term (so that replacementRange is still valid)
			[terms replaceObjectsInRange:rightTermRange withObjectsFromArray:[NSArray arrayWithObject:rightTerm]];
		}
		
		[[replacement subTerms] addObject:rightTerm];
	} else {
		//this is an operator with lower precedence than unary
		//by the time we get here, all unary operators should've been resolved into function terms
		replacementRange.location = index - 1;
		replacementRange.length = 3; //left term, operator, right term
		NSString * function = DDOperatorNames[[operator precedence]];
		replacement = [DDTerm termWithFunctionName:function];
		[[replacement subTerms] addObject:[terms objectAtIndex:index-1]];
		[[replacement subTerms] addObject:[terms objectAtIndex:index+1]];
	}
	
	if (replacement != nil) {
		[terms replaceObjectsInRange:replacementRange withObjectsFromArray:[NSArray arrayWithObject:replacement]];
	}
}

- (DDExpression *) _resolveGroupedTerm {
	NSMutableArray * subterms = [[term subTerms] mutableCopy];
	
	DDExpression * final = nil;
	if ([subterms count] == 1) {
		[self setTerm:[subterms objectAtIndex:0]];
		final = [self expressionByResolvingTerm];
	} else {
		while ([subterms count] > 1) {
			/**
			 steps:
			 1. find the indexes of the operators with the highest precedence
			 2. if there are multiple, use [self parser] to determine which one (rightmost or leftmost)
			 3. 
			 **/
			NSIndexSet * indices = [self indicesOfOperatorsWithHighestPrecedenceInArray:subterms];
			if ([indices count] > 0) {
				NSUInteger index = [indices firstIndex];
				if ([indices count] > 1) {
					//there's more than one. do we use the rightmost or leftmost operator?
					DDTerm * operatorTerm = [subterms objectAtIndex:index];
					DDOperatorAssociativity associativity = [[self parser] associativityForOperator:[[operatorTerm tokenValue] operatorType]];
					DDPrecedence operatorPrecedence = [operatorTerm precedence];
					if (operatorPrecedence == DDPrecedenceUnary) {
						associativity = DDOperatorAssociativityRight;
					}
					if (associativity == DDOperatorAssociativityRight) {
						index = [indices lastIndex];
					}
				}
				
				//we have our operator!
				[self reduceTermsInArray:subterms aroundOperatorAtIndex:index];
			} else {
				//there are no more operators
				//but there are 2 terms?
				//BARF!
				[NSException raise:NSGenericException format:@"invalid format: %@", subterms];
				return nil;
			}
		}
		
		[self setTerm:[subterms objectAtIndex:0]];
		final = [self expressionByResolvingTerm];
	}
	
	[subterms release];
	return final;
}

@end
