//
//  DDMathTokenizer.h
//  DDMathParser
//
//  Created by Dave DeLong on 6/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DDMathToken, DDMathOperatorSet;

@interface DDMathTokenizer : NSObject

@property (readonly) DDMathOperatorSet *operatorSet;
@property (nonatomic, readonly) NSArray *tokens;

- (instancetype)initWithString:(NSString *)expressionString operatorSet:(DDMathOperatorSet *)operatorSet error:(NSError **)error;

@end

@interface DDMathTokenizer (Deprecated)

+ (id)tokenizerWithString:(NSString *)expressionString error:(NSError **)error __attribute__((deprecated("Use -initWithString:operatorSet:error: instead")));
- (id)initWithString:(NSString *)expressionString error:(NSError **)error __attribute__((deprecated("Use -initWithString:operatorSet:error: instead")));

@end
