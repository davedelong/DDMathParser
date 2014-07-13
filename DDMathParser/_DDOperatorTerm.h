//
//  _DDOperatorTerm.h
//  DDMathParser
//
//  Created by Dave DeLong on 7/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "_DDParserTerm.h"

@class DDMathOperator;

@interface _DDOperatorTerm : _DDParserTerm

@property (nonatomic, readonly) DDMathOperator *mathOperator;

@end
