//
//  DDMathTokenInterpreter.h
//  DDMathParser
//
//  Created by Dave DeLong on 7/13/14.
//
//

#import <Foundation/Foundation.h>

@class DDMathTokenizer;

@interface DDMathTokenInterpreter : NSObject

@property (readonly) NSArray *tokens;

- (instancetype)initWithTokenizer:(DDMathTokenizer *)tokenizer error:(NSError **)error;

@end
