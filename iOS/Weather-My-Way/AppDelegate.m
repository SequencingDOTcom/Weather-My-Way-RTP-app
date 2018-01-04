//
//  AppDelegate.m
//  Copyright © 2016 Sequencing. All rights reserved.
//


#import "AppDelegate.h"
#import "SQOAuth.h"
#import "UserHelper.h"
#import "SQToken.h"
#import "LoginViewController.h"
#import "PrepareForecastViewController.h"
#import "LocationWeatherUpdater.h"
#import "BackgroundUpdateManager.h"
#import "WundergroundHelper.h"
#import "InternetConnection.h"
#import "BadgeController.h"
#import "ObserverManager.h"
#import "RegionManager.h"
#import "SignificantLocationManager.h"
@import Firebase;
@import HockeySDK;


// APPLICATION PARAMETERS TO REGISTRATE
static NSString *const CLIENT_ID     = @"Weather My Way (iPhone)";
static NSString *const CLIENT_SECRET = @"QfPiH2NPbn8eyilutdluPE6h_oudKebCaftGjQ14BpyJgSlJFLHlK_sjwBbHH3Qush4dXyD7IE0vQKs8e9xamw";
static NSString *const REDIRECT_URI  = @"wmw://login";
static NSString *const SCOPE         = @"demo,external";

static NSString *const CHILD_APP_CLIENT_ID     = @"Weather My Child Way iOS";
static NSString *const CHILD_APP_CLIENT_SECRET = @"ZDmY_jldHZhUMj50mhC926oloP_EyK09rQkXIrd2zwX8I9PYCiZZt2M_UFlYzOaayJHg-aWyqfTWcmrcfzy0bQ";



@implementation AppDelegate

#pragma mark - Application run

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // REGISTER APPLICATION PARAMETERS
    [[SQOAuth sharedInstance] registerApplicationParametersCliendID:CLIENT_ID
                                                       clientSecret:CLIENT_SECRET
                                                        redirectUri:REDIRECT_URI
                                                              scope:SCOPE
                                                           delegate:nil
                                             viewControllerDelegate:nil];
    
    if ([[[UserHelper alloc] init] isUserAuthorized]) {    // logged in user flow
        NSLog(@"AppDelegate: User is authorized > opening prepareForecastVC");
        
        // show forecast screen
        PrepareForecastViewController *prepareForecastVC = [[PrepareForecastViewController alloc] initWithNibName:@"PrepareForecastViewController" bundle:nil];
        self.window.rootViewController = prepareForecastVC;
        [self.window makeKeyAndVisible];
        
    } else // guest user flow
        NSLog(@"AppDelegate: User is not authorized > opening loginVC");
    
    
    // start Google Firebase
    [FIRApp configure];
    
    // start HockeyApp
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"70c60e7fe31d4df3a9555cc4b404c86c"];
    [[BITHockeyManager sharedHockeyManager] startManager];
    [[BITHockeyManager sharedHockeyManager].authenticator authenticateInstallation];
    [[BITHockeyManager sharedHockeyManager].crashManager setCrashManagerStatus:BITCrashManagerStatusAutoSend];
    
    // preload keyboard
    [self preloadKeyboardToAvoidAnyLagInItAppearance];
    
    // clean badge
    [BadgeController removeBadgeWithTemperature];
    
    
    // register for push notifications
    [self registerForPushNotifications:application];
    
    // register background session
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:3600]; // UIApplicationBackgroundFetchIntervalMinimum
    
    // start Monitoring Significant Location Change
    [[SignificantLocationManager sharedInstance] startMonitoringSignificantLocationChange];
    
    // start monitoring for GPS and regions
    [[RegionManager sharedInstance] startMonitoringForGPSDetection];
    
    
    // start monitoring interactions for logging
    [[ObserverManager sharedInstance] startMonitoringInteractions];
    
    return YES;
}




#pragma mark - Application states
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [BadgeController removeBadgeWithTemperature];
}




