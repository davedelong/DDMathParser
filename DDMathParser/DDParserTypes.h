//
//  DDParserTypes.h
//  DDMathParser
//
//  Created by Dave DeLong on 12/4/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	DDOperatorAssociativityLeft = 0,
	DDOperatorAssociativityRight = 1
} DDOperatorAssociativity;

typedef enum {
	DDTokenTypeNumber = 0,
	DDTokenTypeOperator = 1,
	DDTokenTypeFunction = 2,
	DDTokenTypeVariable = 3
} DDTokenType;

typedef enum {
	DDOperatorInvalid = 0,
	
	DDOperatorBitwiseOr,
	DDOperatorBitwiseXor,
	DDOperatorBitwiseAnd,
	DDOperatorLeftShift,
	DDOperatorRightShift,
	DDOperatorMinus,
	DDOperatorAdd,
	DDOperatorDivide,
	DDOperatorMultiply,
	DDOperatorModulo,
	DDOperatorBitwiseNot,
	DDOperatorFactorial,
	DDOperatorPower,
	DDOperatorParenthesisOpen,
	DDOperatorParenthesisClose,
	
	DDOperatorComma,
	DDOperatorNegate,
} DDOperator;

enum {
	DDPrecedenceBitwiseOr = 0,
	DDPrecedenceBitwiseXor,
	DDPrecedenceBitwiseAnd,
	DDPrecedenceLeftShift,
	DDPrecedenceRightShift,
	DDPrecedenceSubtraction,
	DDPrecedenceAddition,
	DDPrecedenceDivision,
	DDPrecedenceMultiplication,
	DDPrecedenceModulo,
	DDPrecedenceUnary,
	DDPrecedenceFactorial,
	DDPrecedencePower,
	DDPrecedenceParentheses,
	
	DDPrecedenceUnknown = -1
};

enum {
	DDPrecedenceNone = DDPrecedenceUnknown
};
typedef NSInteger DDPrecedence;

//the layout of this array must have the same lyout as the DDPrecedence enum
static NSString * const DDOperatorNames[] = {
	@"or",
	@"xor",
	@"and",
	@"lshift",
	@"rshift",
	@"subtract",
	@"add",
	@"divide",
	@"multiply",
	@"mod",
	@"not",
	@"factorial",
	@"pow",
	nil
};