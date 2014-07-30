//
//  DDMathTokenInterpreter.h
//  DDMathParser
//
//  Created by Dave DeLong on 7/13/14.
//
//

#import <Foundation/Foundation.h>

@class DDMathTokenizer;

typedef NS_OPTIONS(NSInteger, DDMathTokenInterpreterOptions) {
    DDMathTokenInterpreterOptionsAllowsArgumentlessFunctions = 1 << 0,
    DDMathTokenInterpreterOptionsAllowsImplicitMultiplication = 1 << 1,
    DDMathTokenInterpreterOptionsImplicitMultiplicationHasHigherPrecedence = 1 << 2,
};

extern const DDMathTokenInterpreterOptions DDMathTokenInterpreterDefaultOptions;

@interface DDMathTokenInterpreter : NSObject

@property (readonly) NSArray *tokens;

- (instancetype)initWithTokenizer:(DDMathTokenizer *)tokenizer error:(NSError **)error;
- (instancetype)initWithTokenizer:(DDMathTokenizer *)tokenizer options:(DDMathTokenInterpreterOptions)options error:(NSError **)error;

@end
