//
//  DDMathParser.m
//  DDMathParser
//
//  Created by Dave DeLong on 11/11/10.
//  Copyright 2010 Home. All rights reserved.
//

#define DEBUG 0
#define POWER_IS_RIGHT_ASSOCIATIVE 0

#if DEBUG
#define LOGMETHOD() (NSLog(@"%s", _cmd))
#else
#define LOGMETHOD()
#endif

#import "DDMathParser.h"
#import "DDMathStringTokenizer.h"
#import "DDMathStringToken.h"
#import "DDExpression.h"

@interface DDMathParser ()

- (DDMathStringToken *) nextToken;
- (DDMathStringToken *) peekNextToken;

- (DDExpression *) parseBitwiseOrExpression;
- (DDExpression *) parseBitwiseXorExpression;
- (DDExpression *) parseBitwiseAndExpression;
- (DDExpression *) parseBitwiseLeftShiftExpression;
- (DDExpression *) parseBitwiseRightShiftExpression;

- (DDExpression *) parseSubtractionExpression;
- (DDExpression *) parseAdditionExpression;
- (DDExpression *) parseDivisionExpression;
- (DDExpression *) parseMultiplicationExpression;
- (DDExpression *) parseModuloExpression;

- (DDExpression *) parseFactorialExpression;
- (DDExpression *) parsePowerExpression;
- (DDExpression *) parseUnaryExpression;
- (DDExpression *) parseTerminalExpression;
- (DDExpression *) parseFunctionExpression;

@end


@implementation DDMathParser

@synthesize bitwiseOrAssociativity;
@synthesize bitwiseXorAssociativity;
@synthesize bitwiseAndAssociativity;
@synthesize bitwiseLeftShiftAssociativity;
@synthesize bitwiseRightShiftAssociativity;
@synthesize subtractionAssociativity;
@synthesize additionAssociativity;
@synthesize divisionAssociativity;
@synthesize multiplicationAssociativity;
@synthesize modAssociativity;
@synthesize powerAssociativity;

+ (id) mathParserWithString:(NSString *)string {
	return [[[self alloc] initWithString:string] autorelease];
}

- (id) initWithString:(NSString *)string {
	self = [super init];
	if (self) {
		tokenizer = [[DDMathStringTokenizer alloc] initWithString:string];
		currentTokenIndex = 0;
		
		bitwiseOrAssociativity = DDMathParserAssociativityLeft;
		bitwiseXorAssociativity = DDMathParserAssociativityLeft;
		bitwiseAndAssociativity = DDMathParserAssociativityLeft;
		bitwiseLeftShiftAssociativity = DDMathParserAssociativityLeft;
		bitwiseRightShiftAssociativity = DDMathParserAssociativityLeft;
		subtractionAssociativity = DDMathParserAssociativityLeft;
		additionAssociativity = DDMathParserAssociativityLeft;
		divisionAssociativity = DDMathParserAssociativityLeft;
		multiplicationAssociativity = DDMathParserAssociativityLeft;
		modAssociativity = DDMathParserAssociativityLeft;
		
		//determine what associativity NSPredicate/NSExpression is using
		//mathematically, it should be right associative, but it's usually parsed as left associative
		//rdar://problem/8692313
		NSExpression * powerExpression = [(NSComparisonPredicate *)[NSPredicate predicateWithFormat:@"2 ** 3 ** 2 == 0"] leftExpression];
		NSNumber * powerResult = [powerExpression expressionValueWithObject:nil context:nil];
		if ([powerResult intValue] == 512) {
			powerAssociativity = DDMathParserAssociativityRight;
		} else {
			powerAssociativity = DDMathParserAssociativityLeft;
		}
	}
	return self;
}

- (void) dealloc {
	[tokenizer release];
	[super dealloc];
}

- (DDMathStringToken *) currentToken {
	if (currentTokenIndex >= [[tokenizer tokens] count]) { return nil; }
	if (currentTokenIndex == 0) {
		return [[tokenizer tokens] objectAtIndex:currentTokenIndex];
	}
	return [[tokenizer tokens] objectAtIndex:currentTokenIndex-1];
}

- (DDMathStringToken *) nextToken {
	if (currentTokenIndex >= [[tokenizer tokens] count]) { return nil; }
	DDMathStringToken * next = [[tokenizer tokens] objectAtIndex:currentTokenIndex];
	currentTokenIndex++;
	return next;
}

