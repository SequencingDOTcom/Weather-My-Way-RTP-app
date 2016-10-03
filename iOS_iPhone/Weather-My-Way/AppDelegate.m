//
//  AppDelegate.m
//  Copyright © 2016 Sequencing. All rights reserved.
//


#import "AppDelegate.h"
#import "SQOAuth.h"
#import "SQAuthResult.h"
#import "UserHelper.h"
#import "SQToken.h"
#import "SQTokenRefreshProtocol.h"
#import "LoginViewController.h"
#import "PrepareForecastViewController.h"


// APPLICATION PARAMETERS TO REGISTRATE
static NSString *const CLIENT_ID        = @"CLIENT_ID";     // specify here your application CLIENT_ID
static NSString *const CLIENT_SECRET    = @"CLIENT_SECRET"; // specify here your application CLIENT_SECRET
static NSString *const REDIRECT_URI     = @"wmw://login";
static NSString *const SCOPE            = @"demo,external";



@interface AppDelegate () <SQTokenRefreshProtocol>

@end


@implementation AppDelegate

#pragma mark -
#pragma mark Application run

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // REGISTER APPLICATION PARAMETERS
    SQOAuth *authorizationAPI = [SQOAuth sharedInstance];
    [authorizationAPI registrateApplicationParametersCliendID:[CLIENT_ID copy]
                                                 ClientSecret:[CLIENT_SECRET copy]
                                                  RedirectUri:[REDIRECT_URI copy]
                                                        Scope:[SCOPE copy]];
    authorizationAPI.refreshTokenDelegate = self;
    
    // Override point for customization after application launch.
    UserHelper *userHelper = [[UserHelper alloc] init];
    
    if ([userHelper userIsAuthorized]) {
        // logged in user flow
        NSLog(@"AppDelegate: User is authorized > opening prepareForecastVC");
        
        PrepareForecastViewController *prepareForecastVC = [[PrepareForecastViewController alloc] initWithNibName:@"PrepareForecastViewController" bundle:nil];
        self.window.rootViewController = prepareForecastVC;
        [self.window makeKeyAndVisible];
        
    } else {
        // guest user flow
        NSLog(@"AppDelegate: User is not authorized > opening loginVC");
    }
    
    // register for push notifications
    [self registerForPushNotifications:application];

    return YES;
}



#pragma mark -
#pragma mark Application states

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
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}



#pragma mark -
#pragma mark SQTokenRefreshProtocol

- (void)tokenIsRefreshed:(SQToken *)updatedToken {
    UserHelper *userHelper = [[UserHelper alloc] init];
    
    if (updatedToken.accessToken != nil) {
        
        if (updatedToken.refreshToken == nil) {
            
            // updatedToken.refreshToken is empty. We need to load refreshToken from old token and save complete updated token
            SQToken *oldToken = [userHelper loadUserToken];
            
            NSLog(@"\n old token");
            NSLog(@"old token accessToken: %@",    oldToken.accessToken);
            NSLog(@"old token expirationDate: %@", oldToken.expirationDate);
            NSLog(@"old token tokenType: %@",      oldToken.tokenType);
            NSLog(@"old token scope: %@",          oldToken.scope);
            NSLog(@"old token refreshToken: %@",   oldToken.refreshToken);
            
            if (oldToken.refreshToken != nil) {
                updatedToken.refreshToken = oldToken.refreshToken;
                [userHelper saveUserToken:updatedToken];
                
                NSLog(@"\n updated token");
                NSLog(@"updated token accessToken: %@",    updatedToken.accessToken);
                NSLog(@"updated token expirationDate: %@", updatedToken.expirationDate);
                NSLog(@"updated token tokenType: %@",      updatedToken.tokenType);
                NSLog(@"updated token scope: %@",          updatedToken.scope);
                NSLog(@"updated token refreshToken: %@",   updatedToken.refreshToken);
                
                NSLog(@"AppDelegate: Refreshed token was saved into userDefaults");
                
            } else {
                NSLog(@"AppDelegate: token.refreshToken from userDefaults is nil! Can't save updated token into userDefaults");
            }
            
        } else {
            // updatedToken is already valid > save it into UserDefaults
            [userHelper saveUserToken:updatedToken];
            NSLog(@"AppDelegate: Refreshed token was saved into userDefaults");
        }
        
    } else {
        NSLog(@"AppDelegate: Refreshed token.accessToken is nil! Can't save to userDefaults");
    }
}



#pragma mark -
#pragma mark Register for Notifications

- (void)registerForPushNotifications:(UIApplication *)application {
    UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [application registerUserNotificationSettings:settings];
    // [application registerForRemoteNotifications];
}



#pragma mark -
#pragma mark UIApplicationDelegate

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



@end
