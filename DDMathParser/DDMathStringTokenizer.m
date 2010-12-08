//
//  DDMathStringTokenizer.m
//  DDMathParser
//
//  Created by Dave DeLong on 11/11/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "DDMathStringTokenizer.h"
#import "DDMathStringToken.h"

@interface DDMathStringTokenizer ()

- (DDMathStringToken *) _nextToken;

- (DDMathStringToken *) parsedOperator:(unichar)firstCharacter;
- (DDMathStringToken *) parsedNumber:(unichar)firstCharacter;
- (DDMathStringToken *) parsedVariable:(unichar)firstCharacter;
- (DDMathStringToken *) parsedFunction:(unichar)firstCharacter;

@end

@implementation DDMathStringTokenizer

- (id) initWithString:(NSString *)expressionString {
	self = [super init];
	if (self) {
		tokens = [[NSMutableArray alloc] init];
		
		currentCharacterIndex = 0;
		
		//remove all whitespace:
		NSArray * t = [expressionString componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		expressionString = [t componentsJoinedByString:@""];
		
		sourceString = [expressionString retain];
		numberFormatter = [[NSNumberFormatter alloc] init];
		
		@try {
			DDMathStringToken * token = nil;
			while ((token = [self _nextToken])) {
				[tokens addObject:token];
			}
		}
		@catch (NSException * e) {
			NSLog(@"caught: %@", e);
			@throw e;
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
}

- (unichar) _nextCharacter {
	if (currentCharacterIndex >= [sourceString length]) { return 0; }
	
	unichar character = [sourceString characterAtIndex:currentCharacterIndex];
	currentCharacterIndex++;
	return character;
}

- (unichar) _peekNextCharacter {
	unichar peek = [self _nextCharacter];
	if (peek != 0) { currentCharacterIndex--; }
	return peek;
}

- (DDMathStringToken *) _nextToken {
	if (currentCharacterIndex >= [sourceString length]) { return nil; }
	
	unichar character = [self _nextCharacter];
	
	NSUInteger currentIndex = currentCharacterIndex;
	@try {
		if ((character >= '0' && character <= '9')/* || (character == '-')*/) {
			return [self parsedNumber:character];
		}
		if ((character >= 'a' && character <= 'z') ||
				   (character >= 'A' && character <= 'Z')) {
			return [self parsedFunction:character];
		}
		if (character == '$') {
			return [self parsedVariable:character];
		}
	}
	@catch (NSException * e) {
		//failed; reset to where we were before we started
		currentCharacterIndex = currentIndex;
	}
	return [self parsedOperator:character];
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

- (DDMathStringToken *) parsedNumber:(unichar)firstCharacter {
	NSMutableString * n = [NSMutableString stringWithFormat:@"%C", firstCharacter];
	do {
		unichar next = [self _peekNextCharacter];
		if (next != 0) {
			//allowed characters: 0-9, e, .
			if ([[self allowedNumberCharacters] characterIsMember:next]) {
				[n appendFormat:@"%C", [self _nextCharacter]];
			} else {
				break;
			}
		} else {
			break;
		}
	} while (1);
	
	//now that we have a string, verify that it makes a number:
	//use < spellOut, since we don't recognize spelled-out numbers
	NSNumber * parsedNumber = nil;
	for (int i = NSNumberFormatterNoStyle; i < NSNumberFormatterSpellOutStyle; ++i) {
		[numberFormatter setNumberStyle:i];
		parsedNumber = [numberFormatter numberFromString:n];
		if (parsedNumber != nil) { break; }
	}
	
	if (parsedNumber == nil) {
		[NSException raise:NSInvalidArgumentException format:@"unabled to parse: %@", n];
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

- (DDMathStringToken *) parsedFunction:(unichar)firstCharacter {	
	NSMutableString * f = [NSMutableString stringWithFormat:@"%C", firstCharacter];
	while ([[self allowedFunctionCharacters] characterIsMember:[self _peekNextCharacter]]) {
		[f appendFormat:@"%C", [self _nextCharacter]];
	}
	
	if ([self _peekNextCharacter] == '(') {
		return [DDMathStringToken mathStringTokenWithToken:f type:DDTokenTypeFunction];
	}
	
	[NSException raise:NSInvalidArgumentException format:@"unknown identifier: %@", f];
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

- (DDMathStringToken *) parsedVariable:(unichar)firstCharacter {
	//in this case, we *don't* use the firstCharacter (since it is $).  The $ is only to indicate that what follows is a variable
	NSMutableString * v = [NSMutableString string];
	while ([[self allowedVariableCharacters] characterIsMember:[self _peekNextCharacter]]) {
		[v appendFormat:@"%C", [self _nextCharacter]];
	}
	
	if ([v length] == 0) {
		[NSException raise:NSInvalidArgumentException format:@"variable names must be at least 1 character long"];
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

- (DDMathStringToken *) parsedOperator:(unichar)firstCharacter {
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
				[NSException raise:NSInvalidArgumentException format:@"< and > are not supported operators"];
				return nil;
			}
			token = [token stringByAppendingFormat:@"%C", nextCharacter];
		}
		
		if ([token isEqual:@"x"]) { token = @"*"; }
		return [DDMathStringToken mathStringTokenWithToken:token type:DDTokenTypeOperator];
	}
	
	[NSException raise:NSInvalidArgumentException format:@"%@ is not a valid operator", token];
	return nil;
}

@end
