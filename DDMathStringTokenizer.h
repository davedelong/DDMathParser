//
//  DDMathStringTokenizer.h
//  DDMathParser
//
//  Created by Dave DeLong on 11/11/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DDMathStringToken;

@interface DDMathStringTokenizer : NSObject {
	NSString * sourceString;
	NSUInteger currentCharacterIndex;
	
	NSMutableArray * tokens;
	
	NSNumberFormatter * numberFormatter;
}

- (id) initWithString:(NSString *)expressionString;

- (NSArray *) tokens;


@end
