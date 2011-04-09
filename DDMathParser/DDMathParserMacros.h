//
//  DDMathParserMacros.h
//  DDMathParser
//
//  Created by Dave DeLong on 2/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DDTypes.h"

#ifndef ERR_BADARG
#define ERR_BADARG(_f,...) ([NSError errorWithDomain:DDMathParserErrorDomain code:DDErrorCodeInvalidArgument userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:(_f), ##__VA_ARGS__] forKey:NSLocalizedDescriptionKey]])
#endif

#ifndef ERR_GENERIC
#define ERR_GENERIC(_f,...) ([NSError errorWithDomain:DDMathParserErrorDomain code:DDErrorCodeGeneric userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:(_f), ##__VA_ARGS__] forKey:NSLocalizedDescriptionKey]])
#endif

#ifndef ERR_ASSERT
#define ERR_ASSERT(_e) NSAssert((_e) != nil, @"NULL out error")
#endif