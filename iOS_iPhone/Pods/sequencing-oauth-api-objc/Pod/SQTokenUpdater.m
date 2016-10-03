//
//  SQTokenUpdater.h
//  Copyright © 2015-2016 Sequencing.com. All rights reserved
//

#import "SQTokenUpdater.h"
#import "SQAuthResult.h"
#import "SQServerManager.h"
#import "SQToken.h"
#import "SQOAuth.h"

dispatch_source_t CreateDispatchTimer(double interval, dispatch_queue_t queue, dispatch_block_t block)
{
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    if (timer)
    {
        dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, interval * NSEC_PER_SEC), interval * NSEC_PER_SEC, (1ull * NSEC_PER_SEC) / 10);
        dispatch_source_set_event_handler(timer, block);
        dispatch_resume(timer);
    }
    return timer;
}


@implementation SQTokenUpdater

dispatch_source_t _timer;
static double SECONDS_TO_FIRE = 300.f; // 300 time interval lengh in seconds, in order to check token expiration periodically

+ (instancetype)sharedInstance {
    static SQTokenUpdater *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SQTokenUpdater alloc] init];
    });
    return instance;
}


#pragma mark -
#pragma mark Timer methods

- (void)startTimer {
    NSLog(@"\nTokenUpdater: startTimer");
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _timer = CreateDispatchTimer(SECONDS_TO_FIRE, queue, ^{
        // NSLog(@"check date");
        NSDate *nowDate = [NSDate date];
        SQToken *oldToken = [[SQAuthResult sharedInstance] token];
        NSDate *expDate = oldToken.expirationDate;
        if ([nowDate compare:expDate] == NSOrderedDescending) { // NSOrderedDescending
            // access token is expired, let's refresh it
            [self executeRefreshTokenRequest];
        }
    });
}

// use this method when user is logging out
- (void)cancelTimer {
    if (_timer) {
        dispatch_source_cancel(_timer);
        _timer = nil;
    }
    
}


#pragma mark -
#pragma mark Refresh token

- (void)executeRefreshTokenRequest {
    NSLog(@"TokenUpdater: executeRefreshTokenRequest");
    [[SQServerManager sharedInstance] postForNewTokenWithRefreshToken:[[SQAuthResult sharedInstance] token] onSuccess:^(SQToken *updatedToken) {
        if (updatedToken) {
            // store update token in SQAuthResult instance
            [[SQAuthResult sharedInstance] setToken:updatedToken];
            
            // pass on the updated token to the user
            [[[SQOAuth sharedInstance] refreshTokenDelegate] tokenIsRefreshed:updatedToken];
        }
        
    } onFailure:^(NSError *error) {
        NSLog(@"%@", [error localizedDescription]);
    }];
}


@end
