//
//  GeneticForecastHelper.m
//  Copyright © 2016 Sequencing. All rights reserved.
//


#import "GeneticForecastHelper.h"
#import "AppChains.h"
#import "CSVParser.h"
#import "ForecastData.h"
#import "ForecastDayObject.h"
#import "UserAccountHelper.h"



@interface GeneticForecastHelper ()

@property (strong, nonatomic) NSMutableArray *csvFileParsed;

@end



@implementation GeneticForecastHelper


#pragma mark -
#pragma mark Initialazer / Setter

- (instancetype)sharedInstance {
    static GeneticForecastHelper *instance = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [[GeneticForecastHelper alloc] init];
    });
    
    return instance;
}



#pragma mark -
#pragma mark Genetic Forecast array request

- (void)requestForGeneticForecastsWithToken:(NSString *)accessToken
                             withCompletion:(void (^)(NSArray *geneticForecastsArray))completion {
    NSLog(@"[Genetic forecast helper] requestForArrayOfGeneticForecasts");
    
    ForecastData *forecastContainer = [[ForecastData alloc] sharedInstance];
    NSString *vitaminDValue = forecastContainer.vitaminDValue;
    NSString *melanomaRiskValue = forecastContainer.melanomaRiskValue;
    NSArray *arrayOfForecastRequest = [self prepareArrayForForecastRequestBasedOnForecastDayObjects:forecastContainer.forecastDayObjectsListFor10DaysArray
                                                                                       andAlertType:forecastContainer.alertType];
    
    if (accessToken && vitaminDValue && melanomaRiskValue && arrayOfForecastRequest) {
        [self requestForGeneticForecastsArrayBasedOnAccessToken:accessToken
                                                  vitaminDValue:vitaminDValue
                                              melanomaRiskValue:melanomaRiskValue
                                           forecastRequestArray:arrayOfForecastRequest
                                                 withCompletion:^(NSArray *geneticForecastsArray) {
                                                     
                                                     if (geneticForecastsArray && [geneticForecastsArray count] > 0) {
                                                         completion(geneticForecastsArray);
                                                     } else {
                                                         completion(nil);
                                                     }
                                                 }];
    } else {
        completion(nil);
    }
}


- (NSArray *)prepareArrayForForecastRequestBasedOnForecastDayObjects:(NSArray *)forecastDayObjects10DaysArray andAlertType:(NSString *)alertType {
    NSMutableArray *rawPreparedArray = [[NSMutableArray alloc] init];
    
    for (int index = 0; index < [forecastDayObjects10DaysArray count]; index++) {
        
        ForecastDayObject *forecastDayObject = (ForecastDayObject *)forecastDayObjects10DaysArray[index];
        NSMutableDictionary *rawDict = [[NSMutableDictionary alloc] init];
        
        [rawDict setObject:forecastDayObject.date forKey:@"date"];
        [rawDict setObject:forecastDayObject.weatherType forKey:@"weather"];
        if (index == 0 && forecastDayObject.alertType && [forecastDayObject.alertType length] != 0) {
            [rawDict setObject:forecastDayObject.alertType forKey:@"alertCode"];
        } else {
            [rawDict setObject:@"--" forKey:@"alertCode"];
        }
        
        [rawPreparedArray addObject:[NSDictionary dictionaryWithDictionary:rawDict]];
    }
    
    return [NSArray arrayWithArray:rawPreparedArray];
}


- (void)requestForGeneticForecastsArrayBasedOnAccessToken:(NSString *)accessToken
                                            vitaminDValue:(NSString *)vitaminDValue
                                        melanomaRiskValue:(NSString *)melanomaRiskValue
                                     forecastRequestArray:(NSArray *)forecastRequestArray
                                           withCompletion:(void (^)(NSArray *geneticForecastsArray))completion {
    NSLog(@"[Genetic forecast helper] starting request for GeneticForecastsArray");
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            accessToken, @"authToken",
                            vitaminDValue, @"vitaminD",
                            melanomaRiskValue, @"melanomaRisk",
                            forecastRequestArray, @"forecastRequest", nil];
    
    UserAccountHelper *userAccountHelper = [[UserAccountHelper alloc] init];
    [userAccountHelper retrieveGeneticForecastsArrayWithParameters:params withCompletion:^(NSArray *geneticForecastsArray) {
        
        if (geneticForecastsArray && [geneticForecastsArray count] > 0) {
            id item = geneticForecastsArray[0];
            if ([item isKindOfClass:[NSDictionary class]]) {
                if ([[(NSDictionary *)item allKeys] count] > 0 && [[(NSDictionary *)item allKeys] containsObject:@"gtForecast"])  {
                    NSString *gtForecast = [(NSDictionary *)item objectForKey:@"gtForecast"];
                    
                    if (gtForecast != nil && [gtForecast length] != 0 ) {   // valid result
                        completion(geneticForecastsArray);
                        
                    } else {
                        completion(nil);
                    }
                } else {
                    completion(nil);
                }
            } else {
                completion(nil);
            }
        } else {
            completion(nil);
        }
    }];
}



#pragma mark -
#pragma mark Genetic Forecast methods

