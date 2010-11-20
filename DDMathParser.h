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

@interface DDMathParser : NSObject {
	DDMathStringTokenizer * tokenizer;
	NSUInteger currentTokenIndex;
}

+ (id) mathParserWithString:(NSString *)string;
- (id) initWithString:(NSString *)string;

- (DDExpression *) parsedExpression;

@end