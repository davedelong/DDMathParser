//
//  DDMathTokenInterpreter.m
//  DDMathParser
//
//  Created by Dave DeLong on 7/13/14.
//
//

#import "DDMathTokenInterpreter.h"
#import "DDMathTokenizer.h"
#import "DDMathToken.h"
#import "DDMathOperator.h"
#import "DDMathOperatorSet.h"

const DDMathTokenInterpreterOptions DDMathTokenInterpreterDefaultOptions = DDMathTokenInterpreterOptionsAllowsArgumentlessFunctions | DDMathTokenInterpreterOptionsAllowsImplicitMultiplication;

@interface DDMathTokenInterpreter ()

@property (readonly) DDMathTokenizer *tokenizer;
@property (readonly) DDMathOperatorSet *operatorSet;

@property (readonly) BOOL allowsArgumentlessFunctions;
@property (readonly) BOOL allowsImplicitMultiplication;
@property (readonly) BOOL usesHighPrecedenceImplicitMultiplication;

@end

@implementation DDMathTokenInterpreter {
    NSMutableArray *_tokens;
}

- (instancetype)initWithTokenizer:(DDMathTokenizer *)tokenizer error:(NSError *__autoreleasing *)error {
    return [self initWithTokenizer:tokenizer options:DDMathTokenInterpreterDefaultOptions error:error];
}

- (instancetype)initWithTokenizer:(DDMathTokenizer *)tokenizer options:(DDMathTokenInterpreterOptions)options error:(NSError *__autoreleasing *)error {
    self = [super init];
    if (self) {
        _tokens = [NSMutableArray array];
        _tokenizer = tokenizer;
        _operatorSet = tokenizer.operatorSet;
        
        _allowsArgumentlessFunctions = !!(options & DDMathTokenInterpreterOptionsAllowsArgumentlessFunctions);
        _allowsImplicitMultiplication = !!(options & DDMathTokenInterpreterOptionsAllowsImplicitMultiplication);
        _usesHighPrecedenceImplicitMultiplication = !!(options & DDMathTokenInterpreterOptionsImplicitMultiplicationHasHigherPrecedence);
        
        NSError *localError = nil;
        if ([self _interpretTokens:tokenizer error:&localError] == NO) {
            if (error != nil) {
                *error = localError;
            }
            return nil;
        }
    }
    return self;
}

- (BOOL)_interpretTokens:(DDMathTokenizer *)tokenizer error:(NSError **)error {
    
    for (DDMathToken *token in tokenizer.tokens) {
        NSArray *newTokens = [self tokensForToken:token error:error];
        if (newTokens == nil) { return NO; }
        [_tokens addObjectsFromArray:newTokens];
    }
    
    NSArray *newTokens = [self tokensForToken:nil error:error];
    if (newTokens == nil) { return NO; }
    [_tokens addObjectsFromArray:newTokens];
    
    return YES;
}

- (NSArray *)tokensForToken:(DDMathToken *)token error:(NSError **)error {
    DDMathToken *lastToken = self.tokens.lastObject;
    DDMathToken *replacement = token;
    
    if (token != nil) {
        //figure out if "-" and "+" are unary or binary
        replacement = [self replacementTokenForAmbiguousOperator:token previousToken:lastToken error:error];
        if (replacement == nil) { return nil; }
    }
    
    if (replacement.mathOperator.function == DDMathOperatorUnaryPlus) {
        // the unary + operator is a no-op operator.  It does nothing, so we'll throw it out
        return @[];
    }
    
    NSMutableArray *tokens = [NSMutableArray array];
    
    if (self.allowsArgumentlessFunctions) {
        // this checks to see if the previous token was a function that takes no arguments
        NSArray *cleaned = [self extraTokensForArgumentlessFunction:replacement previousToken:lastToken error:error];
        if (cleaned == nil) { return nil; }
        [tokens addObjectsFromArray:cleaned];
    }
    
    if (self.allowsImplicitMultiplication) {
        // this checks to see if we need to inject a multiplication token
        lastToken = tokens.lastObject ?: lastToken;
        NSArray *cleaned = [self extraTokensForImplicitMultiplication:replacement previousToken:lastToken error:error];
        if (cleaned == nil) { return nil; }
        [tokens addObjectsFromArray:cleaned];
    }
    
    if (replacement) {
        [tokens addObject:replacement];
    }
    return tokens;
}

