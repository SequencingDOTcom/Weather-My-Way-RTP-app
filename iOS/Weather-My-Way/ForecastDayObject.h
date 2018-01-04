//
//  ForecastDayObject.h
//  Copyright © 2016 Sequencing. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface ForecastDayObject : NSObject

@property (strong, nonatomic) NSString *date;
@property (strong, nonatomic) NSString *weatherType;
@property (strong, nonatomic) NSString *alertType;
@property (strong, nonatomic) NSString *geneticForecast;

@end
