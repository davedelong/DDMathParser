//
//  _DDParserTerm.m
//  DDMathParser
//
//  Created by Dave DeLong on 7/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DDMathToken.h"

#import "_DDParserTerm.h"

@implementation _DDParserTerm

+ (instancetype)termForToken:(DDMathToken *)token {
    if (token.tokenType == DDTokenTypeNumber) {
        return [[_DDNumberTerm alloc] initWithToken:token];
    } else if (token.tokenType == DDTokenTypeVariable) {
        return [[_DDVariableTerm alloc] initWithToken:token];
    } else if (token.tokenType == DDTokenTypeFunction) {
        return [[_DDFunctionTerm alloc] initWithToken:token];
    } else if (token.mathOperator.function == DDMathOperatorParenthesisOpen) {
        return [[_DDGroupTerm alloc] init];
    } else if (token.mathOperator.function != DDMathOperatorParenthesisClose) {
        // it's an operator that's not an open paren
        return [[_DDOperatorTerm alloc] initWithToken:token];
    } else {
        // it's a close paren
        return nil;
    }
}

- (instancetype)init {
    return [self initWithToken:nil];
}

- (instancetype)initWithToken:(DDMathToken *)token {
    self = [super init];
    if (self) {
        _token = token;
    }
    return self;
}

- (DDMathOperator *)mathOperator {
    return self.token.mathOperator;
}

@end

@implementation _DDGroupTerm {
    NSMutableArray *_subterms;
}

- (instancetype)initWithToken:(DDMathToken *)token {
    self = [super initWithToken:token];
    if (self) {
        _subterms = [NSMutableArray array];
    }
    return self;
}

- (void)addSubterm:(_DDParserTerm *)term {
    [_subterms addObject:term];
}

- (void)setSubterms:(NSArray *)subterms {
    _subterms = [subterms mutableCopy];
}

- (void)replaceTermsInRange:(NSRange)range withTerm:(_DDParserTerm *)replacement {
    [_subterms replaceObjectsInRange:range withObjectsFromArray:@[replacement]];
}

- (DDParserTermType)type { return DDParserTermTypeGroup; }

- (NSString *)description {
    NSArray *descriptions = [[self subterms] valueForKey:@"description"];
    NSString *description = [descriptions componentsJoinedByString:@""];
    return [NSString stringWithFormat:@"(%@)", description];
}

@end


@implementation _DDFunctionTerm

- (instancetype)initWithToken:(DDMathToken *)token {
    self = [super initWithToken:token];
    if (self) {
        if (token.tokenType == DDTokenTypeFunction) {
            _functionName = token.token;
        } else if (token.tokenType == DDTokenTypeOperator) {
            _functionName = token.mathOperator.function;
        } else {
            [NSException raise:NSInternalInconsistencyException format:@"Cannot create a function term from non-function token"];
        }
    }
    return self;
}

- (DDParserTermType)type { return DDParserTermTypeFunction; }

- (NSString *)description {
    NSArray *parameterDescriptions = [[self subterms] valueForKey:@"description"];
    NSString *parameters = [parameterDescriptions componentsJoinedByString:@","];
    parameters = parameters ?: @"";
    return [NSString stringWithFormat:@"%@(%@)", _functionName, parameters];
}

@end


@implementation _DDNumberTerm

- (instancetype)initWithToken:(DDMathToken *)token {
    self = [super initWithToken:token];
    self.resolved = YES;
    return self;
}
- (DDParserTermType)type { return DDParserTermTypeNumber; }
- (NSString *)description {
    return [[self token] description];
}

@end


@implementation _DDVariableTerm

- (instancetype)initWithToken:(DDMathToken *)token {
    self = [super initWithToken:token];
    self.resolved = YES;
    return self;
}
- (DDParserTermType)type { return DDParserTermTypeVariable; }
- (NSString *)description {
    return [NSString stringWithFormat:@"$%@", [[self token] token]];
}

@end


@implementation _DDOperatorTerm

- (DDParserTermType)type { return DDParserTermTypeOperator; }

- (NSString *)description {
    return [[self token] token];
}

@end