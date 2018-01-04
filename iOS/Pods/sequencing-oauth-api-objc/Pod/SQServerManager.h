//
//  SQServerManager.h
//  Copyright © 2017 Sequencing.com. All rights reserved
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class SQToken;


@interface SQServerManager : NSObject

//designated initializer
+ (instancetype)sharedInstance;

// method to set up apllication registration parameters
- (void)registrateParametersCliendID:(NSString *)client_id
                        clientSecret:(NSString *)client_secret
                         redirectUri:(NSString *)redirect_uri
                               scope:(NSString *)scope;

// for guest user, method to authorize user on a lower level
- (void)authorizeUserForVC:(UIViewController *)controller withResult:(void(^)(SQToken *token, BOOL didCancel, BOOL error))result;

// for authorized user, shoud be used when user is authorized but token is expired
- (void)withRefreshToken:(SQToken *)refreshToken updateAccessToken:(void(^)(SQToken *token))refreshedToken;

// registrate account
- (void)registrateAccountForEmailAddress:(NSString *)emailAddress withResult:(void(^)(NSString *error))result;

// reset password
- (void)resetPasswordForEmailAddress:(NSString *)emailAddress withResult:(void(^)(NSString *error))result;


// connect to
- (void)connectToSequencingWithClient_id:(NSString *)client_id
                               userEmail:(NSString *)emailAddress
                              filesArray:(NSArray *)filesArray
                  viewControllerDelegate:(UIViewController *)controller;





@end
