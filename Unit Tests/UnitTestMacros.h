//
//  UnitTestMacros.h
//  DDMathParser
//
//  Created by Dave DeLong on 12/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSNumber* _UnitTestNumber(const void* value, const char* type);

#define TEST(_s, _v) { \
NSNumber *_eval = EVAL(_s); \
NSNumber *_val = NUM(_v); \
STAssertEqualObjects(_eval, _val, @"%@ should be equal to %@", (_s), _val); \
}

#define EVAL(_s) ([(_s) numberByEvaluatingString])

#define NUM(_f) ({typeof(_f) _Y_ = (_f); _UnitTestNumber(&_Y_, @encode(typeof(_f)));})