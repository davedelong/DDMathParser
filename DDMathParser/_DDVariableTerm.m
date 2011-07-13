//
//  _DDVariableTerm.m
//  DDMathParser
//
//  Created by Dave DeLong on 7/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "_DDVariableTerm.h"

@implementation _DDVariableTerm

- (DDParserTermType)type { return DDParserTermTypeVariable; }
- (BOOL)resolveWithParser:(DDParser *)parser error:(NSError **)error {
#pragma unused(parser, error)
    [self setResolved:YES];
    return YES;
}

@end
