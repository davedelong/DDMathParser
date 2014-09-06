//
//  _DDOperatorInfo.m
//  DDMathParser
//
//  Created by Dave DeLong on 10/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DDMathOperator.h"
#import "DDMathOperatorSet.h"

@interface DDMathOperator ()

@property (nonatomic, assign) NSInteger precedence;

@end

@implementation DDMathOperator

+ (instancetype)moduloOperator {
    return OPERATOR(DDMathOperatorModulo, @[@"%"], BINARY, 0, LEFT);
}

+ (instancetype)percentOperator {
    return OPERATOR(DDMathOperatorPercent, @[@"%"], BINARY, 0, LEFT);
}

+ (DDMathOperatorAssociativity)associativityForPowerExpressions {
    static DDMathOperatorAssociativity powerAssociativity = -1;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSExpression *powerExpression = [NSExpression expressionWithFormat:@"2 ** 3 ** 2"];
        NSNumber *powerResult = [powerExpression expressionValueWithObject:nil
                                                                   context:nil];
        int result = [powerResult intValue];
        if (result == 512) {
            powerAssociativity = DDMathOperatorAssociativityRight;
        }
        else if (result == 64) {
            powerAssociativity = DDMathOperatorAssociativityLeft;
        }
    });
    return powerAssociativity;
}

+ (NSArray *)defaultOperators {
    static NSArray *defaultOperators = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableArray *operators = [NSMutableArray array];
        NSInteger precedence = 0;
        
        [operators addObject:OPERATOR(DDMathOperatorLogicalOr, (@[@"||", @"∨"]), BINARY, precedence++, LEFT)];
        [operators addObject:OPERATOR(DDMathOperatorLogicalAnd, (@[@"&&", @"∧"]), BINARY, precedence++, LEFT)];
        
        // == and != have the same precedence
        [operators addObject:OPERATOR(DDMathOperatorLogicalEqual, (@[@"==", @"="]), BINARY, precedence++, LEFT)];
        [operators addObject:OPERATOR(DDMathOperatorLogicalNotEqual, (@[@"!="]), BINARY, precedence++, LEFT)];
        
        [operators addObject:OPERATOR(DDMathOperatorLogicalLessThan, (@[@"<"]), BINARY, precedence++, LEFT)];
        [operators addObject:OPERATOR(DDMathOperatorLogicalGreaterThan, (@[@">"]), BINARY, precedence++, LEFT)];
        [operators addObject:OPERATOR(DDMathOperatorLogicalLessThanOrEqual, (@[@"<=", @"=<", @"≤", @"≯"]), BINARY, precedence++, LEFT)];
        [operators addObject:OPERATOR(DDMathOperatorLogicalGreaterThanOrEqual, (@[@">=", @"=>", @"≥", @"≮"]), BINARY, precedence++, LEFT)];
        [operators addObject:OPERATOR(DDMathOperatorLogicalNot, (@[@"!", @"¬"]), UNARY, precedence++, RIGHT)];
        [operators addObject:OPERATOR(DDMathOperatorBitwiseOr, (@[@"|"]), BINARY, precedence++, LEFT)];
        [operators addObject:OPERATOR(DDMathOperatorBitwiseXor, (@[@"^"]), BINARY, precedence++, LEFT)];
        [operators addObject:OPERATOR(DDMathOperatorBitwiseAnd, (@[@"&"]), BINARY, precedence++, LEFT)];
        [operators addObject:OPERATOR(DDMathOperatorLeftShift, (@[@"<<"]), BINARY, precedence++, LEFT)];
        [operators addObject:OPERATOR(DDMathOperatorRightShift, (@[@">>"]), BINARY, precedence++, LEFT)];
        [operators addObject:OPERATOR(DDMathOperatorAdd, (@[@"+"]), BINARY, precedence, LEFT)];
        [operators addObject:OPERATOR(DDMathOperatorMinus, (@[@"-", @"−"]), BINARY, precedence++, LEFT)];
        
        [operators addObject:OPERATOR(DDMathOperatorMultiply, (@[@"*", @"×"]), BINARY, precedence, LEFT)];
        [operators addObject:OPERATOR(DDMathOperatorDivide, (@[@"/", @"÷"]), BINARY, precedence++, LEFT)];
        
        [operators addObject:OPERATOR(DDMathOperatorImplicitMultiply, nil, BINARY, precedence, LEFT)];
        
        // NOTE: percent-as-modulo precedence goes here (between ImplicitMultiply and Bitwise Not)
        
        [operators addObject:OPERATOR(DDMathOperatorBitwiseNot, (@[@"~"]), UNARY, precedence++, RIGHT)];
        
        // all right associative unary operators have the same precedence
        [operators addObject:OPERATOR(DDMathOperatorUnaryMinus, (@[@"-", @"−"]), UNARY, precedence, RIGHT)];
        [operators addObject:OPERATOR(DDMathOperatorUnaryPlus, (@[@"+"]), UNARY, precedence, RIGHT)];
        [operators addObject:OPERATOR(DDMathOperatorSquareRoot, (@[@"√"]), UNARY, precedence, RIGHT)];
        [operators addObject:OPERATOR(DDMathOperatorCubeRoot, (@[@"∛"]), UNARY, precedence++, RIGHT)];
        
        // all left associative unary operators have the same precedence
        [operators addObject:OPERATOR(DDMathOperatorFactorial, (@[@"!"]), UNARY, precedence, LEFT)];
        // NOTE: percent-as-percent precedence goes here (same as Factorial)
        [operators addObject:OPERATOR(DDMathOperatorDegree, (@[@"º", @"°", @"∘"]), UNARY, precedence++, LEFT)];
        
        
		//determine what associativity NSPredicate/NSExpression is using
		//mathematically, it should be right associative, but it's usually parsed as left associative
		//rdar://problem/8692313
        DDMathOperatorAssociativity powerAssociativity = [self associativityForPowerExpressions];
        [operators addObject:OPERATOR(DDMathOperatorPower, (@[@"**"]), BINARY, precedence, powerAssociativity)];
        precedence++;
        
        // these are defined as unary right/left associative for convenience
        [operators addObject:OPERATOR(DDMathOperatorParenthesisOpen, (@[@"("]), UNARY, precedence, RIGHT)];
        [operators addObject:OPERATOR(DDMathOperatorParenthesisClose, (@[@")"]), UNARY, precedence++, LEFT)];
        
        [operators addObject:OPERATOR(DDMathOperatorComma, (@[@","]), BINARY, precedence++, LEFT)];
        
        defaultOperators = [operators copy];
    });
    return defaultOperators;
}

