//
//  _DDOperatorInfo.h
//  DDMathParser
//
//  Created by Dave DeLong on 10/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDMathParser.h"

@interface DDMathOperator : NSObject

@property (nonatomic, readonly, strong) NSString *function;
@property (nonatomic, readonly, strong) NSArray *tokens;
@property (nonatomic, readonly) DDOperatorArity arity;
@property (nonatomic, assign) DDOperatorAssociativity defaultAssociativity;
@property (nonatomic, readonly) NSInteger precedence;

+ (NSArray *)allOperators;
+ (instancetype)infoForOperatorFunction:(NSString *)operator;
+ (NSArray *)infosForOperatorToken:(NSString *)token;

@end
