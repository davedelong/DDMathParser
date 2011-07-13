//
//  _DDFunctionTerm.m
//  DDMathParser
//
//  Created by Dave DeLong on 7/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "_DDFunctionTerm.h"
#import "DDMathStringToken.h"
#import "DDMathStringTokenizer.h"
#import "DDMathParserMacros.h"
#import "_DDOperatorTerm.h"

@implementation _DDFunctionTerm
@synthesize functionName;

- (id)_initWithTokenizer:(DDMathStringTokenizer *)tokenizer error:(NSError **)error {
    DDMathStringToken *token = [tokenizer nextToken];
    
    self = [super _initWithTokenizer:tokenizer error:error];
    if (self) {
        functionName = [[token token] copy];
        
        // process the subterms to group them up by commas
        NSMutableArray *newSubterms = [NSMutableArray array];
        NSRange subrange = NSMakeRange(0, 0);
        for (_DDParserTerm *term in [self subterms]) {
            if ([term type] == DDParserTermTypeOperator && [(_DDOperatorTerm *)term operatorType] == DDOperatorComma) {
                NSArray *parameterGroupTerms = [[self subterms] subarrayWithRange:subrange];
                
                NSError *error = nil;
                _DDGroupTerm *parameterGroup = [[_DDGroupTerm alloc] _initWithSubterms:parameterGroupTerms error:&error];
                if (parameterGroup) {
                    [newSubterms addObject:parameterGroup];
                }
                [parameterGroup release];
                subrange.location = NSMaxRange(subrange)+1;
                subrange.length = 0;
            } else {
                subrange.length++;
            }
        }
        [self _setSubterms:newSubterms];
    }
    return self;
}

- (void)dealloc {
    [functionName release];
    [super dealloc];
}
- (DDParserTermType)type { return DDParserTermTypeFunction; }

@end
