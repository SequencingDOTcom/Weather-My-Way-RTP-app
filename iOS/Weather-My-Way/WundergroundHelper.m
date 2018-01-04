//
//  WundergroundHelper.m
//  Copyright © 2016 Sequencing. All rights reserved.
//


#import "WundergroundHelper.h"
#import "ConstantsList.h"

static NSString *WUNDERGROUND_KEY = @"";



@interface WundergroundHelper ()

@property (copy, nonatomic) CompletionBlock completionBlock;
@property (retain, nonatomic) NSString *locationID;
@property (assign, nonatomic) NSInteger tryIndex;
@property (assign, nonatomic) NSInteger sleepInterval;

@end




@implementation WundergroundHelper

#pragma mark - Geolookup request
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
                                                                             if (!jsonError) { // json parsed
                                                                                 NSString *locationID = [[parsedObject objectForKey:@"location"] objectForKey:@"l"];
                                                                                 NSString *locationCity = [[parsedObject objectForKey:@"location"] objectForKey:@"city"];
                                                                                 NSString *locationState = [[parsedObject objectForKey:@"location"] objectForKey:@"state"];
                                                                                 NSString *locationCountry = [[parsedObject objectForKey:@"location"] objectForKey:@"country_name"];
                                                                                 id locationIDID = locationID;
                                                                                 id locationCityID = locationCity;
                                                                                 id locationStateID = locationState;
                                                                                 id locationCountryID = locationCountry;
                                                                                 
                                                                                 if (locationID != nil && locationIDID != [NSNull null] &&
                                                                                     locationCity != nil && locationCityID != [NSNull null] &&
                                                                                     locationState != nil && locationStateID != [NSNull null] &&
                                                                                     locationCountry != nil && locationCountryID != [NSNull null]) {
                                                                                     
                                                                                     // return defined location city name
                                                                                     NSMutableDictionary *location = [NSMutableDictionary dictionary];
                                                                                     [location setValue:locationCity forKey:@"city"];
                                                                                     [location setValue:locationState forKey:@"state"];
                                                                                     [location setValue:locationCountry forKey:@"country"];
                                                                                     [location setValue:locationID forKey:@"id"];
                                                                                     
                                                                                     result([NSDictionary dictionaryWithDictionary:location]);
                                                                                     
                                                                                 } else { // json has no value
                                                                                     NSLog(@"WundergroundService json: city or cityID not found");
                                                                                     result(nil);
                                                                                 }
                                                                             } else { // json parsing error
                                                                                 NSLog(@"WundergroundService json error: %@", error.localizedDescription);
                                                                                 result(nil);
                                                                             }
                                                                         } else { // WundergroundService request error
                                                                             NSLog(@"%@", error.localizedDescription);
                                                                             result(nil);
                                                                         }
                                                                     }];
    [dataTask resume];
}



#pragma mark - AutoComplete request
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



#pragma mark - Forecast10day + Conditions request
- (void)wundergroundForecast10dayConditionsDefineByLocationID:(NSString *)locationID withResult:(CompletionBlock)result {
    self.completionBlock = result;
    self.locationID = locationID;
    self.tryIndex = 0;
    self.sleepInterval = 1;
    
    [self executeWundegroundAsyncRequestForForecast];
}


- (void)executeWundegroundAsyncRequestForForecast {
    //*
    //* post notification for weather forecast request start
    [[NSNotificationCenter defaultCenter] postNotificationName:WUNDERGROUND_FORECAST_REQUEST_STARTED_NOTIFICATION_KEY object:nil userInfo:nil];
    //*
    
    NSLog(@"the attempt number: %d", (int)self.tryIndex);
    
    NSString *urlString = [NSString stringWithFormat:@"https://api.wunderground.com/api/%@/forecast10day/conditions/astronomy/alerts%@.json", WUNDERGROUND_KEY, self.locationID];
    NSString *urlStringEncoded = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSLog(@"\n\n%@\n\n", urlStringEncoded);
    
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStringEncoded]];
    [request setHTTPMethod:@"GET"];
    [request setTimeoutInterval:15];
    [request setHTTPShouldHandleCookies:NO];
    
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                                         
                                                                         [self handleWundegroundForecastResponseData:data response:response error:error];
                                                                     }];
    [dataTask resume];
}


