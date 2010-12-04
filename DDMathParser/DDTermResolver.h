//
//  DDTermResolver.h
//  DDMathParser
//
//  Created by Dave DeLong on 12/3/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DDTerm;
@class DDExpression;
@class DDParser;

@interface DDTermResolver : NSObject {
	BOOL resolved;
	DDTerm * term;
	DDExpression * resolvedExpression;
	DDParser * parser;
}

@property (retain) DDTerm * term; //the term to parse
@property (assign) DDParser * parser; //so we can know operator associativity

+ (id) resolverForTerm:(DDTerm *)term parser:(DDParser *)parser;

- (DDTerm *) resolvedTerm;
- (DDExpression *) expressionByResolvingTerm;

@end
