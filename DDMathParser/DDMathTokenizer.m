//
//  DDMathTokenizer.m
//  DDMathParser
//
//  Created by Dave DeLong on 6/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DDMathParser.h"
#import "DDMathTokenizer.h"
#import "DDMathParserMacros.h"
#import "DDMathToken.h"
#import "DDMathOperator.h"
#import "DDMathOperatorSet.h"

#define DD_IS_DIGIT(_c) ((_c) >= '0' && (_c) <= '9')
#define DD_IS_HEX(_c) (((_c) >= '0' && (_c) <= '9') || ((_c) >= 'a' && (_c) <= 'f') || ((_c) >= 'A' && (_c) <= 'F'))
#define DD_IS_WHITESPACE(_c) ([[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:(_c)])

@interface DDMathTokenizer ()

- (unichar)_peekNextCharacter;
- (unichar)_nextCharacter;

- (DDMathToken *)_nextTokenWithError:(NSError **)error;
- (DDMathToken *)_parseNumberWithError:(NSError **)error;
- (DDMathToken *)_parseFunctionWithError:(NSError **)error;
- (DDMathToken *)_parseVariableWithError:(NSError **)error;
- (DDMathToken *)_parseOperatorWithError:(NSError **)error;

@end

@implementation DDMathTokenizer {
    unichar *_characters;
    unichar *_caseInsensitiveCharacters;
    
    NSUInteger _length;
    NSUInteger _characterIndex;
    
    NSMutableArray *_tokens;
    NSUInteger _tokenIndex;
    
}

+ (NSCharacterSet *)_singleCharacterFunctionCharacterSet {
    static dispatch_once_t onceToken;
    static NSCharacterSet *_singleCharFunctionSet = nil;
    dispatch_once(&onceToken, ^{
        NSString *singleChars = [NSString stringWithFormat:@"\u03C0\u03D5\u03C4"];  // π, ϕ, and τ
        _singleCharFunctionSet = [NSCharacterSet characterSetWithCharactersInString:singleChars];
    });
    return _singleCharFunctionSet;
}

- (instancetype)initWithString:(NSString *)expressionString operatorSet:(DDMathOperatorSet *)operatorSet error:(NSError *__autoreleasing *)error {
	ERR_ASSERT(error);
    self = [super init];
    if (self) {
        _operatorSet = operatorSet;
        if (_operatorSet == nil) {
            _operatorSet = [DDMathOperatorSet defaultOperatorSet];
        }
        
        _length = [expressionString length];
        _characters = (unichar *)calloc(_length+1, sizeof(unichar));
        _caseInsensitiveCharacters = (unichar *)calloc(_length+1, sizeof(unichar));
        
        [expressionString getCharacters:_characters];
        [[expressionString lowercaseString] getCharacters:_caseInsensitiveCharacters];
        
        _characterIndex = 0;
        
        _tokens = [[NSMutableArray alloc] init];
        DDMathToken *token = nil;
        while((token = [self _nextTokenWithError:error]) != nil) {
            [_tokens addObject:token];
        }
		
        if (error && *error) {
            self = nil;
        }
    }
    
    return self;
}

- (void)dealloc {
    free(_characters);
    free(_caseInsensitiveCharacters);
}

#pragma mark Character methods

- (unichar)_peekNextCharacter {
    return [self _peek:_characters];
}

- (unichar)_nextCharacter {
    return [self _next:_characters];
}

- (unichar)_peek:(unichar *)characters {
    if (_characterIndex >= _length) { return '\0'; }
    return characters[_characterIndex];
}

- (unichar)_next:(unichar *)characters {
    unichar character = [self _peek:characters];
    if (character != '\0') { _characterIndex++; }
    return character;
}

- (DDMathToken *)_nextTokenWithError:(NSError **)error {
    ERR_ASSERT(error);
    unichar next = [self _peekNextCharacter];
    while (DD_IS_WHITESPACE(next)) {
        (void)[self _nextCharacter];
        next = [self _peekNextCharacter];
    }
    if (next == '\0') { return nil; }
    
    DDMathToken *token = nil;
    if (DD_IS_DIGIT(next) || next == '.') {
        token = [self _parseNumberWithError:error];
    }
    
    if (token == nil && next == '$') {
        token = [self _parseVariableWithError:error];
    }
    
    if (token == nil && (next == '"' || next == '\'')) {
        token = [self _parseStringVariableWithError:error];
    }
    
    if (token == nil) {
        token = [self _parseOperatorWithError:error];
    }
    
    if (token == nil) {
        token = [self _parseFunctionWithError:error];
    }
    
    if (token != nil) {
        *error = nil;
    }
    return token;
}

- (DDMathToken *)_parseNumberWithError:(NSError **)error {
    ERR_ASSERT(error);
    NSUInteger start = _characterIndex;
    DDMathToken *token = nil;
    
    if ([self _peekNextCharacter] == '0') {
        _characterIndex++;
        unichar next = [self _peekNextCharacter];
        if (next == 'x' || next == 'X') {
            _characterIndex++;
            return [self _parseHexNumberWithError:error];
        } else {
            _characterIndex = start;
        }
    }
    
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
        if (length != 1 || _characters[start] != '.') { // do not recognize "." as a number
            NSString *rawToken = [NSString stringWithCharacters:(_characters+start) length:length];
            token = [[DDMathToken alloc] initWithToken:rawToken type:DDTokenTypeNumber operator:nil];
        }
    }
    
    if (!token) {
        _characterIndex = start;
        *error = DD_ERR(DDErrorCodeInvalidNumber, @"unable to parse number");
    }
    return token;
}

