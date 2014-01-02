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
@property (nonatomic, readonly) DDOperatorAssociativity associativity;

+ (NSArray *)allOperators;
+ (instancetype)infoForOperatorFunction:(NSString *)function;
+ (NSArray *)infosForOperatorToken:(NSString *)token;

// the only reason you'd want to init a new Operator is so you can pass it to the +addOperator:... methods
- (id)initWithOperatorFunction:(NSString *)function tokens:(NSArray *)tokens arity:(DDOperatorArity)arity associativity:(DDOperatorAssociativity)associativity;


// modifying operators is not a threadsafe operation
// if you want to do this, you should do it before any evaluation occurs

+ (void)addTokens:(NSArray *)tokens forOperatorFunction:(NSString *)operatorFunction;

+ (void)addOperator:(DDMathOperator *)newOperator withSamePrecedenceAsOperator:(DDMathOperator *)existingOperator;
+ (void)addOperator:(DDMathOperator *)newOperator withLowerPrecedenceThanOperator:(DDMathOperator *)existingOperator;
+ (void)addOperator:(DDMathOperator *)newOperator withHigherPrecedenceThanOperator:(DDMathOperator *)existingOperator;

@end
