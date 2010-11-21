//
//  DDMath.h
//  DDMathParser
//
//  Created by Dave DeLong on 11/18/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DDExpression;
@class DDMathEvaluator;

typedef DDExpression* (^DDMathFunction)(NSArray *, NSDictionary *, DDMathEvaluator *);

enum { DDMathFunctionUnlimitedArguments = -1 };