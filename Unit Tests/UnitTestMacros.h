//
//  UnitTestMacros.h
//  DDMathParser
//
//  Created by Dave DeLong on 12/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSNumber* _UnitTestNumber(const void* value, const char* type);

#define TEST(_s, _v) STAssertEqualObjects(EVAL(_s), NUM(_v), @"")

#define EVAL(_s) [(_s) numberByEvaluatingString]

#define NUM(_f) ({typeof(_f) _Y_ = (_f); _UnitTestNumber(&_Y_, @encode(typeof(_f)));})