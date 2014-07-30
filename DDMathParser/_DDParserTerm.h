//
//  _DDParserTerm.h
//  DDMathParser
//
//  Created by Dave DeLong on 7/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DDMathParser.h"

@class DDMathToken;

typedef NS_ENUM(NSInteger, DDParserTermType) {
    DDParserTermTypeNumber = 1,
    DDParserTermTypeVariable,
    DDParserTermTypeOperator,
    DDParserTermTypeFunction,
    DDParserTermTypeGroup
};

@interface _DDParserTerm : NSObject

+ (instancetype)termForToken:(DDMathToken *)token;
- (instancetype)initWithToken:(DDMathToken *)token;

@property (nonatomic,readonly) DDParserTermType type;
@property (nonatomic,readonly,strong) DDMathToken *token;
@property (nonatomic,getter=isResolved) BOOL resolved;
@property (nonatomic, readonly) DDMathOperator *mathOperator;

@end


@interface _DDGroupTerm : _DDParserTerm

@property (nonatomic, copy) NSArray *subterms;
- (void)addSubterm:(_DDParserTerm *)term;
- (void)replaceTermsInRange:(NSRange)range withTerm:(_DDParserTerm *)replacement;

@end


@interface _DDFunctionTerm : _DDGroupTerm

@property (nonatomic,readonly,strong) NSString *functionName;

@end


@interface _DDNumberTerm : _DDParserTerm

@end


@interface _DDVariableTerm : _DDParserTerm

@end


@interface _DDOperatorTerm : _DDParserTerm

@end