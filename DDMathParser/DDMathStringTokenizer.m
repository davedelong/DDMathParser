//
//  DDMathStringTokenizer.m
//  DDMathParser
//
//  Created by Dave DeLong on 11/11/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "DDMathStringTokenizer.h"
#import "DDMathStringToken.h"
#import "NSNumberFormatter+DDMathParser.h"
#import "DDMathParserMacros.h"

@interface DDMathStringTokenizer ()

- (DDMathStringToken *) _nextTokenWithError:(NSError **)error;

- (DDMathStringToken *) parsedOperator:(unichar)firstCharacter error:(NSError **)error;
- (DDMathStringToken *) parsedNumber:(unichar)firstCharacter error:(NSError **)error;
- (DDMathStringToken *) parsedVariable:(unichar)firstCharacter error:(NSError **)error;
- (DDMathStringToken *) parsedFunction:(unichar)firstCharacter error:(NSError **)error;

@end

@implementation DDMathStringTokenizer

- (id) initWithString:(NSString *)expressionString error:(NSError **)error {
	self = [super init];
	if (self) {
		tokens = [[NSMutableArray alloc] init];
		
		currentCharacterIndex = NSUIntegerMax;
		
		//remove all whitespace:
		NSArray * t = [expressionString componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		expressionString = [t componentsJoinedByString:@""];
		
		sourceString = [expressionString retain];
		numberFormatter = [[NSNumberFormatter alloc] init];
		
		DDMathStringToken * token = nil;
		while ((token = [self _nextTokenWithError:error])) {
			if (error && *error) {
				[self release];
				return nil;
			}
			
			//figure out if "-" and "+" are unary or binary
			if ([token tokenType] == DDTokenTypeOperator && [token operatorPrecedence] == DDPrecedenceUnknown) {
				DDMathStringToken * previous = [tokens lastObject];
				if (previous == nil) {
					[token setOperatorPrecedence:DDPrecedenceUnary];
				} else if ([previous tokenType] == DDTokenTypeOperator && [previous operatorType] != DDOperatorParenthesisClose) {
					[token setOperatorPrecedence:DDPrecedenceUnary];
				} else if ([[token token] isEqual:@"+"]) {
					[token setOperatorPrecedence:DDPrecedenceAddition];
				} else if ([[token token] isEqual:@"-"]) {
					[token setOperatorPrecedence:DDPrecedenceSubtraction];
				} else {
					if (error != nil) {
						*error = ERR_EVAL(@"unknown precedence for token: %@", token);
					}
					[self release];
					return nil;
				}
			}
			
			//this adds support for implicit multiplication
			/**
			 If you have <first token><second token>, then you can either inject a multiplication token or leave it alone.
			 This table explains what should happen for each possible combination:
			 
			 First Token		Second Token	Action
			 -----------------------------------------
			 Number				Number			Multiply
			 Number				Operator		Normal
			 Number				Variable		Multiply
			 Number				Function		Multiply
			 Number				(				Multiply
			 
			 Operator			Number			Normal
			 Operator			Operator		Normal
			 Operator			Variable		Normal
			 Operator			Function		Normal
			 Operator			(				Normal
			 
			 Variable			Number			Multiply
			 Variable			Operator		Normal
			 Variable			Variable		Multiply
			 Variable			Function		Multiply
			 Variable			(				Multiply
			 
			 Function			Number			Normal
			 Function			Operator		Normal
			 Function			Variable		Normal
			 Function			Function		Normal
			 Function			(				Normal
			 
			 )					Number			Multiply
			 )					Operator		Normal
			 )					Variable		Multiply
			 )					Function		Multiply
			 )					(				Multiply
			 **/
			DDMathStringToken * previousToken = [tokens lastObject];
			if (previousToken != nil) {
				if ([previousToken tokenType] == DDTokenTypeNumber ||
					[previousToken tokenType] == DDTokenTypeVariable ||
					[previousToken operatorType] == DDOperatorParenthesisClose) {
					
					if ([token tokenType] != DDTokenTypeOperator || [token operatorType] == DDOperatorParenthesisOpen) {
						//inject a "multiplication" token:
						DDMathStringToken * multiply = [DDMathStringToken mathStringTokenWithToken:@"*" type:DDTokenTypeOperator];
						[tokens addObject:multiply];
					}
					
				}
			}
			
			[tokens addObject:token];
		}
		
		[self reset];
	}
	return self;
}

- (void) dealloc {
	[sourceString release];
	[numberFormatter release];
	[tokens release];
	
	[allowedFunctionCharacters release];
	[allowedVariableCharacters release];
	[allowedNumberCharacters release];
	[allowedOperatorCharacters release];
	
	[super dealloc];
}

- (NSArray *) tokens {
	return [[tokens copy] autorelease];
}

- (DDMathStringToken *) nextToken {
	currentTokenIndex++;
	return [self currentToken];
}

- (DDMathStringToken *) currentToken {
	if (currentTokenIndex >= [tokens count]) { return nil; }
	return [tokens objectAtIndex:currentTokenIndex];
}

- (DDMathStringToken *) peekNextToken {
	DDMathStringToken * peek = [self nextToken];
	currentTokenIndex--;
	return peek;
}

- (DDMathStringToken *) previousToken {
	if (currentTokenIndex <= 0) { return nil; }
	return [tokens objectAtIndex:currentTokenIndex - 1];
}

- (void) reset {
	currentTokenIndex = -1;
	currentCharacterIndex = NSUIntegerMax;
}

- (unichar) _previousCharacter {
	unichar character = '\0';
	if (currentCharacterIndex <= [sourceString length] && currentCharacterIndex > 0) {
		character = [sourceString characterAtIndex:(currentCharacterIndex-1)];
	}
	return character;
}

- (unichar) _currentCharacter {
	if (currentCharacterIndex < [sourceString length]) {
		return [sourceString characterAtIndex:currentCharacterIndex];
	}
	return '\0';
}

- (unichar) _nextCharacter {
	if (currentCharacterIndex == NSUIntegerMax) {
		currentCharacterIndex = 0;
	} else {
		currentCharacterIndex++;
	}
	return [self _currentCharacter];
}

- (unichar) _peekNextCharacter {
	unichar peek = [self _nextCharacter];
	if (peek != 0) { currentCharacterIndex--; }
	return peek;
}

- (DDMathStringToken *) _nextTokenWithError:(NSError **)error {
	unichar character = [self _nextCharacter];
	if (character == '\0') { return nil; }
	
	unichar decimalSeparator = [[[NSLocale currentLocale] objectForKey:NSLocaleDecimalSeparator] characterAtIndex:0];
	NSUInteger currentIndex = currentCharacterIndex;
	
	DDMathStringToken *token = nil;
	if ((character >= '0' && character <= '9') || character == decimalSeparator) {
		token = [self parsedNumber:character error:error];
	} else if ((character >= 'a' && character <= 'z') ||
		(character >= 'A' && character <= 'Z')) {
		token = [self parsedFunction:character error:error];
	} else if (character == '$') {
		token = [self parsedVariable:character error:error];
	}
	
	if (token == nil) {
		//failed; reset to where we were before we started
		currentCharacterIndex = currentIndex;
		token = [self parsedOperator:character error:error];
	}
	return token;
}

- (NSCharacterSet *) allowedNumberCharacters {
	if (allowedNumberCharacters == nil) {
		/**
		 we don't allow commas in numbers, because then "max(3,9)" would be naïvely tokenized as:
		 "max" "(" "3,9" ")"
		 instead of the expected
		 "max" "(" "3" "," "9" ")"
		 */
		NSMutableCharacterSet * c = [NSMutableCharacterSet decimalDigitCharacterSet];
		[c addCharactersInString:@".eE"];
		allowedNumberCharacters = [c copy];
	}
	return allowedNumberCharacters;
}

- (DDMathStringToken *) parsedNumber:(unichar)firstCharacter error:(NSError **)error {
	NSMutableString * n = [NSMutableString stringWithFormat:@"%C", firstCharacter];
	NSNumber * parsedNumber = [[NSNumberFormatter numberFormatter_dd] anyNumberFromString_dd:n];
	do {
		unichar peek = [self _peekNextCharacter];
		if (peek == '\0') { break; }
		[n appendFormat:@"%C", peek];
		NSNumber *thisNumber = [[NSNumberFormatter numberFormatter_dd] anyNumberFromString_dd:n];
		if (thisNumber != nil) {
			//we found something!
			//keep going
			parsedNumber = thisNumber;
			//consume the character
			[self _nextCharacter];
		} else {
			//this didn't work
			//try appending something to the string and see if it likes that
			//this will handle "1e", "1e-", "1e+", ".", and similar
			[n appendString:@"2"];
			thisNumber = [[NSNumberFormatter numberFormatter_dd] anyNumberFromString_dd:n];
			//remove the "2"
			[n replaceCharactersInRange:NSMakeRange([n length]-1, 1) withString:@""];
			if (thisNumber != nil) {
				//it worked
				//remove the "2"
				parsedNumber = thisNumber;
				[self _nextCharacter];
			} else {
				//still couldn't parse. remove the last character that was appended
				[n replaceCharactersInRange:NSMakeRange([n length]-1, 1) withString:@""];
				break;
			}
		}
	} while (1);
	
	if (parsedNumber == nil) {
		if (error != nil) {
			*error = ERR_BADARG(@"unable to parse: %@", n);
		}
		return nil;
	}
	
	return [DDMathStringToken mathStringTokenWithToken:n type:DDTokenTypeNumber];
}

- (NSCharacterSet *) allowedFunctionCharacters {
	if (allowedFunctionCharacters == nil) {
		NSMutableCharacterSet * c = [NSMutableCharacterSet lowercaseLetterCharacterSet];
		[c formUnionWithCharacterSet:[NSCharacterSet uppercaseLetterCharacterSet]];
		[c formUnionWithCharacterSet:[NSCharacterSet decimalDigitCharacterSet]];
		[c addCharactersInString:@"_"];
		allowedFunctionCharacters = [c copy];
	}
	return allowedFunctionCharacters;
}

- (DDMathStringToken *) parsedFunction:(unichar)firstCharacter error:(NSError **)error {	
	NSMutableString * f = [NSMutableString stringWithFormat:@"%C", firstCharacter];
	while ([[self allowedFunctionCharacters] characterIsMember:[self _peekNextCharacter]]) {
		[f appendFormat:@"%C", [self _nextCharacter]];
	}
	
	if ([self _peekNextCharacter] == '(') {
		return [DDMathStringToken mathStringTokenWithToken:f type:DDTokenTypeFunction];
	}
	
	if (error != nil) {
		*error = ERR_BADARG(@"unknown identifier: %@", f);
	}
	return nil;
}

- (NSCharacterSet *) allowedVariableCharacters {
	if (allowedVariableCharacters == nil) {
		NSMutableCharacterSet * c = [NSMutableCharacterSet lowercaseLetterCharacterSet];
		[c formUnionWithCharacterSet:[NSCharacterSet uppercaseLetterCharacterSet]];
		[c formUnionWithCharacterSet:[NSCharacterSet decimalDigitCharacterSet]];
		[c addCharactersInString:@"_"];
		allowedVariableCharacters = [c copy];
	}
	return allowedVariableCharacters;
}

- (DDMathStringToken *) parsedVariable:(unichar)firstCharacter error:(NSError **)error {
	//in this case, we *don't* use the firstCharacter (since it is $).  The $ is only to indicate that what follows is a variable
	NSMutableString * v = [NSMutableString string];
	while ([[self allowedVariableCharacters] characterIsMember:[self _peekNextCharacter]]) {
		[v appendFormat:@"%C", [self _nextCharacter]];
	}
	
	if ([v length] == 0) {
		if (error != nil) {
			*error = ERR_BADARG(@"variable names must be at least 1 character long");
		}
		return nil;
	}
	
	return [DDMathStringToken mathStringTokenWithToken:v type:DDTokenTypeVariable];
}

- (NSCharacterSet *) allowedOperatorCharacters {
	if (allowedOperatorCharacters == nil) {
		allowedOperatorCharacters = [[NSCharacterSet characterSetWithCharactersInString:@"+-*/&|!%^~()<>,x"] retain];
	}
	return allowedOperatorCharacters;
}

- (DDMathStringToken *) parsedOperator:(unichar)firstCharacter error:(NSError **)error {
	NSString * token = [NSString stringWithFormat:@"%C", firstCharacter];
	if ([[self allowedOperatorCharacters] characterIsMember:firstCharacter]) {
		if (firstCharacter == '*') {
			//recognize "**" (pow) as different than "*" (mul)
			if ([self _peekNextCharacter] == '*') {
				token = [token stringByAppendingFormat:@"%C", [self _nextCharacter]];
			}
		} else if (firstCharacter == '<' || firstCharacter == '>') {
			unichar nextCharacter = [self _nextCharacter];
			if (firstCharacter != nextCharacter) {
				if (error != nil) {
					*error = ERR_BADARG(@"< and > are not supported operators");
				}
				return nil;
			}
			token = [token stringByAppendingFormat:@"%C", nextCharacter];
		}
		
		if ([token isEqual:@"x"]) { token = @"*"; }
		return [DDMathStringToken mathStringTokenWithToken:token type:DDTokenTypeOperator];
	}
	
	*error = ERR_BADARG(@"%@ is not a valid operator", token);
	return nil;
}

@end
