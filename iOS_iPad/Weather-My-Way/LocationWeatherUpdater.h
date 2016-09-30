//
//  LocationWeatherUpdater.h
//  Copyright © 2016 Sequencing. All rights reserved.
//


#import <Foundation/Foundation.h>


@protocol LocationWeatherUpdaterDelegate <NSObject>

- (void)locationAndWeatherWereUpdated;
- (void)startedRefreshing;
- (void)finishedRefreshWithError;

@end




@interface LocationWeatherUpdater : NSObject

@property (weak, nonatomic) id <LocationWeatherUpdaterDelegate> delegate;

// designated initializer
+ (instancetype)sharedInstance;

- (void)startTimer;
- (void)cancelTimer;
- (void)checkLocationAvailabilityAndStart;
- (void)getForecast;

@end
