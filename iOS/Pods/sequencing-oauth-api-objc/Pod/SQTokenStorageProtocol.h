//
//  SQTokenStorageProtocol.h
//  Copyright © 2017 Sequencing.com. All rights reserved
//


#import <Foundation/Foundation.h>
@class SQToken;


@protocol SQTokenStorageProtocol <NSObject>

@required
- (SQToken *)loadToken;
- (void)saveToken:(SQToken *)token;
- (void)eraseToken;


@end
