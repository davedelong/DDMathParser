//
//  _DDDecimalFunctions.m
//  DDMathParser
//
//  Created by Dave DeLong on 12/24/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "_DDDecimalFunctions.h"

#pragma mark Constants

NSDecimal DDDecimalNegativeOne() {
	static NSDecimalNumber * _minusOne = nil;
	if (_minusOne == nil) {
		_minusOne = [[NSDecimalNumber alloc] initWithMantissa:1 exponent:0 isNegative:YES];
	}
	return [_minusOne decimalValue];
}

NSDecimal DDDecimalZero() {
	return [[NSDecimalNumber zero] decimalValue];
}

NSDecimal DDDecimalOne() {
	static NSDecimalNumber * _one = nil;
	if (_one == nil) {
		_one = [[NSDecimalNumber alloc] initWithMantissa:1 exponent:0 isNegative:NO];
	}
	return [_one decimalValue];
}

NSDecimal DDDecimalTwo() {
	static NSDecimalNumber * _two = nil;
	if (_two == nil) {
		_two = [[NSDecimalNumber alloc] initWithMantissa:2 exponent:0 isNegative:NO];
	}
	return [_two decimalValue];
}

NSDecimal DDDecimalPi() {
	static NSDecimalNumber * _pi = nil;
	if (_pi == nil) {
		_pi = [[NSDecimalNumber alloc] initWithString:@"3.1415926535897932384626433832795028841971693993751058209749445923078164062862089986280348253421170679"];
	}
	return [_pi decimalValue];
}

NSDecimal DDDecimal2Pi() {
	static NSDecimalNumber * _2pi = nil;
	if (_2pi == nil) {
		NSDecimal pi = DDDecimalPi();
		NSDecimal two = DDDecimalTwo();
		NSDecimal tpi;
		NSDecimalMultiply(&tpi, &pi, &two, NSRoundBankers);
		_2pi = [[NSDecimalNumber alloc] initWithDecimal:tpi];
	}
	return [_2pi decimalValue];
}

NSDecimal DDDecimalPi_2() {
	static NSDecimalNumber * _pi_2 = nil;
	if (_pi_2 == nil) {
		_pi_2 = [[NSDecimalNumber alloc] initWithString:@"1.5707963267948966192313216916397514420985846996875529104874722961539082031431044993140174126710585340"];
	}
	return [_pi_2 decimalValue];
}

NSDecimal DDDecimalPi_4() {
	static NSDecimalNumber * _pi_4 = nil;
	if (_pi_4 == nil) {
		_pi_4 = [[NSDecimalNumber alloc] initWithString:@"0.7853981633974483096156608458198757210492923498437764552437361480769541015715522496570087063355292670"];
	}
	return [_pi_4 decimalValue];
}

NSDecimal DDDecimalSqrt2() {
	static NSDecimalNumber * _sqrt2 = nil;
	if (_sqrt2 == nil) {
		_sqrt2 = [[NSDecimalNumber alloc] initWithString:@"1.414213562373095048801688724209698078569671875376948073176679737990732478462107038850387534327641572"];
	}
	return [_sqrt2 decimalValue];
}

NSDecimal DDDecimalE() {
	static NSDecimalNumber * _e = nil;
	if (_e == nil) {
		_e = [[NSDecimalNumber alloc] initWithString:@"2.7182818284590452353602874713526624977572470936999595749669676277240766303535475945713821785251664274"];
	}
	return [_e decimalValue];
}

NSDecimal DDDecimalLog2e() {
	static NSDecimalNumber * _log2e = nil;
	if (_log2e == nil) {
		_log2e = [[NSDecimalNumber alloc] initWithString:@"1.4426950408889634073599246810018921374266459541529859341354494069311092191811850798855266228935063445"];
	}
	return [_log2e decimalValue];
}

