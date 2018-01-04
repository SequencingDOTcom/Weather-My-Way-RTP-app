//
//  RegionManager.m
//  Copyright © 2017 Sequencing. All rights reserved.
//


#import "RegionManager.h"
#import <CoreLocation/CoreLocation.h>
#import "UserHelper.h"
#import "ConstantsList.h"
#import "LocationManager.h"



@interface RegionManager () <CLLocationManagerDelegate, LocationManagerDelegate>
@end



@implementation RegionManager {
    CLLocationManager *regionLocationManager;
    CLGeocoder        *geocoder;
    CLPlacemark       *placemark;
    CLLocation        *currentLocationFromLocationManager;
}



#pragma mark - Init
+ (instancetype)sharedInstance {
    static RegionManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[RegionManager alloc] init];
        [instance initLocationManager];
    });
    return instance;
}


- (void)initLocationManager {
    regionLocationManager = [[CLLocationManager alloc] init];
    regionLocationManager.delegate = self;
    regionLocationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



#pragma mark - Start Monitoring
- (void)startMonitoringForGPSDetection {
    NSLog(@">>> RegionManager: startMonitoringForGPSDetection");
    [self startMonitoringForKnownLocation];
    [self subscribeForNotification];
}

- (void)subscribeForNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gpsCoordinatesDetected:)
                                                 name:GPS_COORDINATES_DETECTED_NOTIFICATION_KEY
                                               object:nil];
}


- (void)startMonitoringForKnownLocation {
    NSLog(@">>> RegionManager: startMonitoringForKnownLocation");
    UserHelper *userHelper = [[UserHelper alloc] init];
    CLLocation *location = [userHelper loadUserCurrentGPSLocation];
    if (!location) return;
    
    [self startMonitoringForLocation:location];
}


#pragma mark - gpsCoordinatesDetected
- (void)gpsCoordinatesDetected:(NSNotification *)notification {
    NSLog(@">>> RegionManager: gpsCoordinatesDetected");
    if (![self isCLLocationAvailable]) return;
    
    CLLocation *location = [notification.userInfo objectForKey:dict_cllocationKey];
    [self startMonitoringForLocation:location];
    // float latitude  = cllocation.coordinate.latitude;
    // float longitude = cllocation.coordinate.longitude;
}


- (void)startMonitoringForLocation:(CLLocation *)location {
    NSLog(@">>> RegionManager: startMonitoringForLocationRegion");
    for (CLRegion *monitored in [regionLocationManager monitoredRegions])
        [regionLocationManager stopMonitoringForRegion:monitored];
    
    CLCircularRegion *newRegion = [self createRegionWithCLLocationPoint:location];
    [regionLocationManager startMonitoringForRegion:newRegion];
}



#pragma mark - did exit region
- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    NSLog(@">>> RegionManager: didExitRegion");
    LocationManager *locationManager = [LocationManager sharedInstance];
    locationManager.delegate = self;
    [locationManager detectCurrentGPSLocation];
}


- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            [self startMonitoringForKnownLocation]; break;
        case kCLAuthorizationStatusAuthorizedAlways:
            [self startMonitoringForKnownLocation]; break;
        default: break;
    }
}


#pragma mark - LocationManagerDelegate
- (void)locationManager:(LocationManager *)locationManager detectedCurrentGPSLocation:(CLLocation *)currentLocation {
    NSLog(@">>> RegionManager: detectedCurrentGPSLocation");
    [locationManager stopDetectingCurrentGPSLocation];
    locationManager.delegate = nil;
    [self startMonitoringForLocation:currentLocation];
}


- (void)locationManager:(LocationManager *)locationManager failedToDetectCurrentGPSLocation:(NSError *)error {
    [locationManager stopDetectingCurrentGPSLocation];
    locationManager.delegate = nil;
}



#pragma mark - Helpers
- (BOOL)isCLLocationAvailable {
    if (![CLLocationManager locationServicesEnabled]) return NO;
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    switch (status) {
        case kCLAuthorizationStatusNotDetermined: {
            [regionLocationManager requestAlwaysAuthorization];
            return YES;
        } break;
        case kCLAuthorizationStatusAuthorizedWhenInUse: {
            [regionLocationManager requestAlwaysAuthorization];
            return YES;
        } break;
        case kCLAuthorizationStatusAuthorizedAlways:
            return YES; break;
        case kCLAuthorizationStatusDenied:
            return NO; break;
        default: return NO; break;
    }
}


- (CLCircularRegion *)createRegionWithCLLocationPoint:(CLLocation *)currentLocation {
    CLLocationCoordinate2D centerCoordinate = currentLocation.coordinate;
    CLLocationDistance regionRadius = 2000.f;
    CLCircularRegion *currentRegion = [[CLCircularRegion alloc] initWithCenter:centerCoordinate radius:regionRadius identifier:@"region"];
    currentRegion.notifyOnEntry = NO;
    currentRegion.notifyOnExit  = YES;
    return currentRegion;
}






@end
