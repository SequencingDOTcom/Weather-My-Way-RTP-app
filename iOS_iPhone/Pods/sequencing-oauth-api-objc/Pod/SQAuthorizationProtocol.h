//
//  SQAuthorizationProtocol.h
//  Copyright © 2015-2016 Sequencing.com. All rights reserved
//

#import <Foundation/Foundation.h>
@class SQToken;

@protocol SQAuthorizationProtocol <NSObject>

@required
- (void)userIsSuccessfullyAuthorized:(SQToken *)token;
- (void)userIsNotAuthorized;

@optional
- (void)userDidCancelAuthorization;

@end
