//
//  _DDParserTerm.m
//  DDMathParser
//
//  Created by Dave DeLong on 7/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "_DDParserTerm.h"
#import "DDMathStringTokenizer.h"
#import "DDParser.h"

@implementation _DDParserTerm

@synthesize resolved;
@synthesize type;
@synthesize subterms;
@synthesize token;

+ (id)rootTermWithTokenizer:(DDMathStringTokenizer *)tokenizer error:(NSError **)error {
    return nil;
}

+ (id)termWithTokenizer:(DDMathStringTokenizer *)tokenizer error:(NSError **)error {
    return nil;
}

- (BOOL)resolveWithParser:(DDParser *)parser error:(NSError **)error {
    return NO;
}

@end
