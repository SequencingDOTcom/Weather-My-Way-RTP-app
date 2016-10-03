//
//  SQServerManager.h
//  Copyright © 2015-2016 Sequencing.com. All rights reserved
//

#import <Foundation/Foundation.h>

@class SQAuthResult;
@class SQToken;

@interface SQServerManager : NSObject

//designated initializer
+ (instancetype)sharedInstance;

/*
 *  method to set up apllication registration parameters
 */
- (void)registrateParametersCliendID:(NSString *)client_id
                        ClientSecret:(NSString *)client_secret
                         RedirectUri:(NSString *)redirect_uri
                               Scope:(NSString *)scope;

/*
 *  for guest user
 *  method to authorize user on a lower level
 */
- (void)authorizeUser:(void(^)(SQToken *token, BOOL didCancel, BOOL error))result;


/*
 *  for authorized user
 *  shoud be used when user is authorized but token is expired
 */
- (void)withRefreshToken:(SQToken *)refreshToken
       updateAccessToken:(void(^)(SQToken *token))refreshedToken;

/*
 *  for authorized user
 *  shoud be used when user is authorized and token is valid
 */
- (void)launchTokenTimerUpdateWithToken:(SQToken *)token;

/*
 *  for authorized user
 *  update token method on lower level 
 */
- (void)postForNewTokenWithRefreshToken:(SQToken *)token
                              onSuccess:(void(^)(SQToken *updatedToken))success
                              onFailure:(void(^)(NSError *error))failure;

/*
 *  should be called when sign out
 *  this method will stop refreshToken autoupdater
 */
- (void)userDidSignOut;


@end