- (DDMathToken *)_parseHexNumberWithError:(NSError **)error {
    ERR_ASSERT(error);
    DDMathToken *token = nil;
    NSUInteger start = _characterIndex;
    while (DD_IS_HEX([self _peekNextCharacter])) {
        _characterIndex++;
    }
    NSUInteger length = _characterIndex - start;
    if (length > 0) {
        NSString *rawHex = [NSString stringWithCharacters:(_characters+start) length:length];
        NSScanner *scanner = [NSScanner scannerWithString:rawHex];
        
        unsigned long long hexValue = 0;
        [scanner scanHexLongLong:&hexValue];
        
        token = [[DDMathToken alloc] initWithToken:[@(hexValue) stringValue] type:DDTokenTypeNumber operator:nil];
    }
    
    if (!token) {
        _characterIndex = start;
        *error = DD_ERR(DDErrorCodeInvalidNumber, @"unable to parse hex number");
    }
    return token;
}

- (DDMathToken *)_parseFunctionWithError:(NSError **)error {
    ERR_ASSERT(error);
    NSUInteger start = _characterIndex;
    NSUInteger length = 0;
    
    NSCharacterSet *singleCharacterFunctions = [[self class] _singleCharacterFunctionCharacterSet];
    if ([singleCharacterFunctions characterIsMember:[self _peekNextCharacter]]) {
        length++;
        _characterIndex++;
    } else {
        NSCharacterSet *operatorChars = self.operatorSet.operatorCharacters;
        unichar peekNext = '\0';
        while ((peekNext = [self _peekNextCharacter]) != '\0' &&
               DD_IS_WHITESPACE(peekNext) == NO &&
               [operatorChars characterIsMember:peekNext] == NO) {
            
            length++;
            _characterIndex++;
        }
    }
    
    if (length > 0) {
        NSString *rawToken = [NSString stringWithCharacters:(_characters+start) length:length];
        return [[DDMathToken alloc] initWithToken:rawToken type:DDTokenTypeFunction operator:nil];
    }
    
    _characterIndex = start;
    *error = DD_ERR(DDErrorCodeInvalidIdentifier, @"unable to parse identifier");
    return nil;
}

- (DDMathToken *)_parseVariableWithError:(NSError **)error {
    ERR_ASSERT(error);
    NSUInteger start = _characterIndex;
    _characterIndex++; // consume the $
    DDMathToken *token = [self _parseFunctionWithError:error];
    if (token == nil) {
        _characterIndex = start;
        *error = DD_ERR(DDErrorCodeInvalidVariable, @"variable names must be at least 1 character long");
    } else {
        token = [[DDMathToken alloc] initWithToken:token.token type:DDTokenTypeVariable operator:nil];
        *error = nil;
    }
    return token;
}

- (DDMathToken *)_parseStringVariableWithError:(NSError **)error {
    ERR_ASSERT(error);
    NSUInteger start = _characterIndex;
    unichar quoteChar = [self _peekNextCharacter];
    
    _characterIndex++; // consume the quote
    
    BOOL isBackslashEscaped = NO;
    NSMutableString *cleaned = [NSMutableString stringWithCapacity:42];
    
    while (1) {
        unichar next = [self _peekNextCharacter];
        if (next == '\0') { break; }
        
        if (isBackslashEscaped == NO) {
            if (next == '\\') {
                isBackslashEscaped = YES;
                _characterIndex++; // consume the backslash
            } else if (next != quoteChar) {
                [cleaned appendFormat:@"%C", [self _nextCharacter]];
            } else {
                // it's a single/double quote
                break;
            }
        } else {
            [cleaned appendFormat:@"%C", next];
            isBackslashEscaped = NO;
            _characterIndex++;
        }
    }
    
    if ([self _peekNextCharacter] != quoteChar) {
        _characterIndex = start;
        *error = DD_ERR(DDErrorCodeInvalidVariable, @"Unable to parsed quoted variable name");
        return nil;
    } else {
        _characterIndex++;
        *error = nil;
        return [[DDMathToken alloc] initWithToken:cleaned type:DDTokenTypeVariable operator:nil];
    }
}

- (DDMathToken *)_parseOperatorWithError:(NSError **)error {
    ERR_ASSERT(error);
    NSUInteger start = _characterIndex;
    NSUInteger length = 1;
    
    unichar character = [self _next:_caseInsensitiveCharacters];
    
    NSString *lastGood = nil;
    DDMathOperator *lastGoodOperator = nil;
    NSUInteger lastGoodLength = length;
    
    while (character != '\0') {
        NSString *tmp = [NSString stringWithCharacters:(_caseInsensitiveCharacters+start) length:length];
        if ([self.operatorSet hasOperatorWithPrefix:tmp]) {
            NSArray *operators = [self.operatorSet operatorsForToken:tmp];
            if (operators.count > 0) {
                lastGood = tmp;
                lastGoodLength = length;
                lastGoodOperator = (operators.count == 1 ? operators.firstObject : nil);
            }
            character = [self _next:_caseInsensitiveCharacters];
            length++;
        } else {
            break;
        }
    }
    
    if (lastGood != nil) {
        _characterIndex = start+lastGoodLength;
        
        return [[DDMathToken alloc] initWithToken:lastGood type:DDTokenTypeOperator operator:lastGoodOperator];
    }
    
    _characterIndex = start;
    *error = DD_ERR(DDErrorCodeInvalidOperator, @"%C is not a valid operator", character);
    return nil;
}

@end

@implementation DDMathTokenizer (Deprecated)

+ (id)tokenizerWithString:(NSString *)expressionString error:(NSError *__autoreleasing *)error {
    return [[self alloc] initWithString:expressionString operatorSet:nil error:error];
}

- (id)initWithString:(NSString *)expressionString error:(NSError *__autoreleasing *)error {
    return [self initWithString:expressionString operatorSet:nil error:error];
}

@end
