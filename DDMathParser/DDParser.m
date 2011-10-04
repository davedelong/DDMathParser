//
//  DDParser.m
//  DDMathParser
//
//  Created by Dave DeLong on 11/24/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "DDMathParser.h"
#import "DDParser.h"
#import "DDMathParserMacros.h"
#import "_DDParserTerm.h"
#import "DDParserTypes.h"
#import "DDMathStringTokenizer.h"
#import "DDMathStringTokenizer.h"
#import "DDMathStringToken.h"
#import "DDExpression.h"
#import "_DDOperatorInfo.h"

@implementation DDParser

@synthesize bitwiseOrAssociativity;
@synthesize bitwiseXorAssociativity;
@synthesize bitwiseAndAssociativity;
@synthesize bitwiseLeftShiftAssociativity;
@synthesize bitwiseRightShiftAssociativity;
@synthesize additionAssociativity;
@synthesize multiplicationAssociativity;
@synthesize modAssociativity;
@synthesize powerAssociativity;

+ (void) initialize {
	if (self == [DDParser class]) {
		//determine what associativity NSPredicate/NSExpression is using
		//mathematically, it should be right associative, but it's usually parsed as left associative
		//rdar://problem/8692313
		NSExpression * powerExpression = [(NSComparisonPredicate *)[NSPredicate predicateWithFormat:@"2 ** 3 ** 2 == 0"] leftExpression];
		NSNumber * powerResult = [powerExpression expressionValueWithObject:nil context:nil];
		if ([powerResult intValue] == 512) {
			[self setDefaultPowerAssociativity:DDOperatorAssociativityRight];
		}
	}
    [super initialize];
}

#define GET_ASSOCIATIVITY(_op) { \
NSArray *ops = [_DDOperatorInfo infosForOperator:(_op)]; \
_DDOperatorInfo *info = [ops objectAtIndex:0]; \
return [info defaultAssociativity]; \
}

#define SET_ASSOCIATIVITY(_op,_a) { \
NSArray *ops = [_DDOperatorInfo infosForOperator:(_op)]; \
for (_DDOperatorInfo *info in ops) { \
[info setDefaultAssociativity:(_a)]; \
} \
}

+ (DDOperatorAssociativity) defaultBitwiseOrAssociativity { GET_ASSOCIATIVITY(DDOperatorBitwiseOr); }
+ (void) setDefaultBitwiseOrAssociativity:(DDOperatorAssociativity)newAssociativity {  SET_ASSOCIATIVITY(DDOperatorBitwiseOr, newAssociativity); }

+ (DDOperatorAssociativity) defaultBitwiseXorAssociativity { GET_ASSOCIATIVITY(DDOperatorBitwiseXor); }
+ (void) setDefaultBitwiseXorAssociativity:(DDOperatorAssociativity)newAssociativity { SET_ASSOCIATIVITY(DDOperatorBitwiseXor, newAssociativity); }

+ (DDOperatorAssociativity) defaultBitwiseAndAssociativity { GET_ASSOCIATIVITY(DDOperatorBitwiseAnd); }
+ (void) setDefaultBitwiseAndAssociativity:(DDOperatorAssociativity)newAssociativity { SET_ASSOCIATIVITY(DDOperatorBitwiseAnd, newAssociativity); }

+ (DDOperatorAssociativity) defaultBitwiseLeftShiftAssociativity { GET_ASSOCIATIVITY(DDOperatorLeftShift); }
+ (void) setDefaultBitwiseLeftShiftAssociativity:(DDOperatorAssociativity)newAssociativity { SET_ASSOCIATIVITY(DDOperatorLeftShift, newAssociativity); }

+ (DDOperatorAssociativity) defaultBitwiseRightShiftAssociativity { GET_ASSOCIATIVITY(DDOperatorRightShift); }
+ (void) setDefaultBitwiseRightShiftAssociativity:(DDOperatorAssociativity)newAssociativity { SET_ASSOCIATIVITY(DDOperatorRightShift, newAssociativity); }

+ (DDOperatorAssociativity) defaultAdditionAssociativity { GET_ASSOCIATIVITY(DDOperatorAdd); }
+ (void) setDefaultAdditionAssociativity:(DDOperatorAssociativity)newAssociativity {
    SET_ASSOCIATIVITY(DDOperatorAdd, newAssociativity);
    SET_ASSOCIATIVITY(DDOperatorMinus, newAssociativity);
}

