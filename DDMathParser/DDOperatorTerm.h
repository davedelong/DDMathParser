//
//  DDOperatorTerm.h
//  DDMathParser
//
//  Created by Dave DeLong on 12/18/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDTerm.h"

@interface DDOperatorTerm : DDTerm {

}

@property (readonly) DDOperator operatorType;
@property (readonly) DDPrecedence operatorPrecedence;
@property (readonly) NSString * operatorFunction;

@end
