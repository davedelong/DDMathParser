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

- (void) groupParametersStartingAtIndex:(NSUInteger)index error:(NSError **)error;

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
					[self groupParametersStartingAtIndex:groupingIndex++ error:error];
					if (error && *error) {
						[self release];
						return nil;
					}
				} else {
					DDTerm * t = [DDTerm termForTokenType:[peek tokenType] withTokenizer:tokenizer error:error];
					if (error && *error) {
						[self release];
						return nil;
					}
					[[self subTerms] addObject:t];
				}
			}
			
			if (groupingIndex == 0 && [[self subTerms] count] > 0) {
				//we added terms, but never grouped
				[self groupParametersStartingAtIndex:groupingIndex error:error];
				if (error && *error) {
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

- (void) groupParametersStartingAtIndex:(NSUInteger)index error:(NSError **)error {
	if ([[self subTerms] count] == 0) {
		//we hit a comma
		if (error) {
			*error = ERR_EVAL(@"empty function parameter");
		}
		return;
	}
	NSRange groupingRange = NSMakeRange(index, [[self subTerms] count] - index);
	
	if (index >= [[self subTerms] count] || groupingRange.length <= 0) {
		if (error) {
			*error = ERR_EVAL(@"invalid comma placement");
		}
		return;
	}
	
	if (groupingRange.length == 1) {
		//we'd only be grouping one term
		//if it's already a group, then we don't need to do anything
		DDTerm * parameterToGroup = [[self subTerms] objectAtIndex:groupingRange.location];
		if ([parameterToGroup isKindOfClass:[DDGroupTerm class]]) {
			return;
		}
	}
	
	NSArray * sub = [[self subTerms] subarrayWithRange:groupingRange];
	DDTerm * parameterGroup = [DDGroupTerm groupTermWithSubTerms:sub error:error];
	if (error && *error) {
		return;
	}
	[[self subTerms] replaceObjectsInRange:groupingRange withObjectsFromArray:[NSArray arrayWithObject:parameterGroup]];
}

- (NSString *) function {
	return [tokenValue token];
}

- (void) resolveWithParser:(DDParser *)parser error:(NSError **)error {
	for (DDTerm *subTerm in [self subTerms]) {
		[subTerm resolveWithParser:parser error:error];
		if (error && *error) {
			return;
		}
	}
}

- (NSString *) description {
	return [NSString stringWithFormat:@"%@%@", [[self tokenValue] token], [super description]];
}

- (DDExpression *) expressionWithError:(NSError **)error {
	NSMutableArray * parameters = [NSMutableArray array];
	for (DDTerm * param in [self subTerms]) {
		DDExpression * e = [param expressionWithError:error];
		if (error && *error) {
			return nil;
		}
		if (e != nil) {
			[parameters addObject:e];
		}
	}
	return [DDExpression functionExpressionWithFunction:[self function] arguments:parameters error:error];
}

@end
