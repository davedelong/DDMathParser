//
//  NSNumberFormatter+DDMathParser.m
//  DDMathParser
//
//  Created by Dave DeLong on 3/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSNumberFormatter+DDMathParser.h"


@implementation NSNumberFormatter (DDMathParser)

+ (id) numberFormatter_dd {
	static NSNumberFormatter *f = nil;
	static dispatch_once_t predicate;
	dispatch_once(&predicate, ^{
		f = [[NSNumberFormatter alloc] init];
		
		NSLocale *l = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
		[f setLocale:l];
		[l release];
	});
	return f;
}

NSString *__names[] = {
	@"none",
	@"decimal",
	@"currency",
	@"percent",
	@"scientific",
	@"spell out"
};

- (NSNumber *) anyNumberFromString_dd:(NSString *)string {
	NSNumber * parsedNumber = nil;
	NSNumberFormatterStyle originalStyle = [self numberStyle];
	
	for (int i = NSNumberFormatterNoStyle; i < NSNumberFormatterSpellOutStyle; ++i) {
		[self setNumberStyle:i];
		parsedNumber = [self numberFromString:string];
		if (parsedNumber != nil) {
//			NSLog(@"parsed %@ as %@ (%@)", string, parsedNumber, __names[i]);
			break;
		}
	}
	
	[self setNumberStyle:originalStyle];
	return parsedNumber;
}

@end
