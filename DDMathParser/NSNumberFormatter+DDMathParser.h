//
//  NSNumberFormatter+DDMathParser.h
//  DDMathParser
//
//  Created by Dave DeLong on 3/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSNumberFormatter (DDMathParser)

+ (id) numberFormatter_dd;

- (NSNumber *) anyNumberFromString_dd:(NSString *)string;

@end
