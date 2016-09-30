//
//  SQFilesServerManager.h
//  Copyright © 2015-2016 Sequencing.com. All rights reserved
//


#import <Foundation/Foundation.h>

@interface SQFilesServerManager : NSObject

+ (instancetype)sharedInstance;     //designated initializer

- (void)getForFilesWithToken:(NSString *)accessToken
                   onSuccess:(void (^)(NSArray *))success
                   onFailure:(void (^)(NSError *))failure;


@end
