//
//  _DDFunctionExpression.h
//  DDMathParser
//
//  Created by Dave DeLong on 11/18/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDExpression_Internal.h"

@interface _DDFunctionExpression : DDExpression {
	NSString * function;
	NSArray * arguments;
}

- (id) initWithFunction:(NSString *)f arguments:(NSArray *)a error:(NSError **)error;

@end
