//
//  DDMathOperatorSet.m
//  DDMathParser
//
//  Created by Dave DeLong on 7/13/14.
//
//

#import "DDMathOperatorSet.h"
#import "DDMathOperator.h"

@implementation DDMathOperatorSet {
    NSMutableOrderedSet *_operators;
    NSMutableDictionary *_operatorsByFunction;
    NSMutableDictionary *_operatorsByToken;
    
    DDMathOperator *_percentTokenOperator;
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
    return [self initWithOperators:[DDMathOperator defaultOperators]];
}

/*!
 * The actual designated initializer
 */
- (instancetype)initWithOperators:(NSArray *)operators {
    self = [super init];
    if (self) {
        _operators = [NSMutableOrderedSet orderedSetWithArray:[DDMathOperator defaultOperators]];
        _operatorsByFunction = [NSMutableDictionary dictionary];
        _operatorsByToken = [NSMutableDictionary dictionary];
        
        for (DDMathOperator *op in _operators) {
            [_operatorsByFunction setObject:op forKey:op.function];
            for (NSString *token in op.tokens) {
                NSMutableOrderedSet *operatorsForToken = [_operatorsByToken objectForKey:token];
                if (operatorsForToken == nil) {
                    operatorsForToken = [NSMutableOrderedSet orderedSet];
                    [_operatorsByToken setObject:operatorsForToken forKey:token];
                }
                [operatorsForToken addObject:op];
            }
        }
        
        _interpretsPercentSignAsModulo = YES;
        _percentTokenOperator = OPERATOR(DDOperatorModulo, @[@"%"], BINARY, 0, LEFT);
        DDMathOperator *multiply = [self operatorForFunction:DDOperatorMultiply];
        [self addOperator:_percentTokenOperator withPrecedenceHigherThanOperator:multiply];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    DDMathOperatorSet *dupe = [[[self class] alloc] initWithOperators:_operators.array];
    dupe.interpretsPercentSignAsModulo = self.interpretsPercentSignAsModulo;
    return dupe;
}

- (NSArray *)operators {
    return [_operators.array copy];
}

- (void)setInterpretsPercentSignAsModulo:(BOOL)interpretsPercentSignAsModulo {
    if (interpretsPercentSignAsModulo != _interpretsPercentSignAsModulo) {
        _interpretsPercentSignAsModulo = interpretsPercentSignAsModulo;
        
        [_operators removeObject:_percentTokenOperator];
        [_operatorsByFunction removeObjectForKey:_percentTokenOperator.function];
        for (NSString *token in _percentTokenOperator.tokens) {
            NSMutableOrderedSet *operatorsForToken = [_operatorsByToken objectForKey:token];
            [operatorsForToken removeObject:_percentTokenOperator];
            if ([operatorsForToken count] == 0) {
                [_operatorsByToken removeObjectForKey:token];
            }
        }
        
        DDMathOperator *relative = nil;
        if (_interpretsPercentSignAsModulo) {
            _percentTokenOperator = OPERATOR(DDOperatorModulo, @[@"%"], BINARY, 0, LEFT);
            relative = [self operatorForFunction:DDOperatorMultiply];
        } else {
            _percentTokenOperator = OPERATOR(DDOperatorPercent, @[@"%"], UNARY, 0, LEFT);
            // this will put it at the same precedence as factorial and dtor
            relative = [self operatorForFunction:DDOperatorUnaryMinus];
        }
        [self addOperator:_percentTokenOperator withPrecedenceHigherThanOperator:relative];
    }
}

- (void)addTokens:(NSArray *)newTokens forOperatorFunction:(NSString *)operatorFunction {
    DDMathOperator *existing = [self operatorForFunction:operatorFunction];
    if (existing == nil) {
        [NSException raise:NSInvalidArgumentException format:@"No operator is defined for function '%@'", operatorFunction];
        return;
    }
    
    DDMathOperator *newOperator = [[DDMathOperator alloc] initWithOperatorFunction:operatorFunction tokens:newTokens arity:0 precedence:0 associativity:0];
    [self addOperator:newOperator withPrecedenceSameAsOperator:existing];
}

- (void)addOperator:(DDMathOperator *)newOperator withPrecedenceHigherThanOperator:(DDMathOperator *)existingOperator {
    newOperator.precedence = existingOperator.precedence + 1;
    [self _processNewOperator:newOperator relativity:NSOrderedAscending];
}

- (void)addOperator:(DDMathOperator *)newOperator withPrecedenceSameAsOperator:(DDMathOperator *)existingOperator {
    newOperator.precedence = existingOperator.precedence;
    [self _processNewOperator:newOperator relativity:NSOrderedSame];
}

- (void)addOperator:(DDMathOperator *)newOperator withPrecedenceLowerThanOperator:(DDMathOperator *)existingOperator {
    newOperator.precedence = existingOperator.precedence - 1;
    [self _processNewOperator:newOperator relativity:NSOrderedDescending];
}

- (DDMathOperator *)operatorForFunction:(NSString *)function {
    return [_operatorsByFunction objectForKey:function];
}

- (NSArray *)operatorsForToken:(NSString *)token {
    token = [token lowercaseString];
    NSOrderedSet *operators = [_operatorsByToken objectForKey:token];
    return operators.array;
}

- (DDMathOperator *)operatorForToken:(NSString *)token arity:(DDOperatorArity)arity {
    NSArray *operators = [self operatorsForToken:token];
    for (DDMathOperator *op in operators) {
        if (op.arity == arity) {
            return op;
        }
    }
    return nil;
}

- (DDMathOperator *)operatorForToken:(NSString *)token arity:(DDOperatorArity)arity associativity:(DDOperatorAssociativity)associativity {
    NSArray *operators = [self operatorsForToken:token];
    for (DDMathOperator *op in operators) {
        if (op.arity == arity && op.associativity == associativity) {
            return op;
        }
    }
    return nil;
}

#pragma mark - Private

- (void)_processNewOperator:(DDMathOperator *)newOperator relativity:(NSComparisonResult)relativity {
    // first, see if there's an operator for this function already
    DDMathOperator *existingOperatorForFunction = [_operatorsByFunction objectForKey:newOperator.function];
    DDMathOperator *resolvedOperator = newOperator;
    if (existingOperatorForFunction != nil) {
        resolvedOperator = existingOperatorForFunction;
        // there is; just add new tokens; don't change any precedence
        [existingOperatorForFunction addTokens:newOperator.tokens];
    } else {
        // there is not.  this is a genuinely new operator
        
        // first, make sure the tokens involved in this new operator are unique
        for (NSString *token in newOperator.tokens) {
            DDMathOperator *existing = [_operatorsByToken objectForKey:[token lowercaseString]];
            if (existing != nil) {
                [NSException raise:NSInvalidArgumentException format:@"An operator is already defined for '%@'", token];
            }
        }
        
        [_operators addObject:newOperator];
        
        if (relativity != NSOrderedSame) {
            NSInteger newPrecedence = newOperator.precedence;
            
            if (relativity == NSOrderedAscending) {
                // the new operator has a precedence higher than the original operator
                // all operators that have an equivalent (or higher) precedence need to be bumped up one
                // to accomodate the new operator
                [_operators enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    DDMathOperator *op = obj;
                    if (op.precedence >= newPrecedence) {
                        op.precedence++;
                    }
                }];
            } else {
                [_operators enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    DDMathOperator *op = obj;
                    if (op.precedence > newPrecedence || op == newOperator) {
                        op.precedence++;
                    }
                }];
            }
        }
        
        [_operators sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"precedence" ascending:YES]]];
        [_operatorsByFunction setObject:newOperator forKey:newOperator.function];
    }
    
    for (NSString *token in newOperator.tokens) {
        NSString *lowercaseToken = [token lowercaseString];
        NSMutableOrderedSet *operatorsForToken = [_operatorsByToken objectForKey:lowercaseToken];
        if (operatorsForToken == nil) {
            operatorsForToken = [NSMutableOrderedSet orderedSet];
            [_operatorsByToken setObject:operatorsForToken forKey:lowercaseToken];
        }
        [operatorsForToken addObject:resolvedOperator];
    }
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len {
    return [_operators countByEnumeratingWithState:state objects:buffer count:len];
}

@end
