//
//  DateHelper.h
//  Copyright © 2017 Sequencing. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface DateHelper : NSObject

+ (NSString *)actualTimeStringFromDate:(NSDate *)date;
+ (NSString *)convertedTimeStringToUSFromDate:(NSDate *)date;

+ (NSString *)convertedTimeStringToLocaleFromUSTimeString:(NSString *)timeStringUS;
+ (NSDate *)convertedDateToLocaleFromTimeString:(NSString *)timeString;

    
@end
