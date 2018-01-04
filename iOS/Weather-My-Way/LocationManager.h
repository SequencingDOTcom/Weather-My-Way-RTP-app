//
//  LocationManager.h
//  Copyright © 2017 Sequencing. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
@class LocationManager;


@protocol LocationManagerDelegate <NSObject>
@optional
- (void)locationManager:(LocationManager *)locationManager failedToDetectCurrentGPSLocation:(NSError *)error;
- (void)locationManager:(LocationManager *)locationManager detectedCurrentGPSLocation:(CLLocation *)currentLocation;

- (void)locationManager:(LocationManager *)locationManager failedToDefineCurrentLocation:(NSError *)error;
- (void)locationManager:(LocationManager *)locationManager definedCurrentLocation:(NSDictionary *)definedLocation;

@end



@interface LocationManager : NSObject

@property (weak, nonatomic) id<LocationManagerDelegate> delegate;

+ (instancetype)sharedInstance;
- (void)detectCurrentGPSLocation;
- (void)stopDetectingCurrentGPSLocation;

@end
