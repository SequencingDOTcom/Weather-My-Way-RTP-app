//
//  SQTokenStorageAppSettings.h
//  Copyright © 2017 Sequencing.com. All rights reserved
//


#import <Foundation/Foundation.h>
#import "SQTokenStorageProtocol.h"
@class SQToken;


@interface SQTokenStorageAppSettings : NSObject <SQTokenStorageProtocol>

- (SQToken *)loadToken;
- (void)saveToken:(SQToken *)token;
- (void)eraseToken;

@end