+ (BOOL)_isValidToken:(NSString *)token {
    if (token.length == 0) { return YES; }
    
    unichar firstChar = [token characterAtIndex:0];
    if ((firstChar >= '0' && firstChar <= '9' ) || firstChar == '.' || firstChar == '$' || firstChar == '\'' || firstChar == '"') {
        return NO;
    }
    
    NSString *trimmed = [token stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([trimmed isEqual:token] == NO) {
        return NO;
    }
    
    return YES;
}

- (id)initWithOperatorFunction:(NSString *)function tokens:(NSArray *)tokens arity:(DDMathOperatorArity)arity precedence:(NSInteger)precedence associativity:(DDMathOperatorAssociativity)associativity {
    if (arity == DDMathOperatorArityUnknown) {
        [NSException raise:NSInvalidArgumentException format:@"Unable to create operator with unknown arity"];
    }
    //normalize the case on operators
    tokens = [tokens valueForKey:@"lowercaseString"];
    
    //make sure they're valid
    for (NSString *token in tokens) {
        if ([DDMathOperator _isValidToken:token] == NO) {
            [NSException raise:NSInvalidArgumentException format:@"Invalid operator token: %@", token];
        }
    }

    self = [super init];
    if (self) {
        _arity = arity;
        _associativity = associativity;
        _precedence = precedence;
        _tokens = tokens;
        _function = function;
    }
    return self;
}

- (void)addTokens:(NSArray *)moreTokens {
    _tokens = [_tokens arrayByAddingObjectsFromArray:[moreTokens valueForKey:@"lowercaseString"]];
}

- (id)copyWithZone:(NSZone *)zone {
#pragma unused(zone)
    return [[[self class] alloc] initWithOperatorFunction:_function
                                                   tokens:_tokens
                                                    arity:_arity
                                               precedence:_precedence
                                            associativity:_associativity];
}

- (NSString *)debugDescription {
    static NSString *ArityDesc[] = {
        @"Unknown",
        @"Unary",
        @"Binary"
    };
    
    static NSString *AssocDesc[] = {
        @"Left",
        @"Right"
    };
    
    return [NSString stringWithFormat:@"{(%@) => %@(), Arity: %@, Assoc: %@, Precedence: %ld}",
            [_tokens componentsJoinedByString:@", "],
            _function,
            ArityDesc[_arity],
            AssocDesc[_associativity],
            (long)_precedence];
}

- (NSString *)description {
    
    return [NSString stringWithFormat:@"%@ %@",
            [super description],
            [self debugDescription]];
}

@end
