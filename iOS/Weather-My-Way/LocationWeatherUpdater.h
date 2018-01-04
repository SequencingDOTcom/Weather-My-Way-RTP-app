//
//  LocationWeatherUpdater.h
//  Copyright © 2016 Sequencing. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "AppDelegate.h"


@protocol LocationWeatherUpdaterDelegate <NSObject>

- (void)startedRefreshing;
- (void)locationAndWeatherWereUpdated;
- (void)weatherForecastUpdated:(NSDictionary *)weatherForecast;
- (void)finishedRefreshWithError;

@end



@interface LocationWeatherUpdater : NSObject

@property (weak, nonatomic) id <LocationWeatherUpdaterDelegate> delegate;

// designated initializer
+ (instancetype)sharedInstance;
- (void)checkLocationAvailabilityAndStart;
- (void)getForecast;
- (void)refreshWeatherForecastForLocation:(NSDictionary *)location;
- (void)requestForGeneticForecastWithGeneticFile:(NSDictionary *)file withCompletion:(void (^)(NSString *geneticForecast))completion;

// - (void)fetchWeatherAndGeneticForecastsInBackgroundWithCompletion:(void (^)(UIBackgroundFetchResult fetchResult))completion;


@end
