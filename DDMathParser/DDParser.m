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
#import "DDEnumerator.h"
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

- (_DDGroupTerm *)_groupTermWithEnumerator:(DDEnumerator *)enumerator error:(NSError **)error {
    // by the time we enter here, we've already consumed the opening parentheses
    _DDGroupTerm *group = [[_DDGroupTerm alloc] init];
    
    DDMathToken *nextToken = enumerator.peekNextObject;
    while (nextToken && nextToken.mathOperator.function != DDMathOperatorParenthesisClose) {
        _DDParserTerm *nextTerm = [self _termWithEnumerator:enumerator error:error];
        if (nextTerm) {
            [group addSubterm:nextTerm];
        } else {
            // extracting a term failed.  *error should've been filled already
            return nil;
        }
        nextToken = enumerator.peekNextObject;
    }
    
    // consume the closing parenthesis and verify it exists
    if (enumerator.nextObject == nil) {
        if (error) {
            *error = DD_ERR(DDErrorCodeImbalancedParentheses, @"imbalanced parentheses");
        }
        return nil;
    }
    
    return group;
}

- (_DDFunctionTerm *)_functionTermWithFunction:(DDMathToken *)functionToken enumerator:(DDEnumerator *)enumerator error:(NSError **)error {
    _DDFunctionTerm *function = [[_DDFunctionTerm alloc] initWithToken:functionToken];
    
    DDMathToken *openParen = enumerator.nextObject;
    if (openParen.mathOperator.function != DDMathOperatorParenthesisOpen) {
        if (error) {
            *error = DD_ERR(DDErrorCodeImbalancedParentheses, @"missing opening parenthesis after function \"%@\"", function.functionName);
        }
        return nil;
    }
    
    _DDGroupTerm *currentParameterGroup = nil;
    
    
    DDMathToken *nextToken = enumerator.peekNextObject;
    while (nextToken && nextToken.mathOperator.function != DDMathOperatorParenthesisClose) {
        _DDParserTerm *nextTerm = [self _termWithEnumerator:enumerator error:error];
        if (nextTerm) {
            if (nextTerm.mathOperator.function == DDMathOperatorComma) {
                // we're ending the current group
                if (currentParameterGroup) {
                    [function addSubterm:currentParameterGroup];
                    currentParameterGroup = nil;
                } else {
                    if (error) {
                        *error = DD_ERR(DDErrorCodeInvalidArgument, @"invalid empty argument in function \"%@\"", function.functionName);
                    }
                    return nil;
                }
            } else {
                if (currentParameterGroup == nil) {
                    currentParameterGroup = [[_DDGroupTerm alloc] init];
                }
                [currentParameterGroup addSubterm:nextTerm];
            }
        } else {
            // extracting a term failed.  *error should've been filled already
            return nil;
        }
        nextToken = enumerator.peekNextObject;
    }
    
    // consume the closing parenthesis and verify it exists
    if (enumerator.nextObject == nil) {
        if (error) {
            *error = DD_ERR(DDErrorCodeImbalancedParentheses, @"imbalanced parentheses");
        }
        return nil;
    }
    
    if (currentParameterGroup != nil) {
        [function addSubterm:currentParameterGroup];
    }
    
    return function;
}

- (_DDParserTerm *)_termWithEnumerator:(DDEnumerator *)enumerator error:(NSError **)error {
    DDMathToken *next = enumerator.nextObject;
    if (next) {
        _DDParserTerm *term = nil;
        if (next.tokenType == DDTokenTypeNumber) {
            term = [[_DDNumberTerm alloc] initWithToken:next];
        } else if (next.tokenType == DDTokenTypeVariable) {
            term = [[_DDVariableTerm alloc] initWithToken:next];
        } else if (next.tokenType == DDTokenTypeOperator) {
            if (next.mathOperator.function == DDMathOperatorParenthesisOpen) {
                term = [self _groupTermWithEnumerator:enumerator error:error];
            } else {
                term = [[_DDOperatorTerm alloc] initWithToken:next];
            }
        } else if (next.tokenType == DDTokenTypeFunction) {
            term = [self _functionTermWithFunction:next enumerator:enumerator error:error];
        }
        
        return term;
    } else if (error) {
        *error = DD_ERR(DDErrorCodeInvalidFormat, @"can't create a term with a nil token");
    }
    return nil;
}

- (DDExpression *)parsedExpressionWithError:(NSError **)error {
	ERR_ASSERT(error);
    
    _DDGroupTerm *root = [[_DDGroupTerm alloc] init];
    DDEnumerator *tokenEnumerator = [[DDEnumerator alloc] initWithArray:_interpreter.tokens];
    while (tokenEnumerator.peekNextObject != nil) {
        _DDParserTerm *nextTerm = [self _termWithEnumerator:tokenEnumerator error:error];
        if (!nextTerm) {
            return nil;
        }
        
        [root addSubterm:nextTerm];
    }
    
    _DDMathTermResolver *resolver = [[_DDMathTermResolver alloc] initWithTerm:root error:error];
    DDExpression *expression = [resolver expressionWithError:error];
    
    return expression;
}

@end
