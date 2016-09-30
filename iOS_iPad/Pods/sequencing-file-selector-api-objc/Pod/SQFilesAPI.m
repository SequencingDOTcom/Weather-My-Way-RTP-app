//
//  SQFilesAPI.h
//  Copyright © 2015-2016 Sequencing.com. All rights reserved
//

#import "SQFilesAPI.h"
#import "SQFilesServerManager.h"
#import "SQFilesHelper.h"
#import "SQFilesContainer.h"

#define kMainQueue dispatch_get_main_queue()

@interface SQFilesAPI()

// token property
@property (readwrite, nonatomic) NSString *accessToken;

@end

@implementation SQFilesAPI

+ (instancetype)sharedInstance {
    static SQFilesAPI *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SQFilesAPI alloc] init];
    });
    return instance;
}


#pragma mark -
#pragma mark API methods
/*
- (void)instance:(id<SQFileSelectorProtocol>)fileSelectedHandler loadFiles:(void (^)(BOOL))success {
    self.fileSelectedHandler = fileSelectedHandler;
    [self loadFiles:success];
} */


- (void)withToken:(NSString *)accessToken loadFiles:(void(^)(BOOL success))success {
    // send request to server to get files assigned to account
    // and then parse these files into categories and subcategories
    self.accessToken = [accessToken copy];
    
    [self loadFilesFromServer:^(NSArray *files) {
        if (files) {
            [SQFilesHelper parseFilesMainArray:files withHandler:^(NSMutableArray *mySectionsArray, NSMutableArray *sampleSectionsArray) {
                dispatch_async(kMainQueue, ^{
                    SQFilesContainer *filesContainer = [SQFilesContainer sharedInstance];
                    [filesContainer setMySectionsArray:[mySectionsArray copy]];
                    [filesContainer setSampleSectionsArray:[sampleSectionsArray copy]];
                    success(YES);
                });
            }];
        } else {
            success(NO);
        }
    }];
}


- (void)loadFilesFromServer:(void (^)(NSArray *files))files {
    [[SQFilesServerManager sharedInstance] getForFilesWithToken:self.accessToken onSuccess:^(NSArray *filesList) {
        if (filesList) {
            files(filesList);
            
        } else {
            files(nil);
        }
        
    } onFailure:^(NSError *error) {
        NSLog(@"Error: %@", [error localizedDescription]);
        files(nil);
    }];
}


/*
- (void)loadOwnFiles:(void (^)(NSArray *))files {
    [[SQServerManager sharedInstance] getForOwnFilesWithToken:[[SQAuthResult sharedInstance] token] onSuccess:^(NSArray *ownFilesList) {
        if (ownFilesList) {
            files(ownFilesList);
        }
    } onFailure:^(NSError *error) {
        NSLog(@"Error: %@", [error localizedDescription]);
        files(nil);
    }];
} */


/*
- (void)loadSampleFiles:(void (^)(NSArray *))files {
    [[SQServerManager sharedInstance] getForSampleFilesWithToken:[[SQAuthResult sharedInstance] token] onSuccess:^(NSArray *sampleFilesList) {
        if (sampleFilesList) {
            files(sampleFilesList);
        }
    } onFailure:^(NSError *error) {
        NSLog(@"Error: %@", [error localizedDescription]);
        files(nil);
    }];
} */


@end
