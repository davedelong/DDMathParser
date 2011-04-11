//
//  DDTerm.m
//  DDMathParser
//
//  Created by Dave DeLong on 12/2/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "DDTerm.h"
#import "DDMathStringToken.h"
#import "DDMathParserMacros.h"
#import "DDExpression.h"

#import "DDGroupTerm.h"
#import "DDFunctionTerm.h"
#import "DDOperatorTerm.h"

@implementation DDTerm
@synthesize tokenValue;

+ (id) termForTokenType:(DDTokenType)tokenType withTokenizer:(DDMathStringTokenizer *)tokenizer error:(NSError **)error {
	switch (tokenType) {
		case DDTokenTypeFunction:
			return [DDFunctionTerm termWithTokenizer:tokenizer error:error];
		case DDTokenTypeOperator:
			if ([[tokenizer peekNextToken] operatorType] == DDOperatorParenthesisOpen) {
				return [DDGroupTerm termWithTokenizer:tokenizer error:error];
			} else {
				return [DDOperatorTerm termWithTokenizer:tokenizer error:error];
			}
		case DDTokenTypeNumber:
		case DDTokenTypeVariable:
		default:
			return [self termWithTokenizer:tokenizer error:error];
	}
}

+ (id) termWithTokenizer:(DDMathStringTokenizer *)tokenizer error:(NSError **)error {
	return [[[self alloc] initWithTokenizer:tokenizer error:error] autorelease];
}

- (id) initWithTokenizer:(DDMathStringTokenizer *)tokenizer error:(NSError **)error {
	self = [super init];
	if (self) {
		DDMathStringToken * token = [tokenizer nextToken];
		if (tokenizer != nil && token == nil) {
			if (error) {
				*error = ERR_BADARG(@"unable to create term with nil token");
			}
			[self release];
			return nil;
		}
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

- (BOOL) resolveWithParser:(DDParser *)parser error:(NSError **)error {
#pragma unused(parser, error)
	return YES;
}

- (DDExpression *) expressionWithError:(NSError **)error {
	if ([[self tokenValue] tokenType] == DDTokenTypeNumber) {
		return [DDExpression numberExpressionWithNumber:[[self tokenValue] numberValue]];
	} else if ([[self tokenValue] tokenType] == DDTokenTypeVariable) {
		return [DDExpression variableExpressionWithVariable:[[self tokenValue] token]];
	}
	if (error) {
		*error = ERR_GENERIC(@"can't convert %@ to expression", self);
	}
	return nil;
}

@end
