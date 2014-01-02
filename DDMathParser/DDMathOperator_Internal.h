//
//  DDMathOperator_Internal.h
//  DDMathParser
//
//  Created by Dave DeLong on 1/1/14.
//
//

#import "DDMathOperator.h"

@interface DDMathOperator ()

@property (nonatomic, assign) DDOperatorAssociativity associativity;
@property (nonatomic, assign) NSInteger precedence;

@end
