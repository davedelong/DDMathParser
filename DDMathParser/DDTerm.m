//
//  DDTerm.m
//  DDMathParser
//
//  Created by Dave DeLong on 12/2/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "DDTerm.h"
#import "DDMathStringToken.h"
#import "DDExpression.h"

@implementation DDTerm
@synthesize precedence, tokenValue, subTerms;

+ (id) termWithTokenValue:(DDMathStringToken *)o {
	return [self termWithPrecedence:DDPrecedenceNone tokenValue:o];
}

+ (id) termWithPrecedence:(DDPrecedence)p tokenValue:(DDMathStringToken *)o {
	DDTerm * t = [[DDTerm alloc] init];
	[t setPrecedence:p];
	[t setTokenValue:o];
	
	if (p == DDPrecedenceParentheses) {
		[t setSubTerms:[NSMutableArray array]];
	} else {
		[t setSubTerms:nil];
	}
	return [t autorelease];	
}

- (void) dealloc {
	[tokenValue release];
	[subTerms release];
	[super dealloc];
}

- (NSString *) description {
	if ([subTerms count] == 0) {
		if (precedence != DDPrecedenceNone) {
			return [NSString stringWithFormat:@"%@[%d]", tokenValue, precedence];
		}
		return [tokenValue description];
	}
	NSArray * subDescriptions = [subTerms valueForKey:@"description"];
	NSString * join = [subDescriptions componentsJoinedByString:@", "];
	return [NSString stringWithFormat:@"%@(%@)", (tokenValue ? [tokenValue description] : @""), join];
}

@end
