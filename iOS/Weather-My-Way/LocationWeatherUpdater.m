//
//  LocationWeatherUpdater.m
//  Copyright © 2016 Sequencing. All rights reserved.
//


#import "LocationWeatherUpdater.h"
#import <CoreLocation/CoreLocation.h>
#import "SQOAuth.h"
#import "SQToken.h"
#import "UserHelper.h"
#import "UserAccountHelper.h"
#import "WundergroundHelper.h"
#import "ForecastData.h"
#import "GeneticForecastHelper.h"
#import "InternetConnection.h"
#import "ConstantsList.h"


@interface LocationWeatherUpdater () <CLLocationManagerDelegate>

@property (assign, nonatomic) BOOL              alreadyGotLocationPoint;
@property (strong, nonatomic) CLLocation        *currentLocationPoint;
@property (strong, nonatomic) CLCircularRegion  *currentRegion;

@end



@implementation LocationWeatherUpdater {
    CLLocationManager   *locationManager;
    CLGeocoder          *geocoder;
    CLPlacemark         *placemark;
    CLLocation          *currentLocationFromLocationManager;
}



#pragma mark - Full refresh FLOW
#pragma mark Init
+ (instancetype)sharedInstance {
    static LocationWeatherUpdater *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LocationWeatherUpdater alloc] init];
        instance.alreadyGotLocationPoint = NO;
        [instance initLocationManager];
    });
    return instance;
}


- (void)initLocationManager {
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
}




#pragma mark - Autodetect Location
- (void)checkLocationAvailabilityAndStart {
    NSLog(@"LocationWeatherUpdater: checkLocationAvailabilityAndStart");
    if ([CLLocationManager locationServicesEnabled]) {
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        
        switch (status) {
            case kCLAuthorizationStatusNotDetermined: {
                [locationManager requestAlwaysAuthorization];
                [self requestUserLocation];
            } break;
                
            case kCLAuthorizationStatusAuthorizedWhenInUse: {
                [locationManager requestAlwaysAuthorization];
                [self requestUserLocation];
            } break;
                
            case kCLAuthorizationStatusAuthorizedAlways: {
                [self requestUserLocation];
            } break;
                
            case kCLAuthorizationStatusDenied: {
                // !!! just start updating weather forecast + genetic forecast (for know current location from userhelper)
                [self getForecast];
            } break;
                
            default: {
                [self getForecast];
            } break;
        }
        
    } else {
        // !!! just start updating weather forecast + genetic forecast (for know current location from userhelper)
        [self getForecast];
    }
}

- (void)requestUserLocation {
    NSLog(@"LocationWeatherUpdater: requestUserLocation");
    [_delegate startedRefreshing];
    self.alreadyGotLocationPoint = NO;
    [locationManager requestLocation];
}


#pragma mark CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if (!self.alreadyGotLocationPoint) {
        self.alreadyGotLocationPoint = YES;
        
        // !!! just start updating weather forecast + genetic forecast (for know current location from userhelper)
        [self getForecast];
                
    } else
        NSLog(@"LocationWeatherUpdater: already got location point!!!");
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    NSLog(@"LocationWeatherUpdater: locationManager:didUpdateLocations:");
    [locationManager stopUpdatingLocation];
    
    if (self.alreadyGotLocationPoint) {
        NSLog(@"LocationWeatherUpdater: already got location point!!!");
        return;
    }
    
    self.alreadyGotLocationPoint = YES;
    
    if (!locations || [locations count] == 0) {
        // !!! just start updating weather forecast + genetic forecast (for know current location from userhelper)
        [self getForecast];
        return;
    }
    
    if ([InternetConnection internetConnectionIsAvailable] == NO) {
        // !!! just start updating weather forecast + genetic forecast (for known current location from userhelper)
        [self getForecast];
        return;
    }
    
    UserHelper *userHelper = [[UserHelper alloc] init];
    [userHelper saveUserCurrentGPSLocation:[locations lastObject]];
    self.currentLocationPoint = [locations lastObject];
    
    
    // *
    // * post notification with detected location
    // *
    NSDictionary *userInfoDict = @{dict_cllocationKey: [locations lastObject]};
    [[NSNotificationCenter defaultCenter] postNotificationName:GPS_COORDINATES_DETECTED_NOTIFICATION_KEY object:nil userInfo:userInfoDict];
    // *
    
    [self defineLocationDetails:[locations lastObject]];
}



