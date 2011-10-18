//
//  _DDOperatorInfo.m
//  DDMathParser
//
//  Created by Dave DeLong on 10/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "_DDOperatorInfo.h"

@implementation _DDOperatorInfo

@synthesize operator=_operator;
@synthesize arity=_arity;
@synthesize defaultAssociativity=_defaultAssociativity;
@synthesize precedence=_precedence;
@synthesize token=_token;
@synthesize function=_function;

- (id)initWithOperator:(DDOperator)operator arity:(DDOperatorArity)arity precedence:(NSInteger)precedence token:(NSString *)token function:(NSString *)function associativity:(DDOperatorAssociativity)associativity {
    self = [super init];
    if (self) {
        _operator = operator;
        _arity = arity;
        _defaultAssociativity = associativity;
        _precedence = precedence;
        _token = DD_RETAIN(token);
        _function = DD_RETAIN(function);
    }
    return self;
}

+ (id)infoForOperator:(DDOperator)operator arity:(DDOperatorArity)arity precedence:(NSInteger)precedence token:(NSString *)token function:(NSString *)function associativity:(DDOperatorAssociativity)associativity {
    return DD_AUTORELEASE([[self alloc] initWithOperator:operator arity:arity precedence:precedence token:token function:function associativity:associativity]);
}

+ (NSArray *)infosForOperator:(DDOperator)operator {
    static dispatch_once_t onceToken;
    static NSMutableDictionary *_operatorLookup = nil;
    dispatch_once(&onceToken, ^{
        _operatorLookup = [[NSMutableDictionary alloc] init];
        
        NSArray *operators = [self allOperators];
        for (_DDOperatorInfo *info in operators) {
            DDOperator op = [info operator];
            NSNumber *key = [NSNumber numberWithInt:op];
            
            NSMutableArray *value = [_operatorLookup objectForKey:key];
            if (value == nil) {
                value = [NSMutableArray array];
                [_operatorLookup setObject:value forKey:key];
            }
            [value addObject:info];
        }
    });
    return [_operatorLookup objectForKey:[NSNumber numberWithInt:operator]];
}

+ (NSArray *)infosForOperatorToken:(NSString *)token {
    static dispatch_once_t onceToken;
    static NSMutableDictionary *_operatorLookup = nil;
    dispatch_once(&onceToken, ^{
        _operatorLookup = [[NSMutableDictionary alloc] init];
        
        NSArray *operators = [self allOperators];
        for (_DDOperatorInfo *info in operators) {
            
            NSMutableArray *value = [_operatorLookup objectForKey:[info token]];
            if (value == nil) {
                value = [NSMutableArray array];
                [_operatorLookup setObject:value forKey:[info token]];
            }
            [value addObject:info];
        }
    });
    return [_operatorLookup objectForKey:token];
}

#if !DD_HAS_ARC
- (void)dealloc {
    [_token release];
    [_function release];
    [super dealloc];
}
#endif

