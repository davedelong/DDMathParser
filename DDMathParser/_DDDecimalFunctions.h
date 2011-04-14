//
//  _DDDecimalFunctions.h
//  DDMathParser
//
//  Created by Dave DeLong on 12/24/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSDecimal DDDecimalNegativeOne();
extern NSDecimal DDDecimalZero();
extern NSDecimal DDDecimalOne();
extern NSDecimal DDDecimalTwo();

extern NSDecimal DDDecimalPi();
extern NSDecimal DDDecimal2Pi();
extern NSDecimal DDDecimalPi_2();
extern NSDecimal DDDecimalPi_4();
extern NSDecimal DDDecimalSqrt2();
extern NSDecimal DDDecimalE();
extern NSDecimal DDDecimalLog2e();
extern NSDecimal DDDecimalLog10e();
extern NSDecimal DDDecimalLn2();
extern NSDecimal DDDecimalLn10();

#pragma mark Decimal Creation
extern NSDecimal DDDecimalFromInteger(NSInteger i);
extern NSDecimal DDDecimalFromDouble(double d);

#pragma mark Extraction

extern float DDFloatFromDecimal(NSDecimal d);
extern double DDDoubleFromDecimal(NSDecimal d);

#pragma mark Utility Functions
extern BOOL DDDecimalIsNegative(NSDecimal d);
extern BOOL DDDecimalLessThanEpsilon(NSDecimal a, NSDecimal b);

extern void DDDecimalNegate(NSDecimal *d);

extern NSDecimal DDDecimalAverage2(NSDecimal a, NSDecimal b);
extern NSDecimal DDDecimalMod(NSDecimal a, NSDecimal b);
extern NSDecimal DDDecimalMod2Pi(NSDecimal a);
extern NSDecimal DDDecimalAbsoluteValue(NSDecimal a);
extern NSDecimal DDDecimalSqrt(NSDecimal d);
extern NSDecimal DDDecimalInverse(NSDecimal d);
extern NSDecimal DDDecimalFactorial(NSDecimal d);

extern NSDecimal DDDecimalLeftShift(NSDecimal base, NSDecimal shift);
extern NSDecimal DDDecimalRightShift(NSDecimal base, NSDecimal shift);

#pragma mark Trig Functions
extern NSDecimal DDDecimalSin(NSDecimal d);
extern NSDecimal DDDecimalCos(NSDecimal d);
extern NSDecimal DDDecimalTan(NSDecimal d);
extern NSDecimal DDDecimalAsin(NSDecimal d);
extern NSDecimal DDDecimalAcos(NSDecimal d);
extern NSDecimal DDDecimalAtan(NSDecimal d);
extern NSDecimal DDDecimalSinh(NSDecimal d);
extern NSDecimal DDDecimalCosh(NSDecimal d);
extern NSDecimal DDDecimalTanh(NSDecimal d);
extern NSDecimal DDDecimalAsinh(NSDecimal d);
extern NSDecimal DDDecimalAcosh(NSDecimal d);
extern NSDecimal DDDecimalAtanh(NSDecimal d);