//
//  DDParser.h
//  DDMathParser
//
//  Created by Dave DeLong on 11/24/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDParserTypes.h"

@class DDMathStringTokenizer;
@class DDExpression;

@interface DDParser : NSObject {
	DDMathStringTokenizer * tokenizer;
	
	DDOperatorAssociativity bitwiseOrAssociativity;
	DDOperatorAssociativity bitwiseXorAssociativity;
	DDOperatorAssociativity bitwiseAndAssociativity;
	DDOperatorAssociativity bitwiseLeftShiftAssociativity;
	DDOperatorAssociativity bitwiseRightShiftAssociativity;
	DDOperatorAssociativity additionAssociativity;
	DDOperatorAssociativity multiplicationAssociativity;
	DDOperatorAssociativity modAssociativity;
	DDOperatorAssociativity powerAssociativity;
	
}

@property DDOperatorAssociativity bitwiseOrAssociativity;
@property DDOperatorAssociativity bitwiseXorAssociativity;
@property DDOperatorAssociativity bitwiseAndAssociativity;
@property DDOperatorAssociativity bitwiseLeftShiftAssociativity;
@property DDOperatorAssociativity bitwiseRightShiftAssociativity;
@property DDOperatorAssociativity additionAssociativity;
@property DDOperatorAssociativity multiplicationAssociativity;
@property DDOperatorAssociativity modAssociativity;
@property DDOperatorAssociativity powerAssociativity;

+ (id) parserWithString:(NSString *)string;
- (id) initWithString:(NSString *)string;

- (DDExpression *) parsedExpression;
- (DDOperatorAssociativity) associativityForOperator:(DDOperator)operatorType;

@end