#pragma mark - Define location details
- (void)defineLocationDetails:(CLLocation *)cllocation {
    NSLog(@"LocationWeatherUpdater: defineLocationDetails");
    WundergroundHelper *wundergroundHelper = [[WundergroundHelper alloc] init];
    [wundergroundHelper wundergroundGeolookupDefineLocationDetailsBasedOnLocationCoordinates:cllocation withResult:^(NSDictionary *location) {
        if (!location || [[location objectForKey:@"id"] length] == 0) {
            [self getForecast]; // just start updating weather + genetic forecasts
            return;
        }
        
        NSString *locationCity = [location objectForKey:@"city"];
        NSString *locationStateOrCountry = @"";
        NSString *locationID = [location objectForKey:@"id"];
        if ([[location objectForKey:@"state"] length] != 0) {
            locationStateOrCountry = [location objectForKey:@"state"];
        } else {
            locationStateOrCountry = [location objectForKey:@"country"];
        }
        
        
        // *
        // * post notification with defined location
        // *
        NSDictionary *userInfoDict = @{dict_placeKey:      locationCity,
                                       dict_cllocationKey: cllocation};
        [[NSNotificationCenter defaultCenter] postNotificationName:LOCATION_NAME_DEFINED_NOTIFICATION_KEY object:nil userInfo:userInfoDict];
        // *
        
        /*
        UILocalNotification *notification = [[UILocalNotification alloc]init];
        [notification setAlertBody:[NSString stringWithFormat:@"Welcome to region: %@", locationCity]];
        [notification setRepeatInterval:0];
        [notification setFireDate:[NSDate dateWithTimeIntervalSinceNow:1]];
        [notification setTimeZone:[NSTimeZone  defaultTimeZone]];
        [[UIApplication sharedApplication]scheduleLocalNotification:notification];*/
        
        // save defined location details into LocationManager instance
        self.currentLocationPoint = cllocation;
        // [self saveCurrentRegionWithCLLocationPoing:currentLocation andIdentifier:locationCity];
        
        // save defined location details into userDefaults
        NSDictionary *definedLocation = [NSDictionary dictionaryWithObjectsAndKeys:
                                         locationCity,           LOCATION_CITY_DICT_KEY,
                                         locationStateOrCountry, LOCATION_STATE_COUNTRY_DICT_KEY,
                                         locationID,             LOCATION_ID_DICT_KEY,
                                         cllocation,             CLLOCATION_OBJECT_DICT_KEY, nil];
        UserHelper *userHelper = [[UserHelper alloc] init];
        [userHelper saveUserCurrentLocation:definedLocation];
        
        // send selected location to user account on server
        [self sendLocationInfoToServer:definedLocation];
        
        [self getForecast]; // now can start updating weather + genetic forecasts
    }];
}




#pragma mark - Forecast block
- (void)getForecast {
    NSLog(@"LocationWeatherUpdater: getForecast");
    if (![InternetConnection internetConnectionIsAvailable]) {
        [_delegate finishedRefreshWithError];
        return;
    }
    
    [self requestForWeatherForecast:^(NSDictionary *forecast) {
        if (!forecast) {
            [_delegate finishedRefreshWithError];
            return;
        }
        
        ForecastData *forecastContainer = [ForecastData sharedInstance];
        [forecastContainer setForecast:forecast];
        
        [_delegate locationAndWeatherWereUpdated];
    }];
}






#pragma mark - Request for forecast
- (void)requestForWeatherForecast:(void (^)(NSDictionary *forecast))completion {
    NSLog(@"LocationWeatherUpdater: requestForWeatherForecast");
    ForecastData *forecastContainer = [ForecastData  sharedInstance];
    UserHelper *userHelper = [[UserHelper alloc] init];
    NSDictionary *currentLocation = [userHelper loadUserCurrentLocation];
    NSDictionary *selectedLocation = [userHelper loadUserSelectedLocation];
    NSDictionary *defaultLocation = [userHelper loadUserDefaultLocation];
    NSString *locationID;
    NSDictionary *locationForServer;
    
    if (![userHelper locationIsEmpty:currentLocation]) {
        [userHelper saveUserSelectedLocation:currentLocation];
        
        // try to get forecast for current location
        locationID = [currentLocation objectForKey:LOCATION_ID_DICT_KEY];
        forecastContainer.locationForForecast = currentLocation;
        
    } else if (![userHelper locationIsEmpty:selectedLocation]) {
        // try to get forecast for selected location
        locationID = [selectedLocation objectForKey:LOCATION_ID_DICT_KEY];
        forecastContainer.locationForForecast = selectedLocation;
        locationForServer = [selectedLocation copy];
        [self sendLocationInfoToServer:locationForServer];
        
    } else {
        [userHelper saveUserSelectedLocation:defaultLocation];
        
        // try to get forecast for default location
        locationID = [defaultLocation objectForKey:LOCATION_ID_DICT_KEY];
        forecastContainer.locationForForecast = defaultLocation;
        locationForServer = [defaultLocation copy];
        [self sendLocationInfoToServer:locationForServer];
    }
    
    // get forecast with Wunderground service
    [self executeWundergroundWeatherForecastRequestForLocation:locationID
                                                withCompletion:^(NSDictionary *forecast) {
                                                    completion(forecast);
                                                }];
}


