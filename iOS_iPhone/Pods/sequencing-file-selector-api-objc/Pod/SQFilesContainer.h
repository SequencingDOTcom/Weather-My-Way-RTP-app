//
//  SQFilesContainer.h
//  Copyright © 2015-2016 Sequencing.com. All rights reserved
//

#import <Foundation/Foundation.h>

@interface SQFilesContainer : NSObject

@property (strong, nonatomic) NSArray *mySectionsArray;         // array of sectionInfo objects - contains my files in model
@property (strong, nonatomic) NSArray *sampleSectionsArray;     // array of sectionInfo objects - contains sample files in model

// designated initializer
+ (instancetype)sharedInstance;

@end
