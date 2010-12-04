//
//  NSExpression+DDMathParsing.h
//  DDMathParser
//
//  Created by Dave DeLong on 11/23/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DDExpression;

@interface NSExpression (DDMathParsing)

- (DDExpression *) ddexpressionValue;

@end
