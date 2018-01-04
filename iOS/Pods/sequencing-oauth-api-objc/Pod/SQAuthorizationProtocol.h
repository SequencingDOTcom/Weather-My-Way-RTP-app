//
//  SQAuthorizationProtocol.h
//  Copyright © 2017 Sequencing.com. All rights reserved
//


#import <Foundation/Foundation.h>
@class SQToken;


@protocol SQAuthorizationProtocol <NSObject>

@required
- (void)userIsSuccessfullyAuthorized:(SQToken *)token;
- (void)userIsNotAuthorized;
- (void)userDidCancelAuthorization;

@end