- (void)sendLocationInfoToServer:(NSDictionary *)location {
    if (!location) return;
    if (![InternetConnection internetConnectionIsAvailable]) return;
    
    [[SQOAuth sharedInstance] token:^(SQToken *token, NSString *accessToken) {
        if (!token || [token.accessToken length] == 0) return;
        
        NSString *locationID = [location objectForKey:LOCATION_ID_DICT_KEY];
        id locationIDID = locationID;
        if (locationID == nil || locationIDID == [NSNull null]) return;
        
        NSDictionary *parameters = @{@"city" : locationID,
                                     @"token": token.accessToken};
        [[[UserAccountHelper alloc] init] sendSelectedLocationInfoWithParameters:parameters];
    }];
}



- (void)requestForGeneticForecast:(void (^)(NSString *geneticForecast))completion {
    [[SQOAuth sharedInstance] token:^(SQToken *token, NSString *accessToken) {
        if (token == nil || [token.accessToken length] == 0) {
            completion(kAbsentGeneticForecastMessage);
            return;
        }
        
        ForecastData *forecastContainer = [ForecastData  sharedInstance];
        NSString *fileID;
        NSString *fileIDRawValue = [[[[UserHelper alloc] init] loadUserGeneticFile] objectForKey:GENETIC_FILE_ID_DICT_KEY];
        if ([fileIDRawValue containsString:@":"]) {
            NSArray *arrayFileID = [fileIDRawValue componentsSeparatedByString:@":"];
            if ([arrayFileID count] > 1)
                fileID = [arrayFileID lastObject];
        } else
            fileID = fileIDRawValue;
        
        if (forecastContainer.forecastDayObjectsListFor10DaysArray == nil || [forecastContainer.forecastDayObjectsListFor10DaysArray count] == 0) {
            completion(kAbsentGeneticForecastMessage);
            return;
        }
        
        if (fileID == nil || [fileID length] == 0) {
            completion(kAbsentGeneticForecastMessage);
            return;
        }
        
        [self executeAppChainsGeneticForecastRequestForFile:fileID
                                                accessToken:token.accessToken
                                             withCompletion:^(NSString *geneticForecast) {
                                                 completion(geneticForecast);
                                             }];
    }];
}




#pragma mark -
#pragma mark - Refresh Weather for Specific location FLOW
- (void)refreshWeatherForecastForLocation:(NSDictionary *)location {
    UserHelper *userHelper = [[UserHelper alloc] init];
    if ([userHelper locationIsEmpty:location]) {
        [_delegate finishedRefreshWithError];
        return;
    }
    
    NSString *locationID = [location objectForKey:LOCATION_ID_DICT_KEY];
    if (!locationID) {
        [_delegate finishedRefreshWithError];
        return;
    }
    
    [_delegate startedRefreshing];
    
    [self executeWundergroundWeatherForecastRequestForLocation:locationID
                                                withCompletion:^(NSDictionary *forecast) {
                                                    
                                                    if (forecast)
                                                        [_delegate weatherForecastUpdated:forecast];
                                                    else
                                                        [_delegate finishedRefreshWithError];
                                                }];
}



#pragma mark -
#pragma mark - Refresh Genetic Forecast for specific file FLOW

