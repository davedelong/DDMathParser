//
//  DDMathToken.h
//  DDMathParser
//
//  Created by Dave DeLong on 11/16/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDMathOperatorTypes.h"

typedef NS_ENUM(NSInteger, DDTokenType) {
	DDTokenTypeNumber = 0,
	DDTokenTypeOperator = 1,
	DDTokenTypeFunction = 2,
	DDTokenTypeVariable = 3
};

@class DDMathOperator;

@interface DDMathToken : NSObject

- (id)initWithToken:(NSString *)t type:(DDTokenType)type operator:(DDMathOperator *)op;

@property (readonly, getter = isAmbiguous) BOOL ambiguous;
@property (nonatomic, readonly) NSString *token;
@property (nonatomic, readonly) DDTokenType tokenType;

@property (nonatomic, strong) DDMathOperator *mathOperator;
@property (nonatomic, readonly) NSNumber *numberValue;

@end
