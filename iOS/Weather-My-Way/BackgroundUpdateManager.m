//
//  BackgroundUpdateManager.m
//  Copyright © 2017 Sequencing.com. All rights reserved
//


#import "BackgroundUpdateManager.h"
#import <CoreLocation/CoreLocation.h>
#import "BadgeController.h"
#import "ForecastData.h"
#import "LocationManager.h"



@interface BackgroundUpdateManager () <LocationManagerDelegate>

@property (nonatomic) FetchResult    completion;
@property (assign, nonatomic) BOOL   alreadyExecutingBackgroundFetch;
@property (assign, nonatomic) BOOL   alreadyGotLocationPoint;
@property (strong, nonatomic) NSDate *dateWhenInternetDissapeared;

@end



@implementation BackgroundUpdateManager

#pragma mark - Init
+ (instancetype)sharedInstance {
    static BackgroundUpdateManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[BackgroundUpdateManager alloc] init];
        instance.alreadyExecutingBackgroundFetch = NO;
    });
    return instance;
}



#pragma mark - Fetch forecast for location
- (void)fetchTemperatureForCurrentLocationWithCompletion:(FetchResult)completion {
    NSLog(@">>> BackgroundUpdateManager: fetchTemperatureForCurrentLocationWithCompletion");
    /*
    if (self.alreadyExecutingBackgroundFetch) {
        if (completion) completion(UIBackgroundFetchResultNewData);
        return;
    }*/
    
    if (![InternetConnection internetConnectionIsAvailable]) {
        [self handleTimeRangeForAbsentInternetConnection];
        @synchronized (self) {
            if (completion) completion(UIBackgroundFetchResultFailed);
            self.alreadyExecutingBackgroundFetch = NO;
        }
        return;
    }
    
    self.alreadyExecutingBackgroundFetch = YES;
    self.dateWhenInternetDissapeared = nil;
    if (completion) self.completion = completion;
    
    [self checkLocation];
}


- (void)handleTimeRangeForAbsentInternetConnection {
    if (!self.dateWhenInternetDissapeared)
        self.dateWhenInternetDissapeared = [NSDate date];
    else {
        NSDate *currentDate = [NSDate date];
        NSInteger seconds   = [currentDate timeIntervalSinceDate:self.dateWhenInternetDissapeared];
        NSInteger hours     = (int)(floor(seconds / 3600));
        if (hours >= 7) [BadgeController removeBadgeWithTemperature];
    }
}


- (void)checkLocation {
    NSLog(@">>> BackgroundUpdateManager: checkLocation");
    UserHelper *userHelper = [[UserHelper alloc] init];
    NSDictionary *locationObject = [userHelper loadUserCurrentLocation];
    if (!locationObject || [[locationObject allKeys] count] == 0) {
        LocationManager *locationManager = [[LocationManager alloc] init];
        locationManager.delegate = self;
        [locationManager detectCurrentGPSLocation];
        return;
    }
    
    NSString *locationID = [locationObject objectForKey:LOCATION_ID_DICT_KEY];
    if (!locationID || [locationID length] == 0) {
        LocationManager *locationManager = [[LocationManager alloc] init];
        locationManager.delegate = self;
        [locationManager detectCurrentGPSLocation];
        return;
    }
    
    NSLog(@">>> BackgroundUpdateManager: checkForLocation %@", [locationObject objectForKey:LOCATION_CITY_DICT_KEY]);
    [self getWeatherConditionsForLocationID:locationID];
}



#pragma mark - LocationManagerDelegate
- (void)locationManager:(LocationManager *)locationManager failedToDefineCurrentLocation:(NSError *)error {
    [locationManager stopDetectingCurrentGPSLocation];
    locationManager.delegate = nil;
    @synchronized (self) {
        self.completion(UIBackgroundFetchResultFailed);
        self.alreadyExecutingBackgroundFetch = NO;
    }
}


- (void)locationManager:(LocationManager *)locationManager definedCurrentLocation:(NSDictionary *)definedLocation {
    NSLog(@">>> BackgroundUpdateManager: definedCurrentLocation");
    [locationManager stopDetectingCurrentGPSLocation];
    locationManager.delegate = nil;
    [self getWeatherConditionsForLocationID:[definedLocation objectForKey:LOCATION_ID_DICT_KEY]];
}



#pragma mark - Wunderground define conditions
- (void)getWeatherConditionsForLocationID:(NSString *)locationID {
    NSLog(@">>> BackgroundUpdateManager: getWeatherConditions");
    if (![InternetConnection internetConnectionIsAvailable]) {
        @synchronized (self) {
            if (self.completion) self.completion(UIBackgroundFetchResultFailed);
            self.alreadyExecutingBackgroundFetch = NO;
        }
    }
    
    if (!locationID) {
        [BadgeController removeBadgeWithTemperature];
        @synchronized (self) {
            if (self.completion) self.completion(UIBackgroundFetchResultNoData);
            self.alreadyExecutingBackgroundFetch = NO;
        }
    }
    
    WundergroundHelper *wundergroundHelper = [[WundergroundHelper alloc] init];
    [wundergroundHelper wundergroundConditionsForLocationID:locationID withResult:^(NSDictionary *response) {
        if (response) {
            [BadgeController showTheBadgeWithTemperatureFromForecast:response];
            @synchronized (self) {
                if (self.completion) self.completion(UIBackgroundFetchResultNewData);
                self.alreadyExecutingBackgroundFetch = NO;
            }
            
        } else {
            [BadgeController removeBadgeWithTemperature];
            @synchronized (self) {
                if (self.completion) self.completion(UIBackgroundFetchResultNoData);
                self.alreadyExecutingBackgroundFetch = NO;
            }
        }
    }];
    
    /*
    [wundergroundHelper wundergroundForecast10dayConditionsDefineByLocationID:locationID withResult:^(NSDictionary *response) {
        [[ForecastData sharedInstance] setForecast:response];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LOCATION_AND_WEATHER_WERE_UPDATED_IN_BACKGROUND_NOTIFICATION_KEY" object:nil];
        
        if (response) {
            [BadgeController showTheBadgeWithTemperatureFromForecast:response];
            self.alreadyExecutingBackgroundFetch = NO;
            if (self.completion) self.completion(UIBackgroundFetchResultNewData);
            
        } else {
            [BadgeController removeBadgeWithTemperature];
            self.alreadyExecutingBackgroundFetch = NO;
            if (self.completion) self.completion(UIBackgroundFetchResultNoData);
        }
    }];*/
}



@end