- (void)requestForGeneticForecastWithGeneticFile:(NSDictionary *)file withCompletion:(void (^)(NSString *geneticForecast))completion {
    NSLog(@">>>>> LocationWeatherUpdater: requestForGeneticForecastWithGeneticFile");
    if (![InternetConnection internetConnectionIsAvailable]) {
        completion(kAbsentGeneticForecastMessage);
        return;
    }
    
    ForecastData *forecastContainer = [ForecastData sharedInstance];
    UserHelper *userHelper = [[UserHelper alloc] init];
    
    if (!file) file = [userHelper loadUserGeneticFile];
    
    NSLog(@">>>>> LocationWeatherUpdater: SQOAuth get token");
    [[SQOAuth sharedInstance] token:^(SQToken *token, NSString *accessToken) {
        NSLog(@">>>>> LocationWeatherUpdater: SQOAuth got token");
        if (!token || [token.accessToken length] == 0) {
            completion(kAbsentGeneticForecastMessage);
            return;
        }
        
        if (![InternetConnection internetConnectionIsAvailable]) {
            completion(kAbsentGeneticForecastMessage);
            return;
        }
        
        NSString *fileID;
        NSString *fileIDRawValue = [file objectForKey:GENETIC_FILE_ID_DICT_KEY];
        if ([fileIDRawValue containsString:@":"]) {
            NSArray *arrayFileID = [fileIDRawValue componentsSeparatedByString:@":"];
            if ([arrayFileID count] > 1)
                fileID = [arrayFileID lastObject];
        } else fileID = fileIDRawValue;
        
        if (forecastContainer.forecastDayObjectsListFor10DaysArray == nil || [forecastContainer.forecastDayObjectsListFor10DaysArray count] == 0) {
            completion(kAbsentGeneticForecastMessage);
            return;
        }
        
        if (fileID == nil || [fileID length] == 0) {
            completion(kAbsentGeneticForecastMessage);
            return;
        }
        
        [self executeAppChainsGeneticForecastRequestForFile:fileID
                                                accessToken:token.accessToken
                                             withCompletion:^(NSString *geneticForecast) {
                                                 completion(geneticForecast);
                                             }];
    }];
}




#pragma mark -
#pragma mark - Weather Forecast low level request
- (void)executeWundergroundWeatherForecastRequestForLocation:(NSString *)locationID withCompletion:(void (^)(NSDictionary *forecast))completion {
    WundergroundHelper *wundergroundHelper = [[WundergroundHelper alloc] init];
    [wundergroundHelper wundergroundForecast10dayConditionsDefineByLocationID:locationID withResult:^(NSDictionary *forecast) {
        completion(forecast);
    }];
}



#pragma mark - Genetic Forecast low level request
- (void)executeAppChainsGeneticForecastRequestForFile:(NSString *)fileID accessToken:(NSString *)accessToken withCompletion:(void (^)(NSString *geneticForecast))completion {
    NSLog(@">>>>> LocationWeatherUpdater: executeAppChainsGeneticForecastRequestForFile");
    if (![InternetConnection internetConnectionIsAvailable]) {
        completion(kAbsentGeneticForecastMessage);
        return;
    }
    
    GeneticForecastHelper *gfHelper = [GeneticForecastHelper sharedInstance];
    ForecastData *forecastContainer = [ForecastData sharedInstance];
    
    NSLog(@">>>>> LocationWeatherUpdater: gfHelper - requestForGeneticDataForFileID");
    [gfHelper requestForGeneticDataForFileID:fileID
                                 accessToken:accessToken
                              withCompletion:^(BOOL success) {
                                  NSLog(@">>>>> LocationWeatherUpdater: gfHelper - requestForGeneticDataForFileID Completion");
                                  if (!success) {
                                      completion(kAbsentGeneticForecastMessage);
                                      return;
                                  }
                                  
                                  forecastContainer.vitaminDValue     = [gfHelper.vitaminDValue copy];
                                  forecastContainer.melanomaRiskValue = [gfHelper.melanomaRiskValue copy];
                                  
                                  if (![InternetConnection internetConnectionIsAvailable]) {
                                      completion(kAbsentGeneticForecastMessage);
                                      return;
                                  }
                                  
                                  [gfHelper requestForGeneticForecastsWithToken:accessToken
                                                                 withCompletion:^(NSArray *geneticForecastsArray) {
                                                                     if (geneticForecastsArray != nil) {
                                                                         [forecastContainer populateDayObjectsWithGeneticForecasts:geneticForecastsArray];
                                                                         completion([geneticForecastsArray[0] objectForKey:@"gtForecast"]);
                                                                     } else
                                                                         completion(kAbsentGeneticForecastMessage);
                                                                 }];
                              }];
}


@end
