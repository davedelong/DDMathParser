//
//  _DDOperatorInfo.h
//  DDMathParser
//
//  Created by Dave DeLong on 10/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDMathParser.h"

@interface _DDOperatorInfo : NSObject

@property (nonatomic, readonly, DD_STRONG) NSString *function;
@property (nonatomic, readonly, DD_STRONG) NSString *token;
@property (nonatomic, readonly) DDOperatorArity arity;
@property (nonatomic, assign) DDOperatorAssociativity defaultAssociativity;
@property (nonatomic, readonly) NSInteger precedence;

+ (NSArray *)allOperators;
+ (NSArray *)infosForOperatorFunction:(NSString *)operator;
+ (NSArray *)infosForOperatorToken:(NSString *)token;

@end
