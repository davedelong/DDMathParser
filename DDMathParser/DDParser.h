//
//  DDParser.h
//  DDMathParser
//
//  Created by Dave DeLong on 11/24/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DDMathTokenInterpreter;
@class DDExpression;

@interface DDParser : NSObject

- (instancetype)initWithTokenInterpreter:(DDMathTokenInterpreter *)interpreter;

- (DDExpression *)parsedExpressionWithError:(NSError **)error;

@end
