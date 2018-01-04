//
//  SQOAuth.h
//  Copyright © 2017 Sequencing.com. All rights reserved
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SQAuthorizationProtocol.h"
#import "SQTokenAccessProtocol.h"
#import "SQClientSecretAccessProtocol.h"
@class SQToken;



@interface SQOAuth : NSObject <SQTokenAccessProtocol, SQClientSecretAccessProtocol>

@property (weak, nonatomic) UIViewController            *viewControllerDelegate;
@property (weak, nonatomic) id<SQAuthorizationProtocol> delegate;


// designated initializer
+ (instancetype)sharedInstance;

// method to set up apllication registration parameters
- (void)registerApplicationParametersCliendID:(NSString *)client_id
                                 clientSecret:(NSString *)client_secret
                                  redirectUri:(NSString *)redirect_uri
                                        scope:(NSString *)scope
                                     delegate:(id<SQAuthorizationProtocol>)delegate
                       viewControllerDelegate:(UIViewController *)viewControllerDelegate;


// authorization method that uses SQAuthorizationProtocol as result
- (void)authorizeUser;

// should be called when sign out, this method will erase token and delegates
- (void)userDidSignOut;

// method to registrate new account / resetpassword
- (void)callRegisterResetAccountFlow;

// receive updated token
- (void)token:(void(^)(SQToken *token, NSString *accessToken))tokenResult;

// receive client_secret
- (NSString *)clientSecret;


@end
