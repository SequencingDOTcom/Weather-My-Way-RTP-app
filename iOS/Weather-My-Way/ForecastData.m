//
//  ForecastData.m
//  Copyright © 2016 Sequencing. All rights reserved.
//


#import "ForecastData.h"
#import "UserHelper.h"
#import "GeneticForecastHelper.h"
#import "ForecastDayObject.h"


#define appGroupID  @"group.com.sequencing.weather-my-way-ios"



@implementation ForecastData

+ (instancetype)sharedInstance {
    static ForecastData *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ForecastData alloc] init];
    });
    return instance;
}



#pragma mark -
#pragma mark Setters

- (void)setForecast:(NSDictionary *)forecast {
    if (forecast != nil && [[forecast allKeys] containsObject:@"current_observation"] && [[forecast allKeys] containsObject:@"forecast"]) {
        _forecast = forecast;
        
        [self identifyWeatherType];
        [self identifyDayNight];
        [self identifyAlertIfPresent];
        [self pullWeatherTypesForAll10DaysAsObjects];
        [self overrideWeatherTypeBasedOnTypeFromArray];
        
    } else {
        NSLog(@"ForecastData: !Error: received forecast is invalid");
    }
}


- (void)setWeatherType:(NSString *)weatherType {
    _weatherType = weatherType;
}



#pragma mark -
#pragma mark Identify Weather Type

- (void)identifyWeatherType {
    NSString *weatherType;
    if (_forecast != nil) {
        if ([[[_forecast objectForKey:@"current_observation"] allKeys] containsObject:@"weather"]) {
            // get forecast from current observation section
            weatherType = [[_forecast objectForKey:@"current_observation"] objectForKey:@"weather"];
        }
        
        if ([weatherType length] != 0) {
            self.weatherType = [weatherType lowercaseString];
            NSLog(@"ForecastData: weatherType: %@", self.weatherType);
            
        } else { // get weather from forecastday[0]
            if ([[_forecast allKeys] containsObject:@"forecast"]) {
                NSDictionary *forecastDay0 = [[[[_forecast objectForKey:@"forecast"] objectForKey:@"simpleforecast"] objectForKey:@"forecastday"] objectAtIndex:0];
                
                if (forecastDay0 && [[forecastDay0 allKeys] containsObject:@"conditions"]) {
                    weatherType = [forecastDay0 objectForKey:@"conditions"];
                }
                
                if ([weatherType length] != 0) {
                    self.weatherType = [weatherType lowercaseString];
                    NSLog(@"ForecastData: weatherType: %@", self.weatherType);
                }
            }
        }
    } // forecast != nil
}


- (void)overrideWeatherTypeBasedOnTypeFromArray {
    if (self.forecastDayObjectsListFor10DaysArray != nil && [self.forecastDayObjectsListFor10DaysArray count] > 0) {
        ForecastDayObject *forecastDayObject = self.forecastDayObjectsListFor10DaysArray[0];
        if (forecastDayObject.weatherType && [forecastDayObject.weatherType length] != 0) {
            
            self.weatherType = [forecastDayObject.weatherType lowercaseString];
            NSLog(@"ForecastData: overridden weatherType: %@", self.weatherType);
        }
    }
}


- (void)pullWeatherTypesForAll10DaysAsObjects {
    if (_forecast != nil) {
        if ([[_forecast allKeys] containsObject:@"forecast"]) {
            self.forecastDayObjectsListFor10DaysArray = [[NSMutableArray alloc] init];
            NSArray *daysArray = [[[_forecast objectForKey:@"forecast"] objectForKey:@"simpleforecast"] objectForKey:@"forecastday"];
            int arrayCount = (int)[daysArray count];
            
            for (int index = 0; index < 10; index++) {
                NSString *weatherType;
                ForecastDayObject *forecastDayObject = [[ForecastDayObject alloc] init];
                
                if (index < arrayCount) {
                    NSDictionary *forecastDay = [[[[_forecast objectForKey:@"forecast"] objectForKey:@"simpleforecast"] objectForKey:@"forecastday"] objectAtIndex:index];
                    
                    if (forecastDay && [[forecastDay allKeys] containsObject:@"conditions"]) {
                        weatherType = [forecastDay objectForKey:@"conditions"];
                        forecastDayObject.weatherType = (NSString *)weatherType;
                    }
                    if (forecastDay && [[forecastDay allKeys] containsObject:@"date"]) {
                        forecastDayObject.date = [self prepareDateStringByDateDictionary:[forecastDay objectForKey:@"date"]];
                    } else {
                        forecastDayObject.date = @"nodate";
                    }
                    
                    if (index == 0 && self.alertType && [self.alertType length] != 0) {
                        forecastDayObject.alertType = self.alertType;
                    }
                }
                
                [self.forecastDayObjectsListFor10DaysArray addObject:forecastDayObject];
            }
        }
    }
}


