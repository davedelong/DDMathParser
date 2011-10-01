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
    precedence++;
    
    [operators addObject:[self infoForOperator:DDOperatorLogicalAnd arity:DDOperatorArityBinary precedence:precedence token:@"&&" function:@"l_and"]];
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
    
    [operators addObject:[self infoForOperator:DDOperatorMinus arity:DDOperatorArityBinary precedence:precedence token:@"-" function:@"subtract"]];
    // DO NOT INCREMENT PRECEDENCE
    // the next operator is addition, which has the same precedence
    
    [operators addObject:[self infoForOperator:DDOperatorAdd arity:DDOperatorArityBinary precedence:precedence token:@"+" function:@"add"]];
    precedence++;
    
    [operators addObject:[self infoForOperator:DDOperatorDivide arity:DDOperatorArityBinary precedence:precedence token:@"/" function:@"divide"]];
    // DO NOT INCREMENT PRECEDENCE
    // the next operator is multiplication, which has the same precedence
    
    [operators addObject:[self infoForOperator:DDOperatorMultiply arity:DDOperatorArityBinary precedence:precedence token:@"*" function:@"multiply"]];
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
    
    [operators addObject:[self infoForOperator:DDOperatorParenthesisOpen arity:DDOperatorArityUnknown precedence:precedence token:@"(" function:@""]];
    // DO NOT INCREMENT PRECEDENCE
    // the next operator is ), which has the same precedence
    
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
