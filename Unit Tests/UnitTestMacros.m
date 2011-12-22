//
//  UnitTestMacros.m
//  DDMathParser
//
//  Created by Dave DeLong on 12/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "UnitTestMacros.h"

#define NUM_TYPE(_t, _m) { \
if (strcmp(type, @encode(_t)) == 0) { \
return [NSNumber numberWith ## _m:*(_t *)value]; \
} \
}

NSNumber* _UnitTestNumber(const void* value, const char* type) {
    NUM_TYPE(char, Char);
    NUM_TYPE(unsigned char, UnsignedChar);
    NUM_TYPE(short, Short);
    NUM_TYPE(unsigned short, UnsignedShort);
    NUM_TYPE(int, Int)
    NUM_TYPE(unsigned int, UnsignedInt);
    NUM_TYPE(long, Long);
    NUM_TYPE(unsigned long, UnsignedLong);
    NUM_TYPE(long long, LongLong);
    NUM_TYPE(unsigned long long, UnsignedLongLong);
    NUM_TYPE(float, Float);
    NUM_TYPE(double, Double);
    NUM_TYPE(BOOL, Bool);
    NUM_TYPE(NSInteger, Integer);
    NUM_TYPE(NSUInteger, UnsignedInteger);
    return nil;
}
