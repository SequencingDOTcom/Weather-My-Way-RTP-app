//
//  SQSegmentedControlHelper.m
//  Copyright © 2015-2016 Sequencing.com. All rights reserved
//


#import "SQSegmentedControlHelper.h"
#import "SQSectionInfo.h"

@implementation SQSegmentedControlHelper

+ (NSDictionary *)prepareSegmentedControlItemsAndCategoryIndexes:(NSArray *)filesArray {
    NSMutableDictionary *categoryWithItemsAndIndexes = [[NSMutableDictionary alloc] init];
    
    NSMutableArray      *tempItemsArray = [[NSMutableArray alloc] initWithCapacity:[filesArray count]];
    NSMutableDictionary *tempIndexesDictionary = [[NSMutableDictionary alloc] init];
    
    SQSectionInfo *tempSection = [[SQSectionInfo alloc] init];
    
    for (int i = 0; i < [filesArray count]; i++) {
        tempSection = (filesArray)[i];
        
        [tempItemsArray addObject:tempSection.sectionName];
        [tempIndexesDictionary setObject:@(i) forKey:tempSection.sectionName];
    }
    
    [categoryWithItemsAndIndexes setObject:[tempItemsArray copy] forKey:@"items"];
    [categoryWithItemsAndIndexes setObject:[tempIndexesDictionary copy] forKey:@"indexes"];
    
    return [categoryWithItemsAndIndexes copy];
}

@end
