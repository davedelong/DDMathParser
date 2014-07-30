//
//  _DDMathTermResolver.h
//  DDMathParser
//
//  Created by Dave DeLong on 7/30/14.
//
//

#import <Foundation/Foundation.h>

@class _DDParserTerm;
@class DDExpression;

@interface _DDMathTermResolver : NSObject

- (instancetype)initWithTerm:(_DDParserTerm *)term error:(NSError **)error;

- (DDExpression *)expressionWithError:(NSError **)error;

@end
