//
//  DDFunctionTerm.m
//  DDMathParser
//
//  Created by Dave DeLong on 12/18/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "DDFunctionTerm.h"
#import "DDGroupTerm.h"

@interface DDFunctionTerm ()

- (void) groupParametersStartingAtIndex:(NSUInteger)index;

@end


@implementation DDFunctionTerm

- (id) initWithTokenizer:(DDMathStringTokenizer *)tokenizer {
	self = [super initWithTokenizer:tokenizer];
	if (self) {
		if (tokenizer != nil) {
			DDMathStringToken * token = [tokenizer peekNextToken];
			if ([token operatorType] != DDOperatorParenthesisOpen) {
				[NSException raise:NSGenericException format:@"function not followed by an open parenthesis"];
			}
			[tokenizer nextToken]; //consume the opening parenthesis
			
			NSUInteger groupingIndex = 0;
			while ([tokenizer peekNextToken] != nil && [[tokenizer peekNextToken] operatorType] != DDOperatorParenthesisClose) {
				DDMathStringToken * peek = [tokenizer peekNextToken];
				if ([peek operatorType] == DDOperatorComma) {
					[tokenizer nextToken]; //consume the comma
					[self groupParametersStartingAtIndex:groupingIndex++];
				} else {
					DDTerm * t = [DDTerm termForTokenType:[peek tokenType] withTokenizer:tokenizer];
					[[self subTerms] addObject:t];
				}
			}
			
			if (groupingIndex == 0 && [[self subTerms] count] > 0) {
				//we added terms, but never grouped
				[self groupParametersStartingAtIndex:groupingIndex];
			}
			
			token = [tokenizer nextToken];
			if ([token operatorType] != DDOperatorParenthesisClose) {
				[NSException raise:NSGenericException format:@"function does not have a close parenthesis"];
			}
		}
	}
	return self;
}

- (void) groupParametersStartingAtIndex:(NSUInteger)index {
	if ([[self subTerms] count] == 0) {
		//we hit a comma
		[NSException raise:NSGenericException format:@"empty function parameter"];
	}
	NSRange groupingRange = NSMakeRange(index, [[self subTerms] count] - index);
	
	if (index >= [[self subTerms] count] || groupingRange.length <= 0) {
		[NSException raise:NSGenericException format:@"invalid comma placement"];
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
	DDTerm * parameterGroup = [DDGroupTerm groupTermWithSubTerms:sub];
	[[self subTerms] replaceObjectsInRange:groupingRange withObjectsFromArray:[NSArray arrayWithObject:parameterGroup]];
}

- (NSString *) function {
	return [tokenValue token];
}

- (void) resolveWithParser:(DDParser *)parser {
	[[self subTerms] makeObjectsPerformSelector:_cmd withObject:parser];
}

- (NSString *) description {
	return [NSString stringWithFormat:@"%@%@", [[self tokenValue] token], [super description]];
}

- (DDExpression *) expression {
	NSMutableArray * parameters = [NSMutableArray array];
	for (DDTerm * param in [self subTerms]) {
		DDExpression * e = [param expression];
		if (e != nil) {
			[parameters addObject:e];
		}
	}
	return [DDExpression functionExpressionWithFunction:[self function] arguments:parameters];
}

@end
