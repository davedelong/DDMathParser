//
//  DDMathParser.h
//  DDMathParser
//
//  Created by Dave DeLong on 11/11/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DDMathStringTokenizer;
@class DDExpression;

typedef enum {
	DDMathParserAssociativityLeft = 0,
	DDMathParserAssociativityRight = 1
} DDMathParserAssociativity;

@interface DDMathParser : NSObject {
	DDMathStringTokenizer * tokenizer;
	NSUInteger currentTokenIndex;
	
	DDMathParserAssociativity bitwiseOrAssociativity;
	DDMathParserAssociativity bitwiseXorAssociativity;
	DDMathParserAssociativity bitwiseAndAssociativity;
	DDMathParserAssociativity bitwiseLeftShiftAssociativity;
	DDMathParserAssociativity bitwiseRightShiftAssociativity;
	DDMathParserAssociativity subtractionAssociativity;
	DDMathParserAssociativity additionAssociativity;
	DDMathParserAssociativity divisionAssociativity;
	DDMathParserAssociativity multiplicationAssociativity;
	DDMathParserAssociativity modAssociativity;
	DDMathParserAssociativity powerAssociativity;
}

@property DDMathParserAssociativity bitwiseOrAssociativity;
@property DDMathParserAssociativity bitwiseXorAssociativity;
@property DDMathParserAssociativity bitwiseAndAssociativity;
@property DDMathParserAssociativity bitwiseLeftShiftAssociativity;
@property DDMathParserAssociativity bitwiseRightShiftAssociativity;
@property DDMathParserAssociativity subtractionAssociativity;
@property DDMathParserAssociativity additionAssociativity;
@property DDMathParserAssociativity divisionAssociativity;
@property DDMathParserAssociativity multiplicationAssociativity;
@property DDMathParserAssociativity modAssociativity;
@property DDMathParserAssociativity powerAssociativity;

+ (id) mathParserWithString:(NSString *)string;
- (id) initWithString:(NSString *)string;

- (DDExpression *) parsedExpression;

@end