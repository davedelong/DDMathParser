//
//  DDTerm.m
//  DDMathParser
//
//  Created by Dave DeLong on 12/2/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "DDTerm.h"
#import "DDMathStringToken.h"
#import "DDExpression.h"

#import "DDGroupTerm.h"
#import "DDFunctionTerm.h"
#import "DDOperatorTerm.h"

@implementation DDTerm
@synthesize tokenValue;

+ (id) termForTokenType:(DDTokenType)tokenType withTokenizer:(DDMathStringTokenizer *)tokenizer {
	switch (tokenType) {
		case DDTokenTypeFunction:
			return [DDFunctionTerm termWithTokenizer:tokenizer];
		case DDTokenTypeOperator:
			if ([[tokenizer peekNextToken] operatorType] == DDOperatorParenthesisOpen) {
				return [DDGroupTerm termWithTokenizer:tokenizer];
			} else {
				return [DDOperatorTerm termWithTokenizer:tokenizer];
			}
		case DDTokenTypeNumber:
		case DDTokenTypeVariable:
		default:
			return [self termWithTokenizer:tokenizer];
	}
}

+ (id) termWithTokenizer:(DDMathStringTokenizer *)tokenizer {
	return [[[self alloc] initWithTokenizer:tokenizer] autorelease];
}

- (id) initWithTokenizer:(DDMathStringTokenizer *)tokenizer {
	self = [super init];
	if (self) {
		DDMathStringToken * token = [tokenizer nextToken];
		[self setTokenValue:token];
	}
	return self;
}

- (void) dealloc {
	[tokenValue release];
	[super dealloc];
}

- (NSString *) description {
	return [tokenValue token];
}

- (void) resolveWithParser:(DDParser *)parser {
	return;
}

- (DDExpression *) expression {
	if ([[self tokenValue] tokenType] == DDTokenTypeNumber) {
		return [DDExpression numberExpressionWithNumber:[[self tokenValue] numberValue]];
	} else if ([[self tokenValue] tokenType] == DDTokenTypeVariable) {
		return [DDExpression variableExpressionWithVariable:[[self tokenValue] token]];
	}
	[NSException raise:NSGenericException format:@"can't convert %@ to expression", self];
	return nil;
}

@end
