//
//  _DDGroupTerm.m
//  DDMathParser
//
//  Created by Dave DeLong on 7/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "_DDGroupTerm.h"

@implementation _DDGroupTerm
@synthesize subterms;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc {
    [subterms release];
    [super dealloc];
}

@end
