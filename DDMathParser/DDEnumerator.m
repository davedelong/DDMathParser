//
//  DDEnumerator.m
//  DDMathParser
//
//  Created by Dave DeLong on 7/30/14.
//
//

#import "DDEnumerator.h"

@implementation DDEnumerator {
    NSArray *_array;
    NSUInteger _index;
}

- (instancetype)initWithArray:(NSArray *)array {
    self = [super init];
    if (self) {
        _array = array.copy;
        _index = 0;
    }
    return self;
}

- (id)peekNextObject {
    if (_index >= _array.count) { return nil; }
    return _array[_index];
}

- (id)nextObject {
    id object = [self peekNextObject];
    if (object) { _index++; }
    return object;
}

- (NSArray *)allObjects {
    return _array;
}

@end
