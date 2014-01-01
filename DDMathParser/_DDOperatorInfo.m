//
//  _DDOperatorInfo.m
//  DDMathParser
//
//  Created by Dave DeLong on 10/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "_DDOperatorInfo.h"

static NSArray *_allOperators;
static NSDictionary *_operatorsByFunction;
static NSDictionary *_infosByToken;

@implementation _DDOperatorInfo

- (id)initWithOperatorFunction:(NSString *)function tokens:(NSArray *)tokens arity:(DDOperatorArity)arity precedence:(NSInteger)precedence associativity:(DDOperatorAssociativity)associativity {
    self = [super init];
    if (self) {
        _arity = arity;
        _defaultAssociativity = associativity;
        _precedence = precedence;
        _tokens = tokens;
        _function = function;
    }
    return self;
}

+ (id)infoForOperatorFunction:(NSString *)function tokens:(NSArray *)tokens arity:(DDOperatorArity)arity precedence:(NSInteger)precedence associativity:(DDOperatorAssociativity)associativity {
    return [[_DDOperatorInfo alloc] initWithOperatorFunction:function tokens:tokens arity:arity precedence:precedence associativity:associativity];
}

+ (instancetype)infoForOperatorFunction:(NSString *)function {
    [self _buildOperators];
    return [_operatorsByFunction objectForKey:function];
}

+ (NSArray *)infosForOperatorToken:(NSString *)token {
    [self _buildOperators];
    return [_infosByToken objectForKey:token];
}

- (void)addTokens:(NSArray *)moreTokens {
    _tokens = [_tokens arrayByAddingObjectsFromArray:moreTokens];
}

#define UNARY DDOperatorArityUnary
#define BINARY DDOperatorArityBinary
#define LEFT DDOperatorAssociativityLeft
#define RIGHT DDOperatorAssociativityRight

