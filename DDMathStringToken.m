//
//  DDMathStringToken.m
//  DDMathParser
//
//  Created by Dave DeLong on 11/16/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "DDMathStringToken.h"


@implementation DDMathStringToken
@synthesize token, tokenType;

- (void) dealloc {
	[token release];
	[super dealloc];
}

- (id) initWithToken:(NSString *)t type:(DDTokenType)type {
	self = [super init];
	if (self) {
		token = [t copy];
		tokenType = type;
	}
	return self;
}

+ (id) mathStringTokenWithToken:(NSString *)t type:(DDTokenType)type {
	return [[[self alloc] initWithToken:t type:type] autorelease];
}

- (NSNumber *) numberValue {
	if ([self tokenType] != DDTokenTypeNumber) { return nil; }
	
	NSNumberFormatter * f = [[[NSNumberFormatter alloc] init] autorelease];
	for (int style = NSNumberFormatterNoStyle; style < NSNumberFormatterSpellOutStyle; ++style) {
		[f setNumberStyle:style];
		NSNumber * n = [f numberFromString:[self token]];
		if (n != nil) { return n; }
	}
	
	NSLog(@"supposedly invalid number: %@", [self token]);
	return [NSNumber numberWithInt:0];
}

@end
