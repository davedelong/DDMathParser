//
//  DDMathOperatorSet.m
//  DDMathParser
//
//  Created by Dave DeLong on 7/13/14.
//
//

#import "DDMathOperatorSet.h"
#import "DDMathOperator.h"

@interface DDMathOperator (DDMathOperatorSet)

@property (nonatomic, assign) NSInteger precedence;
@property (nonatomic, assign) DDMathOperatorAssociativity associativity;

- (void)addTokens:(NSArray *)moreTokens;

@end

@interface _DDMathOperatorTokenMap : NSObject

@property (nonatomic, readonly) NSCharacterSet *tokenCharacterSet;
- (void)addOperator:(DDMathOperator *)operator;
- (void)removeOperator:(DDMathOperator *)operator;
- (BOOL)isOperatorCharacter:(unichar)character;
- (BOOL)hasOperatorsForPrefix:(NSString *)prefix;
- (NSArray *)operatorsForToken:(NSString *)token;
- (NSString *)existingTokenForOperatorTokens:(DDMathOperator *)operator;
- (void)addTokens:(NSArray *)tokens forOperator:(DDMathOperator *)operator;

@end

@implementation DDMathOperatorSet {
    NSMutableOrderedSet *_operators;
    _DDMathOperatorTokenMap *_operatorsByToken;
    NSMutableDictionary *_operatorsByFunction;
    
    DDMathOperator *_percentOperator;
}

+ (instancetype)defaultOperatorSet {
    static DDMathOperatorSet *defaultSet = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultSet = [[DDMathOperatorSet alloc] init];
    });
    return defaultSet;
}

- (instancetype)init {
    // not actually the designated initializer
    return [self initWithOperators:[DDMathOperator defaultOperators] interpretPercentSignAsModulo:YES];
}

