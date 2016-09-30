//
//  LocationWeatherUpdater.m
//  Copyright © 2016 Sequencing. All rights reserved.
//


#import "LocationWeatherUpdater.h"
#import <CoreLocation/CoreLocation.h>
#import "SQToken.h"
#import "UserHelper.h"
#import "UserAccountHelper.h"
#import "WundergroundHelper.h"
#import "ForecastData.h"
#import "GeneticForecastHelper.h"
#import "InternetConnection.h"


dispatch_source_t CreateLocationTimerDispatch(double interval, dispatch_queue_t queue, dispatch_block_t block) {
    dispatch_source_t timerForLocationRefresh = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    if (timerForLocationRefresh) {
        dispatch_source_set_timer(timerForLocationRefresh, dispatch_time(DISPATCH_TIME_NOW, interval * NSEC_PER_SEC), interval * NSEC_PER_SEC, (1ull * NSEC_PER_SEC) / 10);
        dispatch_source_set_event_handler(timerForLocationRefresh, block);
        dispatch_resume(timerForLocationRefresh);
    }
    return timerForLocationRefresh;
}



@interface LocationWeatherUpdater () <CLLocationManagerDelegate>

@property (assign, nonatomic) BOOL alreadyGotLocationPoint;

@end



@implementation LocationWeatherUpdater {
    CLLocationManager   *locationManager;
    CLGeocoder          *geocoder;
    CLPlacemark         *placemark;
    CLLocation          *currentLocationFromLocationManager;
}

dispatch_source_t _timerForLocationRefresh;
static double SECONDS_TO_FIRE = 1860.f; // time interval lengh in seconds 1800

#pragma mark -
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
    // init location manager
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
}



#pragma mark -
#pragma mark Timer methods

- (void)startTimer {
    NSLog(@"LocationWeatherUpdater: Timer started");
    // timer
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _timerForLocationRefresh = CreateLocationTimerDispatch(SECONDS_TO_FIRE, queue, ^{
        if ([InternetConnection internetConnectionIsAvailable]) {
            [self checkLocationAvailabilityAndStart];
        }
    });
}

// use this method when user is logging out
- (void)cancelTimer {
    if (_timerForLocationRefresh) {
        dispatch_source_cancel(_timerForLocationRefresh);
        _timerForLocationRefresh = nil;
        NSLog(@"LocationWeatherUpdater: Timer canceled");
    }
}



#pragma mark -
#pragma mark Autodetect Location

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
                // [self requestUserLocation];
            } break;
        }
        
    } else {
        // !!! just start updating weather forecast + genetic forecast (for know current location from userhelper)
        [self getForecast];
    }
}

- (void)requestUserLocation {
    NSLog(@"LocationWeatherUpdater: requestUserLocation");
    // getting location once
    [_delegate startedRefreshing];
    self.alreadyGotLocationPoint = NO;
    [locationManager requestLocation];
}


#pragma mark -
#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"LocationWeatherUpdater: locationManager:didFailWithError:");
    if (!self.alreadyGotLocationPoint) {
        self.alreadyGotLocationPoint = YES;
        
        // !!! just start updating weather forecast + genetic forecast (for know current location from userhelper)
        [self getForecast];
        
    } else {
        NSLog(@"LocationWeatherUpdater: already got location point!!!");
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    [locationManager stopUpdatingLocation];
    NSLog(@"LocationWeatherUpdater: locationManager:didUpdateLocations:");
    
    if (!self.alreadyGotLocationPoint) {
        self.alreadyGotLocationPoint = YES;
        
        if (locations && [locations count] > 0) {
            UserHelper *userHelper = [[UserHelper alloc] init];
            CLLocation *oldGPSLocation = [userHelper loadUserCurrentGPSLocation];
            NSDictionary *currentLocation = [userHelper loadUserCurrentLocation];
            
            CLLocationDistance currentDistance = [[locations lastObject] distanceFromLocation:oldGPSLocation]; // distance in meters (double)
            
            if ([InternetConnection internetConnectionIsAvailable]) {
                if ([locations lastObject] != oldGPSLocation
                    || !currentLocation || currentDistance >= 1000.f) {
                    
                    [userHelper saveUserCurrentGPSLocation:[locations lastObject]];
                    [self defineLocationDetails:[locations lastObject]];
                    
                } else {
                    // !!! just start updating weather forecast + genetic forecast (for known current location from userhelper)
                    [self getForecast];
                }
            } else {
                // !!! just start updating weather forecast + genetic forecast (for known current location from userhelper)
                [self getForecast];
            }
        } else {
            // !!! just start updating weather forecast + genetic forecast (for know current location from userhelper)
            [self getForecast];
        }
    } else {
        NSLog(@"LocationWeatherUpdater: already got location point!!!");
    }
}



