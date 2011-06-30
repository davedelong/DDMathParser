//
//  DDMathParserTokenizer.m
//  DDMathParser
//
//  Created by Dave DeLong on 6/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DDMathParserTokenizer.h"
#import "DDMathParserMacros.h"
#import "DDMathStringToken.h"

#define DD_IS_DIGIT(_c) ((_c) >= '0' && (_c) <= '9')

@interface DDMathParserTokenizer ()

- (unichar)_peekNextCharacter;
- (unichar)_nextCharacter;

- (DDMathStringToken *)_nextTokenWithError:(NSError **)error;
- (DDMathStringToken *)_parseNumberWithError:(NSError **)error;
- (DDMathStringToken *)_parseFunctionWithError:(NSError **)error;
- (DDMathStringToken *)_parseVariableWithError:(NSError **)error;
- (DDMathStringToken *)_parseOperatorWithError:(NSError **)error;

+ (NSCharacterSet *)_operatorCharacterSet;
+ (NSCharacterSet *)_functionCharacterSet;

@end

@implementation DDMathParserTokenizer

+ (NSCharacterSet *)_operatorCharacterSet {
    static dispatch_once_t onceToken;
    static NSCharacterSet *_operatorSet = nil;
    dispatch_once(&onceToken, ^{
        _operatorSet = [[NSCharacterSet characterSetWithCharactersInString:@"+-*/&|!%^~()<>,x"] retain];
    });
    return _operatorSet;
}

+ (NSCharacterSet *)_functionCharacterSet {
    static dispatch_once_t onceToken;
    static NSCharacterSet *_functionSet = nil;
    dispatch_once(&onceToken, ^{
        NSMutableCharacterSet * c = [NSMutableCharacterSet lowercaseLetterCharacterSet];
		[c formUnionWithCharacterSet:[NSCharacterSet uppercaseLetterCharacterSet]];
		[c formUnionWithCharacterSet:[NSCharacterSet decimalDigitCharacterSet]];
		[c addCharactersInString:@"_"];
        _functionSet = [c copy];
    });
    return _functionSet;
}

