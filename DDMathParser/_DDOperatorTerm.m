//
//  _DDOperatorTerm.m
//  DDMathParser
//
//  Created by Dave DeLong on 7/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "_DDOperatorTerm.h"
#import "DDMathStringToken.h"

@implementation _DDOperatorTerm

- (DDParserTermType)type { return DDParserTermTypeOperator; }

- (DDOperator)operatorType {
    return [[self token] operatorType];
}

- (DDPrecedence)operatorPrecedence {
    return [[self token] operatorPrecedence];
}

@end
