//
//  SQAuthResult.h
//  Copyright © 2015-2016 Sequencing.com. All rights reserved
//

#import "SQAuthResult.h"
#import "SQToken.h"

@implementation SQAuthResult

+ (instancetype)sharedInstance {
    static SQAuthResult *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SQAuthResult alloc] init];
    });
    return instance;
}

- (void)setToken:(SQToken *)token {
    if(_token == nil) {
        _token = SQToken.new;
    }
    _token.accessToken = token.accessToken;
    _token.expirationDate = token.expirationDate;
    _token.tokenType = token.tokenType;
    _token.scope = token.scope;
    if (token.refreshToken != nil) {
        // DO NOT OVERRIDE REFRESH_TOKEN HERE (after refresh token request it comes as null)
        _token.refreshToken = token.refreshToken;
    }
}

@end
