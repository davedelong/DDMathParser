//
//  DDGroupTerm.h
//  DDMathParser
//
//  Created by Dave DeLong on 12/18/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDTerm.h"

@interface DDGroupTerm : DDTerm {
	NSMutableArray * subTerms;
}

@property (readonly) NSMutableArray * subTerms;

+ (id) rootTermWithTokenizer:(DDMathStringTokenizer *)tokenizer;
+ (id) groupTermWithSubTerms:(NSArray *)sub;

@end
