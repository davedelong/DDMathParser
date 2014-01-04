//
//  _DDOperatorInfo.m
//  DDMathParser
//
//  Created by Dave DeLong on 10/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DDMathOperator_Internal.h"

static NSMutableArray *_allOperators;
static NSMutableDictionary *_operatorsByFunction;
static NSMutableDictionary *_operatorsByToken;

@implementation DDMathOperator

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

- (id)initWithOperatorFunction:(NSString *)function tokens:(NSArray *)tokens arity:(DDOperatorArity)arity associativity:(DDOperatorAssociativity)associativity {
    if (arity == DDOperatorArityUnknown) {
        [NSException raise:NSInvalidArgumentException format:@"Unable to create operator with unknown arity"];
    }
    for (NSString *token in tokens) {
        if ([DDMathOperator _isValidToken:token] == NO) {
            [NSException raise:NSInvalidArgumentException format:@"Invalid operator token: %@", token];
        }
    }
    return [self initWithOperatorFunction:function tokens:tokens arity:arity precedence:0 associativity:associativity];
}

- (id)initWithOperatorFunction:(NSString *)function tokens:(NSArray *)tokens arity:(DDOperatorArity)arity precedence:(NSInteger)precedence associativity:(DDOperatorAssociativity)associativity {
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

+ (NSArray *)allOperators {
    [self _buildOperators];
    return _allOperators;
}

+ (id)infoForOperatorFunction:(NSString *)function tokens:(NSArray *)tokens arity:(DDOperatorArity)arity precedence:(NSInteger)precedence associativity:(DDOperatorAssociativity)associativity {
    return [[DDMathOperator alloc] initWithOperatorFunction:function tokens:tokens arity:arity precedence:precedence associativity:associativity];
}

+ (instancetype)infoForOperatorFunction:(NSString *)function {
    [self _buildOperators];
    return [_operatorsByFunction objectForKey:function];
}

+ (NSArray *)infosForOperatorToken:(NSString *)token {
    [self _buildOperators];
    return [_operatorsByToken objectForKey:[token lowercaseString]];
}

+ (void)_processNewOperator:(DDMathOperator *)newOperator relative:(NSComparisonResult)relative {
    [self _buildOperators];
    // first, see if there's an operator for this function already
    DDMathOperator *existingOperatorForFunction = [_operatorsByFunction objectForKey:newOperator.function];
    DDMathOperator *resolvedOperator = newOperator;
    if (existingOperatorForFunction != nil) {
        resolvedOperator = existingOperatorForFunction;
        // there is; just add new tokens; don't change any precedence
        [existingOperatorForFunction addTokens:newOperator.tokens];
    } else {
        // there is not.  this is a genuinely new operator
        
        // first, make sure the tokens involved in this new operator are unique
        for (NSString *token in newOperator.tokens) {
            DDMathOperator *existing = [_operatorsByToken objectForKey:[token lowercaseString]];
            if (existing != nil) {
                [NSException raise:NSInvalidArgumentException format:@"An operator is already defined for '%@'", token];
            }
        }
        
        [_allOperators addObject:newOperator];
        
        if (relative != NSOrderedSame) {
            NSInteger newPrecedence = newOperator.precedence;
            
            if (relative == NSOrderedAscending) {
                // the new operator has a precedence higher than the original operator
                // all operators that have an equivalent (or higher) precedence need to be bumped up one
                // to accomodate the new operator
                [_allOperators enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    DDMathOperator *op = obj;
                    if (op.precedence >= newPrecedence) {
                        op.precedence++;
                    }
                }];
            } else {
                [_allOperators enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    DDMathOperator *op = obj;
                    if (op.precedence > newPrecedence || op == newOperator) {
                        op.precedence++;
                    }
                }];
            }
        }
        
        [_allOperators sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"precedence" ascending:YES]]];
        [_operatorsByFunction setObject:@[newOperator] forKey:newOperator.function];
    }
    
    for (NSString *token in newOperator.tokens) {
        NSString *lowercaseToken = [token lowercaseString];
        NSMutableArray *operatorsForToken = [_operatorsByToken objectForKey:lowercaseToken];
        if (operatorsForToken == nil) {
            operatorsForToken = [NSMutableArray array];
            [_operatorsByToken setObject:operatorsForToken forKey:lowercaseToken];
        }
        [operatorsForToken addObject:resolvedOperator];
    }
}

+ (void)addTokens:(NSArray *)tokens forOperatorFunction:(NSString *)operatorFunction {
    DDMathOperator *newOperator = [[DDMathOperator alloc] initWithOperatorFunction:operatorFunction tokens:tokens arity:0 precedence:0 associativity:0];
    DDMathOperator *existing = [self infoForOperatorFunction:operatorFunction];
    if (existing == nil) {
        [NSException raise:NSInvalidArgumentException format:@"No operator is defined for function '%@'", operatorFunction];
    }
    [self addOperator:newOperator withSamePrecedenceAsOperator:existing];
}