+ (NSArray *)_buildOperators {
    NSMutableArray *operators = [NSMutableArray array];
    NSInteger precedence = 0;
    
    [operators addObject:[self infoForOperator:DDOperatorLogicalOr arity:DDOperatorArityBinary precedence:precedence token:@"||" function:@"l_or" associativity:DDOperatorAssociativityLeft]];
    [operators addObject:[self infoForOperator:DDOperatorLogicalOr arity:DDOperatorArityBinary precedence:precedence token:@"\u2228" function:@"l_or" associativity:DDOperatorAssociativityLeft]];
    precedence++;
    
    [operators addObject:[self infoForOperator:DDOperatorLogicalAnd arity:DDOperatorArityBinary precedence:precedence token:@"&&" function:@"l_and" associativity:DDOperatorAssociativityLeft]];
    [operators addObject:[self infoForOperator:DDOperatorLogicalAnd arity:DDOperatorArityBinary precedence:precedence token:@"\u2227" function:@"l_and" associativity:DDOperatorAssociativityLeft]];
    precedence++;
    
    // == and != have the same precedence
    [operators addObject:[self infoForOperator:DDOperatorLogicalEqual arity:DDOperatorArityBinary precedence:precedence token:@"==" function:@"l_eq" associativity:DDOperatorAssociativityLeft]];
    [operators addObject:[self infoForOperator:DDOperatorLogicalEqual arity:DDOperatorArityBinary precedence:precedence token:@"=" function:@"l_eq" associativity:DDOperatorAssociativityLeft]];
    [operators addObject:[self infoForOperator:DDOperatorLogicalNotEqual arity:DDOperatorArityBinary precedence:precedence token:@"!=" function:@"l_neq" associativity:DDOperatorAssociativityLeft]];
    precedence++;
    
    [operators addObject:[self infoForOperator:DDOperatorLogicalLessThan arity:DDOperatorArityBinary precedence:precedence token:@"<" function:@"l_lt" associativity:DDOperatorAssociativityLeft]];
    precedence++;
    
    [operators addObject:[self infoForOperator:DDOperatorLogicalGreaterThan arity:DDOperatorArityBinary precedence:precedence token:@">" function:@"l_gt" associativity:DDOperatorAssociativityLeft]];
    precedence++;
    
    [operators addObject:[self infoForOperator:DDOperatorLogicalLessThanOrEqual arity:DDOperatorArityBinary precedence:precedence token:@"<=" function:@"l_ltoe" associativity:DDOperatorAssociativityLeft]];
    [operators addObject:[self infoForOperator:DDOperatorLogicalLessThanOrEqual arity:DDOperatorArityBinary precedence:precedence token:@"\u2264" function:@"l_ltoe" associativity:DDOperatorAssociativityLeft]];
    precedence++;
    
    [operators addObject:[self infoForOperator:DDOperatorLogicalGreaterThanOrEqual arity:DDOperatorArityBinary precedence:precedence token:@">=" function:@"l_gtoe" associativity:DDOperatorAssociativityLeft]];
    [operators addObject:[self infoForOperator:DDOperatorLogicalGreaterThanOrEqual arity:DDOperatorArityBinary precedence:precedence token:@"\u2265" function:@"l_gtoe" associativity:DDOperatorAssociativityLeft]];
    precedence++;
    
    [operators addObject:[self infoForOperator:DDOperatorLogicalNot arity:DDOperatorArityUnary precedence:precedence token:@"!" function:@"l_not" associativity:DDOperatorAssociativityRight]];
    [operators addObject:[self infoForOperator:DDOperatorLogicalNot arity:DDOperatorArityUnary precedence:precedence token:@"\u00ac" function:@"l_not" associativity:DDOperatorAssociativityRight]];
    precedence++;
    
    [operators addObject:[self infoForOperator:DDOperatorBitwiseOr arity:DDOperatorArityBinary precedence:precedence token:@"|" function:@"or" associativity:DDOperatorAssociativityLeft]];
    precedence++;
    
    [operators addObject:[self infoForOperator:DDOperatorBitwiseXor arity:DDOperatorArityBinary precedence:precedence token:@"^" function:@"xor" associativity:DDOperatorAssociativityLeft]];
    precedence++;
    
    [operators addObject:[self infoForOperator:DDOperatorBitwiseAnd arity:DDOperatorArityBinary precedence:precedence token:@"&" function:@"and" associativity:DDOperatorAssociativityLeft]];
    precedence++;
    
    [operators addObject:[self infoForOperator:DDOperatorLeftShift arity:DDOperatorArityBinary precedence:precedence token:@"<<" function:@"lshift" associativity:DDOperatorAssociativityLeft]];
    precedence++;
    
    [operators addObject:[self infoForOperator:DDOperatorRightShift arity:DDOperatorArityBinary precedence:precedence token:@">>" function:@"rshift" associativity:DDOperatorAssociativityLeft]];
    precedence++;

    // addition and subtraction have the same precedence
    [operators addObject:[self infoForOperator:DDOperatorAdd arity:DDOperatorArityBinary precedence:precedence token:@"+" function:@"add" associativity:DDOperatorAssociativityLeft]];
    [operators addObject:[self infoForOperator:DDOperatorMinus arity:DDOperatorArityBinary precedence:precedence token:@"-" function:@"subtract" associativity:DDOperatorAssociativityLeft]];
    precedence++;

    // multiplication and division have the same precedence
    [operators addObject:[self infoForOperator:DDOperatorMultiply arity:DDOperatorArityBinary precedence:precedence token:@"*" function:@"multiply" associativity:DDOperatorAssociativityLeft]];
    [operators addObject:[self infoForOperator:DDOperatorMultiply arity:DDOperatorArityBinary precedence:precedence token:@"\u00d7" function:@"multiply" associativity:DDOperatorAssociativityLeft]];
    [operators addObject:[self infoForOperator:DDOperatorDivide arity:DDOperatorArityBinary precedence:precedence token:@"/" function:@"divide" associativity:DDOperatorAssociativityLeft]];
    [operators addObject:[self infoForOperator:DDOperatorDivide arity:DDOperatorArityBinary precedence:precedence token:@"\u00f7" function:@"divide" associativity:DDOperatorAssociativityLeft]];
    precedence++;
    
    [operators addObject:[self infoForOperator:DDOperatorModulo arity:DDOperatorArityBinary precedence:precedence token:@"%" function:@"mod" associativity:DDOperatorAssociativityLeft]];
    precedence++;
    
    [operators addObject:[self infoForOperator:DDOperatorBitwiseNot arity:DDOperatorArityUnary precedence:precedence token:@"~" function:@"not" associativity:DDOperatorAssociativityLeft]];
    precedence++;
    
    // right associative unary operators have the same precedence
    [operators addObject:[self infoForOperator:DDOperatorUnaryMinus arity:DDOperatorArityUnary precedence:precedence token:@"-" function:@"negate" associativity:DDOperatorAssociativityRight]];
    [operators addObject:[self infoForOperator:DDOperatorUnaryPlus arity:DDOperatorArityUnary precedence:precedence token:@"+" function:@"" associativity:DDOperatorAssociativityRight]];
    precedence++;
    
    // there's only one left associative unary operator
    [operators addObject:[self infoForOperator:DDOperatorFactorial arity:DDOperatorArityUnary precedence:precedence token:@"!" function:@"factorial" associativity:DDOperatorAssociativityLeft]];
    precedence++;
    
    [operators addObject:[self infoForOperator:DDOperatorPower arity:DDOperatorArityBinary precedence:precedence token:@"**" function:@"pow" associativity:DDOperatorAssociativityRight]];
    precedence++;
    
    // ( and ) have the same precedence
    // these are defined as unary right/left associative for convenience
    [operators addObject:[self infoForOperator:DDOperatorParenthesisOpen arity:DDOperatorArityUnary precedence:precedence token:@"(" function:@"" associativity:DDOperatorAssociativityRight]];
    [operators addObject:[self infoForOperator:DDOperatorParenthesisClose arity:DDOperatorArityUnary precedence:precedence token:@")" function:@"" associativity:DDOperatorAssociativityLeft]];
    precedence++;
    
    [operators addObject:[self infoForOperator:DDOperatorComma arity:DDOperatorArityUnknown precedence:precedence token:@"," function:@"" associativity:DDOperatorAssociativityLeft]];
    precedence++;
    
    return operators;
}

+ (NSArray *)allOperators {
    static NSArray *_allOperators;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _allOperators = [[self _buildOperators] copy];
    });
    return _allOperators;
}

@end