- (void)handleWundegroundForecastResponseData:(NSData *)data response:(NSURLResponse *)response error:(NSError *)error {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSInteger statusCode = [httpResponse statusCode];
    
    if (error) {
        [self failedToReceiveWeatherForecastWithResponse:response description:error.localizedDescription];
        return;
    }
    
    if (![VALID_STATUS_CODES containsObject:@(statusCode)]) {
        [self failedToReceiveWeatherForecastWithResponse:response description:nil];
        return;
    }
    
    if (!data) {
        [self failedToReceiveWeatherForecastWithResponse:response description:nil];
        return;
    }
    
    NSError *jsonError;
    NSData *jsonData = data;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&jsonError];
    
    if (jsonError) {
        [self failedToReceiveWeatherForecastWithResponse:response description:jsonError.localizedDescription];
        return;
    }
    
    if (![self isForecastJsonValid:parsedObject]) {
        [self failedToReceiveWeatherForecastWithResponse:response description:@"Invalid JSON from Wunderground weather forecast request"];
        return;
    }
    
    // returned valid request result
    
    //*
    //* post notification for weather forecast request finished successfully
    [[NSNotificationCenter defaultCenter] postNotificationName:WUNDERGROUND_FORECAST_REQUEST_FINISHED_NOTIFICATION_KEY object:nil userInfo:nil];
    //*
    
    self.completionBlock(parsedObject);
}


- (void)failedToReceiveWeatherForecastWithResponse:(NSURLResponse *)response description:(NSString *)description {
    //*
    //* post notification for weather forecast request finished with failure
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSInteger statusCode = [httpResponse statusCode];
    
    NSString *failureDescription = [NSString stringWithFormat:@"Status code %d. %@. Try #%d", (int)statusCode, description, (int)(self.tryIndex + 1)];
    NSDictionary *userInfoDict = @{dict_failureDescriptionKey: failureDescription};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:WUNDERGROUND_FORECAST_REQUEST_FAILED_NOTIFICATION_KEY object:nil userInfo:userInfoDict];
    //*
    
    if (self.tryIndex < 3) {
        self.sleepInterval = self.sleepInterval + self.tryIndex;
        sleep((int)self.sleepInterval);
        self.tryIndex++;
        [self executeWundegroundAsyncRequestForForecast];
        
    } else {
        self.completionBlock(nil);
    }
}


