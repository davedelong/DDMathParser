//
//  DDParser.m
//  DDMathParser
//
//  Created by Dave DeLong on 11/24/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "DDMathParser.h"
#import "DDParser.h"
#import "DDMathParserMacros.h"
#import "DDMathTokenInterpreter.h"
#import "DDMathToken.h"
#import "DDExpression.h"

#import "_DDParserTerm.h"

#import "_DDMathTermResolver.h"

@implementation DDParser {
    DDMathTokenInterpreter *_interpreter;
}

- (instancetype)initWithTokenInterpreter:(DDMathTokenInterpreter *)interpreter {
    NSParameterAssert(interpreter);
    self = [super init];
    if (self) {
        _interpreter = interpreter;
    }
    return self;
}

- (DDExpression *)parsedExpressionWithError:(NSError **)error {
	ERR_ASSERT(error);
    
    _DDGroupTerm *root = [[_DDGroupTerm alloc] init];
    NSMutableArray *currentGroups = [NSMutableArray arrayWithObject:root];
    
    for (DDMathToken *token in _interpreter.tokens) {
        _DDParserTerm *term = [_DDParserTerm termForToken:token];
        
        if (term != nil) {
            [currentGroups.lastObject addSubterm:term];
            
            if ([term isKindOfClass:[_DDGroupTerm class]]) {
                [currentGroups addObject:term];
            }
        } else {
            // nil gets returned to indicate the closure of a group
            [currentGroups removeLastObject];
            
            if (currentGroups.count == 0) {
                *error = ERR(DDErrorCodeImbalancedParentheses, @"imbalanced parentheses");
            }
        }
    }
    
    _DDMathTermResolver *resolver = [[_DDMathTermResolver alloc] initWithTerm:root error:error];
    DDExpression *expression = [resolver expressionWithError:error];
    
    return expression;
}

@end
