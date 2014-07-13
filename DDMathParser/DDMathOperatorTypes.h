//
//  DDMathOperatorTypes.h
//  DDMathParser
//
//  Created by Dave DeLong on 12/4/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, DDMathOperatorAssociativity) {
	DDMathOperatorAssociativityLeft = 0,
	DDMathOperatorAssociativityRight = 1
};

typedef NS_ENUM(NSInteger, DDMathOperatorArity) {
    DDMathOperatorArityUnknown = 0,
    
    DDMathOperatorArityUnary,
    DDMathOperatorArityBinary
};

extern NSString *const DDMathOperatorLogicalOr;
extern NSString *const DDMathOperatorLogicalAnd;
extern NSString *const DDMathOperatorLogicalNot;
extern NSString *const DDMathOperatorLogicalEqual;
extern NSString *const DDMathOperatorLogicalNotEqual;
extern NSString *const DDMathOperatorLogicalLessThan;
extern NSString *const DDMathOperatorLogicalGreaterThan;
extern NSString *const DDMathOperatorLogicalLessThanOrEqual;
extern NSString *const DDMathOperatorLogicalGreaterThanOrEqual;
extern NSString *const DDMathOperatorBitwiseOr;
extern NSString *const DDMathOperatorBitwiseXor;
extern NSString *const DDMathOperatorBitwiseAnd;
extern NSString *const DDMathOperatorLeftShift;
extern NSString *const DDMathOperatorRightShift;
extern NSString *const DDMathOperatorMinus;
extern NSString *const DDMathOperatorAdd;
extern NSString *const DDMathOperatorDivide;
extern NSString *const DDMathOperatorMultiply;
extern NSString *const DDMathOperatorModulo;
extern NSString *const DDMathOperatorBitwiseNot;
extern NSString *const DDMathOperatorFactorial;
extern NSString *const DDMathOperatorDegree;
extern NSString *const DDMathOperatorPercent;
extern NSString *const DDMathOperatorPower;
extern NSString *const DDMathOperatorParenthesisOpen;
extern NSString *const DDMathOperatorParenthesisClose;
extern NSString *const DDMathOperatorComma;
extern NSString *const DDMathOperatorUnaryMinus;
extern NSString *const DDMathOperatorUnaryPlus;
extern NSString *const DDMathOperatorSquareRoot;
extern NSString *const DDMathOperatorCubeRoot;

#define UNARY DDMathOperatorArityUnary
#define BINARY DDMathOperatorArityBinary
#define LEFT DDMathOperatorAssociativityLeft
#define RIGHT DDMathOperatorAssociativityRight
#define OPERATOR(_func, _toks, _arity, _prec, _assoc) [[DDMathOperator alloc] initWithOperatorFunction:(_func) tokens:(_toks) arity:(_arity) precedence:(_prec) associativity:(_assoc)]
