//
//  GeneticForecastServer.m
//  			
//
//  Created by Bogdan Laukhin on 4/5/17.
//  Copyright © 2017 Sequencing. All rights reserved.
//


#import "GeneticForecastServer.h"
#import "UserAccountHelper.h"
#import "ConstantsList.h"


@implementation GeneticForecastServer


+ (void)requestForGeneticForecastsArrayBasedOnAccessToken:(NSString *)accessToken
                                            vitaminDValue:(NSString *)vitaminDValue
                                        melanomaRiskValue:(NSString *)melanomaRiskValue
                                     forecastRequestArray:(NSArray *)forecastRequestArray
                                           withCompletion:(void (^)(NSArray *geneticForecastsArray))completion {
    
    NSLog(@"starting request for GeneticForecastsArray - Server");
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            accessToken, @"authToken",
                            vitaminDValue, @"vitaminD",
                            melanomaRiskValue, @"melanomaRisk",
                            forecastRequestArray, @"forecastRequest", nil];
    
    UserAccountHelper *userAccountHelper = [[UserAccountHelper alloc] init];
    [userAccountHelper retrieveGeneticForecastsArrayWithParameters:params withCompletion:^(NSArray *geneticForecastsArray) {
        
        NSLog(@"got geneticForecastsArray");
        // NSLog(@"geneticForecastsArray: %@", geneticForecastsArray);
        
        if (!geneticForecastsArray || [geneticForecastsArray count] == 0) {
            [self nofityAboutGeneticForecastsFailureWithDescription:@"Genetic Forecasts: empty genetic forecasts array"];
            completion(nil);
            return;
        }
        
        id item = geneticForecastsArray[0];
        if (![item isKindOfClass:[NSDictionary class]]) {
            [self nofityAboutGeneticForecastsFailureWithDescription:@"Genetic Forecasts: invalid format of genetic forecast for one day (not dictionary)"];
            completion(nil);
            return;
        }
        
        if ([[(NSDictionary *)item allKeys] count] == 0 ||
            ![[(NSDictionary *)item allKeys] containsObject:@"gtForecast"]) {
            [self nofityAboutGeneticForecastsFailureWithDescription:@"Genetic Forecasts: genetic forecast for one day is absent intelf"];
            completion(nil);
            return;
        }
        
        NSString *gtForecast = [(NSDictionary *)item objectForKey:@"gtForecast"];
        if (gtForecast != nil && [gtForecast length] != 0 )
            completion(geneticForecastsArray); // valid result
        
        else {
            [self nofityAboutGeneticForecastsFailureWithDescription:@"Genetic Forecasts: genetic forecast for one day is absent intelf"];
            completion(nil);
        }
    }];
}


+ (void)nofityAboutGeneticForecastsFailureWithDescription:(NSString *)description {
    //*
    //* post notification for appchains request finished with failure
    NSString *failureDescription = [NSString stringWithFormat:@"%@", description];
    NSDictionary *userInfoDict = @{dict_failureDescriptionKey: failureDescription};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:APPCHAINS_REQUEST_FAILED_NOTIFICATION_KEY object:nil userInfo:userInfoDict];
    //*
}


@end
