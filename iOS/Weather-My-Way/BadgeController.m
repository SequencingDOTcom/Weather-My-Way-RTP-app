//
//  BadgeController.m
//  Copyright © 2017 Sequencing.com. All rights reserved
//


#import "BadgeController.h"
#import "UserHelper.h"



@implementation BadgeController

#pragma mark - Handle badge
+ (void)showTheBadgeWithTemperatureFromForecast:(NSDictionary *)forecast {
    if (![self isForecastValid:forecast]) {
        [self removeBadgeWithTemperature];
        return;
    }
        
    NSUInteger numberUnsigned = [self temperatureValueFromForecast:forecast];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:numberUnsigned];
    
    /*
    if ([[[UserHelper alloc] init] isAdminUser])
        [self showLocalNotification:numberUnsigned];*/
}



+ (void)removeBadgeWithTemperature {
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}




#pragma mark - Helpers
+ (int)temperatureType {
    UserHelper *userHelper = [[UserHelper alloc] init];
    int temperatureType = [[userHelper loadSettingTemperatureUnit] unsignedShortValue];
    
    return temperatureType;
}


+ (NSString *)temperatureKey {
    int temperatureType = [self temperatureType];
    NSString *temperatureKey;
    if (temperatureType == 1)
        temperatureKey = @"temp_c";
    else
        temperatureKey = @"temp_f";
    
    return temperatureKey;
}



+ (NSUInteger)temperatureValueFromForecast:(NSDictionary *)forecast {
    NSString *temperatureKey = [self temperatureKey];
    
    id temp = [[forecast objectForKey:@"current_observation"] objectForKey:temperatureKey];
    NSString *temperature = [NSString stringWithFormat:@"%@", temp];
    if ([temperature length] == 0) return 0;
    
    double temperatureDouble = [temperature doubleValue];
    int roundedValue = (int)lroundf(temperatureDouble);
    // int roundedValue = roundf([temperature floatValue]);
    int preciseValue;
    
    if (roundedValue < 1) preciseValue = 1;
    else preciseValue = roundedValue;
    
    NSNumber *numberObject = [NSNumber numberWithInteger:preciseValue];
    NSUInteger numberUnsigned = numberObject.unsignedIntegerValue;
    return numberUnsigned;
}



+ (BOOL)isForecastValid:(NSDictionary *)forecast {
    BOOL invalid = NO;
    
    if (!forecast || [forecast allKeys] == 0)
        return invalid;
    
    if (![[forecast allKeys] containsObject:@"current_observation"])
        return invalid;
    
    NSDictionary *current_observation = [forecast objectForKey:@"current_observation"];
    if (!current_observation || [current_observation allKeys] == 0)
        return invalid;
    
    if (![[current_observation allKeys] containsObject:@"temp_c"] || ![[current_observation allKeys] containsObject:@"temp_f"])
        return invalid;
    
    id tempC = [current_observation objectForKey:@"temp_c"];
    id tempF = [current_observation objectForKey:@"temp_f"];
    NSString *temperatureC = [NSString stringWithFormat:@"%@", tempC];
    NSString *temperatureF = [NSString stringWithFormat:@"%@", tempF];
    
    if (!temperatureC || [temperatureC length] == 0 || !temperatureF || [temperatureF length] == 0)
        return invalid;
    
    return  YES;
}



+ (void)showLocalNotification:(NSUInteger)temperature {
    NSDictionary *currentLocation = [[[UserHelper alloc] init] loadUserCurrentLocation];
    NSString     *city = [currentLocation objectForKey:LOCATION_CITY_DICT_KEY];
    
    NSString *text = [NSString stringWithFormat:@"Location: %@. Temperature: %ld", city, (unsigned long)temperature];
    UILocalNotification *notification = [[UILocalNotification alloc]init];
    [notification setAlertBody:text];
    [notification setRepeatInterval:0];
    [notification setFireDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    [notification setTimeZone:[NSTimeZone defaultTimeZone]];
    [notification setSoundName:[NSString stringWithFormat:@"%@", [[NSBundle mainBundle] pathForResource:@"notes_of_the_optimistic" ofType:@"caf"]]];
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}


@end
