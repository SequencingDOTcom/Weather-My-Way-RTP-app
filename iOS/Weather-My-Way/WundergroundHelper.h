//
//  WundergroundHelper.h
//  Copyright © 2016 Sequencing. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


typedef void(^CompletionBlock)(NSDictionary *response);


@interface WundergroundHelper : NSObject

// geolookup method - revert gps point into location details
- (void)wundergroundGeolookupDefineLocationDetailsBasedOnLocationCoordinates:(CLLocation *)location withResult:(void (^)(NSDictionary *location))result;

// autoComplete method - validate provided city - returns 1 result or several is variations available
- (void)wundergroundAutoCompleteValidateProvidedCity:(NSString *)city withResult:(void (^)(NSArray *locations))result;

// forecast10day + conditions
- (void)wundergroundForecast10dayConditionsDefineByLocationID:(NSString *)locationID withResult:(CompletionBlock)result;

// conditions for GPS location
- (void)wundergroundConditionsForGPSLocation:(CLLocation *)location withResult:(CompletionBlock)result;
- (void)wundergroundConditionsForLocationID:(NSString *)locationID  withResult:(CompletionBlock)result;

@end
