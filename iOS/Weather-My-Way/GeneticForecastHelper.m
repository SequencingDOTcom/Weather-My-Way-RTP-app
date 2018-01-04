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
#import "GeneticForecastServer.h"
#import "GeneticForecastCSV.h"
#import "ConstantsList.h"


#define csvFileName @"recs.csv"



@implementation GeneticForecastHelper

#pragma mark - Initialazer / Setter

+ (instancetype)sharedInstance {
    static GeneticForecastHelper *instance = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [[GeneticForecastHelper alloc] init];
    });
    
    return instance;
}



#pragma mark - Genetic Forecast array request

- (void)requestForGeneticForecastsWithToken:(NSString *)accessToken
                             withCompletion:(void (^)(NSArray *geneticForecastsArray))completion {
    ForecastData *forecastContainer = [ForecastData sharedInstance];
    NSString *vitaminDValue = forecastContainer.vitaminDValue;
    NSString *melanomaRiskValue = forecastContainer.melanomaRiskValue;
    NSArray *arrayOfForecastRequest = [self prepareArrayForForecastRequestBasedOnForecastDayObjects:forecastContainer.forecastDayObjectsListFor10DaysArray
                                                                                       andAlertType:forecastContainer.alertType];
    
    if (accessToken && vitaminDValue && melanomaRiskValue && arrayOfForecastRequest) {
        
        // genetic forecast - use the server implementation
        [GeneticForecastServer requestForGeneticForecastsArrayBasedOnAccessToken:accessToken
                                                                   vitaminDValue:vitaminDValue
                                                               melanomaRiskValue:melanomaRiskValue
                                                            forecastRequestArray:arrayOfForecastRequest
                                                                  withCompletion:^(NSArray *geneticForecastsArray) {
                                                                      
                                                                      //*
                                                                      //* post notification for appchains request finished successfully
                                                                      [[NSNotificationCenter defaultCenter] postNotificationName:APPCHAINS_REQUEST_FINISHED_NOTIFICATION_KEY object:nil userInfo:nil];
                                                                      //*
                                                                      
                                                                      completion(geneticForecastsArray);
                                                                  }];
        
        // genetic forecast - use the csv implementation
        /*
        GeneticForecastCSV *gtForecastCSV = [GeneticForecastCSV sharedInstance];
        [gtForecastCSV requestForGeneticForecastsArrayBasedOnAccessToken:nil
                                                           vitaminDValue:vitaminDValue
                                                       melanomaRiskValue:melanomaRiskValue
                                                    forecastRequestArray:arrayOfForecastRequest
                                                          withCompletion:^(NSArray *geneticForecastsArray) {
                                                              
                                                              completion(geneticForecastsArray);
                                                          }];*/
    } else completion(nil);
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





#pragma mark - Genetic Forecast methods

- (void)requestForGeneticDataForFileID:(NSString *)fileID
                           accessToken:(NSString *)accessToken
                        withCompletion:(void (^)(BOOL success))completion {
    NSLog(@">>>>> GeneticForecastHelper requestForGeneticParameters");
    if ([fileID length] != 0 && [accessToken length] != 0) {
        
        //*
        //* post notification for appchains request start
        [[NSNotificationCenter defaultCenter] postNotificationName:APPCHAINS_REQUEST_STARTED_NOTIFICATION_KEY object:nil userInfo:nil];
        //*
        
        [self requestForAppChainsBasedOnFileID:fileID
                                   accessToken:accessToken
                                withCompletion:^(NSDictionary *geneticPrameters) {
                                    
                                    if (geneticPrameters &&
                                        [[geneticPrameters allKeys] containsObject:@"vitaminDValue"] &&
                                        [[geneticPrameters allKeys] containsObject:@"riskValue"]) {
                                        
                                        self.vitaminDValue = [geneticPrameters objectForKey:@"vitaminDValue"];
                                        self.melanomaRiskValue = [geneticPrameters objectForKey:@"riskValue"];
                                        completion(YES);
                                        
                                    } else {
                                        //*
                                        //* post notification for appchains request finished with failure
                                        NSString *failureDescription = [NSString stringWithFormat:@"%@", @"Empty genetic file appchains information"];
                                        NSDictionary *userInfoDict = @{dict_failureDescriptionKey: failureDescription};
                                        [[NSNotificationCenter defaultCenter] postNotificationName:APPCHAINS_REQUEST_FAILED_NOTIFICATION_KEY object:nil userInfo:userInfoDict];
                                        //*
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
    NSLog(@">>>>> GeneticForecastHelper: requestForAppChainsBasedOnFileID");
    AppChains *appChains = [[AppChains alloc] initWithToken:accessToken withHostName:@"api.sequencing.com"];
    
    NSArray *appChainsForRequest = @[@[@"Chain88", fileID],
                                     @[@"Chain9",  fileID]];
    
    [appChains getBatchReportWithApplicationMethodName:appChainsForRequest
                                      withSuccessBlock:^(NSArray *reportResultsArray) {
                                          
                                          NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
                                          
                                          for (NSDictionary *appChainReportDict in reportResultsArray) {
                                              
                                              Report *result = [appChainReportDict objectForKey:@"report"];
                                              NSString *appChainID = [appChainReportDict objectForKey:@"appChainID"];
                                              NSString *appChainValue = [NSString stringWithFormat:@""];
                                              
                                              if ([appChainID isEqualToString:@"Chain88"]) {
                                                  
                                                  appChainValue = [self parseReportForChain88:result];
                                                  if ([appChainValue length] > 0)
                                                      [parameters setObject:appChainValue forKey:@"vitaminDValue"];
                                                  else
                                                      [parameters setObject:@"" forKey:@"vitaminDValue"];
                                                  
                                                  
                                              } else if ([appChainID isEqualToString:@"Chain9"]) {
                                                  
                                                  appChainValue = [self parseReportForChain9:result];
                                                  if ([appChainValue length] > 0)
                                                      [parameters setObject:appChainValue forKey:@"riskValue"];
                                                  else
                                                      [parameters setObject:@"" forKey:@"riskValue"];
                                              }
                                          }
                                          completion([NSDictionary dictionaryWithDictionary:parameters]);
                                          
                                      }
                                      withFailureBlock:^(NSError *error) {
                                          //*
                                          //* post notification for appchains request finished with failure
                                          NSString *failureDescription = [NSString stringWithFormat:@"%@", error.localizedDescription];
                                          NSDictionary *userInfoDict = @{dict_failureDescriptionKey: failureDescription};
                                          [[NSNotificationCenter defaultCenter] postNotificationName:APPCHAINS_REQUEST_FAILED_NOTIFICATION_KEY object:nil userInfo:userInfoDict];
                                          //*
                                          
                                          NSLog(@"batch request error: %@", error);
                                          completion(nil);
                                      }];
    
    // protocol v1
    /*
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
                          }]; // end of request for chain88 */
}



- (void)requestForChain88BasedOnFileID:(NSString *)fileID
                           accessToken:(NSString *)accessToken
                        withCompletion:(void (^)(NSString *vitaminDValue))completion {
    NSLog(@"starting request for chains88: vitaminDValue");
    AppChains *appChains = [[AppChains alloc] initWithToken:accessToken withHostName:@"api.sequencing.com"];
    
    [appChains getReportWithApplicationMethodName:@"Chain88"
                                 withDatasourceId:fileID
                                 withSuccessBlock:^(Report *result) {
                                     
                                     completion([self parseReportForChain88:result]);
                                 }
                                 withFailureBlock:^(NSError *error) {
                                     if (error) {
                                         NSLog(@"[appChain88 Error] %@", error);
                                         completion(nil);
                                     } else completion(nil);
                                 }];
}


- (void)requestForChain9BasedOnFileID:(NSString *)fileID
                          accessToken:(NSString *)accessToken
                       withCompletion:(void (^)(NSString *melanomaRiskValue))completion {
    NSLog(@"starting request for chains9: melanomaRiskValue");
    AppChains *appChains = [[AppChains alloc] initWithToken:accessToken withHostName:@"api.sequencing.com"];
    
    [appChains getReportWithApplicationMethodName:@"Chain9"
                                 withDatasourceId:fileID
                                 withSuccessBlock:^(Report *result) {
                                     
                                     completion([self parseReportForChain9:result]);
                                 }
                                 withFailureBlock:^(NSError *error) {
                                     if (error) {
                                         NSLog(@"appChains error: %@", error);
                                         completion(nil);
                                     } else completion(nil);
                                 }];
}



- (NSString *)parseReportForChain88:(Report *)result {
    NSString *vitaminDValue;
    
    if ([result isSucceeded]) {
        NSString *vitaminDKey = @"result";
        
        for (Result *obj in [result getResults]) {
            ResultValue *frv = [obj getValue];
            
            if ([frv getType] == kResultTypeText) {
                // NSLog(@"\nfrv %@=%@\n", [obj getName], [(TextResultValue *)frv getData]);
                
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
    }
    return vitaminDValue;
}


- (NSString *)parseReportForChain9:(Report *)result {
    NSString *riskValue;
    
    if ([result isSucceeded]) {
        NSString *riskKey = @"RiskDescription";
        
        for (Result *obj in [result getResults]) {
            ResultValue *frv = [obj getValue];
            
            if ([frv getType] == kResultTypeText) {
                // NSLog(@"\nfrv %@=%@\n", [obj getName], [(TextResultValue *)frv getData]);
                
                if ([[obj getName] isEqualToString:riskKey]) {
                    riskValue = [(TextResultValue *)frv getData];
                }
            }
        }
    }
    return riskValue;;
}




@end
