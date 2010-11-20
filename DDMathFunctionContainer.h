//
//  DDMathFunctionContainer.h
//  DDMathParser
//
//  Created by Dave DeLong on 11/18/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDTypes.h"

@interface DDMathFunctionContainer : NSObject {
	DDMathFunction function;
	NSString * name;
}

@property (nonatomic, copy) DDMathFunction function;
@property (nonatomic, copy) NSString * name;
@property (nonatomic) NSInteger numberOfArguments;

+ (NSDictionary *) nsexpressionFunctions;
+ (id) mathFunctionWithName:(NSString *)name function:(DDMathFunction)function numberOfArguments:(NSInteger)numberOfArguments;

@end