- (DDMathStringToken *) peekNextToken {
	DDMathStringToken * next = [self nextToken];
	if (next != nil) { currentTokenIndex--; }
	return next;
}

- (DDExpression *) parsedExpression {
	currentTokenIndex = 0;
	
	return [self parseBitwiseOrExpression];
}

#pragma mark -

/**
 What's with the while() loop?
 It's because most of these operators are left associative, but using a normal recursive descent parser
 with a left associative operator results in infinite recursive.
 
 So if I have the left associative rule:
 
   E => E "-" T | T
 
 Then I can make this into non-left associative by writing it as:
 
   E => T B
   B => "-" T B | ε
 
 Ref: http://stackoverflow.com/questions/4007479#4010791
 **/

- (DDExpression *) parseBinaryFunction:(NSString *)function token:(NSString *)expectedToken associativity:(DDMathParserAssociativity)associativity nextLevel:(SEL)next {
	DDExpression * left = [self performSelector:next];
	if (associativity == DDMathParserAssociativityLeft) {
		while ([[[self peekNextToken] token] isEqual:expectedToken]) {
			[self nextToken]; /*consumer the binary operator*/
			DDExpression * right = [self performSelector:next];
			if (right == nil) {
				[NSException raise:NSInvalidArgumentException format:@"no right expression to binary %@", expectedToken];
				return nil;
			}
			left = [DDExpression functionExpressionWithFunction:function arguments:[NSArray arrayWithObjects:left, right, nil]];
		}
	} else {
		if ([[[self peekNextToken] token] isEqual:expectedToken]) {
			[self nextToken]; /*consumer the binary operator*/
			DDExpression * right = [self parseBinaryFunction:function token:expectedToken associativity:associativity nextLevel:next];
			if (right == nil) {
				[NSException raise:NSInvalidArgumentException format:@"no right expression to binary %@", expectedToken];
				return nil;
			}
			left = [DDExpression functionExpressionWithFunction:function arguments:[NSArray arrayWithObjects:left, right, nil]];
		}
	}
	return left;
}

- (DDExpression *) parseBitwiseOrExpression {
	LOGMETHOD();
	return [self parseBinaryFunction:@"or" 
							   token:@"|" 
					   associativity:bitwiseOrAssociativity 
						   nextLevel:@selector(parseBitwiseXorExpression)];
}

- (DDExpression *) parseBitwiseXorExpression {
	LOGMETHOD();
	return [self parseBinaryFunction:@"xor" 
							   token:@"^" 
					   associativity:bitwiseXorAssociativity 
						   nextLevel:@selector(parseBitwiseAndExpression)];
}

- (DDExpression *) parseBitwiseAndExpression {
	LOGMETHOD();
	return [self parseBinaryFunction:@"and" 
							   token:@"&" 
					   associativity:bitwiseAndAssociativity 
						   nextLevel:@selector(parseBitwiseLeftShiftExpression)];
}

- (DDExpression *) parseBitwiseLeftShiftExpression {
	LOGMETHOD();
	return [self parseBinaryFunction:@"lshift" 
							   token:@"<<" 
					   associativity:bitwiseLeftShiftAssociativity 
						   nextLevel:@selector(parseBitwiseRightShiftExpression)];
}

- (DDExpression *) parseBitwiseRightShiftExpression {
	LOGMETHOD();
	return [self parseBinaryFunction:@"rshift" 
							   token:@">>" 
					   associativity:bitwiseRightShiftAssociativity 
						   nextLevel:@selector(parseSubtractionExpression)];
}

- (DDExpression *) parseSubtractionExpression {
	LOGMETHOD();
	return [self parseBinaryFunction:@"subtract" 
							   token:@"-" 
					   associativity:subtractionAssociativity 
						   nextLevel:@selector(parseAdditionExpression)];
}

- (DDExpression *) parseAdditionExpression {
	LOGMETHOD();
	return [self parseBinaryFunction:@"add" 
							   token:@"+" 
					   associativity:additionAssociativity 
						   nextLevel:@selector(parseDivisionExpression)];
}

- (DDExpression *) parseDivisionExpression {
	LOGMETHOD();
	return [self parseBinaryFunction:@"divide" 
							   token:@"/" 
					   associativity:divisionAssociativity 
						   nextLevel:@selector(parseMultiplicationExpression)];
}