#pragma mark -
#pragma mark Define location details

- (void)defineLocationDetails:(CLLocation *)currentLocation {
    NSLog(@"LocationWeatherUpdater: defineLocationDetails");
    WundergroundHelper *wundergroundHelper = [[WundergroundHelper alloc] init];
    [wundergroundHelper wundergroundGeolookupDefineLocationDetailsBasedOnLocationCoordinates:currentLocation withResult:^(NSDictionary *location) {
        
        if (location != nil && [[location objectForKey:@"id"] length] != 0) { // location details are defined
            NSString *locationCity = [location objectForKey:@"city"];
            NSString *locationStateOrCountry = @"";
            NSString *locationID = [location objectForKey:@"id"];
            if ([[location objectForKey:@"state"] length] != 0) {
                locationStateOrCountry = [location objectForKey:@"state"];
            } else {
                locationStateOrCountry = [location objectForKey:@"country"];
            }
            
            // save defined location details into userDefaults
            NSDictionary *location = [NSDictionary dictionaryWithObjectsAndKeys:
                                      locationCity,             LOCATION_CITY_DICT_KEY,
                                      locationStateOrCountry,   LOCATION_STATE_COUNTRY_DICT_KEY,
                                      locationID,               LOCATION_ID_DICT_KEY, nil];
            UserHelper *userHelper = [[UserHelper alloc] init];
            [userHelper saveUserCurrentLocation:location];
            
            
            // send selected location to user account on server
            [self sendLocationInfoToServer:location];
            
            
            // !!! now can start updating weather forecast + genetic forecast (as we already know current location)
            [self getForecast];
            
        } else {
            // !!! just start updating weather forecast + genetic forecast (for know current location from userhelper)
            [self getForecast];
        }
    }];
}



#pragma mark -
#pragma mark Forecast block

- (void)getForecast {
    NSLog(@"LocationWeatherUpdater: getForecast");
    if ([InternetConnection internetConnectionIsAvailable]) {
        
        [self requestForWeatherForecast:^(NSDictionary *forecast) {
            if (forecast != nil) {
                // save forecast into data container
                ForecastData *forecastContainer = [[ForecastData alloc] sharedInstance];
                [forecastContainer setForecast:forecast];
                
                // request for genetic forecast based on appchain job result
                if ([InternetConnection internetConnectionIsAvailable]) {
                    [self requestForGeneticForecast:^(NSString *geneticForecast) {
                        
                        if ([geneticForecast length] != 0) {
                            forecastContainer.geneticForecast = geneticForecast;
                        } else {
                            forecastContainer.geneticForecast = kAbsentGeneticForecastMessage;
                        }
                        
                        // !!! send message to delegate to refresh UI (on Forecast screen)
                        NSLog(@"LocationWeatherUpdater: _delegate locationAndWeatherWereUpdated");
                        [_delegate locationAndWeatherWereUpdated];
                    }];
                } else {
                    [_delegate finishedRefreshWithError];
                }
            } else {
                [_delegate finishedRefreshWithError];
            }
        }];
    } else {
        [_delegate finishedRefreshWithError];
    }
}



#pragma mark -
#pragma mark Request for forecast

