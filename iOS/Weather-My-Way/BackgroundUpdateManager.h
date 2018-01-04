//
//  BackgroundUpdateManager.h
//  Copyright © 2017 Sequencing.com. All rights reserved
//


#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "UserHelper.h"
#import "WundergroundHelper.h"
#import "InternetConnection.h"
#import "BadgeController.h"


typedef void(^FetchResult)(UIBackgroundFetchResult result);



@interface BackgroundUpdateManager : NSObject

+ (instancetype)sharedInstance;

- (void)fetchTemperatureForCurrentLocationWithCompletion:(FetchResult)completion;

@end
