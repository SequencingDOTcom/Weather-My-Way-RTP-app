//
//  SQTokenAccessProtocol.h
//  Copyright © 2017 Sequencing.com. All rights reserved
//


#import <Foundation/Foundation.h>
@class SQToken;


@protocol SQTokenAccessProtocol <NSObject>

- (void)token:(void(^)(SQToken *token, NSString *accessToken))tokenResult;


@end
