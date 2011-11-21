//
//  _DDOperatorTerm.m
//  DDMathParser
//
//  Created by Dave DeLong on 7/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "_DDOperatorTerm.h"
#import "DDMathStringToken.h"
#import "DDMathParserMacros.h"

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

- (BOOL)resolveWithParser:(DDParser *)parser error:(NSError *__autoreleasing *)error {
#pragma unused(parser)
    ERR_ASSERT(error);
    *error = ERR(DDErrorCodeOperatorMissingOperands, @"missing operand(s) for operator: %@", [self token]);
    return NO;
}

- (NSString *)description {
    return [[self token] token];
}

@end
