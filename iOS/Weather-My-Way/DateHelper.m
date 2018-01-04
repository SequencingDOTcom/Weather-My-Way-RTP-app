//
//  DateHelper.m
//  Copyright © 2017 Sequencing. All rights reserved.
//


#import "DateHelper.h"


@implementation DateHelper


+ (NSString *)actualTimeStringFromDate:(NSDate *)date {
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    
    if ([self is24hTimeFormat])
        [dateFormatter setDateFormat:@"HH:mm"];
    else
        [dateFormatter setDateFormat:@"hh:mm a"];
    NSString *timeString = [dateFormatter stringFromDate:date];
    return timeString;
}



+ (NSString *)convertedTimeStringToUSFromDate:(NSDate *)date {
    NSString *timeString = @"";
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    
    if ([self is24hTimeFormat]) {
        dateFormatter.dateFormat = @"HH:mm";
        NSString *selectedTime = [dateFormatter stringFromDate:date];
        NSDate *date = [dateFormatter dateFromString:selectedTime];
        dateFormatter.dateFormat = @"hh:mm a";
        timeString = [dateFormatter stringFromDate:date];
    } else {
        dateFormatter.dateFormat = @"hh:mm a";
        timeString = [dateFormatter stringFromDate:date];
    }
    return timeString;
}



+ (NSString *)convertedTimeStringToLocaleFromUSTimeString:(NSString *)timeStringUS {
    NSString *timeString = @"";
    if ([self is24hTimeFormat]) {
        NSDateFormatter *date12hFormatter = [NSDateFormatter new];
        date12hFormatter.timeStyle = NSDateFormatterShortStyle;
        [date12hFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
        date12hFormatter.dateFormat = @"hh:mm a";
        NSDate *date12h = [date12hFormatter dateFromString:timeStringUS];
        
        NSDateFormatter *date24hFormatter = [[NSDateFormatter alloc] init];
        [date12hFormatter setLocale:[NSLocale currentLocale]];
        date24hFormatter.dateFormat = @"HH:mm";
        timeString = [date24hFormatter stringFromDate:date12h];
        
    } else {
        NSDateFormatter *date12hFormatter = [NSDateFormatter new];
        date12hFormatter.timeStyle = NSDateFormatterShortStyle;
        [date12hFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
        date12hFormatter.dateFormat = @"hh:mm a";
        NSDate *date12h = [date12hFormatter dateFromString:timeStringUS];
        
        [date12hFormatter setLocale:[NSLocale currentLocale]];
        timeString = [date12hFormatter stringFromDate:date12h];
    }
    return timeString;
}



+ (NSDate *)convertedDateToLocaleFromTimeString:(NSString *)timeString {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //[dateFormatter setLocale:[NSLocale currentLocale]];
    //[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    //[dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    
    if ([self is24hTimeFormat]) [dateFormatter setDateFormat:@"HH:mm"];
    else [dateFormatter setDateFormat:@"h:mm a"];
    
    return [dateFormatter dateFromString:timeString];
}



+ (BOOL)is24hTimeFormat {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateStyle:NSDateFormatterNoStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    NSRange amRange = [dateString rangeOfString:[formatter AMSymbol]];
    NSRange pmRange = [dateString rangeOfString:[formatter PMSymbol]];
    BOOL is24h = (amRange.location == NSNotFound && pmRange.location == NSNotFound);
    return is24h;
}


@end
