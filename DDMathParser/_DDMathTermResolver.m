//
//  _DDMathTermResolver.m
//  DDMathParser
//
//  Created by Dave DeLong on 7/30/14.
//
//

#import "_DDMathTermResolver.h"

#import "_DDParserTerm.h"
#import "DDMathToken.h"
#import "DDMathOperator.h"
#import "DDMathParserMacros.h"

@implementation _DDMathTermResolver {
    _DDParserTerm *_term;
}

- (instancetype)initWithTerm:(_DDParserTerm *)term error:(NSError **)error {
    self = [super init];
    if (self) {
        if ([self _resolveTerm:term error:error] == NO) { return nil; }
        
        _term = term;
    }
    return self;
}

#pragma mark - Resolution

- (BOOL)_resolveTerm:(_DDParserTerm *)term error:(NSError **)error {
    if (term.resolved == YES) { return YES; }
    
    if (term.type == DDParserTermTypeFunction) {
        return [self _resolveFunctionTerm:(_DDFunctionTerm *)term error:error];
    } else if (term.type == DDParserTermTypeGroup) {
        return [self _resolveGroupTerm:(_DDGroupTerm *)term error:error];
    } else {
        [NSException raise:NSInternalInconsistencyException format:@"Attempting to resolve unknown term: %@", term];
    }
    
    return NO;
}

#pragma mark Function Resolution

- (BOOL)_resolveFunctionTerm:(_DDFunctionTerm *)term error:(NSError **)error {
    if (term.subterms.count > 0) {
        // resolve each parameter
        for (_DDParserTerm *subterm in term.subterms) {
            if (![self _resolveTerm:subterm error:error]) { return NO; }
        }
    }
    term.resolved = YES;
    return YES;
}

- (NSArray *)_resolveFunctionParameters:(NSArray *)terms error:(NSError **)error {
    if (terms.count == 0) { return terms; }
    
    NSMutableArray *groups = [NSMutableArray arrayWithObject:[[_DDGroupTerm alloc] init]];
    
    for (_DDParserTerm *term in terms) {
        BOOL shouldAddToGroup = YES;
        
        if (term.mathOperator.function == DDMathOperatorComma) {
            [groups addObject:[[_DDGroupTerm alloc] init]];
            shouldAddToGroup = NO;
        }
        
        if (shouldAddToGroup == YES) {
            [groups.lastObject addSubterm:term];
        }
        
    }
    
    NSMutableArray *newParameters = [NSMutableArray array];
    for (_DDGroupTerm *group in groups) {
        if (group.subterms.count == 0) {
            if (error) {
                *error = DD_ERR(DDErrorCodeInvalidFormat, @"Functions cannot have empty parameters");
            }
            return nil;
        } else if (group.subterms.count == 1) {
            [newParameters addObject:group.subterms[0]];
        } else {
            [newParameters addObject:group];
        }
    }
    
    return newParameters;
}

#pragma mark Group Term Resolution

- (BOOL)_resolveGroupTerm:(_DDGroupTerm *)term error:(NSError **)error {
    while (term.subterms.count > 1) {
        NSIndexSet *operatorIndices = [self _indicesOfOperatorsWithHighestPrecendenceInGroup:term];
        if (operatorIndices.count == 0) {
            if (error) {
                *error = DD_ERR(DDErrorCodeInvalidFormat, @"invalid format: %@", term);
            }
            return NO;
        }
        
        NSUInteger operatorIndex = operatorIndices.firstIndex;
        if (operatorIndices.count > 1) {
            // we have more than one index
            // use a different index if the operator is right associative
            _DDParserTerm *operatorTerm = term.subterms[operatorIndex];
            if (operatorTerm.mathOperator.associativity == DDMathOperatorAssociativityRight) {
                operatorIndex = operatorIndices.lastIndex;
            }
        }
        
        // we have the index for the next operator
        if (![self _reduceOperator:operatorIndex inGroup:term error:error]) {
            return NO;
        }
    }
    
    if (term.subterms.count > 0) {
        _DDParserTerm *subterm = term.subterms[0];
        if (![self _resolveTerm:subterm error:error]) {
            return NO;
        }
    }
    
    term.resolved = YES;
    return YES;
}

- (NSIndexSet *)_indicesOfOperatorsWithHighestPrecendenceInGroup:(_DDGroupTerm *)group {
    NSMutableIndexSet * indices = [NSMutableIndexSet indexSet];
    __block NSInteger currentPrecedence = -1;
    [group.subterms enumerateObjectsUsingBlock:^(_DDParserTerm *term, NSUInteger idx, BOOL *stop) {
        
        if (term.type == DDParserTermTypeOperator && term.resolved == NO) {
            NSInteger precedence = term.mathOperator.precedence;
            if (precedence > currentPrecedence) {
                currentPrecedence = precedence;
                [indices removeAllIndexes];
                [indices addIndex:idx];
            } else if (precedence == currentPrecedence) {
                [indices addIndex:idx];
            }
        }
    }];
    return indices;
}

