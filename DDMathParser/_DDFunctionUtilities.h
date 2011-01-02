//
//  __DDFunctionUtilities.h
//  DDMathParser
//
//  Created by Dave DeLong on 12/21/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDTypes.h"

@interface _DDFunctionUtilities : NSObject {

}

+ (DDMathFunction) addFunction;
+ (DDMathFunction) subtractFunction;
+ (DDMathFunction) multiplyFunction;
+ (DDMathFunction) divideFunction;
+ (DDMathFunction) modFunction;
+ (DDMathFunction) negateFunction;
+ (DDMathFunction) factorialFunction;
+ (DDMathFunction) powFunction;
+ (DDMathFunction) andFunction;
+ (DDMathFunction) orFunction;
+ (DDMathFunction) notFunction;
+ (DDMathFunction) xorFunction;
+ (DDMathFunction) rshiftFunction;
+ (DDMathFunction) lshiftFunction;
+ (DDMathFunction) averageFunction;
+ (DDMathFunction) sumFunction;
+ (DDMathFunction) countFunction;
+ (DDMathFunction) minFunction;
+ (DDMathFunction) maxFunction;
+ (DDMathFunction) medianFunction;
+ (DDMathFunction) stddevFunction;
+ (DDMathFunction) randomFunction;
+ (DDMathFunction) sqrtFunction;
+ (DDMathFunction) logFunction;
+ (DDMathFunction) lnFunction;
+ (DDMathFunction) log2Function;
+ (DDMathFunction) expFunction;
+ (DDMathFunction) ceilFunction;
+ (DDMathFunction) absFunction;
+ (DDMathFunction) floorFunction;

+ (DDMathFunction) sinFunction;
+ (DDMathFunction) cosFunction;
+ (DDMathFunction) tanFunction;
+ (DDMathFunction) asinFunction;
+ (DDMathFunction) acosFunction;
+ (DDMathFunction) atanFunction;
+ (DDMathFunction) sinhFunction;
+ (DDMathFunction) coshFunction;
+ (DDMathFunction) tanhFunction;
+ (DDMathFunction) asinhFunction;
+ (DDMathFunction) acoshFunction;
+ (DDMathFunction) atanhFunction;

+ (DDMathFunction) cscFunction;
+ (DDMathFunction) secFunction;
+ (DDMathFunction) cotanFunction;
+ (DDMathFunction) acscFunction;
+ (DDMathFunction) asecFunction;
+ (DDMathFunction) acotanFunction;
+ (DDMathFunction) cschFunction;
+ (DDMathFunction) sechFunction;
+ (DDMathFunction) cotanhFunction;
+ (DDMathFunction) acschFunction;
+ (DDMathFunction) asechFunction;
+ (DDMathFunction) acotanhFunction;


+ (DDMathFunction) dtorFunction;
+ (DDMathFunction) rtodFunction;

+ (DDMathFunction) piFunction;
+ (DDMathFunction) pi_2Function;
+ (DDMathFunction) pi_4Function;
+ (DDMathFunction) sqrt2Function;
+ (DDMathFunction) eFunction;
+ (DDMathFunction) log2eFunction;
+ (DDMathFunction) log10eFunction;
+ (DDMathFunction) ln2Function;
+ (DDMathFunction) ln10Function;

@end
