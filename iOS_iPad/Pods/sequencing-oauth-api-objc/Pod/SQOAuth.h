//
//  SQOAuth.h
//  Copyright © 2015-2016 Sequencing.com. All rights reserved
//

#import <Foundation/Foundation.h>
#import "SQAuthorizationProtocol.h"
#import "SQTokenRefreshProtocol.h"
@class SQToken;

@interface SQOAuth : NSObject

@property (nonatomic) id<SQAuthorizationProtocol> authorizationDelegate;
@property (nonatomic) id<SQTokenRefreshProtocol>  refreshTokenDelegate;


// designated initializer
+ (instancetype)sharedInstance;

/*
 *  method to set up apllication registration parameters
 */
- (void)registrateApplicationParametersCliendID:(NSString *)client_id
                                   ClientSecret:(NSString *)client_secret
                                    RedirectUri:(NSString *)redirect_uri
                                          Scope:(NSString *)scope;

/*
 *  authorization method that uses SQAuthorizationProtocol as result
 */
- (void)authorizeUser;

/*
 *  shoud be used when user is authorized but token is expired
 */
- (void)withRefreshToken:(SQToken *)refreshToken
       updateAccessToken:(void(^)(SQToken *token))tokenResult;

/*
 *  save token object into AuthResult container
 *  and launch token timer updater
 */
- (void)launchTokenTimerUpdateWithToken:(SQToken *)token;

/*
 *  should be called when sign out
 *  this method will stop refreshToken autoupdater
 */
- (void)userDidSignOut;


@end
