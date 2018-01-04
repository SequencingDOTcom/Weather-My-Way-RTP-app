//
//  GeneticForecastServer.h
//  Copyright © 2017 Sequencing. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface GeneticForecastServer : NSObject

+ (void)requestForGeneticForecastsArrayBasedOnAccessToken:(NSString *)accessToken
                                            vitaminDValue:(NSString *)vitaminDValue
                                        melanomaRiskValue:(NSString *)melanomaRiskValue
                                     forecastRequestArray:(NSArray *)forecastRequestArray
                                           withCompletion:(void (^)(NSArray *geneticForecastsArray))completion;

@end