- (NSString *)prepareDateStringByDateDictionary:(NSDictionary *)dayDictionary {
    NSString *dateString;
    if ([[dayDictionary allKeys] containsObject:@"month"] && [[dayDictionary allKeys] containsObject:@"day"] && [[dayDictionary allKeys] containsObject:@"year"]) {
        
        id monthRowValue = [dayDictionary objectForKey:@"month"];
        id dayRowValue   = [dayDictionary objectForKey:@"day"];
        id yearRowValue  = [dayDictionary objectForKey:@"year"];
        
        NSInteger monthValue = [monthRowValue integerValue];
        NSInteger dayValue   = [dayRowValue integerValue];
        NSInteger yearValue  = [yearRowValue integerValue];
        
        NSNumber *monthNumber = [NSNumber numberWithInteger:monthValue];
        NSNumber *dayNumber   = [NSNumber numberWithInteger:dayValue];
        NSNumber *yearNumber  = [NSNumber numberWithInteger:yearValue];
        
        NSString *month = [monthNumber stringValue];
        NSString *day   = [dayNumber stringValue];
        NSString *year  = [yearNumber stringValue];
        
        if ([month length] != 0 && [day length] != 0 && [year length] != 0) {
            dateString = [NSString stringWithFormat:@"%@.%@.%@", month, day, year];
        } else {
            dateString = @"";
        }
    }
    return dateString;
}




#pragma mark - Identify Day Night

- (void)identifyDayNight {
    NSString *dayNight;
    int sunriseHour = [self identifySunriseHour];
    int sunsetHour  = [self identifySunsetHour];
    
    if (_forecast != nil) {
        int hour;
        if ([[[_forecast objectForKey:@"current_observation"] allKeys] containsObject:@"local_time_rfc822"]) {
            NSString *time = [[_forecast objectForKey:@"current_observation"] objectForKey:@"local_time_rfc822"];
            NSRange rangeForColumn = [time rangeOfString:@":"];
            NSRange rangeForHour = NSMakeRange(rangeForColumn.location - 2, 2);
            NSString *hourRow = [time substringWithRange:rangeForHour];
            hour = [hourRow intValue];
        } else {
            hour = 10;
        }
        
        if (hour >= sunsetHour || hour < sunriseHour) {
            dayNight = @"night";
        } else {
            dayNight = @"day";
        }
    }
    
    if ([dayNight length] != 0) {
        _dayNight = dayNight;
        NSLog(@"ForecastData: dayNight: %@", _dayNight);
    } else {
        _dayNight = @"day";
    }
}


- (int)identifySunriseHour {
    int hour = 5;
    
    if (_forecast != nil) {
        if ([[_forecast allKeys] containsObject:@"sun_phase"]) {
            NSString *hourString = [[[_forecast objectForKey:@"sun_phase"] objectForKey:@"sunrise"] objectForKey:@"hour"];
            
            if ([hourString length] != 0) {
                hour = [hourString intValue];
            }
        }
    }
    return hour;
}


- (int)identifySunsetHour {
    int hour = 20;
    
    if (_forecast != nil) {
        if ([[_forecast allKeys] containsObject:@"sun_phase"]) {
            NSString *hourString = [[[_forecast objectForKey:@"sun_phase"] objectForKey:@"sunset"] objectForKey:@"hour"];
            
            if ([hourString length] != 0) {
                hour = [hourString intValue];
            }
        }
    }
    return hour;
}



