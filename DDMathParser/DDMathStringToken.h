//
//  DDMathStringToken.h
//  DDMathParser
//
//  Created by Dave DeLong on 11/16/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDParserTypes.h"

@class _DDOperatorInfo;

@interface DDMathStringToken : NSObject {
	NSString *token;
    NSNumber *numberValue;
	DDTokenType tokenType;
    _DDOperatorInfo *operatorInfo;
    BOOL ambiguous;
}

+ (id) mathStringTokenWithToken:(NSString *)t type:(DDTokenType)type;

@property (nonatomic,readonly) NSString * token;
@property (nonatomic,readonly) DDTokenType tokenType;
@property (nonatomic,readonly) DDOperator operatorType;
@property (nonatomic,readonly) DDOperatorArity operatorArity;
@property (nonatomic,readonly) DDOperatorAssociativity operatorAssociativity;
@property (nonatomic,readonly) NSInteger operatorPrecedence;
@property (nonatomic,readonly) NSString *operatorFunction;

- (NSNumber *) numberValue;

- (void)resolveToOperator:(DDOperator)operator;

@end
