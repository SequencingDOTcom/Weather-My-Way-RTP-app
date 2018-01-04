//
//  SQSectionInfo.m
//  Copyright © 2015-2016 Sequencing.com. All rights reserved
//

#import "SQSectionInfo.h"

@implementation SQSectionInfo

- (instancetype)initWithName:(NSString *)name {
    self = [super init];
    if (self) {
        _rowHeights = [[NSMutableArray alloc] init];
        _sectionName = name;
        _filesArray = [[NSMutableArray alloc] init];
    }
    return self;
}


- (id)objectInRowHeightsAtIndex:(NSUInteger)idx {
    return self.rowHeights[idx];
}


- (void)insertObject:(id)anObject inRowHeightsAtIndex:(NSUInteger)idx {
    [self.rowHeights insertObject:anObject atIndex:idx];
}


- (void)addFile:(NSDictionary *)file withHeight:(float)height {
    [self.filesArray addObject:file];      // adding file itself
    [self insertObject:@(height) inRowHeightsAtIndex:[_filesArray count] - 1]; // adding row height for this file
}

@end
