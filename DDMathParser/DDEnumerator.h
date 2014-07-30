//
//  DDEnumerator.h
//  DDMathParser
//
//  Created by Dave DeLong on 7/30/14.
//
//

#import <Foundation/Foundation.h>

@interface DDEnumerator : NSEnumerator

- (instancetype)initWithArray:(NSArray *)array;

- (id)peekNextObject;

@end
