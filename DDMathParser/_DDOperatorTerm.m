//
//  _DDOperatorTerm.m
//  DDMathParser
//
//  Created by Dave DeLong on 7/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "_DDOperatorTerm.h"
#import "DDMathStringToken.h"

@implementation _DDOperatorTerm

- (DDParserTermType)type { return DDParserTermTypeOperator; }

- (DDOperator)operatorType {
    return [[self token] operatorType];
}

- (DDPrecedence)operatorPrecedence {
    return [[self token] operatorPrecedence];
}

- (DDOperatorArity)operatorArity {
    return [[self token] operatorArity];
}

- (NSString *)operatorFunction {
    
    static NSDictionary *operatorNames = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
		operatorNames = [[NSDictionary alloc] initWithObjectsAndKeys:
						 @"or", @"|",
						 @"xor", @"^", 
						 @"and", @"&", 
						 @"lshift", @"<<", 
						 @"rshift", @">>", 
						 @"subtract", @"-",
						 @"add", @"+", 
						 @"divide", @"/", 
						 @"multiply", @"*", 
						 @"mod", @"%", 
						 @"not", @"~", 
						 @"factorial", @"!", 
						 @"pow", @"**", 
						 nil];
    });
	
	NSString * function = [operatorNames objectForKey:[[self token] token]];
	if ([self operatorPrecedence] == DDPrecedenceUnary) {
		if ([[[self token] token] isEqual:@"-"]) { return @"negate"; }
		if ([[[self token] token] isEqual:@"+"]) { return @""; }
	}
    
    return function;
}

- (NSString *)description {
    return [[self token] token];
}

@end