+ (void)_buildOperators {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableArray *operators = [NSMutableArray array];
        NSInteger precedence = 0;
        
        [operators addObject:[self infoForOperatorFunction:DDOperatorLogicalOr tokens:@[@"||", @"\u2228"] arity:BINARY precedence:precedence associativity:LEFT]];
        precedence++;
        
        [operators addObject:[self infoForOperatorFunction:DDOperatorLogicalAnd tokens:@[@"&&", @"\u2227"] arity:BINARY precedence:precedence associativity:LEFT]];
        precedence++;
        
        // == and != have the same precedence
        [operators addObject:[self infoForOperatorFunction:DDOperatorLogicalEqual tokens:@[@"==", @"="] arity:BINARY precedence:precedence associativity:LEFT]];
        [operators addObject:[self infoForOperatorFunction:DDOperatorLogicalNotEqual tokens:@[@"!="] arity:BINARY precedence:precedence associativity:LEFT]];
        precedence++;
        
        [operators addObject:[self infoForOperatorFunction:DDOperatorLogicalLessThan tokens:@[@"<"] arity:BINARY precedence:precedence associativity:LEFT]];
        precedence++;
        
        [operators addObject:[self infoForOperatorFunction:DDOperatorLogicalGreaterThan tokens:@[@">"] arity:BINARY precedence:precedence associativity:LEFT]];
        precedence++;
        
        // \u2264 is ≤, \u226f is ≯ (not greater than)
        [operators addObject:[self infoForOperatorFunction:DDOperatorLogicalLessThanOrEqual tokens:@[@"<=", @"=<", @"\u2264", @"\u226f"] arity:BINARY precedence:precedence associativity:LEFT]];
        precedence++;
        
        // \u2265 is ≥, \u226e is ≮ (not less than)
        [operators addObject:[self infoForOperatorFunction:DDOperatorLogicalGreaterThanOrEqual tokens:@[@">=", @"=>", @"\u2265", @"\u226e"] arity:BINARY precedence:precedence associativity:LEFT]];
        precedence++;
        
        // \u00AC is ¬
        [operators addObject:[self infoForOperatorFunction:DDOperatorLogicalNot tokens:@[@"!", @"\u00ac"] arity:UNARY precedence:precedence associativity:RIGHT]];
        precedence++;
        
        [operators addObject:[self infoForOperatorFunction:DDOperatorBitwiseOr tokens:@[@"|"] arity:BINARY precedence:precedence associativity:LEFT]];
        precedence++;
        
        [operators addObject:[self infoForOperatorFunction:DDOperatorBitwiseXor tokens:@[@"^"] arity:BINARY precedence:precedence associativity:LEFT]];
        precedence++;
        
        [operators addObject:[self infoForOperatorFunction:DDOperatorBitwiseAnd tokens:@[@"&"] arity:BINARY precedence:precedence associativity:LEFT]];
        precedence++;
        
        [operators addObject:[self infoForOperatorFunction:DDOperatorLeftShift tokens:@[@"<<"] arity:BINARY precedence:precedence associativity:LEFT]];
        precedence++;
        
        [operators addObject:[self infoForOperatorFunction:DDOperatorRightShift tokens:@[@">>"] arity:BINARY precedence:precedence associativity:LEFT]];
        precedence++;
        
        // addition and subtraction have the same precedence
        [operators addObject:[self infoForOperatorFunction:DDOperatorAdd tokens:@[@"+"] arity:BINARY precedence:precedence associativity:LEFT]];
        // \u2212 is −
        [operators addObject:[self infoForOperatorFunction:DDOperatorMinus tokens:@[@"-", @"\u2212"] arity:BINARY precedence:precedence associativity:LEFT]];
        precedence++;
        
        // multiplication and division have the same precedence
        // \u00d7 is ×
        [operators addObject:[self infoForOperatorFunction:DDOperatorMultiply tokens:@[@"*", @"\u00d7"] arity:BINARY precedence:precedence associativity:LEFT]];
        // \u00f7 is ÷
        [operators addObject:[self infoForOperatorFunction:DDOperatorDivide tokens:@[@"/", @"\u00f7"] arity:BINARY precedence:precedence associativity:LEFT]];
        precedence++;
        
#if DD_INTERPRET_PERCENT_SIGN_AS_MOD
        [operators addObject:[self infoForOperatorFunction:DDOperatorModulo tokens:@[@"%"] arity:BINARY precedence:precedence associativity:LEFT]];
        precedence++;
#endif
        
        [operators addObject:[self infoForOperatorFunction:DDOperatorBitwiseNot tokens:@[@"~"] arity:UNARY precedence:precedence associativity:RIGHT]];
        precedence++;
        
        // right associative unary operators have the same precedence
        // \u2212 is −
        [operators addObject:[self infoForOperatorFunction:DDOperatorUnaryMinus tokens:@[@"-", @"\u2212"] arity:UNARY precedence:precedence associativity:RIGHT]];
        [operators addObject:[self infoForOperatorFunction:DDOperatorUnaryPlus tokens:@[@"+"] arity:UNARY precedence:precedence associativity:RIGHT]];
        precedence++;
        
        // all the left associative unary operators have the same precedence
        [operators addObject:[self infoForOperatorFunction:DDOperatorFactorial tokens:@[@"!"] arity:UNARY precedence:precedence associativity:LEFT]];
        // \u00ba is º (option-0); not necessary a degree sign, but common enough for it
        // \u00b0 is °
        [operators addObject:[self infoForOperatorFunction:DDOperatorDegree tokens:@[@"\u00ba", @"\u00b0"] arity:UNARY precedence:precedence associativity:LEFT]];
        
#if !DD_INTERPRET_PERCENT_SIGN_AS_MOD
        [operators addObject:[self infoForOperatorFunction:DDOperatorPercent tokens:@[@"%"] arity:UNARY precedence:precedence associativity:LEFT]];
#endif
        
        precedence++;
        
        [operators addObject:[self infoForOperatorFunction:DDOperatorPower tokens:@[@"**"] arity:BINARY precedence:precedence associativity:RIGHT]];
        precedence++;
        
        // ( and ) have the same precedence
        // these are defined as unary right/left associative for convenience
        [operators addObject:[self infoForOperatorFunction:DDOperatorParenthesisOpen tokens:@[@"("] arity:UNARY precedence:precedence associativity:RIGHT]];
        [operators addObject:[self infoForOperatorFunction:DDOperatorParenthesisClose tokens:@[@")"] arity:UNARY precedence:precedence associativity:LEFT]];
        precedence++;
        
        [operators addObject:[self infoForOperatorFunction:DDOperatorComma tokens:@[@","] arity:DDOperatorArityUnknown precedence:precedence associativity:LEFT]];
        precedence++;
        
        _allOperators = [operators copy];
        NSArray *functions = [_allOperators valueForKey:@"function"];
        _operatorsByFunction = [NSDictionary dictionaryWithObjects:_allOperators forKeys:functions];
        
        
#if DD_INCLUDE_OPERATOR_WORDS
        // these should all be lowercase
        [[_operatorsByFunction objectForKey:DDOperatorLogicalOr] addTokens:@[@"or"]];
        [[_operatorsByFunction objectForKey:DDOperatorLogicalAnd] addTokens:@[@"and"]];
        [[_operatorsByFunction objectForKey:DDOperatorLogicalEqual] addTokens:@[@"eq"]];
        [[_operatorsByFunction objectForKey:DDOperatorLogicalNotEqual] addTokens:@[@"neq"]];
        [[_operatorsByFunction objectForKey:DDOperatorLogicalLessThan] addTokens:@[@"lt"]];
        [[_operatorsByFunction objectForKey:DDOperatorLogicalGreaterThan] addTokens:@[@"gt"]];
        [[_operatorsByFunction objectForKey:DDOperatorLogicalLessThanOrEqual] addTokens:@[@"lte", @"ltoe"]];
        [[_operatorsByFunction objectForKey:DDOperatorLogicalGreaterThanOrEqual] addTokens:@[@"gte", @"gtoe"]];
#endif
        
        NSMutableDictionary *lookupByToken = [NSMutableDictionary dictionary];
        for (_DDOperatorInfo *info in _allOperators) {
            NSArray *tokens = [info tokens];
            for (NSString *token in tokens) {
                NSMutableArray *infosForThisToken = [lookupByToken objectForKey:token];
                if (infosForThisToken == nil) {
                    infosForThisToken = [NSMutableArray array];
                    [lookupByToken setObject:infosForThisToken forKey:token];
                }
                [infosForThisToken addObject:info];
            }
        }
        _infosByToken = [lookupByToken copy];
    });
}

+ (NSArray *)allOperators {
    [self _buildOperators];
    return _allOperators;
}

@end
