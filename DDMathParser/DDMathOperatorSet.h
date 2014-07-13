//
//  DDMathOperatorSet.h
//  DDMathParser
//
//  Created by Dave DeLong on 7/13/14.
//
//

#import <Foundation/Foundation.h>
#import "DDMathOperatorTypes.h"

@class DDMathOperator;

/*!
 * Maintains a collection of \c DDMathOperators.
 * Modifications to an Operator Set are not thread-safe.
 */
@interface DDMathOperatorSet : NSObject <NSFastEnumeration, NSCopying>

@property (readonly, copy) NSArray *operators;
@property (nonatomic) BOOL interpretsPercentSignAsModulo; // default is YES

+ (instancetype)defaultOperatorSet;

- (instancetype)init;

- (DDMathOperator *)operatorForFunction:(NSString *)function;
- (NSArray *)operatorsForToken:(NSString *)token;
- (DDMathOperator *)operatorForToken:(NSString *)token arity:(DDOperatorArity)arity;
- (DDMathOperator *)operatorForToken:(NSString *)token arity:(DDOperatorArity)arity associativity:(DDOperatorAssociativity)associativity;

- (void)addOperator:(DDMathOperator *)newOperator withPrecedenceSameAsOperator:(DDMathOperator *)existingOperator;
- (void)addOperator:(DDMathOperator *)newOperator withPrecedenceLowerThanOperator:(DDMathOperator *)existingOperator;
- (void)addOperator:(DDMathOperator *)newOperator withPrecedenceHigherThanOperator:(DDMathOperator *)existingOperator;

- (void)addTokens:(NSArray *)newTokens forOperatorFunction:(NSString *)operatorFunction;

@end
