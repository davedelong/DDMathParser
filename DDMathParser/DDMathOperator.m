//
//  _DDOperatorInfo.m
//  DDMathParser
//
//  Created by Dave DeLong on 10/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DDMathOperator.h"
#import "DDMathOperatorSet.h"

@implementation DDMathOperator

+ (NSArray *)defaultOperators {
    static NSArray *defaultOperators = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableArray *operators = [NSMutableArray array];
        NSInteger precedence = 0;
        
        [operators addObject:OPERATOR(DDMathOperatorLogicalOr, (@[@"||", @"\u2228"]), BINARY, precedence, LEFT)];
        precedence++;
        
        [operators addObject:OPERATOR(DDMathOperatorLogicalAnd, (@[@"&&", @"\u2227"]), BINARY, precedence, LEFT)];
        precedence++;
        
        // == and != have the same precedence
        [operators addObject:OPERATOR(DDMathOperatorLogicalEqual, (@[@"==", @"="]), BINARY, precedence, LEFT)];
        [operators addObject:OPERATOR(DDMathOperatorLogicalNotEqual, (@[@"!="]), BINARY, precedence, LEFT)];
        precedence++;
        
        [operators addObject:OPERATOR(DDMathOperatorLogicalLessThan, (@[@"<"]), BINARY, precedence, LEFT)];
        precedence++;
        
        [operators addObject:OPERATOR(DDMathOperatorLogicalGreaterThan, (@[@">"]), BINARY, precedence, LEFT)];
        precedence++;
        
        // \u2264 is ≤, \u226f is ≯ (not greater than)
        [operators addObject:OPERATOR(DDMathOperatorLogicalLessThanOrEqual, (@[@"<=", @"=<", @"\u2264", @"\u226f"]), BINARY, precedence, LEFT)];
        precedence++;
        
        // \u2265 is ≥, \u226e is ≮ (not less than)
        [operators addObject:OPERATOR(DDMathOperatorLogicalGreaterThanOrEqual, (@[@">=", @"=>", @"\u2265", @"\u226e"]), BINARY, precedence, LEFT)];
        precedence++;
        
        // \u00AC is ¬
        [operators addObject:OPERATOR(DDMathOperatorLogicalNot, (@[@"!", @"\u00ac"]), UNARY, precedence, RIGHT)];
        precedence++;
        
        [operators addObject:OPERATOR(DDMathOperatorBitwiseOr, (@[@"|"]), BINARY, precedence, LEFT)];
        precedence++;
        
        [operators addObject:OPERATOR(DDMathOperatorBitwiseXor, (@[@"^"]), BINARY, precedence, LEFT)];
        precedence++;
        
        [operators addObject:OPERATOR(DDMathOperatorBitwiseAnd, (@[@"&"]), BINARY, precedence, LEFT)];
        precedence++;
        
        [operators addObject:OPERATOR(DDMathOperatorLeftShift, (@[@"<<"]), BINARY, precedence, LEFT)];
        precedence++;
        
        [operators addObject:OPERATOR(DDMathOperatorRightShift, (@[@">>"]), BINARY, precedence, LEFT)];
        precedence++;
        
        // addition and subtraction have the same precedence
        [operators addObject:OPERATOR(DDMathOperatorAdd, (@[@"+"]), BINARY, precedence, LEFT)];
        // \u2212 is −
        [operators addObject:OPERATOR(DDMathOperatorMinus, (@[@"-", @"\u2212"]), BINARY, precedence, LEFT)];
        precedence++;
        
        // multiplication and division have the same precedence
        // \u00d7 is ×
        [operators addObject:OPERATOR(DDMathOperatorMultiply, (@[@"*", @"\u00d7"]), BINARY, precedence, LEFT)];
        // \u00f7 is ÷
        [operators addObject:OPERATOR(DDMathOperatorDivide, (@[@"/", @"\u00f7"]), BINARY, precedence, LEFT)];
        precedence++;
        
        // NOTE: percent-as-modulo precedence goes here (between Multiply and Bitwise Not)
        
        [operators addObject:OPERATOR(DDMathOperatorBitwiseNot, (@[@"~"]), UNARY, precedence, RIGHT)];
        precedence++;
        
        // right associative unary operators have the same precedence
        // \u2212 is −
        [operators addObject:OPERATOR(DDMathOperatorUnaryMinus, (@[@"-", @"\u2212"]), UNARY, precedence, RIGHT)];
        [operators addObject:OPERATOR(DDMathOperatorUnaryPlus, (@[@"+"]), UNARY, precedence, RIGHT)];
        // \u221a is √
        [operators addObject:OPERATOR(DDMathOperatorSquareRoot, (@[@"\u221a"]), UNARY, precedence, RIGHT)];
        // \u221b is ∛
        [operators addObject:OPERATOR(DDMathOperatorCubeRoot, (@[@"\u221b"]), UNARY, precedence, RIGHT)];
        precedence++;
        
        // all the left associative unary operators have the same precedence
        [operators addObject:OPERATOR(DDMathOperatorFactorial, (@[@"!"]), UNARY, precedence, LEFT)];
        // \u00ba is º (option-0); not necessary a degree sign (acutally masculine ordinal), but common enough for it
        // \u00b0 is °
        [operators addObject:OPERATOR(DDMathOperatorDegree, (@[@"\u00ba", @"\u00b0", @"\u2218"]), UNARY, precedence, LEFT)];
        
        // NOTE: percent-as-percent precedence goes here (same as Factorial)
        precedence++;
        
		//determine what associativity NSPredicate/NSExpression is using
		//mathematically, it should be right associative, but it's usually parsed as left associative
		//rdar://problem/8692313
		NSExpression *powerExpression = [NSExpression expressionWithFormat:@"2 ** 3 ** 2"];
		NSNumber *powerResult = [powerExpression expressionValueWithObject:nil context:nil];
        DDMathOperatorAssociativity powerAssociativity = LEFT;
		if ([powerResult intValue] == 512) {
			powerAssociativity = RIGHT;
		}
        
        [operators addObject:OPERATOR(DDMathOperatorPower, (@[@"**"]), BINARY, precedence, powerAssociativity)];
        precedence++;
        
        // ( and ) have the same precedence
        // these are defined as unary right/left associative for convenience
        [operators addObject:OPERATOR(DDMathOperatorParenthesisOpen, (@[@"("]), UNARY, precedence, RIGHT)];
        [operators addObject:OPERATOR(DDMathOperatorParenthesisClose, (@[@")"]), UNARY, precedence, LEFT)];
        precedence++;
        
        [operators addObject:OPERATOR(DDMathOperatorComma, (@[@","]), DDMathOperatorArityUnknown, precedence, LEFT)];
        precedence++;
        
        defaultOperators = [operators copy];
    });
    return defaultOperators;
}

+ (BOOL)_isValidToken:(NSString *)token {
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
