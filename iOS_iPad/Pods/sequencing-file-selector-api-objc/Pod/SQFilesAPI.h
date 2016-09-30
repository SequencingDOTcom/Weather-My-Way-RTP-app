//
//  SQFilesAPI.h
//  Copyright © 2015-2016 Sequencing.com. All rights reserved
//

#import <Foundation/Foundation.h>
#import "SQFileSelectorProtocol.h"

@interface SQFilesAPI : NSObject

// instance for protocol delegate
@property (nonatomic) id <SQFileSelectorProtocol> fileSelectedHandler;

@property (nonatomic) BOOL closeButton;
@property (strong, nonatomic) NSString *selectedFileID;
@property (strong, nonatomic) NSString *videoFileName;

// designated initializer
+ (instancetype)sharedInstance;


// load all files in one method
- (void)withToken:(NSString *)accessToken loadFiles:(void(^)(BOOL success))success;


// load own files method
// - (void)loadOwnFiles:(void(^)(NSArray *myFiles))files;

// load sample files method
// - (void)loadSampleFiles:(void(^)(NSArray *sampleFiles))files;

@end