- (BOOL)_reduceOperator:(NSUInteger)operatorIndex inGroup:(_DDGroupTerm *)group error:(NSError **)error {
    ERR_ASSERT(error);
    _DDParserTerm *operatorTerm = group.subterms[operatorIndex];
    
    if (operatorTerm.mathOperator.arity == DDMathOperatorArityBinary) {
        return [self _reduceBinaryOperator:operatorIndex inGroup:group error:error];
    } else if (operatorTerm.mathOperator.arity == DDMathOperatorArityUnary) {
        return [self _reduceUnaryOperator:operatorIndex inGroup:group error:error];
    } else {
        *error = DD_ERR(DDErrorCodeInvalidOperatorArity, @"unknown arity for operator: %@", operatorTerm);
        return NO;
    }
}

- (BOOL)_reduceBinaryOperator:(NSUInteger)operatorIndex inGroup:(_DDGroupTerm *)group error:(NSError **)error {
    _DDParserTerm *term = group.subterms[operatorIndex];
    
    if (operatorIndex == 0) {
        if (error) {
            *error = DD_ERR(DDErrorCodeBinaryOperatorMissingLeftOperand, @"no left operand to binary %@", term);
        }
        return NO;
    }
    if (operatorIndex >= group.subterms.count - 1) {
        if (error) {
            *error = DD_ERR(DDErrorCodeBinaryOperatorMissingRightOperand, @"no right operand to binary %@", term);
        }
        return NO;
    }
    
    if (![self _collapseRightAssociativeUnaryOperatorsStartingAtIndex:operatorIndex+1 inGroup:group error:error]) {
        return NO;
    }
    
    NSInteger indexDelta = 0;
    if (![self _collapseLeftAssociativeUnaryOperatorsStartingAtIndex:operatorIndex-1 inGroup:group delta:&indexDelta error:error]) {
        return NO;
    }
    
    // if collapsing left associative unary operators happened, then we need to shift our index down the same amount
    // because our position has changed
    operatorIndex -= indexDelta;
    
    NSRange replacementRange = NSMakeRange(operatorIndex-1, 3);
    
    _DDParserTerm *leftOperand = group.subterms[operatorIndex-1];
    _DDParserTerm *rightOperand = group.subterms[operatorIndex+1];
    
    if (![self _resolveTerm:leftOperand error:error]) { return NO; }
    if (![self _resolveTerm:rightOperand error:error]) { return NO; }
    
    _DDFunctionTerm *function = [[_DDFunctionTerm alloc] initWithToken:term.token];
    function.subterms = @[leftOperand, rightOperand];
    function.resolved = YES;
    
    [group replaceTermsInRange:replacementRange withTerm:function];
    return YES;
}

