//
//  DDTerm.h
//  DDMathParser
//
//  Created by Dave DeLong on 12/2/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDParserTypes.h"

@class DDExpression;
@class DDMathStringToken;

@interface DDTerm : NSObject {
	DDPrecedence precedence;
	DDMathStringToken * tokenValue;
	NSMutableArray * subTerms;
}

+ (id) termWithTokenValue:(DDMathStringToken *)o;
+ (id) termWithPrecedence:(DDPrecedence)p tokenValue:(DDMathStringToken *)o;

@property DDPrecedence precedence;
@property (retain) DDMathStringToken * tokenValue;
@property (retain) NSMutableArray * subTerms;

@end
