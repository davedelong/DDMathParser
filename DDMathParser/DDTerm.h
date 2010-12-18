//
//  DDTerm.h
//  DDMathParser
//
//  Created by Dave DeLong on 12/2/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDParserTypes.h"
#import "DDMathStringTokenizer.h"
#import "DDMathStringToken.h"
#import "DDParser.h"
#import "DDExpression.h"

@interface DDTerm : NSObject {
	BOOL resolved;
	DDMathStringToken * tokenValue;
}

@property (retain) DDMathStringToken * tokenValue;

+ (id) termForTokenType:(DDTokenType)tokenType withTokenizer:(DDMathStringTokenizer *)tokenizer;

+ (id) termWithTokenizer:(DDMathStringTokenizer *)tokenizer;
- (id) initWithTokenizer:(DDMathStringTokenizer *)tokenizer;

- (void) resolveWithParser:(DDParser *)parser;

- (DDExpression *) expression;

@end
