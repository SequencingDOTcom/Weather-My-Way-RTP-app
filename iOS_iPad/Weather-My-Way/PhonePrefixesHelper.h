//
//  PhonePrefixesHelper.h
//  Copyright © 2016 Sequencing. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface PhonePrefixesHelper : NSObject

// designated initializer
- (instancetype)sharedInstance;

- (NSMutableDictionary *)phonePrefixesDictionary;
- (NSMutableDictionary *)phonePrefixesDictionaryWithCodesInKeys;

- (NSMutableArray *)arrayOfCountriesWithCodes;
- (NSArray *)arrayOfCountriesWithCodesInNames;

- (NSString *)countryFullNameByCountryISO3166:(NSString *)countryISO3166;

@end
