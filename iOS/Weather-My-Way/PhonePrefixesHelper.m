//
//  PhonePrefixesHelper.m
//  Copyright © 2016 Sequencing. All rights reserved.
//


#import "PhonePrefixesHelper.h"
#import "CSVParser.h"

#define csvFileName     @"phone_prefixes.csv"
#define kDefaultCounty  @"United States"


@interface PhonePrefixesHelper ()

@property (strong, nonatomic) NSMutableArray *csvFileParsed;

@end


@implementation PhonePrefixesHelper

#pragma mark -
#pragma mark Initialazer / Setter

- (instancetype)sharedInstance {
    static PhonePrefixesHelper *instance = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [[PhonePrefixesHelper alloc] init];
        instance.csvFileParsed = [self parseCSVFile];
    });
    
    return instance;
}


- (NSMutableDictionary *)phonePrefixesDictionary {
    NSMutableDictionary *phonePrefixesDict = [[NSMutableDictionary alloc] init];
    for (NSArray *array in _csvFileParsed) {
        if (array) {
            id country = [array firstObject];
            NSString *countryKey = [NSString stringWithFormat:@"%@", country];
            
            id dialCode = [array lastObject];
            NSString *dialCodeValue = [NSString stringWithFormat:@"%@", dialCode];
            
            if ([countryKey length] != 0 && [dialCodeValue length] != 0) {
                [phonePrefixesDict setValue:dialCodeValue forKey:countryKey];
            }
        }
    }
    return phonePrefixesDict;
}

- (NSMutableDictionary *)phonePrefixesDictionaryWithCodesInKeys {
    NSMutableDictionary *phonePrefixesDict = [[NSMutableDictionary alloc] init];
    for (NSArray *array in _csvFileParsed) {
        if (array) {
            id dialCode = [array lastObject];
            NSString *dialCodeValue = [NSString stringWithFormat:@"%@", dialCode];
            
            id country = [array firstObject];
            NSString *countryKey = [NSString stringWithFormat:@"%@ (%@)", country, dialCodeValue];
            
            if ([countryKey length] != 0 && [dialCodeValue length] != 0) {
                [phonePrefixesDict setValue:dialCodeValue forKey:countryKey];
            }
        }
    }
    return phonePrefixesDict;
}


- (NSMutableArray *)arrayOfCountriesWithCodes {
    NSMutableArray *phonePrefixesArray = [[NSMutableArray alloc] init];
    for (NSArray *array in _csvFileParsed) {
        if (array) {
            id country = [array firstObject];
            NSString *countryKey = [NSString stringWithFormat:@"%@", country];
            
            id dialCode = [array lastObject];
            NSString *dialCodeValue = [NSString stringWithFormat:@"%@", dialCode];
            
            if ([countryKey length] != 0 && [dialCodeValue length] != 0) {
                NSString *countryWithCode = [NSString stringWithFormat:@"%@ %@", countryKey, dialCodeValue];
                [phonePrefixesArray addObject:countryWithCode];
            }
        }
    }
    return phonePrefixesArray;
}

- (NSArray *)arrayOfCountriesWithCodesInNames {
    NSDictionary *countriesCodeDict = [self phonePrefixesDictionaryWithCodesInKeys];
    NSArray *keys = [countriesCodeDict allKeys];
    return keys;
}


- (NSString *)countryFullNameByCountryISO3166:(NSString *)countryISO3166 {
    NSString *countryFullName = kDefaultCounty;
    for (NSArray *array in _csvFileParsed) {
        if (array) {
            id countryISO = [array objectAtIndex:1];
            NSString *countryISOName = [NSString stringWithFormat:@"%@", countryISO];
            
            if ([countryISOName isEqualToString:countryISO3166]) {
                id country = [array firstObject];
                countryFullName = [NSString stringWithFormat:@"%@", country];
            }
        }
    }
    return countryFullName;
}



#pragma mark -
#pragma mark CSV parser helper

- (NSMutableArray *)parseCSVFile {
    NSString    *csvFilePath = [[NSBundle mainBundle] pathForResource:csvFileName ofType:nil];
    NSError     *error;
    NSString    *csvFileContents = [NSString stringWithContentsOfFile:csvFilePath encoding:NSUTF8StringEncoding error:&error];
    NSMutableArray *parsedCSV;
    
    if (csvFileContents && !error) {
        parsedCSV = [CSVParser loadAndParseCSVFileBasedOnStringData:csvFileContents hasHeaderFields:NO];
    }
    return parsedCSV;
}


@end
