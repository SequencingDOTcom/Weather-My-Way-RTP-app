//
//  WundergroundHelper.m
//  Copyright © 2016 Sequencing. All rights reserved.
//


#import "WundergroundHelper.h"

static NSString *WUNDERGROUND_KEY = @"WUNDERGROUND_KEY";    // specify here your WUNDERGROUND_KEY


@implementation WundergroundHelper

#pragma mark -
#pragma mark Geolookup request

- (void)wundergroundGeolookupDefineLocationDetailsBasedOnLocationCoordinates:(CLLocation *)location withResult:(void (^)(NSDictionary *location))result {
    NSLog(@"\nWunderground Geolookup request");
    
    NSString *urlString = [NSString stringWithFormat:@"https://api.wunderground.com/api/%@/geolookup/q/%f,%f.json", WUNDERGROUND_KEY, location.coordinate.latitude, location.coordinate.longitude];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"GET"];
    [request setTimeoutInterval:15];
    [request setHTTPShouldHandleCookies:NO];
    
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                                         
                                                                         if (data && response && error == nil) {
                                                                             NSError *jsonError;
                                                                             NSData *jsonData = data;
                                                                             NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                                                                                          options:0
                                                                                                                                            error:&jsonError];
                                                                             if (!jsonError) {
                                                                                 // json parsed
                                                                                 NSString *locationCity = [[parsedObject objectForKey:@"location"] objectForKey:@"city"];
                                                                                 NSString *locationState = [[parsedObject objectForKey:@"location"] objectForKey:@"state"];
                                                                                 NSString *locationCountry = [[parsedObject objectForKey:@"location"] objectForKey:@"country_name"];
                                                                                 NSString *locationID = [[parsedObject objectForKey:@"location"] objectForKey:@"l"];
                                                                                 
                                                                                 if ([locationCity length] != 0 && [locationID length] != 0) {
                                                                                     // return defined location city name
                                                                                     NSMutableDictionary *location = [NSMutableDictionary dictionary];
                                                                                     [location setValue:locationCity forKey:@"city"];
                                                                                     [location setValue:locationState forKey:@"state"];
                                                                                     [location setValue:locationCountry forKey:@"country"];
                                                                                     [location setValue:locationID forKey:@"id"];
                                                                                     
                                                                                     result([NSDictionary dictionaryWithDictionary:location]);
                                                                                     
                                                                                 } else {
                                                                                     // json has no value
                                                                                     NSLog(@"WundergroundService json: city or cityID not found");
                                                                                     result(nil);
                                                                                 }
                                                                             } else {
                                                                                 // json parsing error
                                                                                 NSLog(@"WundergroundService json error: %@", error.localizedDescription);
                                                                                 result(nil);
                                                                             }
                                                                         } else {
                                                                             // WundergroundService request error
                                                                             NSLog(@"%@", error.localizedDescription);
                                                                             result(nil);
                                                                         }
                                                                     }];
    [dataTask resume];
}



#pragma mark -
#pragma mark AutoComplete request

- (void)wundergroundAutoCompleteValidateProvidedCity:(NSString *)city withResult:(void (^)(NSArray *locations))result {
    NSLog(@"\nWunderground AutoComplete request");
    NSString *urlString = [NSString stringWithFormat:@"http://autocomplete.wunderground.com/aq?query=%@&cities=1", city];
    NSString *urlStringEncoded = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStringEncoded]];
    [request setHTTPMethod:@"GET"];
    [request setTimeoutInterval:15];
    [request setHTTPShouldHandleCookies:NO];
    [request setValue:@"en-us" forHTTPHeaderField:@"Accept-Language"];
    
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                                         
                                                                         if (data && response && error == nil) {
                                                                             NSError *jsonError;
                                                                             NSData *jsonData = data;
                                                                             NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                                                                                          options:0
                                                                                                                                            error:&jsonError];
                                                                             if (!jsonError) {
                                                                                 // json parsed
                                                                                 if ([parsedObject objectForKey:@"RESULTS"]) {
                                                                                     // return validated city/cities
                                                                                     NSArray *array = [parsedObject objectForKey:@"RESULTS"];
                                                                                     result(array);
                                                                                     
                                                                                 } else {
                                                                                     // json has no value
                                                                                     NSLog(@"WundergroundService json: results not found");
                                                                                     result(nil);
                                                                                 }
                                                                             } else {
                                                                                 // json parsing error
                                                                                 NSLog(@"WundergroundService json error: %@", error.localizedDescription);
                                                                                 result(nil);
                                                                             }
                                                                         } else {
                                                                             // WundergroundService request error
                                                                             NSLog(@"%@", error.localizedDescription);
                                                                             result(nil);
                                                                         }
                                                                     }];
    [dataTask resume];
}



