//
//  DemoController.m
//  DDMathParser
//
//  Created by Dave DeLong on 12/4/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "DemoController.h"
#import "DDMathParser.h"

@implementation DemoController
@synthesize inputField;
@synthesize answerField;
@synthesize variableList;
@synthesize orderedVariables;

- (void) dealloc {
	[inputField release];
	[answerField release];
	[variableList release];
	[orderedVariables release];
	
	[variables release];
	[super dealloc];
}

- (void) awakeFromNib {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:NSControlTextDidChangeNotification object:inputField];
	[answerField setStringValue:@""];
	variables = [[NSMutableDictionary alloc] init];
}

- (NSArray *) variablesInExpression:(DDExpression *)e {
	NSMutableArray * v = [NSMutableArray array];
	if ([e expressionType] == DDExpressionTypeVariable) {
		[v addObject:[e variable]];
	} else if ([e expressionType] == DDExpressionTypeFunction) {
		for (DDExpression * se in [e arguments]) {
			[v addObjectsFromArray:[self variablesInExpression:se]];
		}
	}
	return v;
}

- (void) updateVariablesWithExpression:(DDExpression *)e {
	NSArray * v = [self variablesInExpression:e];
	
	NSMutableSet * keysThatShouldBeRemoved = [NSMutableSet setWithArray:[variables allKeys]];
	[keysThatShouldBeRemoved minusSet:[NSSet setWithArray:v]];
	
	[variables removeObjectsForKeys:[keysThatShouldBeRemoved allObjects]];
	for (NSString * variable in v) {
		if ([variables objectForKey:variable] == nil) {
			[variables setObject:[NSNumber numberWithInt:0] forKey:variable];
		}
	}
	
	NSArray * orderedKeys = [[variables allKeys] sortedArrayUsingSelector:@selector(compare:)];
	[self setOrderedVariables:orderedKeys];
}

- (void) evaluate {
	NSString * string = [inputField stringValue];
	if ([string length] > 0) {
		NSLog(@"evaluating: %@", string);
		@try {
			DDExpression * expression = [DDExpression expressionFromString:string];
			NSLog(@"parsed: %@", expression);
			[self updateVariablesWithExpression:expression];
			NSNumber * result = [expression evaluateWithSubstitutions:variables evaluator:nil];
			[answerField setTextColor:[NSColor blackColor]];
			[answerField setStringValue:[result description]];
		}
		@catch (NSException * e) {
			NSLog(@"caught: %@", e);
			[answerField setTextColor:[NSColor redColor]];
		}
	} else {
		[answerField setStringValue:@""];
		[variables removeAllObjects];
	}
	
	[variableList reloadData];		
}

- (void) textChanged:(NSNotification *)note {
	[self evaluate];
}

#pragma mark NSTableView stuff

-(NSInteger) numberOfRowsInTableView:(NSTableView *)tableView {
	return [variables count];
}

- (id) tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	NSString * variable = [orderedVariables objectAtIndex:row];
	if ([[tableColumn identifier] isEqual:@"variable"]) {
		return variable;
	}
	return [variables objectForKey:variable];
}

- (BOOL) tableView:(NSTableView *)tableView shouldEditTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	return [[tableColumn identifier] isEqual:@"value"];
}

- (void) tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	NSString * variable = [orderedVariables objectAtIndex:row];
	if (![object isKindOfClass:[NSNumber class]]) {
		NSLog(@"invalid object: %@", object);
		object = [NSNumber numberWithInt:0];
	}
	[variables setObject:object forKey:variable];
	[self evaluate];
}

@end