- (void)requestForGeneticDataForFileID:(NSString *)fileID
                           accessToken:(NSString *)accessToken
                        withCompletion:(void (^)(BOOL success))completion {
    NSLog(@"[Genetic forecast helper] requestForGeneticParameters");
    
    if ([fileID length] != 0 && [accessToken length] != 0) {
        [self requestForAppChainsBasedOnFileID:fileID
                                   accessToken:accessToken
                                withCompletion:^(NSDictionary *geneticPrameters) {
                                    
                                    if (geneticPrameters &&
                                        [[geneticPrameters allKeys] containsObject:@"vitaminDValue"] && [[geneticPrameters allKeys] containsObject:@"riskValue"]) {
                                        
                                        self.vitaminDValue = [geneticPrameters objectForKey:@"vitaminDValue"];
                                        self.melanomaRiskValue = [geneticPrameters objectForKey:@"riskValue"];
                                        completion(YES);
                                        
                                    } else {
                                        completion(NO);
                                    }
                                }];
    } else {
        completion(NO);
    }
}



- (void)requestForAppChainsBasedOnFileID:(NSString *)fileID
                             accessToken:(NSString *)accessToken
                          withCompletion:(void (^)(NSDictionary *geneticPrameters))completion {
    [self requestForChain88BasedOnFileID:fileID
                             accessToken:accessToken
                          withCompletion:^(NSString *vitaminDValue) {
                              
                              if ([vitaminDValue length] != 0) {
                                  
                                  [self requestForChain9BasedOnFileID:fileID
                                                          accessToken:accessToken
                                                       withCompletion:^(NSString *melanomaRiskValue) {
                                                           
                                                           if (vitaminDValue && melanomaRiskValue) {
                                                               
                                                               NSDictionary *parameters = @{@"vitaminDValue": vitaminDValue,
                                                                                            @"riskValue":     melanomaRiskValue};
                                                               completion(parameters);
                                                               
                                                           } else {
                                                               NSLog(@"[chains9 error] melanomaRiskValue is absent");
                                                               completion(nil);
                                                           }
                                                       }]; // end of request for chain9
                              } else {
                                  NSLog(@"[chains88 error] vitaminDValue is absent");
                                  completion(nil);
                              }
                          }]; // end of request for chain88
}



- (void)requestForChain88BasedOnFileID:(NSString *)fileID
                           accessToken:(NSString *)accessToken
                        withCompletion:(void (^)(NSString *vitaminDValue))completion {
    NSLog(@"starting request for chains88: vitaminDValue");
    
    AppChains *appChains = [[AppChains alloc] initWithToken:accessToken withHostName:@"api.sequencing.com"];
    
    [appChains getReportWithRemoteMethodName:@"StartApp"
                   withApplicationMethodName:@"Chain88"
                            withDatasourceId:fileID
                            withSuccessBlock:^(Report *result) {
                                if ([result isSucceeded]) {
                                    
                                    NSString *vitaminDKey = @"result";
                                    NSString *vitaminDValue;
                                    
                                    for (Result *obj in [result getResults]) {
                                        ResultValue *frv = [obj getValue];
                                        
                                        if ([frv getType] == kResultTypeText) {
                                            
                                            NSLog(@"\nfrv %@=%@\n", [obj getName], [(TextResultValue *)frv getData]);
                                            
                                            if ([[obj getName] isEqualToString:vitaminDKey]) {
                                                NSString *vitaminDRawValue = [(TextResultValue *)frv getData];
                                                
                                                if ([vitaminDRawValue length] != 0) {
                                                    if ([vitaminDRawValue isEqualToString:@"no"]) {
                                                        vitaminDValue = @"False";
                                                    } else {
                                                        vitaminDValue = @"True";
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    
                                    if (vitaminDValue && [vitaminDValue length] != 0) {
                                        completion(vitaminDValue);
                                        
                                    } else {
                                        completion(nil);
                                    }
                                } else {
                                    completion(nil);
                                }
                            }
                            withFailureBlock:^(NSError *error) {
                                if (error) {
                                    NSLog(@"[appChain88 Error] %@", error);
                                    completion(nil);
                                } else {
                                    completion(nil);
                                }
                            }];
}



- (void)requestForChain9BasedOnFileID:(NSString *)fileID
                          accessToken:(NSString *)accessToken
                       withCompletion:(void (^)(NSString *melanomaRiskValue))completion {
    NSLog(@"starting request for chains9: melanomaRiskValue");
    
    AppChains *appChains = [[AppChains alloc] initWithToken:accessToken withHostName:@"api.sequencing.com"];
    
    [appChains getReportWithRemoteMethodName:@"StartApp"
                   withApplicationMethodName:@"Chain9"
                            withDatasourceId:fileID
                            withSuccessBlock:^(Report *result) {
                                if ([result isSucceeded]) {
                                    
                                    NSString *riskKey = @"RiskDescription";
                                    NSString *riskValue;
                                    
                                    for (Result *obj in [result getResults]) {
                                        ResultValue *frv = [obj getValue];
                                        
                                        if ([frv getType] == kResultTypeText) {
                                            
                                            NSLog(@"\nfrv %@=%@\n", [obj getName], [(TextResultValue *)frv getData]);
                                            
                                            if ([[obj getName] isEqualToString:riskKey]) {
                                                riskValue = [(TextResultValue *)frv getData];
                                            }
                                        }
                                    }
                                    
                                    if (riskValue && [riskValue length] != 0) {
                                        completion(riskValue);
                                        
                                    } else {
                                        NSLog(@"appChains error: Result is empty");
                                        completion(nil);
                                    }
                                } else {
                                    NSLog(@"appChains error: Result is empty");
                                    completion(nil);
                                }
                            }
                            withFailureBlock:^(NSError *error) {
                                if (error) {
                                    NSLog(@"appChains error: %@", error);
                                    completion(nil);
                                }
                            }];
}




@end
