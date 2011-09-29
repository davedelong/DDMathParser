//
//  DDParser.m
//  DDMathParser
//
//  Created by Dave DeLong on 11/24/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "DDParser.h"
#import "DDMathParserMacros.h"
#import "_DDParserTerm.h"
#import "DDParserTypes.h"
#import "DDMathStringTokenizer.h"
#import "DDMathStringTokenizer.h"
#import "DDMathStringToken.h"
#import "DDExpression.h"

static DDOperatorAssociativity defaultBitwiseOrAssociativity = DDOperatorAssociativityLeft;
static DDOperatorAssociativity defaultBitwiseXorAssociativity = DDOperatorAssociativityLeft;
static DDOperatorAssociativity defaultBitwiseAndAssociativity = DDOperatorAssociativityLeft;
static DDOperatorAssociativity defaultBitwiseLeftShiftAssociativity = DDOperatorAssociativityLeft;
static DDOperatorAssociativity defaultBitwiseRightShiftAssociativity = DDOperatorAssociativityLeft;
static DDOperatorAssociativity defaultAdditionAssociativity = DDOperatorAssociativityLeft;
static DDOperatorAssociativity defaultMultiplicationAssociativity = DDOperatorAssociativityLeft;
static DDOperatorAssociativity defaultModAssociativity = DDOperatorAssociativityLeft;
static DDOperatorAssociativity defaultPowerAssociativity = DDOperatorAssociativityLeft;

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

+ (DDOperatorAssociativity) defaultBitwiseOrAssociativity { return defaultBitwiseOrAssociativity; }
+ (void) setDefaultBitwiseOrAssociativity:(DDOperatorAssociativity)newAssociativity { defaultBitwiseOrAssociativity = newAssociativity; }

+ (DDOperatorAssociativity) defaultBitwiseXorAssociativity { return defaultBitwiseXorAssociativity; }
+ (void) setDefaultBitwiseXorAssociativity:(DDOperatorAssociativity)newAssociativity { defaultBitwiseXorAssociativity = newAssociativity; }

+ (DDOperatorAssociativity) defaultBitwiseAndAssociativity { return defaultBitwiseAndAssociativity; }
+ (void) setDefaultBitwiseAndAssociativity:(DDOperatorAssociativity)newAssociativity { defaultBitwiseAndAssociativity = newAssociativity; }

+ (DDOperatorAssociativity) defaultBitwiseLeftShiftAssociativity { return defaultBitwiseLeftShiftAssociativity; }
+ (void) setDefaultBitwiseLeftShiftAssociativity:(DDOperatorAssociativity)newAssociativity { defaultBitwiseLeftShiftAssociativity = newAssociativity; }

+ (DDOperatorAssociativity) defaultBitwiseRightShiftAssociativity { return defaultBitwiseRightShiftAssociativity; }
+ (void) setDefaultBitwiseRightShiftAssociativity:(DDOperatorAssociativity)newAssociativity { defaultBitwiseRightShiftAssociativity = newAssociativity; }

+ (DDOperatorAssociativity) defaultAdditionAssociativity { return defaultAdditionAssociativity; }
+ (void) setDefaultAdditionAssociativity:(DDOperatorAssociativity)newAssociativity { defaultAdditionAssociativity = newAssociativity; }

+ (DDOperatorAssociativity) defaultMultiplicationAssociativity { return defaultMultiplicationAssociativity; }
+ (void) setDefaultMultiplicationAssociativity:(DDOperatorAssociativity)newAssociativity { defaultMultiplicationAssociativity = newAssociativity; }

+ (DDOperatorAssociativity) defaultModAssociativity { return defaultModAssociativity; }
+ (void) setDefaultModAssociativity:(DDOperatorAssociativity)newAssociativity { defaultModAssociativity = newAssociativity; }

+ (DDOperatorAssociativity) defaultPowerAssociativity { return defaultPowerAssociativity; }
+ (void) setDefaultPowerAssociativity:(DDOperatorAssociativity)newAssociativity { defaultPowerAssociativity = newAssociativity; }


+ (id) parserWithString:(NSString *)string error:(NSError **)error {
    return AUTORELEASE([[self alloc] initWithString:string error:error]);
}

- (id) initWithString:(NSString *)string error:(NSError **)error {
    DDMathStringTokenizer *t = [DDMathStringTokenizer tokenizerWithString:string error:error];
    return [self initWithTokenizer:t error:error];
}

+ (id)parserWithTokenizer:(DDMathStringTokenizer *)tokenizer error:(NSError **)error {
	return AUTORELEASE([[self alloc] initWithTokenizer:tokenizer error:error]);
}

- (id)initWithTokenizer:(DDMathStringTokenizer *)t error:(NSError **)error {
	ERR_ASSERT(error);
	self = [super init];
	if (self) {
		tokenizer = RETAIN(t);
		if (!tokenizer) {
			RELEASE(self);
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

#if !HAS_ARC
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
            
		default: return DDOperatorAssociativityLeft;
	}
	return DDOperatorAssociativityLeft;
}

- (DDExpression *) parsedExpressionWithError:(NSError **)error {
	ERR_ASSERT(error);
	[tokenizer reset]; //reset the token stream
    
    DDExpression *expression = nil;
    
#if HAS_ARC
    @autoreleasepool {
#else
	NSAutoreleasePool * parserPool = [[NSAutoreleasePool alloc] init];
#endif
    
    _DDParserTerm *root = [_DDParserTerm rootTermWithTokenizer:tokenizer error:error];
    if (!root) {
        goto errorExit;
    }
    
    if (![root resolveWithParser:self error:error]) {
        goto errorExit;
    }
	
	expression = RETAIN([root expressionWithError:error]);
	
errorExit:
#if HAS_ARC
        ;
    }
#else
    [*error retain];
	[parserPool drain];
    [*error autorelease];
#endif
    
	return AUTORELEASE(expression);
}

@end
