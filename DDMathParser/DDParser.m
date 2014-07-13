//
//  DDParser.m
//  DDMathParser
//
//  Created by Dave DeLong on 11/24/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "DDMathParser.h"
#import "DDParser.h"
#import "DDMathParserMacros.h"
#import "_DDParserTerm.h"
#import "DDMathOperatorTypes.h"
#import "DDMathTokenizer.h"
#import "DDMathTokenizer.h"
#import "DDMathStringToken.h"
#import "DDExpression.h"
#import "DDMathOperator.h"
#import "DDMathOperatorSet.h"

@implementation DDParser {
	DDMathTokenizer * _tokenizer;
}

+ (id)parserWithString:(NSString *)string error:(NSError **)error {
    return [[self alloc] initWithString:string error:error];
}

- (id)initWithString:(NSString *)string error:(NSError **)error {
    DDMathTokenizer *t = [[DDMathTokenizer alloc] initWithString:string operatorSet:nil error:error];
    return [self initWithTokenizer:t error:error];
}

+ (id)parserWithTokenizer:(DDMathTokenizer *)tokenizer error:(NSError **)error {
	return [[self alloc] initWithTokenizer:tokenizer error:error];
}

- (id)initWithTokenizer:(DDMathTokenizer *)t error:(NSError **)error {
	ERR_ASSERT(error);
	self = [super init];
	if (self) {
        _operatorSet = t.operatorSet;
		_tokenizer = t;
		if (!_tokenizer) {
			return nil;
		}
	}
	return self;
}

- (DDMathOperatorAssociativity)associativityForOperatorFunction:(NSString *)function {
    DDMathOperator *operator = [_operatorSet operatorForFunction:function];
    return operator.associativity;
}

- (DDExpression *)parsedExpressionWithError:(NSError **)error {
	ERR_ASSERT(error);
	[_tokenizer reset]; //reset the token stream
    
    DDExpression *expression = nil;
    
    _DDParserTerm *root = [_DDParserTerm rootTermWithTokenizer:_tokenizer error:error];
    if ([root resolveWithParser:self error:error]) {
        expression = [root expressionWithError:error];
    }
    
	return expression;
}

@end