- (BOOL)isForecastJsonValid:(NSDictionary *)forecastJson {
    BOOL validationResult = NO;
    
    NSArray *allKeys = [forecastJson allKeys];
    if ([allKeys containsObject:@"current_observation"] &
        [allKeys containsObject:@"forecast"] &
        [allKeys containsObject:@"sun_phase"]) {
        
        // validate "current_observation" section
        NSDictionary *current_observation = [forecastJson objectForKey:@"current_observation"];
        NSArray *current_observationAllKeys = [current_observation allKeys];
        if ([current_observationAllKeys containsObject:@"display_location"] &
            [current_observationAllKeys containsObject:@"observation_location"] &
            [current_observationAllKeys containsObject:@"local_time_rfc822"] &
            [current_observationAllKeys containsObject:@"temp_f"] &
            [current_observationAllKeys containsObject:@"temp_c"] &
            [current_observationAllKeys containsObject:@"weather"] &
            [current_observationAllKeys containsObject:@"wind_dir"] &
            [current_observationAllKeys containsObject:@"wind_kph"] &
            [current_observationAllKeys containsObject:@"wind_mph"] &
            [current_observationAllKeys containsObject:@"relative_humidity"] &
            [current_observationAllKeys containsObject:@"icon"]) {
            
            // validate "forecast" section
            NSDictionary *forecast = [forecastJson objectForKey:@"forecast"];
            NSArray *forecastAllKeys = [forecast allKeys];
            if ([forecastAllKeys containsObject:@"txt_forecast"] &
                [forecastAllKeys containsObject:@"simpleforecast"]) {
                
                // validate "txt_forecast" subsection in "forecast" section
                NSDictionary *txt_forecast = [forecast objectForKey:@"txt_forecast"];
                NSArray *txt_forecastAllKeys = [txt_forecast allKeys];
                if ([txt_forecastAllKeys containsObject:@"forecastday"]) {
                    
                    id txt_forecastForecastday = [txt_forecast objectForKey:@"forecastday"];
                    if ([txt_forecastForecastday isKindOfClass:[NSArray class]]) {
                        
                        int numberOfDays = (int)[(NSArray *)txt_forecastForecastday count];
                        if (numberOfDays == 20) {
                            
                            // validate "simpleforecast" subsection in "forecast" section
                            NSDictionary *simpleforecast = [forecast objectForKey:@"simpleforecast"];
                            NSArray *simpleforecastAllKeys = [simpleforecast allKeys];
                            if ([simpleforecastAllKeys containsObject:@"forecastday"]) {
                                
                                id simpleforecastForecastday = [simpleforecast objectForKey:@"forecastday"];
                                if ([simpleforecastForecastday isKindOfClass:[NSArray class]]) {
                                    
                                    int numberOfDays = (int)[(NSArray *)simpleforecastForecastday count];
                                    if (numberOfDays == 10) {
                                        
                                        NSLog(@">>> Wunderground: weather forecast json is valid <<<");
                                        validationResult = YES;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    return validationResult;
}




#pragma mark - Conditions FOR GPS point request
- (void)wundergroundConditionsForGPSLocation:(CLLocation *)location withResult:(CompletionBlock)result {
    if (!location) {
        result(nil);
        return;
    }
    
    self.completionBlock = result;
    NSString *urlString = [NSString stringWithFormat:@"https://api.wunderground.com/api/%@/conditions/q/%f,%f.json", WUNDERGROUND_KEY, location.coordinate.latitude, location.coordinate.longitude];
    NSString *urlStringEncoded = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStringEncoded]];
    [request setHTTPMethod:@"GET"];
    [request setTimeoutInterval:20];
    [request setHTTPShouldHandleCookies:NO];
    
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                                         [self handleWundegroundConditionsResponseData:data response:response error:error];
                                                                     }];
    [dataTask resume];
}


- (void)wundergroundConditionsForLocationID:(NSString *)locationID withResult:(CompletionBlock)result {
    if (!locationID || [locationID length] == 0) {
        result(nil);
        return;
    }
    
    self.completionBlock = result;
    NSString *urlString = [NSString stringWithFormat:@"https://api.wunderground.com/api/%@/conditions%@.json", WUNDERGROUND_KEY, locationID];
    NSString *urlStringEncoded = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStringEncoded]];
    [request setHTTPMethod:@"GET"];
    [request setTimeoutInterval:20];
    [request setHTTPShouldHandleCookies:NO];
    
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                                         [self handleWundegroundConditionsResponseData:data response:response error:error];
                                                                     }];
    [dataTask resume];
}



- (void)handleWundegroundConditionsResponseData:(NSData *)data response:(NSURLResponse *)response error:(NSError *)error {
    if (error) {
        self.completionBlock(nil);
        return;
    }
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSInteger statusCode = [httpResponse statusCode];
    if (![VALID_STATUS_CODES containsObject:@(statusCode)]) {
        self.completionBlock(nil);
        return;
    }
    
    if (!data) {
        self.completionBlock(nil);
        return;
    }
    
    NSError *jsonError;
    NSData *jsonData = data;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&jsonError];
    if (jsonError) {
        self.completionBlock(nil);
        return;
    }
    
    if (![self isConditionsJsonValid:parsedObject]) {
        self.completionBlock(nil);
        return;
    }
    
    self.completionBlock(parsedObject);
}


- (BOOL)isConditionsJsonValid:(NSDictionary *)forecastJson {
    NSArray *allKeys = [forecastJson allKeys];
    if (![allKeys containsObject:@"current_observation"]) return NO;
    
    // validate "current_observation" section
    NSDictionary *current_observation = [forecastJson objectForKey:@"current_observation"];
    NSArray *current_observationAllKeys = [current_observation allKeys];
    if (![current_observationAllKeys containsObject:@"temp_f"] || ![current_observationAllKeys containsObject:@"temp_c"])
        return NO;
    else
        return YES;
}


@end