+ (DDOperatorAssociativity) defaultMultiplicationAssociativity { GET_ASSOCIATIVITY(DDOperatorMultiply); }
+ (void) setDefaultMultiplicationAssociativity:(DDOperatorAssociativity)newAssociativity {
    SET_ASSOCIATIVITY(DDOperatorMultiply, newAssociativity);
    SET_ASSOCIATIVITY(DDOperatorDivide, newAssociativity);
}

+ (DDOperatorAssociativity) defaultModAssociativity { GET_ASSOCIATIVITY(DDOperatorModulo); }
+ (void) setDefaultModAssociativity:(DDOperatorAssociativity)newAssociativity { SET_ASSOCIATIVITY(DDOperatorModulo, newAssociativity); }

+ (DDOperatorAssociativity) defaultPowerAssociativity { GET_ASSOCIATIVITY(DDOperatorPower); }
+ (void) setDefaultPowerAssociativity:(DDOperatorAssociativity)newAssociativity { SET_ASSOCIATIVITY(DDOperatorPower, newAssociativity); }


+ (id) parserWithString:(NSString *)string error:(NSError **)error {
    return DD_AUTORELEASE([[self alloc] initWithString:string error:error]);
}

- (id) initWithString:(NSString *)string error:(NSError **)error {
    DDMathStringTokenizer *t = [DDMathStringTokenizer tokenizerWithString:string error:error];
    return [self initWithTokenizer:t error:error];
}

+ (id)parserWithTokenizer:(DDMathStringTokenizer *)tokenizer error:(NSError **)error {
	return DD_AUTORELEASE([[self alloc] initWithTokenizer:tokenizer error:error]);
}

- (id)initWithTokenizer:(DDMathStringTokenizer *)t error:(NSError **)error {
	ERR_ASSERT(error);
	self = [super init];
	if (self) {
		tokenizer = DD_RETAIN(t);
		if (!tokenizer) {
			DD_RELEASE(self);
			return nil;
		}
		
		bitwiseOrAssociativity = [[self class] defaultBitwiseOrAssociativity];
		bitwiseXorAssociativity = [[self class] defaultBitwiseXorAssociativity];
		bitwiseAndAssociativity = [[self class] defaultBitwiseAndAssociativity];
		bitwiseLeftShiftAssociativity = [[self class] defaultBitwiseLeftShiftAssociativity];
		bitwiseRightShiftAssociativity = [[self class] defaultBitwiseRightShiftAssociativity];
		additionAssociativity = [[self class] defaultAdditionAssociativity];
		multiplicationAssociativity = [[self class] defaultMultiplicationAssociativity];
		modAssociativity = [[self class] defaultModAssociativity];
		powerAssociativity = [[self class] defaultPowerAssociativity];
	}
	return self;
}

#if !DD_HAS_ARC
- (void) dealloc {
	[tokenizer release];
	[super dealloc];
}
#endif

- (DDOperatorAssociativity) associativityForOperator:(DDOperator)operatorType {
	switch (operatorType) {
        // binary operators can have customizable associativity
		case DDOperatorBitwiseOr: return bitwiseOrAssociativity;
		case DDOperatorBitwiseXor: return bitwiseXorAssociativity;
		case DDOperatorBitwiseAnd: return bitwiseAndAssociativity;
		case DDOperatorLeftShift: return bitwiseLeftShiftAssociativity;
		case DDOperatorRightShift: return bitwiseRightShiftAssociativity;
		case DDOperatorMinus:
		case DDOperatorAdd: return additionAssociativity;
		case DDOperatorDivide:
		case DDOperatorMultiply: return multiplicationAssociativity;
		case DDOperatorModulo: return modAssociativity;
		case DDOperatorPower: return powerAssociativity;
			
        // unary operators are always right associative (except for factorial)
        case DDOperatorUnaryPlus:
        case DDOperatorUnaryMinus:
		case DDOperatorBitwiseNot: return DDOperatorAssociativityRight;
            
        // factorial is always left associative
        case DDOperatorFactorial: return DDOperatorAssociativityLeft;
        // logical not is always right associative
        case DDOperatorLogicalNot: return DDOperatorAssociativityRight;
            
		default: return DDOperatorAssociativityLeft;
	}
	return DDOperatorAssociativityLeft;
}

- (DDExpression *) parsedExpressionWithError:(NSError **)error {
	ERR_ASSERT(error);
	[tokenizer reset]; //reset the token stream
    
    DDExpression *expression = nil;
    
    _DDParserTerm *root = [_DDParserTerm rootTermWithTokenizer:tokenizer error:error];
    if ([root resolveWithParser:self error:error]) {
        expression = [root expressionWithError:error];
    }
    
	return expression;
}

@end
