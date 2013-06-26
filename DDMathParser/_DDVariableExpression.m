//
//  _DDVariableExpression.m
//  DDMathParser
//
//  Created by Dave DeLong on 11/18/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "DDMathParser.h"
#import "_DDVariableExpression.h"
#import "DDMathEvaluator.h"
#import "DDMathEvaluator+Private.h"
#import "DDMathParserMacros.h"

@implementation _DDVariableExpression {
	
	NSString *_variable;
}

- (id)initWithVariable:(NSString *)v {
	self = [super init];
	if (self) {
        if ([v hasPrefix:@"$"]) {
            v = [v substringFromIndex:1];
        }
        if ([v length] == 0) {
            DD_RELEASE(self);
            return nil;
        }
		_variable = [v copy];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    return [self initWithVariable:[aDecoder decodeObjectForKey:@"variable"]];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[self variable] forKey:@"variable"];
}

#if !DD_HAS_ARC
- (void)dealloc {
	[_variable release];
	[super dealloc];
}
#endif

- (DDExpressionType)expressionType { return DDExpressionTypeVariable; }

- (NSString *)variable { return _variable; }

- (DDExpression *)simplifiedExpressionWithEvaluator:(DDMathEvaluator *)evaluator error:(NSError **)error {
#pragma unused(evaluator, error)
	return self;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"$%@", [self variable]];
}

@end
