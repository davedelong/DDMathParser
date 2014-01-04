//
//  NSExpression+EasyParsing.m
//  DDMathParser
//
//  Created by Dave DeLong on 11/18/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "NSExpression+EasyParsing.h"


@implementation NSExpression (EasyParsing)

+ (NSExpression *)expressionWithString:(NSString *)string {
	NSString * format = [NSString stringWithFormat:@"%@ = 0", string];
	NSComparisonPredicate * p = (NSComparisonPredicate *)[NSPredicate predicateWithFormat:format];
	return [p leftExpression];
}

@end
