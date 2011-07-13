//
//  _DDGroupTerm.m
//  DDMathParser
//
//  Created by Dave DeLong on 7/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "_DDGroupTerm.h"
#import "DDMathStringTokenizer.h"
#import "DDMathStringToken.h"
#import "DDMathParserMacros.h"

@implementation _DDGroupTerm
@synthesize subterms;

- (void)_setSubterms:(NSArray *)newTerms {
    [subterms release];
    subterms = [newTerms mutableCopy];
}

- (id)_initWithSubterms:(NSArray *)terms error:(NSError **)error {
#pragma unused(error)
    self = [super init];
    if (self) {
        [self _setSubterms:terms];
    }
    return self;
}

- (id)_initWithTokenizer:(DDMathStringTokenizer *)tokenizer error:(NSError **)error {
    self = [super _initWithTokenizer:tokenizer error:error];
    if (self) {
        NSMutableArray *terms = [NSMutableArray array];
        DDMathStringToken *nextToken = [tokenizer peekNextToken];
        while (nextToken && [nextToken operatorType] != DDOperatorParenthesisClose) {
            _DDParserTerm *nextTerm = [_DDParserTerm termWithTokenizer:tokenizer error:error];
            if (nextTerm) {
                [terms addObject:nextTerm];
            } else {
                // extracting a term failed.  *error should've been filled already
                [self release];
                return nil;
            }
            nextToken = [tokenizer peekNextToken];
        }
        
        // consume the closing parenthesis and verify it exists
        if ([tokenizer nextToken] == nil) {
            *error = ERR_BADARG(@"imbalanced parentheses");
            [self release];
            return nil;
        }
        
        [self _setSubterms:terms];
    }
    return self;
}

- (void)dealloc {
    [subterms release];
    [super dealloc];
}

- (DDParserTermType)type { return DDParserTermTypeGroup; }

@end
