//
//  DemoController.h
//  DDMathParser
//
//  Created by Dave DeLong on 12/4/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DDMathEvaluator;

@interface DemoController : NSObject <NSTableViewDelegate, NSTableViewDataSource> {
	NSTextField * inputField;
	NSTextField * answerField;
	
	NSTableView * variableList;
	
	NSArray * orderedVariables;
	NSMutableDictionary * variables;
    DDMathEvaluator *evaluator;
}

@property (nonatomic, retain) NSArray * orderedVariables;
@property (nonatomic, retain) IBOutlet NSTextField * inputField;
@property (nonatomic, retain) IBOutlet NSTextField * answerField;
@property (nonatomic, retain) IBOutlet NSTableView * variableList;

@end