- (id)initWithString:(NSString *)expressionString error:(NSError **)error {
	ERR_ASSERT(error);
    self = [super init];
    if (self) {
        
        NSUInteger length = [expressionString length];
        _characters = calloc(length, sizeof(unichar));
        
        for (NSUInteger i = 0; i < length; ++i) {
            unichar character = [expressionString characterAtIndex:i];
            if (![[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:character]) {
                _characters[_length] = character;
                _length++;
            }
        }
        _characterIndex = 0;
        
        NSMutableArray *t = [NSMutableArray array];
        DDMathStringToken *token = nil;
        while((token = [self _nextTokenWithError:error]) != nil) {
			
			//figure out if "-" and "+" are unary or binary
			if ([token tokenType] == DDTokenTypeOperator && [token operatorPrecedence] == DDPrecedenceUnknown) {
				DDMathStringToken * previous = [t lastObject];
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
						*error = ERR_GENERIC(@"unknown precedence for token: %@", token);
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
			DDMathStringToken * previousToken = [t lastObject];
			if (previousToken != nil) {
				if ([previousToken tokenType] == DDTokenTypeNumber ||
					[previousToken tokenType] == DDTokenTypeVariable ||
					[previousToken operatorType] == DDOperatorParenthesisClose) {
					
					if ([token tokenType] != DDTokenTypeOperator || [token operatorType] == DDOperatorParenthesisOpen) {
						//inject a "multiplication" token:
						DDMathStringToken * multiply = [DDMathStringToken mathStringTokenWithToken:@"*" type:DDTokenTypeOperator];
						[t addObject:multiply];
					}
					
				}
			}
            
            [t addObject:token];
        }
        _tokens = [t copy];
        
		
        if (error && *error) {
            [self release], self = nil;
        }
    }
    
    return self;
}

- (void)dealloc {
    free(_characters);
    [_tokens release];
    [super dealloc];
}

#pragma mark Character methods

- (NSArray *)tokens {
    return [[_tokens copy] autorelease];
}
- (DDMathStringToken *) nextToken {
    DDMathStringToken *t = [self peekNextToken];
    if (t != nil) {
        _tokenIndex++;
    }
    return t;
}

- (DDMathStringToken *) currentToken {
    if (_tokenIndex > [_tokens count]) { return nil; }
    if (_tokenIndex == 0) { return nil; }
    
    return [_tokens objectAtIndex:(_tokenIndex-1)];
}

- (DDMathStringToken *) peekNextToken {
    if (_tokenIndex >= [_tokens count]) { return nil; }
    return [_tokens objectAtIndex:_tokenIndex];
}

- (DDMathStringToken *) previousToken {
    if (_tokenIndex <= 1) { return nil; }
    if (_tokenIndex > [_tokens count]+1) { return nil; }
    return [_tokens objectAtIndex:_tokenIndex-2];
}

- (void) reset {
	_tokenIndex = 0;
    _characterIndex = 0;
}

- (unichar)_peekNextCharacter {
    if (_characterIndex >= _length) { return '\0'; }
    return _characters[_characterIndex];
}

- (unichar)_nextCharacter {
    unichar character = [self _peekNextCharacter];
    if (character != '\0') { _characterIndex++; }
    return character;
}

- (DDMathStringToken *)_nextTokenWithError:(NSError **)error {
    unichar next = [self _peekNextCharacter];
    if (next == '\0') { return nil; }
    
    DDMathStringToken *token = nil;
    if (DD_IS_DIGIT(next) || next == '.') {
        token = [self _parseNumberWithError:error];
    }
    
    if (token == nil && ((next >= 'a' && next <= 'z') || (next >= 'A' && next <= 'Z') || DD_IS_DIGIT(next))) {
        token = [self _parseFunctionWithError:error];
    }
    
    if (token == nil && next == '$') {
        token = [self _parseVariableWithError:error];
    }
    
    if (token == nil) {
        token = [self _parseOperatorWithError:error];
    }
    
    if (token != nil) {
        *error = nil;
    }
    return token;
}

- (DDMathStringToken *)_parseNumberWithError:(NSError **)error {
    NSUInteger start = _characterIndex;
    
    while (DD_IS_DIGIT([self _peekNextCharacter])) {
        _characterIndex++;
    }
    
    if ([self _peekNextCharacter] == '.') {
        _characterIndex++;
        
        while (DD_IS_DIGIT([self _peekNextCharacter])) {
            _characterIndex++;
        }
    }
    
    NSUInteger indexBeforeE = _characterIndex;
    if ([self _peekNextCharacter] == 'e' || [self _peekNextCharacter] == 'E') {
        _characterIndex++;
        
        // there might any number of "-" or "+" characters preceding the exponent
        while ([self _peekNextCharacter] == '-' || [self _peekNextCharacter] == '+') {
            _characterIndex++;
        }
        
        NSUInteger indexAtExponentDigits = _characterIndex;
        while (DD_IS_DIGIT([self _peekNextCharacter])) {
            _characterIndex++;
        }
        
        if (_characterIndex == indexAtExponentDigits) {
            // we didn't read any digits following the "e"
            // therefore the entire exponent range is invalid
            // reset to just before we saw the "e"
            _characterIndex = indexBeforeE;
        }
    }
    
    NSUInteger length = _characterIndex - start;
    if (length > 0) {
        NSString *rawToken = [NSString stringWithCharacters:(_characters+start) length:length];
        DDMathStringToken *token = [DDMathStringToken mathStringTokenWithToken:rawToken type:DDTokenTypeNumber];
        return token;
    }
    
    *error = ERR_BADARG(@"unable to parse number");
    return nil;
}

- (DDMathStringToken *)_parseFunctionWithError:(NSError **)error {
    NSUInteger start = _characterIndex;
    NSUInteger length = 0;
    
    NSCharacterSet *functionSet = [[self class] _functionCharacterSet];
    while ([functionSet characterIsMember:[self _peekNextCharacter]]) {
        length++;
        _characterIndex++;
    }
    
    if (length > 0) {
        NSString *rawToken = [NSString stringWithCharacters:(_characters+start) length:length];
        return [DDMathStringToken mathStringTokenWithToken:rawToken type:DDTokenTypeFunction];
    }
    
    _characterIndex = start;
    *error = ERR_BADARG(@"unable to parse identifier");
    return nil;
}

- (DDMathStringToken *)_parseVariableWithError:(NSError **)error {
    NSUInteger start = _characterIndex;
    _characterIndex++; // consume the $
    DDMathStringToken *token = [self _parseFunctionWithError:error];
    if (token == nil) {
        _characterIndex = start;
        *error = ERR_BADARG(@"variable names must be at least 1 character long");
    } else {
        token = [DDMathStringToken mathStringTokenWithToken:[token token] type:DDTokenTypeVariable];
        *error = nil;
    }
    return token;
}

- (DDMathStringToken *)_parseOperatorWithError:(NSError **)error {
    NSUInteger start = _characterIndex;
    NSUInteger length = 1;
    
    unichar character = [self _nextCharacter];
    
    NSCharacterSet *operatorCharacters = [[self class] _operatorCharacterSet];
    if ([operatorCharacters characterIsMember:character]) {
        if (character == '*') {
            if ([self _peekNextCharacter] == '*') {
                _characterIndex++; // consume the second *
                length++;
            }
        } else if (character == '<' || character == '>') {
            unichar nextCharacter = [self _nextCharacter];
            if (nextCharacter != character) {
                *error = ERR_BADARG(@"< and > are not supported operators");
                _characterIndex = start;
                return nil;
            } else {
                length++;
            }
        }
        
        NSString *rawToken = [NSString stringWithCharacters:(_characters + start) length:length];
        if (length == 1 && character == 'x') {
            rawToken = @"*";
        }
        return [DDMathStringToken mathStringTokenWithToken:rawToken type:DDTokenTypeOperator];
    }
    
    _characterIndex = start;
    *error = ERR_BADARG(@"%C is not a valid operator", character);
    return nil;
}

@end