+ (void)addOperator:(DDMathOperator *)newOperator withSamePrecedenceAsOperator:(DDMathOperator *)existingOperator {
    newOperator.precedence = existingOperator.precedence;
    [self _processNewOperator:newOperator relative:NSOrderedSame];
}

+ (void)addOperator:(DDMathOperator *)newOperator withHigherPrecedenceThanOperator:(DDMathOperator *)existingOperator {
    newOperator.precedence = existingOperator.precedence + 1;
    [self _processNewOperator:newOperator relative:NSOrderedAscending];
}

+ (void)addOperator:(DDMathOperator *)newOperator withLowerPrecedenceThanOperator:(DDMathOperator *)existingOperator {
    newOperator.precedence = existingOperator.precedence - 1;
    [self _processNewOperator:newOperator relative:NSOrderedDescending];
}

#define UNARY DDOperatorArityUnary
#define BINARY DDOperatorArityBinary
#define LEFT DDOperatorAssociativityLeft
#define RIGHT DDOperatorAssociativityRight

+ (void)_buildOperators {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _allOperators = [NSMutableArray array];
        NSInteger precedence = 0;
        
        [_allOperators addObject:[self infoForOperatorFunction:DDOperatorLogicalOr tokens:@[@"||", @"\u2228"] arity:BINARY precedence:precedence associativity:LEFT]];
        precedence++;
        
        [_allOperators addObject:[self infoForOperatorFunction:DDOperatorLogicalAnd tokens:@[@"&&", @"\u2227"] arity:BINARY precedence:precedence associativity:LEFT]];
        precedence++;
        
        // == and != have the same precedence
        [_allOperators addObject:[self infoForOperatorFunction:DDOperatorLogicalEqual tokens:@[@"==", @"="] arity:BINARY precedence:precedence associativity:LEFT]];
        [_allOperators addObject:[self infoForOperatorFunction:DDOperatorLogicalNotEqual tokens:@[@"!="] arity:BINARY precedence:precedence associativity:LEFT]];
        precedence++;
        
        [_allOperators addObject:[self infoForOperatorFunction:DDOperatorLogicalLessThan tokens:@[@"<"] arity:BINARY precedence:precedence associativity:LEFT]];
        precedence++;
        
        [_allOperators addObject:[self infoForOperatorFunction:DDOperatorLogicalGreaterThan tokens:@[@">"] arity:BINARY precedence:precedence associativity:LEFT]];
        precedence++;
        
        // \u2264 is ≤, \u226f is ≯ (not greater than)
        [_allOperators addObject:[self infoForOperatorFunction:DDOperatorLogicalLessThanOrEqual tokens:@[@"<=", @"=<", @"\u2264", @"\u226f"] arity:BINARY precedence:precedence associativity:LEFT]];
        precedence++;
        
        // \u2265 is ≥, \u226e is ≮ (not less than)
        [_allOperators addObject:[self infoForOperatorFunction:DDOperatorLogicalGreaterThanOrEqual tokens:@[@">=", @"=>", @"\u2265", @"\u226e"] arity:BINARY precedence:precedence associativity:LEFT]];
        precedence++;
        
        // \u00AC is ¬
        [_allOperators addObject:[self infoForOperatorFunction:DDOperatorLogicalNot tokens:@[@"!", @"\u00ac"] arity:UNARY precedence:precedence associativity:RIGHT]];
        precedence++;
        
        [_allOperators addObject:[self infoForOperatorFunction:DDOperatorBitwiseOr tokens:@[@"|"] arity:BINARY precedence:precedence associativity:LEFT]];
        precedence++;
        
        [_allOperators addObject:[self infoForOperatorFunction:DDOperatorBitwiseXor tokens:@[@"^"] arity:BINARY precedence:precedence associativity:LEFT]];
        precedence++;
        
        [_allOperators addObject:[self infoForOperatorFunction:DDOperatorBitwiseAnd tokens:@[@"&"] arity:BINARY precedence:precedence associativity:LEFT]];
        precedence++;
        
        [_allOperators addObject:[self infoForOperatorFunction:DDOperatorLeftShift tokens:@[@"<<"] arity:BINARY precedence:precedence associativity:LEFT]];
        precedence++;
        
        [_allOperators addObject:[self infoForOperatorFunction:DDOperatorRightShift tokens:@[@">>"] arity:BINARY precedence:precedence associativity:LEFT]];
        precedence++;
        
        // addition and subtraction have the same precedence
        [_allOperators addObject:[self infoForOperatorFunction:DDOperatorAdd tokens:@[@"+"] arity:BINARY precedence:precedence associativity:LEFT]];
        // \u2212 is −
        [_allOperators addObject:[self infoForOperatorFunction:DDOperatorMinus tokens:@[@"-", @"\u2212"] arity:BINARY precedence:precedence associativity:LEFT]];
        precedence++;
        
        // multiplication and division have the same precedence
        // \u00d7 is ×
        [_allOperators addObject:[self infoForOperatorFunction:DDOperatorMultiply tokens:@[@"*", @"\u00d7"] arity:BINARY precedence:precedence associativity:LEFT]];
        // \u00f7 is ÷
        [_allOperators addObject:[self infoForOperatorFunction:DDOperatorDivide tokens:@[@"/", @"\u00f7"] arity:BINARY precedence:precedence associativity:LEFT]];
        precedence++;
        
#if DD_INTERPRET_PERCENT_SIGN_AS_MOD
        [_allOperators addObject:[self infoForOperatorFunction:DDOperatorModulo tokens:@[@"%"] arity:BINARY precedence:precedence associativity:LEFT]];
        precedence++;
#endif
        
        [_allOperators addObject:[self infoForOperatorFunction:DDOperatorBitwiseNot tokens:@[@"~"] arity:UNARY precedence:precedence associativity:RIGHT]];
        precedence++;
        
        // right associative unary operators have the same precedence
        // \u2212 is −
        [_allOperators addObject:[self infoForOperatorFunction:DDOperatorUnaryMinus tokens:@[@"-", @"\u2212"] arity:UNARY precedence:precedence associativity:RIGHT]];
        [_allOperators addObject:[self infoForOperatorFunction:DDOperatorUnaryPlus tokens:@[@"+"] arity:UNARY precedence:precedence associativity:RIGHT]];
        precedence++;
        
        // all the left associative unary operators have the same precedence
        [_allOperators addObject:[self infoForOperatorFunction:DDOperatorFactorial tokens:@[@"!"] arity:UNARY precedence:precedence associativity:LEFT]];
        // \u00ba is º (option-0); not necessary a degree sign, but common enough for it
        // \u00b0 is °
        [_allOperators addObject:[self infoForOperatorFunction:DDOperatorDegree tokens:@[@"\u00ba", @"\u00b0"] arity:UNARY precedence:precedence associativity:LEFT]];
        
#if !DD_INTERPRET_PERCENT_SIGN_AS_MOD
        [operators addObject:[self infoForOperatorFunction:DDOperatorPercent tokens:@[@"%"] arity:UNARY precedence:precedence associativity:LEFT]];
#endif
        
        precedence++;
        
        [_allOperators addObject:[self infoForOperatorFunction:DDOperatorPower tokens:@[@"**"] arity:BINARY precedence:precedence associativity:RIGHT]];
        precedence++;
        
        // ( and ) have the same precedence
        // these are defined as unary right/left associative for convenience
        [_allOperators addObject:[self infoForOperatorFunction:DDOperatorParenthesisOpen tokens:@[@"("] arity:UNARY precedence:precedence associativity:RIGHT]];
        [_allOperators addObject:[self infoForOperatorFunction:DDOperatorParenthesisClose tokens:@[@")"] arity:UNARY precedence:precedence associativity:LEFT]];
        precedence++;
        
        [_allOperators addObject:[self infoForOperatorFunction:DDOperatorComma tokens:@[@","] arity:DDOperatorArityUnknown precedence:precedence associativity:LEFT]];
        precedence++;
        
        NSArray *functions = [_allOperators valueForKey:@"function"];
        _operatorsByFunction = [NSMutableDictionary dictionaryWithObjects:_allOperators forKeys:functions];
        
        _operatorsByToken = [NSMutableDictionary dictionary];
        for (DDMathOperator *op in _allOperators) {
            NSArray *tokens = [op tokens];
            for (NSString *token in tokens) {
                NSString *lowercaseToken = [token lowercaseString];
                NSMutableArray *operatorsForThisToken = [_operatorsByToken objectForKey:lowercaseToken];
                if (operatorsForThisToken == nil) {
                    operatorsForThisToken = [NSMutableArray array];
                    [_operatorsByToken setObject:operatorsForThisToken forKey:lowercaseToken];
                }
                [operatorsForThisToken addObject:op];
            }
        }
    });
}

- (void)addTokens:(NSArray *)moreTokens {
    _tokens = [_tokens arrayByAddingObjectsFromArray:moreTokens];
}

- (NSString *)description {
    static NSString *ArityDesc[] = {
        @"Unknown",
        @"Unary",
        @"Binary"
    };
    
    static NSString *AssocDesc[] = {
        @"Left",
        @"Right"
    };
    
    return [NSString stringWithFormat:@"%@ {(%@) => %@(), Arity: %@, Assoc: %@, Precedence: %ld}",
            [super description],
            [_tokens componentsJoinedByString:@", "],
            _function,
            ArityDesc[_arity],
            AssocDesc[_associativity],
            (long)_precedence];
}

@end
