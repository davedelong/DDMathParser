//
//  _DDNumberTerm.m
//  DDMathParser
//
//  Created by Dave DeLong on 7/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "_DDNumberTerm.h"

@implementation _DDNumberTerm

- (DDParserTermType)type { return DDParserTermTypeNumber; }
- (BOOL)resolveWithParser:(DDParser *)parser error:(NSError **)error {
#pragma unused(parser, error)
    [self setResolved:YES];
    return YES;
}

@end
