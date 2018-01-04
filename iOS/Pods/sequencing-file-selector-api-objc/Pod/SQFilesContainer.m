//
//  SQFilesContainer.m
//  Copyright © 2015-2016 Sequencing.com. All rights reserved
//

#import "SQFilesContainer.h"


@implementation SQFilesContainer

+ (instancetype)sharedInstance {
    static SQFilesContainer *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SQFilesContainer alloc] init];
    });
    return instance;
}

@end