- (DDMathToken *)replacementTokenForAmbiguousOperator:(DDMathToken *)token previousToken:(DDMathToken *)previous error:(NSError **)error {
    // short circuit if this isn't an ambiguous operator
    if (token.tokenType != DDTokenTypeOperator) { return token; }
    if (token.ambiguous == NO) { return token; }
    
    DDMathOperator *resolvedOperator = nil;
    DDMathOperatorArity arity = DDMathOperatorArityBinary;
    
    if (previous == nil) {
        // this is the first token in the stream
        // and of necessity must be a unary token
        arity = DDMathOperatorArityUnary;
    } else if (previous.tokenType == DDTokenTypeOperator) {
        if (previous.mathOperator.arity == DDMathOperatorArityBinary) {
            // a binary operator can't be followed by a binary operator
            // therefore this is a unary operator
            arity = DDMathOperatorArityUnary;
        } else if (previous.mathOperator.arity == DDMathOperatorArityUnary) {
            if (previous.mathOperator.associativity == DDMathOperatorAssociativityRight) {
                // a right-assoc unary operator can't be followed by a binary operator
                // therefore this needs to be a unary operator
                arity = DDMathOperatorArityUnary;
            } else {
                // a left-assoc unary operator can be followed by:
                // another left-assoc unary operator,
                // a binary operator,
                // or a right-assoc unary operator (assuming implicit multiplication)
                // we'll prefer them from left-to-right:
                // left-assoc unary, binary, right-assoc unary
                // TODO: is this correct?? should we be looking at precedence instead?
                resolvedOperator = [self.operatorSet operatorForToken:token.token arity:DDMathOperatorArityUnary associativity:DDMathOperatorAssociativityLeft];
                
                if (resolvedOperator == nil) {
                    resolvedOperator = [self.operatorSet operatorForToken:token.token arity:DDMathOperatorArityBinary];
                }
                if (resolvedOperator == nil) {
                    resolvedOperator = [self.operatorSet operatorForToken:token.token arity:DDMathOperatorArityUnary associativity:DDMathOperatorAssociativityRight];
                }
            }
        } else {
            // the previous operator is ambiguous too??
            // fatal error!
            [NSException raise:NSInternalInconsistencyException format:@"Didn't resolve ambiguous operator: %@", previous];
            return nil;
        }
    } else if (previous.tokenType == DDTokenTypeNumber || previous.tokenType == DDTokenTypeVariable) {
        // a number/variable can be followed by:
        // a left-assoc unary operator,
        // a binary operator,
        // or a right-assoc unary operator (assuming implicit multiplication)
        // we'll prefer them from left-to-right:
        // left-assoc unary, binary, right-assoc unary
        // TODO: is this correct?? should we be looking at precedence instead?
        resolvedOperator = [self.tokenizer.operatorSet operatorForToken:token.token arity:DDMathOperatorArityUnary associativity:DDMathOperatorAssociativityLeft];
        
        if (resolvedOperator == nil) {
            resolvedOperator = [self.operatorSet operatorForToken:token.token arity:DDMathOperatorArityBinary];
        }
        if (resolvedOperator == nil) {
            resolvedOperator = [self.operatorSet operatorForToken:token.token arity:DDMathOperatorArityUnary associativity:DDMathOperatorAssociativityRight];
        }
    } else {
        arity = DDMathOperatorArityBinary;
    }
    
    if (resolvedOperator == nil) {
        resolvedOperator = [self.tokenizer.operatorSet operatorForToken:token.token arity:arity];
    }
    
    if (resolvedOperator == nil) {
        if (error) {
            *error = DD_ERR(DDErrorCodeUnknownOperatorPrecedence, @"unknown precedence for token: %@", token);
        }
        return nil;
    }
    
    return [[DDMathToken alloc] initWithToken:token.token type:DDTokenTypeOperator operator:resolvedOperator];
}

- (NSArray *)extraTokensForArgumentlessFunction:(DDMathToken *)token previousToken:(DDMathToken *)previous error:(NSError **)error {
    NSArray *replacements = @[];
    
    if (previous != nil && previous.tokenType == DDTokenTypeFunction) {
        if (token == nil || token.tokenType != DDTokenTypeOperator || token.mathOperator.function != DDMathOperatorParenthesisOpen) {
            
            DDMathToken *openParen = [[DDMathToken alloc] initWithToken:@"("
                                                                   type:DDTokenTypeOperator
                                                               operator:[self.operatorSet operatorForFunction:DDMathOperatorParenthesisOpen]];
            
            DDMathToken *closeParen = [[DDMathToken alloc] initWithToken:@")"
                                                                    type:DDTokenTypeOperator
                                                                operator:[self.operatorSet operatorForFunction:DDMathOperatorParenthesisClose]];
            
            replacements = @[openParen, closeParen];
        }
    }
    return replacements;
}

- (NSArray *)extraTokensForImplicitMultiplication:(DDMathToken *)token previousToken:(DDMathToken *)previous error:(NSError **)error {
    // See: https://github.com/davedelong/DDMathParser/wiki/Implicit-Multiplication
    
    NSArray *replacements = @[];
    
    if (previous != nil && token != nil) {
        BOOL shouldInsertMultiplier = NO;
        
        if (previous.tokenType == DDTokenTypeNumber ||
            previous.tokenType == DDTokenTypeVariable ||
            (previous.mathOperator.arity == DDMathOperatorArityUnary && previous.mathOperator.associativity == DDMathOperatorAssociativityLeft)) {
            
            if (token.tokenType != DDTokenTypeOperator ||
                (token.mathOperator.arity == DDMathOperatorArityUnary && token.mathOperator.associativity == DDMathOperatorAssociativityRight)) {
                //inject a "multiplication" token:
                shouldInsertMultiplier = YES;
            }
            
        }
        
        if (shouldInsertMultiplier) {
            DDMathOperator *multiplyOperator = nil;
            if (self.usesHighPrecedenceImplicitMultiplication) {
                multiplyOperator = [self.operatorSet operatorForFunction:DDMathOperatorImplicitMultiply];
            } else {
                multiplyOperator = [self.operatorSet operatorForFunction:DDMathOperatorMultiply];
            }
            
            DDMathToken *multiply = [[DDMathToken alloc] initWithToken:@"*" type:DDTokenTypeOperator operator:multiplyOperator];
            replacements = @[multiply];
        }
    }
    return replacements;
}

@end
