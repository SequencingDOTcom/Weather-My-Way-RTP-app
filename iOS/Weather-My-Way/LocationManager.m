//
//  LocationManager.m
//  Copyright © 2017 Sequencing. All rights reserved.
//


#import "LocationManager.h"
#import "UserHelper.h"
#import "ConstantsList.h"
#import "WundergroundHelper.h"



@interface LocationManager () <CLLocationManagerDelegate>

@property (assign, nonatomic) BOOL alreadyGotLocationPoint;

@end



@implementation LocationManager {
    CLLocationManager *locationManager;
}


#pragma mark - Init
+ (instancetype)sharedInstance {
    static LocationManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LocationManager alloc] init];
        instance.alreadyGotLocationPoint = NO;
        [instance initLocationManager];
    });
    return instance;
}



- (void)initLocationManager {
    NSLog(@">>> LocationManager: initLocationManager");
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
}



- (void)detectCurrentGPSLocation {
    NSLog(@">>> LocationManager: detectCurrentGPSLocation");
    if (![self isCLLocationAvailable]) {
        if ([_delegate respondsToSelector:@selector(locationManager:failedToDetectCurrentGPSLocation:)])
            [_delegate locationManager:self failedToDetectCurrentGPSLocation:nil];
        return;
    }
    self.alreadyGotLocationPoint = NO;
    [locationManager requestLocation];
}


- (void)stopDetectingCurrentGPSLocation {
    [locationManager stopUpdatingLocation];
}


- (BOOL)isCLLocationAvailable {
    if (![CLLocationManager locationServicesEnabled]) return NO;
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    switch (status) {
        case kCLAuthorizationStatusNotDetermined: {
            [locationManager requestAlwaysAuthorization];
            return YES;
        } break;
        case kCLAuthorizationStatusAuthorizedWhenInUse: {
            [locationManager requestAlwaysAuthorization];
            return YES;
        } break;
        case kCLAuthorizationStatusAuthorizedAlways:
            return YES; break;
        case kCLAuthorizationStatusDenied:
            return NO; break;
        default: return NO; break;
    }
}



#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if (self.alreadyGotLocationPoint) return;
    self.alreadyGotLocationPoint = YES;
    if ([_delegate respondsToSelector:@selector(locationManager:failedToDetectCurrentGPSLocation:)])
        [_delegate locationManager:self failedToDetectCurrentGPSLocation:error];
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    if (self.alreadyGotLocationPoint) return;
    [locationManager stopUpdatingLocation];
    
    self.alreadyGotLocationPoint = YES;
    if (!locations || [locations count] == 0) {
        if ([_delegate respondsToSelector:@selector(locationManager:failedToDetectCurrentGPSLocation:)])
            [_delegate locationManager:self failedToDetectCurrentGPSLocation:nil];
        return;
    }
    
    UserHelper *userHelper = [[UserHelper alloc] init];
    [userHelper saveUserCurrentGPSLocation:[locations lastObject]];
    
    if ([_delegate respondsToSelector:@selector(locationManager:detectedCurrentGPSLocation:)])
        [_delegate locationManager:self detectedCurrentGPSLocation:[locations lastObject]];
    
    [self defineLocationDetails:[locations lastObject]];
}


#pragma mark - Define location details
- (void)defineLocationDetails:(CLLocation *)cllocation {
    WundergroundHelper *wundergroundHelper = [[WundergroundHelper alloc] init];
    [wundergroundHelper wundergroundGeolookupDefineLocationDetailsBasedOnLocationCoordinates:cllocation withResult:^(NSDictionary *location) {
        
        if (!location || [[location objectForKey:@"id"] length] == 0) {
            if ([_delegate respondsToSelector:@selector(locationManager:failedToDefineCurrentLocation:)])
                [_delegate locationManager:self failedToDefineCurrentLocation:nil];
            return;
        }
        
        NSString *locationCity = [location objectForKey:@"city"];
        NSString *locationStateOrCountry = @"";
        NSString *locationID = [location objectForKey:@"id"];
        if ([[location objectForKey:@"state"] length] != 0)
            locationStateOrCountry = [location objectForKey:@"state"];
        else
            locationStateOrCountry = [location objectForKey:@"country"];
        
        NSDictionary *definedLocation = [NSDictionary dictionaryWithObjectsAndKeys:
                                         locationCity,           LOCATION_CITY_DICT_KEY,
                                         locationStateOrCountry, LOCATION_STATE_COUNTRY_DICT_KEY,
                                         locationID,             LOCATION_ID_DICT_KEY,
                                         cllocation,             CLLOCATION_OBJECT_DICT_KEY, nil];
        UserHelper *userHelper = [[UserHelper alloc] init];
        [userHelper saveUserCurrentLocation:definedLocation];
        
        NSLog(@">>> LocationManager: definedCurrentLocation: %@", locationCity);
        if ([_delegate respondsToSelector:@selector(locationManager:definedCurrentLocation:)])
            [_delegate locationManager:self definedCurrentLocation:definedLocation];
    }];
}


@end
