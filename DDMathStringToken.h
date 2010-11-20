//
//  DDMathStringToken.h
//  DDMathParser
//
//  Created by Dave DeLong on 11/16/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	DDTokenTypeNumber = 0,
	DDTokenTypeOperator = 1,
	DDTokenTypeFunction = 2,
	DDTokenTypeVariable = 3
} DDTokenType;

@interface DDMathStringToken : NSObject {

}

+ (id) mathStringTokenWithToken:(NSString *)t type:(DDTokenType)type;

@property (readonly) NSString * token;
@property (readonly) DDTokenType tokenType;

- (NSNumber *) numberValue;

@end