- (void)requestForWeatherForecast:(void (^)(NSDictionary *forecast))completion {
    NSLog(@"LocationWeatherUpdater: requestForWeatherForecast");
    ForecastData *forecastContainer = [[ForecastData alloc] sharedInstance];
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
        
    } else {
        [userHelper saveUserSelectedLocation:defaultLocation];
        
        // try to get forecast for default location
        locationID = [defaultLocation objectForKey:LOCATION_ID_DICT_KEY];
        forecastContainer.locationForForecast = defaultLocation;
        locationForServer = [defaultLocation copy];
    }
    
    // update location on Server (user account)
    [self sendLocationInfoToServer:locationForServer];
    
    // get forecast with Wunderground service
    WundergroundHelper *wundergroundHelper = [[WundergroundHelper alloc] init];
    [wundergroundHelper wundergroundForecast10dayConditionsDefineByLocationID:locationID withResult:^(NSDictionary *forecast) {
        if (forecast) {
            completion(forecast);
            
        } else {
            NSLog(@"PrepareForecastVC: !Error: forecast from wunderground server is empty");
            completion(nil);
        }
    }];
}

- (void)sendLocationInfoToServer:(NSDictionary *)location {
    if (location) {
        UserHelper *userHelper = [[UserHelper alloc] init];
        NSString *locationID = [location objectForKey:LOCATION_ID_DICT_KEY];
        NSDictionary *parameters = @{@"city"  : locationID,
                                     @"token" : [userHelper loadUserToken].accessToken};
        UserAccountHelper *userAccountHelper = [[UserAccountHelper alloc] init];
        [userAccountHelper sendSelectedLocationInfoWithParameters:parameters];
        NSLog(@"sendSelectedLocationInfoWithParameters");
    }
}



#pragma mark -
#pragma mark Genetic forecast

- (void)requestForGeneticForecast:(void (^)(NSString *geneticForecast))completion {
    NSLog(@"[LocationWeatherUpdater] requestForGeneticForecast");
    GeneticForecastHelper *gfHelper = [[GeneticForecastHelper alloc] sharedInstance];
    ForecastData *forecastContainer = [[ForecastData alloc] sharedInstance];
    UserHelper *userHelper = [[UserHelper alloc] init];
    
    NSString *fileID;
    NSString *fileIDRawValue = [[userHelper loadUserGeneticFile] objectForKey:GENETIC_FILE_ID_DICT_KEY];
    if ([fileIDRawValue containsString:@":"]) {
        NSArray *arrayFileID = [fileIDRawValue componentsSeparatedByString:@":"];
        if ([arrayFileID count] > 1) {
            fileID = [arrayFileID lastObject];
        }
    } else {
        fileID = fileIDRawValue;
    }
    
    SQToken *token = [userHelper loadUserToken];
    
    if (forecastContainer.forecastDayObjectsListFor10DaysArray && [forecastContainer.forecastDayObjectsListFor10DaysArray count] > 0) {
        if ([fileID length] != 0) {
            if ([token.accessToken length] != 0) {
                
                [gfHelper requestForGeneticDataForFileID:fileID
                                             accessToken:token.accessToken
                                          withCompletion:^(BOOL success) {
                                              if (success) {
                                                  forecastContainer.vitaminDValue     = [gfHelper.vitaminDValue copy];
                                                  forecastContainer.melanomaRiskValue = [gfHelper.melanomaRiskValue copy];
                                                  
                                                  [gfHelper requestForGeneticForecastsWithToken:token.accessToken
                                                                                 withCompletion:^(NSArray *geneticForecastsArray) {
                                                                                     if (geneticForecastsArray != nil) {
                                                                                         [forecastContainer populateDayObjectsWithGeneticForecasts:geneticForecastsArray];
                                                                                         completion([geneticForecastsArray[0] objectForKey:@"gtForecast"]);
                                                                                     } else {
                                                                                         completion(kAbsentGeneticForecastMessage);
                                                                                     }
                                                                                 }];
                                              } else {
                                                  completion(kAbsentGeneticForecastMessage);
                                              }
                                          }];
            } else {
                completion(kAbsentGeneticForecastMessage);
            }
        } else {
            completion(kAbsentGeneticForecastMessage);
        }
    } else {
        completion(kAbsentGeneticForecastMessage);
    }
}





@end