#pragma mark - Register for Notifications
- (void)registerForPushNotifications:(UIApplication *)application {
    UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [application registerUserNotificationSettings:settings];
    // [application registerForRemoteNotifications];
}


#pragma mark - UIApplicationDelegate
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    if (notificationSettings.types != UIUserNotificationTypeNone) {
        [application registerForRemoteNotifications];
    }
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    UserHelper *userHelper = [[UserHelper alloc] init];
    NSString *savedDeviceToken = [[userHelper loadDeviceToken] copy];
    
    NSString *deviceTokenString = [[[[deviceToken description]
                                     stringByReplacingOccurrencesOfString: @"<" withString: @""]
                                     stringByReplacingOccurrencesOfString: @">" withString: @""]
                                     stringByReplacingOccurrencesOfString: @" " withString: @""];
    
    // save device token
    [userHelper saveDeviceToken:deviceTokenString];
    
    if (![deviceTokenString isEqualToString:savedDeviceToken]) {
        // new device token differs from saved > save previous device token as old > save received device token as current
        [userHelper saveDeviceTokenOld:savedDeviceToken];
    }
    NSLog(@"\ndeviceToken:%@", deviceTokenString);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Failed to registerForRemoteNotifications: %@", error);
}



- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"didReceiveRemoteNotification: %@", userInfo);
    if (![[[userInfo objectForKey:@"aps"] allKeys] containsObject:@"content-available"]) {
        NSLog(@"didReceive Remote Push Notification: %@", userInfo);
        // show local notification as app is active (in background)
        if (application.applicationState == UIApplicationStateActive ) {
            UILocalNotification *localNotification = [[UILocalNotification alloc] init];
            localNotification.userInfo = userInfo;
            localNotification.soundName = UILocalNotificationDefaultSoundName;
            localNotification.alertBody = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
            localNotification.fireDate = [NSDate date];
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        }
        
        // show alert if app is in foreground
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *close = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:close];
        if (![self.window.rootViewController presentedViewController]) {
            [self.window.rootViewController presentViewController:alert animated:TRUE completion:nil];
        }
    }
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    @synchronized (self) {
        if ([[[userInfo objectForKey:@"aps"] allKeys] containsObject:@"content-available"]) {
            NSLog(@"did receive silent push notification");
            [[BackgroundUpdateManager sharedInstance] fetchTemperatureForCurrentLocationWithCompletion:^(UIBackgroundFetchResult result) {
                completionHandler(result);
            }];
            
        } else {
            NSLog(@"didReceive Remote Push Notification: %@", userInfo);
            // show local notification as app is active (in background)
            if (application.applicationState == UIApplicationStateActive ) {
                UILocalNotification *localNotification = [[UILocalNotification alloc] init];
                localNotification.userInfo = userInfo;
                localNotification.soundName = UILocalNotificationDefaultSoundName;
                localNotification.alertBody = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
                localNotification.fireDate = [NSDate date];
                [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
            }
            
            // show alert if app is in foreground
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]
                                                                           message:nil
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *close = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:close];
            if (![self.window.rootViewController presentedViewController])
                [self.window.rootViewController presentViewController:alert animated:TRUE completion:nil];
            completionHandler(UIBackgroundFetchResultNewData);
        }
    }
}


- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    @synchronized (self) {
        [[BackgroundUpdateManager sharedInstance] fetchTemperatureForCurrentLocationWithCompletion:^(UIBackgroundFetchResult result) {
            completionHandler(result);
        }];
    }
}




#pragma mark - Keyboard preload
- (void)preloadKeyboardToAvoidAnyLagInItAppearance {
    NSLog(@"preloadKeyboardToAvoidAnyLagInItAppearance");
    UITextField *lagFreeField = [[UITextField alloc] init];
    [self.window addSubview:lagFreeField];
    [lagFreeField becomeFirstResponder];
    [lagFreeField resignFirstResponder];
    [lagFreeField removeFromSuperview];
}


- (NSString *)cliendSecret {
    return CLIENT_SECRET;
}


@end
