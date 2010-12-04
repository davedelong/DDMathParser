//
//  DDMathStringToken.h
//  DDMathParser
//
//  Created by Dave DeLong on 11/16/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDParserTypes.h"

@interface DDMathStringToken : NSObject {

}

+ (id) mathStringTokenWithToken:(NSString *)t type:(DDTokenType)type;

@property (readonly) NSString * token;
@property (readonly) DDTokenType tokenType;
@property (readonly) DDOperator operatorType;

- (NSNumber *) numberValue;

@end
