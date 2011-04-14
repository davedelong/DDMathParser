//
//  DDFunctionTerm.m
//  DDMathParser
//
//  Created by Dave DeLong on 12/18/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "DDFunctionTerm.h"
#import "DDGroupTerm.h"
#import "DDMathParserMacros.h"

@interface DDFunctionTerm ()

- (BOOL) groupParametersStartingAtIndex:(NSUInteger)index error:(NSError **)error;

@end


@implementation DDFunctionTerm

- (id) initWithTokenizer:(DDMathStringTokenizer *)tokenizer error:(NSError **)error {
	self = [super initWithTokenizer:tokenizer error:error];
	if (self) {
		if (tokenizer != nil) {
			DDMathStringToken * token = [tokenizer peekNextToken];
			if ([token operatorType] != DDOperatorParenthesisOpen) {
				if (error) {
					*error = ERR_BADARG(@"function not followed by an open parenthesis");
				}
				[self release];
				return nil;
			}
			[tokenizer nextToken]; //consume the opening parenthesis
			
			NSUInteger groupingIndex = 0;
			while ([tokenizer peekNextToken] != nil && [[tokenizer peekNextToken] operatorType] != DDOperatorParenthesisClose) {
				DDMathStringToken * peek = [tokenizer peekNextToken];
				if ([peek operatorType] == DDOperatorComma) {
					[tokenizer nextToken]; //consume the comma
					if (![self groupParametersStartingAtIndex:groupingIndex++ error:error]) {
						[self release];
						return nil;
					}
				} else {
					DDTerm * t = [DDTerm termForTokenType:[peek tokenType] withTokenizer:tokenizer error:error];
					if (!t) {
						[self release];
						return nil;
					}
					[[self subTerms] addObject:t];
				}
			}
			
			while (groupingIndex < [[self subTerms] count]) {
				//make sure everything gets grouped properly
				if (![self groupParametersStartingAtIndex:groupingIndex++ error:error]) {
					[self release];
					return nil;
				}
			}
			
			token = [tokenizer nextToken];
			if ([token operatorType] != DDOperatorParenthesisClose) {
				if (error) {
					*error = ERR_BADARG(@"function does not have a close parenthesis");
				}
				[self release];
				return nil;
			}
		}
	}
	return self;
}

- (BOOL) groupParametersStartingAtIndex:(NSUInteger)index error:(NSError **)error {
	if ([[self subTerms] count] == 0) {
		//we hit a comma
		if (error) {
			*error = ERR_GENERIC(@"empty function parameter");
		}
		return NO;
	}
	NSRange groupingRange = NSMakeRange(index, [[self subTerms] count] - index);
	
	if (index >= [[self subTerms] count] || groupingRange.length <= 0) {
		if (error) {
			*error = ERR_GENERIC(@"invalid comma placement");
		}
		return NO;
	}
	
	if (groupingRange.length == 1) {
		//we'd only be grouping one term
		//if it's already a group, then we don't need to do anything
		DDTerm * parameterToGroup = [[self subTerms] objectAtIndex:groupingRange.location];
		if ([parameterToGroup isKindOfClass:[DDGroupTerm class]]) {
			return YES;
		}
	}
	
	NSArray * sub = [[self subTerms] subarrayWithRange:groupingRange];
	DDTerm * parameterGroup = [DDGroupTerm groupTermWithSubTerms:sub error:error];
	if (!parameterGroup) {
		return NO;
	}
	[[self subTerms] replaceObjectsInRange:groupingRange withObjectsFromArray:[NSArray arrayWithObject:parameterGroup]];
	return YES;
}

- (NSString *) function {
	return [tokenValue token];
}

- (BOOL) resolveWithParser:(DDParser *)parser error:(NSError **)error {
	for (DDTerm *subTerm in [self subTerms]) {
		if (![subTerm resolveWithParser:parser error:error]) {
			return NO;
		}
	}
	return YES;
}

- (NSString *) description {
	return [NSString stringWithFormat:@"%@%@", [[self tokenValue] token], [super description]];
}

- (DDExpression *) expressionWithError:(NSError **)error {
	NSMutableArray * parameters = [NSMutableArray array];
	for (DDTerm * param in [self subTerms]) {
		DDExpression * e = [param expressionWithError:error];
		if (!e) {
			return nil;
		}
        [parameters addObject:e];
	}
	return [DDExpression functionExpressionWithFunction:[self function] arguments:parameters error:error];
}

@end
