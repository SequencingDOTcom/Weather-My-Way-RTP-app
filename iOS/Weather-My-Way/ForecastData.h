//
//  ForecastData.h
//  Copyright © 2016 Sequencing. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface ForecastData : NSObject

@property (strong, nonatomic) NSDictionary *forecast;
@property (strong, nonatomic) NSString *geneticForecast;

@property (strong, nonatomic) NSString *weatherType;
@property (strong, nonatomic) NSString *dayNight;

@property (strong, nonatomic) NSString *alertType;

@property (strong, nonatomic) NSDictionary *locationForForecast;

@property (strong, nonatomic) NSString *vitaminDValue;
@property (strong, nonatomic) NSString *melanomaRiskValue;

@property (strong, nonatomic) NSMutableArray *forecastDayObjectsListFor10DaysArray;

// designated initializer
+ (instancetype)sharedInstance;

- (void)populateDayObjectsWithGeneticForecasts:(NSArray *)geneticForecastsArray;


@end
