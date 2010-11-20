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

@end


@implementation DDMathParser

+ (id) mathParserWithString:(NSString *)string {
	return [[[self alloc] initWithString:string] autorelease];
}

- (id) initWithString:(NSString *)string {
	self = [super init];
	if (self) {
		tokenizer = [[DDMathStringTokenizer alloc] initWithString:string];
		currentTokenIndex = 0;
	}
	return self;
}

- (void) dealloc {
	[tokenizer release];
	[super dealloc];
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

- (DDExpression *) parseBitwiseOrExpression {
	LOGMETHOD();
	DDExpression * left = [self parseBitwiseXorExpression];
	while ([[[self peekNextToken] token] isEqual:@"|"]) {
		[self nextToken]; //consume the |
		DDExpression * right = [self parseBitwiseXorExpression];
		if (right == nil) {
			[NSException raise:NSInvalidArgumentException format:@"no right expression to binary |"];
			return nil;
		}
		
		left = [DDExpression functionExpressionWithFunction:@"OR" arguments:[NSArray arrayWithObjects:left, right, nil]];
	}
	return left;
}

- (DDExpression *) parseBitwiseXorExpression {
	LOGMETHOD();
	DDExpression * left = [self parseBitwiseAndExpression];
	while ([[[self peekNextToken] token] isEqual:@"^"]) {
		[self nextToken]; //consume the ^
		DDExpression * right = [self parseBitwiseAndExpression];
		if (right == nil) {
			[NSException raise:NSInvalidArgumentException format:@"no right expression for binary ^"];
			return nil;
		}
		left = [DDExpression functionExpressionWithFunction:@"XOR" arguments:[NSArray arrayWithObjects:left, right, nil]];
	}
	
	return left;
}

- (DDExpression *) parseBitwiseAndExpression {
	LOGMETHOD();
	DDExpression * left = [self parseBitwiseLeftShiftExpression];
	while ([[[self peekNextToken] token] isEqual:@"&"]) {
		[self nextToken]; //consume the &
		DDExpression * right = [self parseBitwiseLeftShiftExpression];
		if (right == nil) {
			[NSException raise:NSInvalidArgumentException format:@"no right expression to binary &"];
			return nil;
		}
		left = [DDExpression functionExpressionWithFunction:@"AND" arguments:[NSArray arrayWithObjects:left, right, nil]];
	}
	return left;
}

- (DDExpression *) parseBitwiseLeftShiftExpression {
	LOGMETHOD();
	DDExpression * left = [self parseBitwiseRightShiftExpression];
	while ([[[self peekNextToken] token] isEqual:@"<<"]) {
		[self nextToken]; //consume the <<
		DDExpression * right = [self parseBitwiseRightShiftExpression];
		if (right == nil) {
			[NSException raise:NSInvalidArgumentException format:@"no right expression to binary <<"];
			return nil;
		}
		left = [DDExpression functionExpressionWithFunction:@"LSHIFT" arguments:[NSArray arrayWithObjects:left, right, nil]];
	}
	return left;
}

- (DDExpression *) parseBitwiseRightShiftExpression {
	LOGMETHOD();
	DDExpression * left = [self parseSubtractionExpression];
	while ([[[self peekNextToken] token] isEqual:@">>"]) {
		[self nextToken]; //consume the >>
		DDExpression * right = [self parseSubtractionExpression];
		if (right == nil) {
			[NSException raise:NSInvalidArgumentException format:@"no right expression to binary >>"];
			return nil;
		}
		left = [DDExpression functionExpressionWithFunction:@"RSHIFT" arguments:[NSArray arrayWithObjects:left, right, nil]];
	}
	return left;
}

- (DDExpression *) parseSubtractionExpression {
	DDExpression * left = [self parseAdditionExpression];
	while ([[[self peekNextToken] token] isEqual:@"-"]) {
		[self nextToken]; //consume the -
		DDExpression * right = [self parseAdditionExpression];
		if (right == nil) {
			[NSException raise:NSInvalidArgumentException format:@"no right expression to binary -"];
			return nil;
		}
		left = [DDExpression functionExpressionWithFunction:@"SUBTRACT" arguments:[NSArray arrayWithObjects:left, right, nil]];
	}
	return left;
}

- (DDExpression *) parseAdditionExpression {
	LOGMETHOD();
	DDExpression * left = [self parseDivisionExpression];
	while ([[[self peekNextToken] token] isEqual:@"+"]) {
		[self nextToken]; //consume the +
		DDExpression * right = [self parseDivisionExpression];
		if (right == nil) {
			[NSException raise:NSInvalidArgumentException format:@"no right expression to binary +"];
			return nil;
		}
		left = [DDExpression functionExpressionWithFunction:@"ADD" arguments:[NSArray arrayWithObjects:left, right, nil]];
	}
	return left;
}

- (DDExpression *) parseDivisionExpression {
	LOGMETHOD();
	DDExpression * left = [self parseMultiplicationExpression];
	while ([[[self peekNextToken] token] isEqual:@"/"]) {
		[self nextToken]; //consume the /
		DDExpression * right = [self parseMultiplicationExpression];
		if (right == nil) {
			[NSException raise:NSInvalidArgumentException format:@"no right expression to binary /"];
			return nil;
		}
		left = [DDExpression functionExpressionWithFunction:@"DIVIDE" arguments:[NSArray arrayWithObjects:left, right, nil]];
	}
	return left;
}

- (DDExpression *) parseMultiplicationExpression {
	LOGMETHOD();
	DDExpression * left = [self parseModuloExpression];
	while ([[[self peekNextToken] token] isEqual:@"*"]) {
		[self nextToken]; //consume the *
		DDExpression * right = [self parseModuloExpression];
		if (right == nil) {
			[NSException raise:NSInvalidArgumentException format:@"no right expression to binary *"];
			return nil;
		}
		left = [DDExpression functionExpressionWithFunction:@"MULTIPLY" arguments:[NSArray arrayWithObjects:left, right, nil]];
	}
	return left;
}

- (DDExpression *) parseModuloExpression {
	LOGMETHOD();
	DDExpression * left = [self parseUnaryExpression];
	while ([[[self peekNextToken] token] isEqual:@"%"]) {
		[self nextToken]; //consume the %
		DDExpression * right = [self parseUnaryExpression];
		if (right == nil) {
			[NSException raise:NSInvalidArgumentException format:@"no right expression to binary %"];
			return nil;
		}
		left = [DDExpression functionExpressionWithFunction:@"MOD" arguments:[NSArray arrayWithObjects:left, right, nil]];
	}
	return left;
	
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
		NSString * function = ([[next token] isEqual:@"-"] ? @"NEGATE" : @"NOT");
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
	
#if POWER_IS_RIGHT_ASSOCIATIVE
	DDExpression * terminal = [self parseTerminalExpression];
	if ([[[self peekNextToken] token] isEqual:@"**"]) {
		[self nextToken]; //consume the **
		DDExpression * power = [self parsePowerExpression];
		if (power == nil) {
			[NSException raise:NSInvalidArgumentException format:@"no right expression to binary **"];
			return nil;
		}
		return [DDExpression functionExpressionWithFunction:@"POW" arguments:[NSArray arrayWithObjects:terminal, power, nil]];
	}
	return terminal;
#else
	DDExpression * left = [self parseTerminalExpression];
	while ([[[self peekNextToken] token] isEqual:@"**"]) {
		[self nextToken]; //consume the **
		DDExpression * right = [self parseTerminalExpression];
		if (right == nil) {
			[NSException raise:NSInvalidArgumentException format:@"no right expression to binary **"];
			return nil;
		}
		left = [DDExpression functionExpressionWithFunction:@"pow" arguments:[NSArray arrayWithObjects:left, right, nil]];
	}
	return left;
#endif
}

- (DDExpression *) parseTerminalExpression {
	LOGMETHOD();
	DDMathStringToken * next = [self nextToken];
	if ([next tokenType] == DDTokenTypeNumber) {
		return [DDExpression numberExpressionWithNumber:[next numberValue]];
	} else if ([next tokenType] == DDTokenTypeVariable) {
		return [DDExpression variableExpressionWithVariable:[next token]];
	} else if ([next tokenType] == DDTokenTypeFunction) {
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

@end
