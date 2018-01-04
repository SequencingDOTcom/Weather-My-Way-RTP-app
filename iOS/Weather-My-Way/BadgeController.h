//
//  BadgeController.h
//  Copyright © 2017 Sequencing.com. All rights reserved
//


#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "UserHelper.h"


@interface BadgeController : NSObject

+ (void)showTheBadgeWithTemperatureFromForecast:(NSDictionary *)forecast;

+ (void)removeBadgeWithTemperature;

@end