- (BOOL)_collapseRightAssociativeUnaryOperatorsStartingAtIndex:(NSUInteger)index inGroup:(_DDGroupTerm *)group error:(NSError **)error {
    
    NSUInteger nextIndex = index;
    
    _DDParserTerm *term = group.subterms[nextIndex];
    if (term.resolved == YES) { return YES; }
    
    while (term.mathOperator.associativity == DDMathOperatorAssociativityRight && term.mathOperator.arity == DDMathOperatorArityUnary) {
        nextIndex++;
        if (nextIndex < group.subterms.count - 1) {
            term = group.subterms[nextIndex];
        } else {
            term = nil;
        }
    }
    
    NSUInteger lastIndex = nextIndex - 1;
    for (NSUInteger currentIndex = lastIndex; currentIndex >= index; currentIndex--) {
        if (![self _reduceUnaryOperator:currentIndex inGroup:group error:error]) {
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)_collapseLeftAssociativeUnaryOperatorsStartingAtIndex:(NSUInteger)index inGroup:(_DDGroupTerm *)group delta:(NSInteger *)indexDelta error:(NSError **)error {
    
    NSInteger nextIndex = index;
    
    _DDParserTerm *term = group.subterms[nextIndex];
    if (term.resolved == YES) { return YES; }
    
    while (term.mathOperator.associativity == DDMathOperatorAssociativityLeft && term.mathOperator.arity == DDMathOperatorArityUnary) {
        nextIndex--;
        if (nextIndex >= 0) {
            term = group.subterms[nextIndex];
        } else {
            term = nil;
        }
    }
    
    NSInteger firstIndex = nextIndex + 1;
    NSInteger delta = 0;
    for (NSUInteger currentIndex = firstIndex; currentIndex <= index; currentIndex++) {
        if (![self _reduceUnaryOperator:currentIndex inGroup:group error:error]) {
            return NO;
        } else {
            delta++;
        }
    }
    
    *indexDelta = delta;
    return YES;
}

- (BOOL)_reduceUnaryOperator:(NSUInteger)operatorIndex inGroup:(_DDGroupTerm *)group error:(NSError **)error {
    _DDParserTerm *term = group.subterms[operatorIndex];
    DDMathOperatorAssociativity associativity = term.mathOperator.associativity;
    
    NSRange replacementRange;
    _DDParserTerm *parameter = nil;
    
    if (associativity == DDMathOperatorAssociativityRight) {
        // right associative unary operator (negate, not)
        if (operatorIndex >= group.subterms.count - 1) {
            if (error) {
                *error = DD_ERR(DDErrorCodeUnaryOperatorMissingRightOperand, @"no right operand to unary %@", term);
            }
            return NO;
        }
        
        parameter = group.subterms[operatorIndex+1];
        replacementRange = NSMakeRange(operatorIndex, 2);
        
    } else {
        // left associative unary operator (factorial)
        if (operatorIndex == 0) {
            *error = DD_ERR(DDErrorCodeUnaryOperatorMissingLeftOperand, @"no left operand to unary %@", term);
            return NO;
        }
        
        parameter = group.subterms[operatorIndex-1];
        replacementRange = NSMakeRange(operatorIndex-1, 2);
        
    }
    
    if (parameter.type == DDParserTermTypeOperator) {
        if (error) {
            *error = DD_ERR(DDErrorCodeInvalidFormat, @"unary operator %@ is attempting to operate on another operator %@", term, parameter);
        }
        return NO;
    }
    
    if (![self _resolveTerm:parameter error:error]) { return NO; }
    
    _DDFunctionTerm *function = [[_DDFunctionTerm alloc] initWithToken:term.token];
    function.subterms = @[parameter];
    function.resolved = YES;
    
    [group replaceTermsInRange:replacementRange withTerm:function];
    
    return YES;
}

#pragma mark - Expressionification

- (DDExpression *)expressionWithError:(NSError *__autoreleasing *)error {
    return [self expressionForTerm:_term error:error];
}

- (DDExpression *)expressionForTerm:(_DDParserTerm *)term error:(NSError **)error {
    if (term.resolved == NO) {
        [NSException raise:NSInternalInconsistencyException format:@"Attempting to create expression from unresolved term"];
    }
    
    if (term.type == DDParserTermTypeNumber) {
        return [DDExpression numberExpressionWithNumber:term.token.numberValue];
        
    } else if (term.type == DDParserTermTypeVariable) {
        return [DDExpression variableExpressionWithVariable:term.token.token];
        
    } else if (term.type == DDParserTermTypeGroup) {
        _DDGroupTerm *group = (_DDGroupTerm *)term;
        if (group.subterms.count != 1) {
            if (error) {
                *error = DD_ERR(DDErrorCodeInvalidFormat, @"Unable to create expression from term: %@", group);
            }
            return nil;
        }
        
        return [self expressionForTerm:group.subterms[0] error:error];
        
    } else if (term.type == DDParserTermTypeFunction) {
        _DDFunctionTerm *function = (_DDFunctionTerm *)term;
        
        NSMutableArray *parameters = [NSMutableArray array];
        for (_DDParserTerm *term in function.subterms) {
            DDExpression *parameter = [self expressionForTerm:term error:error];
            if (!parameter) { return nil; }
            
            [parameters addObject:parameter];
        }
        
        return [DDExpression functionExpressionWithFunction:function.functionName arguments:parameters error:error];
        
    } else if (term.type == DDParserTermTypeOperator) {
        if (error) {
            if (term.mathOperator.arity == DDMathOperatorArityUnary) {
                if (term.mathOperator.associativity == DDMathOperatorAssociativityLeft) {
                    *error = DD_ERR(DDErrorCodeUnaryOperatorMissingLeftOperand, @"no left operand to unary %@", term.token);
                } else {
                    *error = DD_ERR(DDErrorCodeUnaryOperatorMissingRightOperand, @"no right operand to unary %@", term.token);
                }
            } else {
                *error = DD_ERR(DDErrorCodeOperatorMissingOperands, @"missing operands for operator: %@", term.token);
            }
        }
    } else {
        [NSException raise:NSInternalInconsistencyException format:@"Cannot create expression from unknown term: %@", term];
    }
    
    return nil;
}

@end
