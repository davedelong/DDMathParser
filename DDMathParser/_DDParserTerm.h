//
//  _DDParserTerm.h
//  DDMathParser
//
//  Created by Dave DeLong on 7/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DDMathParser.h"

@class DDMathStringToken;
@class DDMathStringTokenizer;
@class DDParser;
@class DDExpression;

typedef NS_ENUM(NSInteger, DDParserTermType) {
    DDParserTermTypeNumber = 1,
    DDParserTermTypeVariable,
    DDParserTermTypeOperator,
    DDParserTermTypeFunction,
    DDParserTermTypeGroup
};

@interface _DDParserTerm : NSObject

@property (nonatomic,getter=isResolved) BOOL resolved;
@property (nonatomic,readonly) DDParserTermType type;
@property (nonatomic,readonly) DDMathStringToken *token;

+ (id)rootTermWithTokenizer:(DDMathStringTokenizer *)tokenizer error:(NSError * __autoreleasing *)error;
+ (id)termWithTokenizer:(DDMathStringTokenizer *)tokenizer error:(NSError * __autoreleasing *)error;
- (id)_initWithTokenizer:(DDMathStringTokenizer *)tokenizer error:(NSError * __autoreleasing *)error;

- (BOOL)resolveWithParser:(DDParser *)parser error:(NSError * __autoreleasing *)error;
- (DDExpression *)expressionWithError:(NSError * __autoreleasing *)error;

@end
