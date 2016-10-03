//
//  SQOAuth.h
//  Copyright © 2015-2016 Sequencing.com. All rights reserved
//

#import "SQOAuth.h"
#import "SQServerManager.h"
#import "SQToken.h"


@implementation SQOAuth

#pragma mark -
#pragma mark Initializer

+ (instancetype)sharedInstance {
    static SQOAuth *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SQOAuth alloc] init];
    });
    return instance;
}


- (void)registrateApplicationParametersCliendID:(NSString *)client_id
                                   ClientSecret:(NSString *)client_secret
                                    RedirectUri:(NSString *)redirect_uri
                                          Scope:(NSString *)scope {
    [[SQServerManager sharedInstance] registrateParametersCliendID:client_id
                                                    ClientSecret:client_secret
                                                     RedirectUri:redirect_uri
                                                           Scope:scope];
}



#pragma mark -
#pragma mark for Guest user

- (void)authorizeUser {
    [[SQServerManager sharedInstance] authorizeUser:^(SQToken *token, BOOL didCancel, BOOL error) {
        
        if (token.accessToken != nil) {
            [self.authorizationDelegate userIsSuccessfullyAuthorized:token];
            
        } else if (didCancel) {
            if ([self.authorizationDelegate respondsToSelector:@selector(userDidCancelAuthorization)]) {
                [self.authorizationDelegate userDidCancelAuthorization];
            }
            
        } else if (error) {
            [self.authorizationDelegate userIsNotAuthorized];
            
        }
    }];
}



#pragma mark -
#pragma mark for Authorized user

- (void)withRefreshToken:(SQToken *)refreshToken updateAccessToken:(void (^)(SQToken *))tokenResult {
    [[SQServerManager sharedInstance] withRefreshToken:refreshToken
                                     updateAccessToken:^(SQToken *token) {
                                         if (token) {
                                             tokenResult(token);
                                         } else {
                                             tokenResult(nil);
                                         }
                                     }];
}


- (void)launchTokenTimerUpdateWithToken:(SQToken *)token {
    [[SQServerManager sharedInstance] launchTokenTimerUpdateWithToken:token];
}


- (void)userDidSignOut {
    [[SQServerManager sharedInstance] userDidSignOut];
}




@end
