//
//  UnitTestMacros.h
//  DDMathParser
//
//  Created by Dave DeLong on 12/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TEST(_s, _v) { \
    NSNumber *_eval = EVAL(_s); \
    NSNumber *_val = @(_v); \
    XCTAssertEqualObjects(_eval, _val, @"%@ should be equal to %@", (_s), _val); \
}

#define EVAL(_s) ([(_s) numberByEvaluatingString])