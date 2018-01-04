//
//  SQSectionInfo.h
//  Copyright © 2015-2016 Sequencing.com. All rights reserved
//

#import <Foundation/Foundation.h>

@interface SQSectionInfo : NSObject

@property (nonatomic) NSString *sectionName;        // category name
@property (nonatomic) NSMutableArray *filesArray;   // array with files related to category (section)
@property (nonatomic) NSMutableArray *rowHeights;   // height for each file row


- (instancetype)initWithName:(NSString*)name;
- (id)objectInRowHeightsAtIndex:(NSUInteger)idx;    // returns row height by index
- (void)insertObject:(id)anObject inRowHeightsAtIndex:(NSUInteger)idx;  // set row height by index
- (void)addFile:(NSDictionary *)file withHeight:(float)height;

@end
