//
//  SQTokenStorageAppSettings.m
//  Copyright © 2017 Sequencing.com. All rights reserved
//


#import "SQTokenStorageAppSettings.h"
#import "SQToken.h"


NSString *KEY_TOKEN_ACCESS = @"__SEQUENCING-OAUTH-COCOAPOD-OBJC-PLUGIN-USERTOKEN-KEY";




@implementation SQTokenStorageAppSettings


- (SQToken *)loadToken {
    NSData *tokenData = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_TOKEN_ACCESS];
    SQToken *token = [NSKeyedUnarchiver unarchiveObjectWithData:tokenData];
    if (token)
        return token;
    else
        return nil;
}


- (void)saveToken:(SQToken *)token {
    if (!token) return;
    if ([token.accessToken length] == 0) return;
    
    SQToken *oldToken = [self loadToken];
    if (!oldToken) [self archiveToken:token];
    else {
        oldToken.accessToken    = token.accessToken;
        oldToken.expirationDate = token.expirationDate;
        oldToken.tokenType      = token.tokenType;
        oldToken.scope          = token.scope;
        if (token.refreshToken != nil) // DO NOT OVERRIDE REFRESH_TOKEN HERE (after refresh token request it comes as null)
            oldToken.refreshToken = token.refreshToken;
        [self archiveToken:oldToken];
    }
}


- (void)archiveToken:(SQToken *)token {
    NSData *tokenData = [NSKeyedArchiver archivedDataWithRootObject:token];
    [[NSUserDefaults standardUserDefaults] setObject:tokenData forKey:KEY_TOKEN_ACCESS];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)eraseToken {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:KEY_TOKEN_ACCESS];
}


@end
