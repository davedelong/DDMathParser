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
@synthesize precedence=_precedence;
@synthesize token=_token;
@synthesize function=_function;

- (id)initWithOperator:(DDOperator)operator arity:(DDOperatorArity)arity precedence:(NSInteger)precedence token:(NSString *)token function:(NSString *)function {
    self = [super init];
    if (self) {
        _operator = operator;
        _arity = arity;
        _precedence = precedence;
        _token = DD_RETAIN(token);
        _function = DD_RETAIN(function);
    }
    return self;
}

+ (id)infoForOperator:(DDOperator)operator arity:(DDOperatorArity)arity precedence:(NSInteger)precedence token:(NSString *)token function:(NSString *)function {
    return DD_AUTORELEASE([[self alloc] initWithOperator:operator arity:arity precedence:precedence token:token function:function]);
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
    
    [operators addObject:[self infoForOperator:DDOperatorLogicalOr arity:DDOperatorArityBinary precedence:precedence token:@"||" function:@"l_or"]];
    [operators addObject:[self infoForOperator:DDOperatorLogicalOr arity:DDOperatorArityBinary precedence:precedence token:@"\u2228" function:@"l_or"]];
    precedence++;
    
    [operators addObject:[self infoForOperator:DDOperatorLogicalAnd arity:DDOperatorArityBinary precedence:precedence token:@"&&" function:@"l_and"]];
    [operators addObject:[self infoForOperator:DDOperatorLogicalAnd arity:DDOperatorArityBinary precedence:precedence token:@"\u2227" function:@"l_and"]];
    precedence++;
    
    // == and != have the same precedence
    [operators addObject:[self infoForOperator:DDOperatorLogicalEqual arity:DDOperatorArityBinary precedence:precedence token:@"==" function:@"l_eq"]];
    [operators addObject:[self infoForOperator:DDOperatorLogicalNotEqual arity:DDOperatorArityBinary precedence:precedence token:@"!=" function:@"l_neq"]];
    precedence++;
    
    [operators addObject:[self infoForOperator:DDOperatorLogicalLessThan arity:DDOperatorArityBinary precedence:precedence token:@"<" function:@"l_lt"]];
    precedence++;
    
    [operators addObject:[self infoForOperator:DDOperatorLogicalGreaterThan arity:DDOperatorArityBinary precedence:precedence token:@">" function:@"l_gt"]];
    precedence++;
    
    [operators addObject:[self infoForOperator:DDOperatorLogicalLessThanOrEqual arity:DDOperatorArityBinary precedence:precedence token:@"<=" function:@"l_ltoe"]];
    [operators addObject:[self infoForOperator:DDOperatorLogicalLessThanOrEqual arity:DDOperatorArityBinary precedence:precedence token:@"\u2264" function:@"l_ltoe"]];
    precedence++;
    
    [operators addObject:[self infoForOperator:DDOperatorLogicalGreaterThanOrEqual arity:DDOperatorArityBinary precedence:precedence token:@">=" function:@"l_gtoe"]];
    [operators addObject:[self infoForOperator:DDOperatorLogicalGreaterThanOrEqual arity:DDOperatorArityBinary precedence:precedence token:@"\u2265" function:@"l_gtoe"]];
    precedence++;
    
    [operators addObject:[self infoForOperator:DDOperatorLogicalNot arity:DDOperatorArityUnary precedence:precedence token:@"!" function:@"l_not"]];
    [operators addObject:[self infoForOperator:DDOperatorLogicalNot arity:DDOperatorArityUnary precedence:precedence token:@"\u00ac" function:@"l_not"]];
    precedence++;
    
    [operators addObject:[self infoForOperator:DDOperatorBitwiseOr arity:DDOperatorArityBinary precedence:precedence token:@"|" function:@"or"]];
    precedence++;
    
    [operators addObject:[self infoForOperator:DDOperatorBitwiseXor arity:DDOperatorArityBinary precedence:precedence token:@"^" function:@"xor"]];
    precedence++;
    
    [operators addObject:[self infoForOperator:DDOperatorBitwiseAnd arity:DDOperatorArityBinary precedence:precedence token:@"&" function:@"and"]];
    precedence++;
    
    [operators addObject:[self infoForOperator:DDOperatorLeftShift arity:DDOperatorArityBinary precedence:precedence token:@"<<" function:@"lshift"]];
    precedence++;
    
    [operators addObject:[self infoForOperator:DDOperatorRightShift arity:DDOperatorArityBinary precedence:precedence token:@">>" function:@"rshift"]];
    precedence++;

    // addition and subtraction have the same precedence
    [operators addObject:[self infoForOperator:DDOperatorAdd arity:DDOperatorArityBinary precedence:precedence token:@"+" function:@"add"]];
    [operators addObject:[self infoForOperator:DDOperatorMinus arity:DDOperatorArityBinary precedence:precedence token:@"-" function:@"subtract"]];
    precedence++;

    // multiplication and division have the same precedence
    [operators addObject:[self infoForOperator:DDOperatorMultiply arity:DDOperatorArityBinary precedence:precedence token:@"*" function:@"multiply"]];
    [operators addObject:[self infoForOperator:DDOperatorDivide arity:DDOperatorArityBinary precedence:precedence token:@"/" function:@"divide"]];
    precedence++;
    
    [operators addObject:[self infoForOperator:DDOperatorModulo arity:DDOperatorArityBinary precedence:precedence token:@"%" function:@"mod"]];
    precedence++;
    
    [operators addObject:[self infoForOperator:DDOperatorBitwiseNot arity:DDOperatorArityUnary precedence:precedence token:@"~" function:@"not"]];
    precedence++;
    
    [operators addObject:[self infoForOperator:DDOperatorUnaryMinus arity:DDOperatorArityUnary precedence:precedence token:@"-" function:@"negate"]];
    precedence++;
    
    [operators addObject:[self infoForOperator:DDOperatorUnaryPlus arity:DDOperatorArityUnary precedence:precedence token:@"+" function:@""]];
    precedence++;
    
    [operators addObject:[self infoForOperator:DDOperatorFactorial arity:DDOperatorArityUnary precedence:precedence token:@"!" function:@"factorial"]];
    precedence++;
    
    [operators addObject:[self infoForOperator:DDOperatorPower arity:DDOperatorArityBinary precedence:precedence token:@"**" function:@"pow"]];
    precedence++;
    
    // ( and ) have the same precedence
    [operators addObject:[self infoForOperator:DDOperatorParenthesisOpen arity:DDOperatorArityUnknown precedence:precedence token:@"(" function:@""]];
    [operators addObject:[self infoForOperator:DDOperatorParenthesisClose arity:DDOperatorArityUnknown precedence:precedence token:@")" function:@""]];
    precedence++;
    
    [operators addObject:[self infoForOperator:DDOperatorComma arity:DDOperatorArityUnknown precedence:precedence token:@"," function:@""]];
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
