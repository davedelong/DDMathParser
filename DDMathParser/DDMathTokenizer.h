//
//  DDMathTokenizer.h
//  DDMathParser
//
//  Created by Dave DeLong on 6/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DDMathToken, DDMathOperatorSet;

@interface DDMathTokenizer : NSEnumerator

@property (readonly) DDMathOperatorSet *operatorSet;

- (instancetype)initWithString:(NSString *)expressionString operatorSet:(DDMathOperatorSet *)operatorSet error:(NSError **)error;

- (DDMathToken *)peekNextObject;

- (void)reset;

// methods overridable by subclasses
- (void)didParseToken:(DDMathToken *)token;

// methods that can be used by subclasses
- (void)appendToken:(DDMathToken *)token;

@end

@interface DDMathTokenizer (Deprecated)

+ (id)tokenizerWithString:(NSString *)expressionString error:(NSError **)error __attribute__((deprecated("Use -initWithString:operatorSet:error: instead")));
- (id)initWithString:(NSString *)expressionString error:(NSError **)error __attribute__((deprecated("Use -initWithString:operatorSet:error: instead")));

@end