NSDecimal DDDecimalLog10e() {
	static NSDecimalNumber * _log10e = nil;
	if (_log10e == nil) {
		_log10e = [[NSDecimalNumber alloc] initWithString:@"0.4342944819032518276511289189166050822943970058036665661144537831658646492088707747292249493384317483"];
	}
	return [_log10e decimalValue];
}

NSDecimal DDDecimalLn2() {
	static NSDecimalNumber * _ln2 = nil;
	if (_ln2 == nil) {
		_ln2 = [[NSDecimalNumber alloc] initWithString:@"0.693147180559945309417232121458176568075500134360255254120680009493393621969694715605863326996418687"];
	}
	return [_ln2 decimalValue];
}

NSDecimal DDDecimalLn10() {
	static NSDecimalNumber * _ln10 = nil;
	if (_ln10 == nil) {
		_ln10 = [[NSDecimalNumber alloc] initWithString:@"2.30258509299404568401799145468436420760110148862877297603332790096757260967735248023599720508959830"];
	}
	return [_ln10 decimalValue];
}

#pragma mark Creation

NSDecimal DDDecimalFromInteger(NSInteger i) {
	unsigned long long ull = i;
	return [[NSDecimalNumber decimalNumberWithMantissa:ull exponent:0 isNegative:(i < 0)] decimalValue];
}

NSDecimal DDDecimalFromDouble(double d) {
	return [[NSNumber numberWithDouble:d] decimalValue];
}

#pragma mark Extraction

float DDFloatFromDecimal(NSDecimal d) {
	return [[NSDecimalNumber decimalNumberWithDecimal:d] floatValue];
}

double DDDoubleFromDecimal(NSDecimal d) {
	return [[NSDecimalNumber decimalNumberWithDecimal:d] doubleValue];
}

#pragma mark Utilties

BOOL DDDecimalIsNegative(NSDecimal d) {
	NSDecimal z = DDDecimalZero();
	return (NSDecimalCompare(&d, &z) == NSOrderedAscending); //d < z
}

BOOL DDDecimalIsInteger(NSDecimal d) {
	NSDecimal rounded = d;
	NSDecimalRound(&rounded, &d, 0, NSRoundDown);
	return (NSDecimalCompare(&rounded, &d) == NSOrderedSame);
}

NSDecimal DDDecimalAverage2(NSDecimal a, NSDecimal b) {
	NSDecimal r;
	NSDecimalAdd(&r, &a, &b, NSRoundBankers);
	NSDecimal t = DDDecimalTwo();
	NSDecimalDivide(&r, &r, &t, NSRoundBankers);
	return r;
}

NSDecimal DDDecimalMod(NSDecimal a, NSDecimal b) {
	//a % b == a - (b * floor(a / b))
	NSDecimal result;
	NSDecimalDivide(&result, &a, &b, NSRoundBankers);
	NSDecimalRound(&result, &result, 0, NSRoundDown);
	NSDecimalMultiply(&result, &b, &result, NSRoundBankers);
	NSDecimalSubtract(&result, &a, &result, NSRoundBankers);
	return result;	
}

NSDecimal DDDecimalMod2Pi(NSDecimal a) {
	return DDDecimalMod(a, DDDecimal2Pi());
}

NSDecimal DDDecimalAbsoluteValue(NSDecimal a) {
	if (DDDecimalIsNegative(a)) {
		NSDecimal nOne = DDDecimalNegativeOne();
		NSDecimalMultiply(&a, &a, &nOne, NSRoundBankers);
	}
	return a;
}

BOOL DDDecimalLessThanEpsilon(NSDecimal a, NSDecimal b) {
	NSDecimal epsilon = DDDecimalOne();
	NSDecimalMultiplyByPowerOf10(&epsilon, &epsilon, -64, NSRoundBankers);
	
	NSDecimal diff;
	NSDecimalSubtract(&diff, &a, &b, NSRoundBankers);
	diff = DDDecimalAbsoluteValue(diff);
	return (NSDecimalCompare(&diff, &epsilon) == NSOrderedAscending);
}

