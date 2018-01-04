//
//  SettingsUpdater.m
//  Copyright © 2016 Sequencing. All rights reserved.
//


#import "SettingsUpdater.h"
#import "InternetConnection.h"
#import "UserAccountHelper.h"
#import "UserHelper.h"
#import "SQToken.h"
#import "SQOAuth.h"


dispatch_source_t CreateSettingsTimerDispatch(double interval, dispatch_queue_t queue, dispatch_block_t block) {
    dispatch_source_t timerForSettingsRefresh = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    if (timerForSettingsRefresh) {
        dispatch_source_set_timer(timerForSettingsRefresh, dispatch_time(DISPATCH_TIME_NOW, interval * NSEC_PER_SEC), interval * NSEC_PER_SEC, (1ull * NSEC_PER_SEC) / 10);
        dispatch_source_set_event_handler(timerForSettingsRefresh, block);
        dispatch_resume(timerForSettingsRefresh);
    }
    return timerForSettingsRefresh;
}



@implementation SettingsUpdater

dispatch_source_t _timerForSettingsRefresh;
static double SECONDS_TO_FIRE = 3660.f; // time interval lengh in seconds

#pragma mark -
#pragma mark Init

+ (instancetype)sharedInstance {
    static SettingsUpdater *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SettingsUpdater alloc] init];
    });
    return instance;
}



#pragma mark -
#pragma mark Timer methods

- (void)startTimer {
    NSLog(@"SettingsUpdater: Timer started");
    // timer
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _timerForSettingsRefresh = CreateSettingsTimerDispatch(SECONDS_TO_FIRE, queue, ^{
        [self retrieveUserSettings];
    });
}

// use this method when user is logging out
- (void)cancelTimer {
    if (_timerForSettingsRefresh) {
        dispatch_source_cancel(_timerForSettingsRefresh);
        _timerForSettingsRefresh = nil;
        NSLog(@"SettingsUpdater: Timer canceled");
    }
}



#pragma mark - Settings request

- (void)retrieveUserSettings {
    if (![InternetConnection internetConnectionIsAvailable])
        return;
    
    [[SQOAuth sharedInstance] token:^(SQToken *token, NSString *accessToken) {
        if (token == nil || [token.accessToken length] == 0)
            return;
        
        UserHelper *userHelper = [[UserHelper alloc] init];
        UserAccountHelper *userAccountHelper = [[UserAccountHelper alloc] init];
        
        [_delegate settingsSyncRequestStarted];
        NSString *oldDeviceToken = [userHelper loadDeviceTokenOld];
        NSString *newDeviceToken = [userHelper loadDeviceToken];
        
        NSDictionary *parameters = @{@"accessToken"   : token.accessToken,
                                     @"expiresIn"     : token.expirationDate,
                                     @"tokenType"     : token.tokenType,
                                     @"scope"         : token.scope,
                                     @"refreshToken"  : token.refreshToken,
                                     @"oldDeviceToken": ([oldDeviceToken length] != 0) ? oldDeviceToken : [NSNull null],
                                     @"newDeviceToken": ([newDeviceToken length] != 0) ? newDeviceToken : [NSNull null],
                                     @"sendPush"      : [self proccessPushSettings],
                                     @"deviceType"    : @(1),
                                     @"appVersion"    : [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]};
        
        [userAccountHelper retrieveUserSettings:parameters
                                 withCompletion:^(NSDictionary *userAccountSettings) {
                                     if (userAccountSettings)
                                         [userAccountHelper processUserAccountSettings:userAccountSettings];
                                     
                                     [_delegate settingsSyncRequestFinished];
                                 }];
    }];
}


- (NSString *)proccessPushSettings {
    UserHelper *userHelper = [[UserHelper alloc] init];
    NSNumber *pushSettingValue = [userHelper loadSettingIPhoneDailyForecast];
    NSString *pushSetting;
    if (pushSettingValue) {
        switch ([pushSettingValue intValue]) {
            case 0:
                pushSetting = @"false";
                break;
            case 1:
                pushSetting = @"true";
                break;
            default: {
                [userHelper saveSettingIPhoneDailyForecast:[NSNumber numberWithBool:YES]];
                pushSetting = @"true";
            }   break;
        }
    }
    return pushSetting;
}




@end
