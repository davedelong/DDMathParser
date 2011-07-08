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

typedef DDExpression* (^DDMathFunction)(NSArray *, NSDictionary *, DDMathEvaluator *, NSError **);

#pragma mark Error Codes

extern NSString * const DDMathParserErrorDomain;

enum {
    DDErrorCodeGeneric = -1,
    DDErrorCodeInvalidArgument = 1,
};

typedef NSInteger DDErrorCode;