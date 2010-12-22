//
//  DDMathEvaluator+Private.h
//  DDMathParser
//
//  Created by Dave DeLong on 11/17/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDMathEvaluator.h"
#import "_DDFunctionExpression.h"

@interface DDMathEvaluator ()

- (DDMathFunction) functionWithName:(NSString *)functionName;

- (NSNumber *) evaluateFunction:(DDExpression *)function withSubstitutions:(NSDictionary *)variables;
- (NSString *) nsexpressionFunctionWithName:(NSString *)functionName;

- (void) functionExpressionFailedToResolve:(_DDFunctionExpression *)functionExpression;

@end
