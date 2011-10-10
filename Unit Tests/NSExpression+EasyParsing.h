//
//  NSExpression+EasyParsing.h
//  DDMathParser
//
//  Created by Dave DeLong on 11/18/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSExpression (EasyParsing)

+ (NSExpression *) expressionWithString:(NSString *)string;

@end
