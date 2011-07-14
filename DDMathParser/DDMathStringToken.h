//
//  DDMathStringToken.h
//  DDMathParser
//
//  Created by Dave DeLong on 11/16/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDParserTypes.h"

@interface DDMathStringToken : NSObject {
	NSString *token;
    NSNumber *numberValue;
	DDTokenType tokenType;
	DDOperator operatorType;
	DDPrecedence operatorPrecedence;
}

+ (id) mathStringTokenWithToken:(NSString *)t type:(DDTokenType)type;

@property (nonatomic,readonly) NSString * token;
@property (nonatomic,readonly) DDTokenType tokenType;
@property (nonatomic,readonly) DDOperator operatorType;
@property (nonatomic,readonly) DDOperatorArity operatorArity;
@property (nonatomic) DDPrecedence operatorPrecedence;

- (NSNumber *) numberValue;

@end