#pragma mark -
#pragma mark Conditions request

- (void)wundergroundConditionsDefineLocationConditionsBasedOnLocationID:(NSString *)locationID withResult:(void (^)(NSDictionary *conditions))result {
    NSLog(@"\nWunderground Conditions request");
    
    NSString *urlString = [NSString stringWithFormat:@"https://api.wunderground.com/api/%@/conditions%@.json", WUNDERGROUND_KEY, locationID];
    
    NSString *urlStringEncoded = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStringEncoded]];
    [request setHTTPMethod:@"GET"];
    [request setTimeoutInterval:15];
    [request setHTTPShouldHandleCookies:NO];
    
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                                         
                                                                         if (data && response && error == nil) {
                                                                             NSError *jsonError;
                                                                             NSData *jsonData = data;
                                                                             NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                                                                                          options:0
                                                                                                                                            error:&jsonError];
                                                                             if (!jsonError) {
                                                                                 // json parsed
                                                                                 if ([parsedObject objectForKey:@"current_observation"]) {
                                                                                     // return validated city/cities
                                                                                     NSDictionary *conditions = [parsedObject objectForKey:@"current_observation"];
                                                                                     result(conditions);
                                                                                     
                                                                                 } else {
                                                                                     // json has no value
                                                                                     NSLog(@"WundergroundService json: results not found");
                                                                                     result(nil);
                                                                                 }
                                                                             } else {
                                                                                 // json parsing error
                                                                                 NSLog(@"WundergroundService json error: %@", error.localizedDescription);
                                                                                 result(nil);
                                                                             }
                                                                         } else {
                                                                             // WundergroundService request error
                                                                             NSLog(@"%@", error.localizedDescription);
                                                                             result(nil);
                                                                         }
                                                                     }];
    [dataTask resume];
}



#pragma mark -
#pragma mark Forecast10day + Conditions request

- (void)wundergroundForecast10dayConditionsDefineByLocationID:(NSString *)locationID withResult:(void (^)(NSDictionary *forecast))result {
    NSLog(@"\nWunderground Forecast10day + Conditions request");
    
    NSString *urlString = [NSString stringWithFormat:@"https://api.wunderground.com/api/%@/forecast10day/conditions/astronomy/alerts%@.json", WUNDERGROUND_KEY, locationID];
    
    NSString *urlStringEncoded = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStringEncoded]];
    [request setHTTPMethod:@"GET"];
    [request setTimeoutInterval:15];
    [request setHTTPShouldHandleCookies:NO];
    
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                                         
                                                                         if (data && response && error == nil) {
                                                                             NSError *jsonError;
                                                                             NSData *jsonData = data;
                                                                             NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                                                                                          options:0
                                                                                                                                            error:&jsonError];
                                                                             if (!jsonError) {
                                                                                 // json parsed
                                                                                 if ([parsedObject objectForKey:@"current_observation"] && [parsedObject objectForKey:@"forecast"]) {
                                                                                     // return valid request result
                                                                                     result(parsedObject);
                                                                                     
                                                                                 } else {
                                                                                     // json has no value
                                                                                     NSLog(@"WundergroundService json: results not found");
                                                                                     result(nil);
                                                                                 }
                                                                             } else {
                                                                                 // json parsing error
                                                                                 NSLog(@"WundergroundService json error: %@", error.localizedDescription);
                                                                                 result(nil);
                                                                             }
                                                                         } else {
                                                                             // WundergroundService request error
                                                                             NSLog(@"%@", error.localizedDescription);
                                                                             result(nil);
                                                                         }
                                                                     }];
    [dataTask resume];
}



@end