- (instancetype)initWithOperators:(NSArray *)operators interpretPercentSignAsModulo:(BOOL)percentAsMod {
    self = [super init];
    if (self) {
        _operators = [NSMutableOrderedSet orderedSetWithArray:operators];
        _operatorsByFunction = [NSMutableDictionary dictionary];
        _operatorsByToken = [[_DDMathOperatorTokenMap alloc] init];
        
        for (DDMathOperator *op in _operators) {
            _operatorsByFunction[op.function] = op;
            [_operatorsByToken addOperator:op];
        }
        
        self.interpretsPercentSignAsModulo = percentAsMod;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    DDMathOperatorSet *dupe = [[[self class] alloc] initWithOperators:_operators.array interpretPercentSignAsModulo:self.interpretsPercentSignAsModulo];
    dupe.interpretsPercentSignAsModulo = self.interpretsPercentSignAsModulo;
    return dupe;
}

- (void)setInterpretsPercentSignAsModulo:(BOOL)interpretsPercentSignAsModulo {
    _interpretsPercentSignAsModulo = interpretsPercentSignAsModulo;
    if (_percentOperator != nil) {
        [self removeOperator:_percentOperator];
    }
    
    if (_interpretsPercentSignAsModulo == YES) {
        _percentOperator = [DDMathOperator moduloOperator];
        DDMathOperator *implicitMultiply = [self operatorForFunction:DDMathOperatorImplicitMultiply];
        [self addOperator:_percentOperator withPrecedenceHigherThanOperator:implicitMultiply];
    } else {
        _percentOperator = [DDMathOperator percentOperator];
        DDMathOperator *factorial = [self operatorForFunction:DDMathOperatorFactorial];
        [self addOperator:_percentOperator withPrecedenceSameAsOperator:factorial];
    }
}

- (NSArray *)operators {
    return _operators.array.copy;
}

- (NSCharacterSet *)operatorCharacters {
    return _operatorsByToken.tokenCharacterSet;
}

- (BOOL)isOperatorCharacter:(unichar)character {
    return [_operatorsByToken isOperatorCharacter:character];
}

- (BOOL)hasOperatorWithPrefix:(NSString *)prefix {
    return [_operatorsByToken hasOperatorsForPrefix:prefix];
}

- (DDMathOperator *)operatorForFunction:(NSString *)function {
    return _operatorsByFunction[function];
}

- (NSArray *)operatorsForToken:(NSString *)token {
    return [_operatorsByToken operatorsForToken:token];
}

- (DDMathOperator *)operatorForToken:(NSString *)token arity:(DDMathOperatorArity)arity {
    NSArray *operators = [self operatorsForToken:token];
    for (DDMathOperator *operator in operators) {
        if (operator.arity == arity) { return operator; }
    }
    return nil;
}

- (DDMathOperator *)operatorForToken:(NSString *)token arity:(DDMathOperatorArity)arity associativity:(DDMathOperatorAssociativity)associativity {
    NSArray *operators = [self operatorsForToken:token];
    for (DDMathOperator *operator in operators) {
        if (operator.arity == arity && operator.associativity == associativity) { return operator; }
    }
    return nil;
}

- (void)addTokens:(NSArray *)newTokens forOperatorFunction:(NSString *)operatorFunction {
    DDMathOperator *existing = [self operatorForFunction:operatorFunction];
    if (existing != nil) {
        DDMathOperator *tmp = OPERATOR(operatorFunction, newTokens, existing.arity, existing.precedence, existing.associativity);
        [self addOperator:tmp withPrecedenceSameAsOperator:existing];
    } else {
        [NSException raise:NSInternalInconsistencyException format:@"No operators defined for %@ function", operatorFunction];
    }
}

- (void)removeOperator:(DDMathOperator *)operator {
    if ([_operators containsObject:operator]) {
        [_operators removeObject:operator];
        
        [_operatorsByFunction removeObjectForKey:operator.function];
        [_operatorsByToken removeOperator:operator];
    }
}

- (void)addOperator:(DDMathOperator *)newOperator withPrecedenceSameAsOperator:(DDMathOperator *)existingOperator {
    newOperator.precedence = existingOperator.precedence;
    [self _processOperator:newOperator sorter:^BOOL(DDMathOperator *other) {
        return NO;
    }];
}

- (void)addOperator:(DDMathOperator *)newOperator withPrecedenceLowerThanOperator:(DDMathOperator *)existingOperator {
    newOperator.precedence = existingOperator.precedence;
    [self _processOperator:newOperator sorter:^BOOL(DDMathOperator *other) {
        return other.precedence >= existingOperator.precedence;
    }];
}

- (void)addOperator:(DDMathOperator *)newOperator withPrecedenceHigherThanOperator:(DDMathOperator *)existingOperator {
    newOperator.precedence = existingOperator.precedence;
    [self _processOperator:newOperator sorter:^BOOL(DDMathOperator *other) {
        return other.precedence > existingOperator.precedence;
    }];
}

- (void)_processOperator:(DDMathOperator *)operator sorter:(BOOL(^)(DDMathOperator *other))sorter {
    if (_operatorsByFunction[operator.function] != nil) {
        // existing operator to which we are adding tokens
        DDMathOperator *existing = _operatorsByFunction[operator.function];
        [existing addTokens:operator.tokens];
        [_operatorsByToken addTokens:operator.tokens forOperator:existing];
        
    } else {
        NSString *existingToken = [_operatorsByToken existingTokenForOperatorTokens:operator];
        if (existingToken != nil) {
            [NSException raise:NSInvalidArgumentException format:@"An operator is already defined for %@", existingToken];
        }
        
        for (DDMathOperator *other in _operators) {
            if (sorter(other)) {
                other.precedence++;
            }
        }
        
        [_operators addObject:operator];
        _operatorsByFunction[operator.function] = operator;
        [_operatorsByToken addOperator:operator];
    }
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len {
    return [_operators countByEnumeratingWithState:state objects:buffer count:len];
}

@end

@implementation _DDMathOperatorTokenMap {
    NSMutableDictionary *_map;
    NSCountedSet *_tokenCharacters;
    NSCharacterSet *_allowedTokenCharacters;
    
    NSCharacterSet *_tokenCharacterSet;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _map = [NSMutableDictionary dictionary];
        _tokenCharacters = [NSCountedSet set];
        _allowedTokenCharacters = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
    }
    return self;
}

- (NSString *)_convertTokenCharacter:(unichar)character {
    if ([_allowedTokenCharacters characterIsMember:character]) {
        return [NSString stringWithFormat:@"%C", character];
    }
    return nil;
}

- (void)addToken:(NSString *)token {
    for (NSUInteger i = 0; i < token.length; ++i) {
        NSString *tokenCharacter = [self _convertTokenCharacter:[token characterAtIndex:i]];
        if (tokenCharacter) {
            [_tokenCharacters addObject:tokenCharacter];
        }
    }
}

- (void)removeToken:(NSString *)token {
    for (NSUInteger i = 0; i < token.length; ++i) {
        NSString *tokenCharacter = [self _convertTokenCharacter:[token characterAtIndex:i]];
        if (tokenCharacter) {
            [_tokenCharacters removeObject:tokenCharacter];
        }
    }
}

- (void)addTokens:(NSArray *)tokens forOperator:(DDMathOperator *)operator {
    for (NSString *token in tokens) {
        NSString *lowercaseToken = token.lowercaseString;
        
        NSMutableOrderedSet *existingOperators = _map[lowercaseToken];
        if (existingOperators == nil) {
            existingOperators = [NSMutableOrderedSet orderedSet];
            _map[lowercaseToken] = existingOperators;
        }
        
        if ([existingOperators containsObject:operator] == NO) {
            [existingOperators addObject:operator];
        }
        [self addToken:lowercaseToken];
    }
}

- (void)addOperator:(DDMathOperator *)operator {
    [self addTokens:operator.tokens forOperator:operator];
    
    NSString *tokenCharacters = [_tokenCharacters.allObjects componentsJoinedByString:@""];
    _tokenCharacterSet = [NSCharacterSet characterSetWithCharactersInString:tokenCharacters];
}

- (void)removeOperator:(DDMathOperator *)operator {
    for (NSString *token in operator.tokens) {
        NSMutableOrderedSet *existingOperators = _map[token.lowercaseString];
        if (existingOperators) {
            [existingOperators removeObject:operator];
            [self removeToken:token.lowercaseString];
        }
    }
    
    NSString *tokenCharacters = [_tokenCharacters.allObjects componentsJoinedByString:@""];
    _tokenCharacterSet = [NSCharacterSet characterSetWithCharactersInString:tokenCharacters];
}

- (NSString *)existingTokenForOperatorTokens:(DDMathOperator *)operator {
    for (NSString *token in operator.tokens) {
        if ([_map[token.lowercaseString] count] > 0) {
            return token.lowercaseString;
        }
    }
    return nil;
}

- (BOOL)isOperatorCharacter:(unichar)character {
    NSString *converted = [self _convertTokenCharacter:character];
    if (converted != nil) {
        return [_tokenCharacters containsObject:converted];
    }
    return NO;
}

- (BOOL)hasOperatorsForPrefix:(NSString *)prefix {
    NSString *lowercasePrefix = prefix.lowercaseString;
    for (NSString *token in _map) {
        if ([token hasPrefix:lowercasePrefix]) {
            return YES;
        }
    }
    return NO;
}

- (NSArray *)operatorsForToken:(NSString *)token {
    NSMutableOrderedSet *existing = _map[token.lowercaseString];
    return existing.array.copy;
}

@end
