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

- (NSString *)operatorType {
    return [[self token] operatorType];
}

- (NSInteger)operatorPrecedence {
    return [[self token] operatorPrecedence];
}

- (DDOperatorArity)operatorArity {
    return [[self token] operatorArity];
}

- (NSString *)operatorFunction {
    return [[self token] operatorFunction];
}

- (NSString *)description {
    return [[self token] token];
}

@end
