//
//  DDMathParserTokenizer.m
//  DDMathParser
//
//  Created by Dave DeLong on 6/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DDMathParser.h"
#import "DDMathStringTokenizer.h"
#import "DDMathParserMacros.h"
#import "DDMathStringToken.h"

#define DD_IS_DIGIT(_c) ((_c) >= '0' && (_c) <= '9')
#define DD_IS_WHITESPACE(_c) ([[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:(_c)])

@interface DDMathStringTokenizer ()

- (BOOL)_processToken:(DDMathStringToken *)token withError:(NSError **)error;
- (BOOL)_processUnknownOperatorToken:(DDMathStringToken *)token withError:(NSError **)error;
- (BOOL)_processImplicitMultiplicationWithToken:(DDMathStringToken *)token error:(NSError **)error;
- (BOOL)_processArgumentlessFunctionWithToken:(DDMathStringToken *)token error:(NSError **)error;

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

@implementation DDMathStringTokenizer

+ (NSCharacterSet *)_operatorCharacterSet {
    static dispatch_once_t onceToken;
    static NSCharacterSet *_operatorSet = nil;
    dispatch_once(&onceToken, ^{
        // \u2228 is ∨
        // \u2227 is ∧
        // \u00AC is ¬
        // \u2264 is ≤
        // \u2265 is ≥
        _operatorSet = DD_RETAIN([NSCharacterSet characterSetWithCharactersInString:@"+-*/&|!%^~()<>,=\u2228\u2227\u00ac\u2264\u2265"]);
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

+ (NSCharacterSet *)_singleCharacterFunctionCharacterSet {
    static dispatch_once_t onceToken;
    static NSCharacterSet *_singleCharFunctionSet = nil;
    dispatch_once(&onceToken, ^{
        NSString *singleChars = [NSString stringWithFormat:@"\u03C0\u03D5\u03C4"];  // π, ϕ, and τ
        _singleCharFunctionSet = DD_RETAIN([NSCharacterSet characterSetWithCharactersInString:singleChars]);
    });
    return _singleCharFunctionSet;
}

+ (id)tokenizerWithString:(NSString *)expressionString error:(NSError **)error {
    return DD_AUTORELEASE([[self alloc] initWithString:expressionString error:error]);
}

- (id)initWithString:(NSString *)expressionString error:(NSError **)error {
	ERR_ASSERT(error);
    self = [super init];
    if (self) {
        
        _length = [expressionString length];
        _characters = calloc(_length+1, sizeof(unichar));
        [expressionString getCharacters:_characters];
        
        _characterIndex = 0;
        
        _tokens = [[NSMutableArray alloc] init];
        DDMathStringToken *token = nil;
        while((token = [self _nextTokenWithError:error]) != nil) {
            if (![self _processToken:token withError:error]) {
                DD_RELEASE(self);
                return nil;
            }
        }
        
        [self _processToken:nil withError:error];
		
        if (error && *error) {
            DD_RELEASE(self);
            self = nil;
        }
    }
    
    return self;
}

- (void)finalize {
    free(_characters);
    [super finalize];
}

- (void)dealloc {
    free(_characters);
#if !DD_HAS_ARC
    [_tokens release];
    [super dealloc];
#endif
}

- (BOOL)_processToken:(DDMathStringToken *)token withError:(NSError **)error {
    //figure out if "-" and "+" are unary or binary
    (void)[self _processUnknownOperatorToken:token withError:error];
    
    if ([token operatorType] == DDOperatorUnaryPlus) {
        // the unary + operator is a no-op operator.  It does nothing, so we'll throw it out
        return YES;
    }
    
    //this adds support for not adding parentheses to functions
    (void)[self _processArgumentlessFunctionWithToken:token error:error];
    
    //this adds support for implicit multiplication
    (void)[self _processImplicitMultiplicationWithToken:token error:error];
    
    [self appendToken:token];
    return YES;
}

- (BOOL)_processUnknownOperatorToken:(DDMathStringToken *)token withError:(NSError **)error {
    DDMathStringToken *previousToken = [_tokens lastObject];   
    if ([token tokenType] == DDTokenTypeOperator && [token operatorType] == DDOperatorInvalid) {
        DDOperator resolvedOperator = DDOperatorInvalid;
        
        BOOL shouldBeUnary = NO;
        
        if (previousToken == nil) {
            shouldBeUnary = YES;
        } else if ([previousToken tokenType] == DDTokenTypeOperator && 
                   [previousToken operatorType] != DDOperatorParenthesisClose && 
                   [previousToken operatorType] != DDOperatorFactorial) {
            shouldBeUnary = YES;
        }
        
        if (shouldBeUnary) {
            if ([[token token] isEqual:@"+"]) {
                resolvedOperator = DDOperatorUnaryPlus;
            } else if ([[token token] isEqual:@"-"]) {
                resolvedOperator = DDOperatorUnaryMinus;
            }
        } else {
            if ([[token token] isEqual:@"+"]) {
                resolvedOperator = DDOperatorAdd;
            } else if ([[token token] isEqual:@"-"]) {
                resolvedOperator = DDOperatorMinus;
            }
        }
        
        if ([[token token] isEqual:@"!"]) {
            if (previousToken == nil) {
                resolvedOperator = DDOperatorLogicalNot;
            } else if ([previousToken tokenType] == DDTokenTypeOperator && [previousToken operatorType] != DDOperatorParenthesisClose) {
                resolvedOperator = DDOperatorLogicalNot;
            }
        }
        
        [token resolveToOperator:resolvedOperator];
        
        if ([token operatorType] == DDOperatorInvalid) {
            if (error != nil) {
                *error = ERR_GENERIC(@"unknown precedence for token: %@", token);
            }
            return NO;
        }
    }
    
    if ([[previousToken token] isEqual:@"!"] && [previousToken operatorType] == DDOperatorInvalid) {
        [previousToken resolveToOperator:DDOperatorFactorial];
        if (error != nil) {
            *error = nil;
        }
    }
    
    return YES;
}

- (BOOL)_processImplicitMultiplicationWithToken:(DDMathStringToken *)token error:(NSError **)error {
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
    DDMathStringToken *previousToken = [_tokens lastObject];
    if (previousToken != nil && token != nil) {
        BOOL shouldInsertMultiplier = NO;
        if ([previousToken tokenType] == DDTokenTypeNumber ||
            [previousToken tokenType] == DDTokenTypeVariable ||
            [previousToken operatorType] == DDOperatorParenthesisClose) {
            
            if ([token tokenType] != DDTokenTypeOperator || [token operatorType] == DDOperatorParenthesisOpen) {
                //inject a "multiplication" token:
                shouldInsertMultiplier = YES;
            }
            
        }
        
        if (shouldInsertMultiplier == NO && [previousToken tokenType] == DDTokenTypeOperator && [token tokenType] == DDTokenTypeOperator) {
            if ([previousToken operatorArity] == DDOperatorArityUnary && [token operatorArity] == DDOperatorArityUnary) {
                if ([previousToken operatorAssociativity] != [token operatorAssociativity]) {
                    shouldInsertMultiplier = YES;
                }
            }
        }
        
        if (shouldInsertMultiplier) {
            DDMathStringToken * multiply = [DDMathStringToken mathStringTokenWithToken:@"*" type:DDTokenTypeOperator];
            
            [self appendToken:multiply];
        }
    }
    return YES;
}

- (BOOL)_processArgumentlessFunctionWithToken:(DDMathStringToken *)token error:(NSError **)error {
    DDMathStringToken *previousToken = [_tokens lastObject];
    if (previousToken != nil && [previousToken tokenType] == DDTokenTypeFunction) {
        if ([token tokenType] != DDTokenTypeOperator || [token operatorType] != DDOperatorParenthesisOpen || token == nil) {
            DDMathStringToken *openParen = [DDMathStringToken mathStringTokenWithToken:@"(" type:DDTokenTypeOperator];
            [self appendToken:openParen];
            
            DDMathStringToken *closeParen = [DDMathStringToken mathStringTokenWithToken:@")" type:DDTokenTypeOperator];
            [self appendToken:closeParen];
        }
    }
    return YES;
}

// methods overridable by subclasses
- (void)didParseToken:(DDMathStringToken *)token {
    // default implementation does nothing
#pragma unused(token)
    return;
}

// methods that can be used by subclasses
- (void)appendToken:(DDMathStringToken *)token {
    [self didParseToken:token];
    if (token) {
        [(NSMutableArray *)_tokens addObject:token];
    }
}

#pragma mark Character methods

- (NSArray *)tokens {
    return DD_AUTORELEASE([_tokens copy]);
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
    ERR_ASSERT(error);
    unichar next = [self _peekNextCharacter];
    while (DD_IS_WHITESPACE(next)) {
        (void)[self _nextCharacter];
        next = [self _peekNextCharacter];
    }
    if (next == '\0') { return nil; }
    
    DDMathStringToken *token = nil;
    if (DD_IS_DIGIT(next) || next == '.') {
        token = [self _parseNumberWithError:error];
    }
    
    if (token == nil) {
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
    ERR_ASSERT(error);
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
        
        // there might a "-" or "+" character preceding the exponent
        if ([self _peekNextCharacter] == '-' || [self _peekNextCharacter] == '+') {
            _characterIndex++;
        }
        
        NSUInteger indexAtExponentDigits = _characterIndex;
        while (DD_IS_DIGIT([self _peekNextCharacter])) {
            _characterIndex++;
        }
        
        if (_characterIndex == indexAtExponentDigits) {
            // we didn't read any digits following the "e" or the "-"/"+"
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
    ERR_ASSERT(error);
    NSUInteger start = _characterIndex;
    NSUInteger length = 0;
    
    NSCharacterSet *singleCharacterFunctions = [[self class] _singleCharacterFunctionCharacterSet];
    if ([singleCharacterFunctions characterIsMember:[self _peekNextCharacter]]) {
        length++;
        _characterIndex++;
    } else {    
        NSCharacterSet *functionSet = [[self class] _functionCharacterSet];
        while ([functionSet characterIsMember:[self _peekNextCharacter]]) {
            length++;
            _characterIndex++;
        }
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
    ERR_ASSERT(error);
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
    ERR_ASSERT(error);
    NSUInteger start = _characterIndex;
    NSUInteger length = 1;
    
    unichar character = [self _nextCharacter];
    
    NSCharacterSet *operatorCharacters = [[self class] _operatorCharacterSet];
    if ([operatorCharacters characterIsMember:character]) {
        unichar peekNext = [self _peekNextCharacter];
        if (character == '<' || character == '>' || character == '*' || character == '&' || character == '|' || character == '=') {
            // <, >, *, &, |, =
            if (peekNext == character) {
                // <<, >>, **, &&, ||, ==
                _characterIndex++;
                length++;
            }
        }
        
        if ((character == '<' || character == '>' || character == '!') && peekNext == '=' && length == 1) {
            // <=, >=, !=
            _characterIndex++;
            length++;
        }
        
        NSString *rawToken = [NSString stringWithCharacters:(_characters + start) length:length];
        return [DDMathStringToken mathStringTokenWithToken:rawToken type:DDTokenTypeOperator];
    }
    
    _characterIndex = start;
    *error = ERR_BADARG(@"%C is not a valid operator", character);
    return nil;
}

@end