NSDecimal DDDecimalSqrt(const NSDecimal * d) {
	NSDecimal s = *d;
	s._exponent /= 2;
	for (NSUInteger iterationCount = 0; iterationCount < 50; ++iterationCount) {
		NSDecimal low;
		NSDecimalDivide(&low, d, &s, NSRoundBankers);
		s = DDDecimalAverage2(low, s);
		
		NSDecimal square;
		NSDecimalMultiply(&square, &s, &s, NSRoundBankers);
		if (DDDecimalLessThanEpsilon(square, *d)) { break; }
	};
	return s;
}

NSDecimal DDDecimalInverse(NSDecimal d) {
	NSDecimal one = DDDecimalOne();
	NSDecimalDivide(&d, &one, &d, NSRoundBankers);
	return d;
}

NSDecimal DDDecimalFactorial(NSDecimal d) {
	if (DDDecimalIsInteger(d)) {
		NSDecimal one = DDDecimalOne();
		NSDecimal final = one;
		if (DDDecimalIsNegative(d)) {
			final = DDDecimalNegativeOne();
			NSDecimalMultiply(&d, &d, &final, NSRoundBankers);
		}
		while (NSDecimalCompare(&d, &one) == NSOrderedDescending) {
			NSDecimalMultiply(&final, &final, &d, NSRoundBankers);
			NSDecimalSubtract(&d, &d, &one, NSRoundBankers);
		}
		return final;
	} else {
		double f = DDDoubleFromDecimal(d);
		f = tgamma(f+1);
		return DDDecimalFromDouble(f);
	}
}

#pragma mark Trig Functions
NSDecimal DDDecimalSin(NSDecimal x) {
	x = DDDecimalMod2Pi(x);
	double d = DDDoubleFromDecimal(x);
	d = sin(d);
	return DDDecimalFromDouble(d);
}

NSDecimal DDDecimalCos(NSDecimal x) {
	x = DDDecimalMod2Pi(x);
	double d = DDDoubleFromDecimal(x);
	d = cos(d);
	return DDDecimalFromDouble(d);
	
}

NSDecimal DDDecimalTan(NSDecimal x) {
	x = DDDecimalMod2Pi(x);
	double d = DDDoubleFromDecimal(x);
	d = tan(d);
	return DDDecimalFromDouble(d);
	
}

NSDecimal DDDecimalAsin(NSDecimal x) {
	double d = DDDoubleFromDecimal(x);
	d = asin(d);
	return DDDecimalFromDouble(d);
}

NSDecimal DDDecimalAcos(NSDecimal x) {
	double d = DDDoubleFromDecimal(x);
	d = acos(d);
	return DDDecimalFromDouble(d);	
}

NSDecimal DDDecimalAtan(NSDecimal x) {
	double d = DDDoubleFromDecimal(x);
	d = atan(d);
	return DDDecimalFromDouble(d);
}

NSDecimal DDDecimalSinh(NSDecimal x) {
	double d = DDDoubleFromDecimal(x);
	d = sinh(d);
	return DDDecimalFromDouble(d);
}

NSDecimal DDDecimalCosh(NSDecimal x) {
	double d = DDDoubleFromDecimal(x);
	d = cosh(d);
	return DDDecimalFromDouble(d);
}

NSDecimal DDDecimalTanh(NSDecimal x) {
	double d = DDDoubleFromDecimal(x);
	d = tanh(d);
	return DDDecimalFromDouble(d);
}

NSDecimal DDDecimalAsinh(NSDecimal x) {
	double d = DDDoubleFromDecimal(x);
	d = asinh(d);
	return DDDecimalFromDouble(d);
}

NSDecimal DDDecimalAcosh(NSDecimal x) {
	double d = DDDoubleFromDecimal(x);
	d = acosh(d);
	return DDDecimalFromDouble(d);
}

NSDecimal DDDecimalAtanh(NSDecimal x) {
	double d = DDDoubleFromDecimal(x);
	d = atanh(d);
	return DDDecimalFromDouble(d);
}
