//
//  SignificantLocationManager.m
//  Copyright © 2017 Sequencing. All rights reserved.
//

#import "SignificantLocationManager.h"
#import "UserHelper.h"
#import "ConstantsList.h"
#import "LocationManager.h"



@interface SignificantLocationManager () <CLLocationManagerDelegate, LocationManagerDelegate>
@end


@implementation SignificantLocationManager {
    CLLocationManager *locationManager;
}



#pragma mark - Init
+ (instancetype)sharedInstance {
    static SignificantLocationManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SignificantLocationManager alloc] init];
        [instance initLocationManager];
    });
    return instance;
}


- (void)initLocationManager {
    NSLog(@">>> SignificantLocationManager: initLocationManager");
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
}



#pragma mark - Start Monitoring Significant Location Change

- (void)startMonitoringSignificantLocationChange {
    NSLog(@">>> SignificantLocationManager: startMonitoringSignificantLocationChange");
    if (![self isCLLocationAvailable]) return;
    [locationManager startMonitoringSignificantLocationChanges];
}


#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    // [locationManager stopMonitoringSignificantLocationChanges];
    [self startMonitoringSignificantLocationChange];
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    NSLog(@">>> SignificantLocationManager: didUpdateLocations");
    if (!locations || [locations count] == 0) return;
    UserHelper *userHelper = [[UserHelper alloc] init];
    [userHelper saveUserCurrentGPSLocation:[locations lastObject]];
}


- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            [self startMonitoringSignificantLocationChange]; break;
        case kCLAuthorizationStatusAuthorizedAlways:
            [self startMonitoringSignificantLocationChange]; break;
        default: break;
    }
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


@end
