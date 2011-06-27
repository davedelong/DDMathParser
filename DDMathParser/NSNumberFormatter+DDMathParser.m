//
//  NSNumberFormatter+DDMathParser.m
//  DDMathParser
//
//  Created by Dave DeLong on 3/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSNumberFormatter+DDMathParser.h"


@implementation NSNumberFormatter (DDMathParser)

+ (NSNumber *)anyNumberFromString_dd:(NSString *)string {
    static dispatch_once_t onceToken;
    static NSNumberFormatter *formatters[5] = { NULL };
    static int numberOfFormatters = sizeof(formatters)/sizeof(formatters[0]);
    dispatch_once(&onceToken, ^{
        NSLocale *l = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        
        for (int i = 0; i < numberOfFormatters; ++i) {
            formatters[i] = [[NSNumberFormatter alloc] init];
            [formatters[i] setLocale:l];
            [formatters[i] setNumberStyle:i];
        }
        
        [l release];
    });
    
    for (int i = 0; i < numberOfFormatters; ++i) {
        NSNumber *n = [formatters[i] numberFromString:string];
        if (n != nil) { return n; }
    }
    return nil;
}

@end
