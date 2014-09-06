//
//  _DDOperatorInfo.h
//  DDMathParser
//
//  Created by Dave DeLong on 10/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDMathParser.h"
#import "DDMathOperatorTypes.h"

#define OPERATOR(_func, _toks, _arity, _prec, _assoc) [[DDMathOperator alloc] initWithOperatorFunction:(_func) tokens:(_toks) arity:(_arity) precedence:(_prec) associativity:(_assoc)]

@interface DDMathOperator : NSObject <NSCopying>

+ (NSArray *)defaultOperators;

+ (instancetype)moduloOperator;
+ (instancetype)percentOperator;

+ (DDMathOperatorAssociativity)associativityForPowerExpressions;

// the only reason you'd want to init a new \c MathOperator is so you can pass it to the -[DDMathOperatorSet addOperator:...] methods
- (id)initWithOperatorFunction:(NSString *)function
                        tokens:(NSArray *)tokens
                         arity:(DDMathOperatorArity)arity
                    precedence:(NSInteger)precedence
                 associativity:(DDMathOperatorAssociativity)associativity;

@property (nonatomic, readonly, strong) NSString *function;
@property (nonatomic, readonly, strong) NSArray *tokens;
@property (nonatomic, readonly) DDMathOperatorArity arity;
@property (nonatomic, readonly) NSInteger precedence;
@property (nonatomic, readonly) DDMathOperatorAssociativity associativity;

@end
