//
//  ConstantRecognizer.m
//  DDMathParser
//
//  Created by Dave DeLong on 7/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ConstantRecognizer.h"
#import "DDMathStringToken.h"

@implementation ConstantRecognizer

- (void)didParseToken:(DDMathStringToken *)token {
    static NSSet *functionNames = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        functionNames = [[NSSet alloc] initWithObjects:@"e", @"pi", @"\u03C0", @"phi", @"\u03D5", nil];
    });
    
    DDMathStringToken *previous = [[self tokens] lastObject];
    if (previous != nil && [previous tokenType] == DDTokenTypeFunction) {
        NSString *functionName = [previous token];
        if ([functionNames containsObject:functionName]) {
            if ([token tokenType] != DDTokenTypeOperator || [token operatorType] != DDOperatorParenthesisOpen) {
                // the previous token was a function name and this new token is not an open parenthesis
                DDMathStringToken *open = [DDMathStringToken mathStringTokenWithToken:@"(" type:DDTokenTypeOperator];
                DDMathStringToken *close = [DDMathStringToken mathStringTokenWithToken:@")" type:DDTokenTypeOperator];
                
                [self appendToken:open];
                [self appendToken:close];
            }
        }
    }
}

@end
