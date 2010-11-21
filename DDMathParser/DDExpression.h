//
//  DDExpression.h
//  DDMathParser
//
//  Created by Dave DeLong on 11/16/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	DDExpressionTypeNumber = 0,
	DDExpressionTypeFunction = 1,
	DDExpressionTypeVariable = 2
} DDExpressionType;

@class DDMathEvaluator;

@interface DDExpression : NSObject {

}

+ (id) expressionFromString:(NSString *)expressionString;
+ (id) numberExpressionWithNumber:(NSNumber *)number;
+ (id) functionExpressionWithFunction:(NSString *)function arguments:(NSArray *)arguments;
+ (id) variableExpressionWithVariable:(NSString *)variable;

- (DDExpressionType) expressionType;

- (NSNumber *) evaluateWithSubstitutions:(NSDictionary *)substitutions evaluator:(DDMathEvaluator *)evaluator;

- (NSExpression *) expressionValue;
- (NSExpression *) expressionValueForEvaluator:(DDMathEvaluator *)evaluator;

- (DDExpression *) simplifiedExpression;
- (DDExpression *) simplifiedExpressionWithEvaluator:(DDMathEvaluator *)evaluator;

#pragma mark Number methods
- (NSNumber *) number;

#pragma mark Function methods
- (NSString *) function;
//returns an array of DDExpression objects
- (NSArray *) arguments;

#pragma mark Variable
- (NSString *) variable;

@end