- (DDExpression *) parseMultiplicationExpression {
	LOGMETHOD();
	return [self parseBinaryFunction:@"multiply" 
							   token:@"*" 
					   associativity:multiplicationAssociativity 
						   nextLevel:@selector(parseModuloExpression)];
}

- (DDExpression *) parseModuloExpression {
	LOGMETHOD();
	return [self parseBinaryFunction:@"mod" 
							   token:@"%" 
					   associativity:modAssociativity 
						   nextLevel:@selector(parseUnaryExpression)];
	
}

- (DDExpression *) parseUnaryExpression {
	LOGMETHOD();
	DDMathStringToken * next = [self peekNextToken];
	if ([[next token] isEqual:@"-"] || [[next token] isEqual:@"~"]) {
		[self nextToken]; //consume the operator
		DDExpression * unary = [self parseUnaryExpression];
		if (unary == nil) {
			[NSException raise:NSInvalidArgumentException format:@"no right expression to binary %@", [next token]];
			return nil;
		}
		NSString * function = ([[next token] isEqual:@"-"] ? @"negate" : @"not");
		return [DDExpression functionExpressionWithFunction:function arguments:[NSArray arrayWithObject:unary]];
	}
	return [self parseFactorialExpression];
}

- (DDExpression *) parseFactorialExpression {
	LOGMETHOD();
	DDExpression * left = [self parsePowerExpression];
	while ([[[self peekNextToken] token] isEqual:@"!"]) {
		[self nextToken]; //consume the !
		left = [DDExpression functionExpressionWithFunction:@"factorial" arguments:[NSArray arrayWithObject:left]];
	}
	return left;
}

- (DDExpression *) parsePowerExpression {
	LOGMETHOD();
	return [self parseBinaryFunction:@"pow" 
							   token:@"**" 
					   associativity:powerAssociativity 
						   nextLevel:@selector(parseTerminalExpression)];
}

- (DDExpression *) parseTerminalExpression {
	LOGMETHOD();
	DDMathStringToken * next = [self nextToken];
	if ([next tokenType] == DDTokenTypeNumber) {
		return [DDExpression numberExpressionWithNumber:[next numberValue]];
	} else if ([next tokenType] == DDTokenTypeVariable) {
		return [DDExpression variableExpressionWithVariable:[next token]];
	} else if ([next tokenType] == DDTokenTypeFunction) {
		return [self parseFunctionExpression];
	} else if ([[next token] isEqual:@"("]) {
		DDExpression * parenthetical = [self parseBitwiseOrExpression];
		DDMathStringToken * closing = [self nextToken];
		if ([[closing token] isEqual:@")"] == NO) {
			[NSException raise:NSInvalidArgumentException format:@"no closing parenthesis found"];
			return nil;
		}
		return parenthetical;
	}
	
	[NSException raise:NSInvalidArgumentException format:@"unexpected token: %@", [next token]];
	return nil;
}

- (DDExpression *) parseFunctionExpression {
	DDMathStringToken * next = [self currentToken];
	NSString * function = [next token];
	NSMutableArray * arguments = [NSMutableArray array];
	
	next = [self nextToken];
	if ([[next token] isEqual:@"("] == NO) {
		//this should be unreachable, since a Function token is only generated if the following character is (
		[NSException raise:NSInvalidArgumentException format:@"function not followed by (.  should be unreachable"];
		return nil;
	}
	next = [self peekNextToken];
	if (next == nil) {
		[NSException raise:NSInvalidArgumentException format:@"formula must have closing parenthesis"];
		return nil;
	}
	if ([[next token] isEqual:@")"] == NO) {		
		DDExpression * argument = [self parseBitwiseOrExpression];
		if (argument != nil) {
			[arguments addObject:argument];
		}	
		do {
			next = [self nextToken];
			if ([[next token] isEqual:@","]) {
				argument = [self parseBitwiseOrExpression];
				if (argument != nil) {
					[arguments addObject:argument];
				}
			} else if ([[next token] isEqual:@")"]) {
				break;
			} else {
				[NSException raise:NSInvalidArgumentException format:@"unexpected token found in function: %@", [next token]];
				return nil;
			}
		} while (1);
	}
	
	return [DDExpression functionExpressionWithFunction:function arguments:arguments];
}

@end