#pragma mark -
#pragma mark Identify Alert

- (void)identifyAlertIfPresent {
    NSArray  *alertsArray;
    NSString *alertTypeCode;
    
    if ([[_forecast allKeys] containsObject:@"alerts"]) {
        alertsArray = [_forecast objectForKey:@"alerts"];
    }
    if (alertsArray && [alertsArray count] > 0) {
        alertTypeCode = [self identifyAlertTypeCode:[alertsArray lastObject]];
    }
    
    if ([alertTypeCode length] != 0) {
        // save alert type to property
        _alertType = alertTypeCode;
        
    } else {
        // otherwise remove old property value
        _alertType = nil;
    }
}

- (NSString *)identifyAlertTypeCode:(NSDictionary *)alertDict {
    NSString *alertCode;
    
    if ([[alertDict allKeys] containsObject:@"type"]) {
        if ([[alertDict objectForKey:@"type"] length] != 0) {
            
            alertCode = [alertDict objectForKey:@"type"];
        }
    }
    return alertCode;
}




#pragma mark -
#pragma mark Update Missing Location Details

- (void)updateCurrentLocationMissingDetails {
    if (self.forecast) {
        NSString *locationCity = [[[self.forecast objectForKey:@"current_observation"] objectForKey:@"display_location"] objectForKey:@"city"];
        NSString *locationStateOrCountry = [[[self.forecast objectForKey:@"current_observation"] objectForKey:@"display_location"] objectForKey:@"state_name"];
        NSString *locationID = [[_locationForForecast objectForKey:LOCATION_ID_DICT_KEY] copy];
        
        NSDictionary *currentUpdatedLocation = [NSDictionary dictionaryWithObjectsAndKeys:
                                                locationCity,           LOCATION_CITY_DICT_KEY,
                                                locationStateOrCountry, LOCATION_STATE_COUNTRY_DICT_KEY,
                                                locationID,             LOCATION_ID_DICT_KEY, nil];
        
        UserHelper *userHelper = [[UserHelper alloc] init];
        NSDictionary *currentLocation = [userHelper loadUserCurrentLocation];
        
        if ([[currentLocation objectForKey:LOCATION_CITY_DICT_KEY] length] == 0
            && [[currentLocation objectForKey:LOCATION_ID_DICT_KEY] isEqualToString:locationID]) {
            [userHelper saveUserCurrentLocation:[currentUpdatedLocation copy]];
        }
        
        if ([[self.locationForForecast objectForKey:LOCATION_CITY_DICT_KEY] length] == 0
            && [[self.locationForForecast objectForKey:LOCATION_ID_DICT_KEY] isEqualToString:locationID]) {
            self.locationForForecast = [currentUpdatedLocation copy];
        }
    }
}




#pragma mark -
#pragma mark Populate List Of Genetic Forecasts

- (void)populateDayObjectsWithGeneticForecasts:(NSArray *)geneticForecastsArray {
    if (geneticForecastsArray && [geneticForecastsArray count] > 0) {
        
        int internalArrayCount = (int)[self.forecastDayObjectsListFor10DaysArray count];
        int externalArrayCount = (int)[geneticForecastsArray count];
        
        for (int index = 0; index < 10; index++) {
            ForecastDayObject *forecastDayObject;
            
            if (index < internalArrayCount && index < externalArrayCount) {
                forecastDayObject = self.forecastDayObjectsListFor10DaysArray[index];
                NSString *geneticForecast = [geneticForecastsArray[index] objectForKey:@"gtForecast"];
                
                if ([geneticForecast length] != 0) {
                    forecastDayObject.geneticForecast = geneticForecast;
                }
            }
            if (forecastDayObject != nil) {
                [self.forecastDayObjectsListFor10DaysArray replaceObjectAtIndex:index withObject:forecastDayObject];
            }
        }
    }
}

@end
