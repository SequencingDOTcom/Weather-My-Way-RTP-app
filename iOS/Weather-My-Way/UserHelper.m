//
//  UserHelper.m
//  Copyright © 2016 Sequencing. All rights reserved.
//


#import "UserHelper.h"
#import "SQToken.h"
#import "UserAccountHelper.h"


NSString *USER_IS_AUTHORIZED_KEY                = @"USER_IS_AUTHORIZED_KEY";

NSString *KEY_FOR_TOKEN                         = @"KEY_FOR_TOKEN";
NSString *KEY_FOR_DEVICE_TOKEN                  = @"KEY_FOR_DEVICE_TOKEN";
NSString *KEY_FOR_DEVICE_TOKEN_OLD              = @"KEY_FOR_DEVICE_TOKEN_OLD";

NSString *KEY_FOR_USER_ACCOUNT_NAME             = @"KEY_FOR_USER_ACCOUNT_NAME";
NSString *KEY_FOR_USER_ACCOUNT_EMAIL            = @"KEY_FOR_USER_ACCOUNT_EMAIL";

NSString *KEY_FOR_USER_GENETIC_FILE             = @"KEY_FOR_USER_GENETIC_FILE";
NSString *GENETIC_FILE_NAME_DICT_KEY            = @"GENETIC_FILE_NAME_DICT_KEY";
NSString *GENETIC_FILE_ID_DICT_KEY              = @"GENETIC_FILE_ID_DICT_KEY";

NSString *KEY_FOR_USER_CURRENT_GPS_LOCATION     = @"KEY_FOR_USER_CURRENT_GPS_LOCATION";

NSString *KEY_FOR_USER_CURRENT_LOCATION         = @"KEY_FOR_USER_CURRENT_LOCATION";
NSString *KEY_FOR_USER_SELECTED_LOCATION        = @"KEY_FOR_USER_SELECTED_LOCATION";

NSString *LOCATION_CITY_DICT_KEY                = @"LOCATION_CITY_DICT_KEY";
NSString *LOCATION_STATE_COUNTRY_DICT_KEY       = @"LOCATION_STATE_COUNTRY_DICT_KEY";
NSString *LOCATION_ID_DICT_KEY                  = @"LOCATION_ID_DICT_KEY";
NSString *CLLOCATION_OBJECT_DICT_KEY            = @"CLLOCATION_OBJECT_DICT_KEY";

// default location details, NY City
static NSString *DEFAULT_LOCATION_CITY          = @"New York City";
static NSString *DEFAULT_LOCATION_STATE_COUNTRY = @"NY";
static NSString *DEFAULT_LOCATION_ID            = @"/q/zmw:10001.5.99999";

NSString *KEY_FOR_KNOWN_VIDEO_FILE_NAME         = @"KEY_FOR_KNOWN_VIDEO_FILE_NAME";

NSString *KEY_FOR_SETTING_TEMPERATURE_UNIT      = @"KEY_FOR_SETTING_TEMPERATURE_UNIT";
NSString *KEY_FOR_SETTING_IPHONE_DAILY          = @"KEY_FOR_SETTING_IPHONE_DAILY";
NSString *KEY_FOR_SETTING_EMAIL_DAILY           = @"KEY_FOR_SETTING_EMAIL_DAILY";
NSString *KEY_FOR_SETTING_EMAIL_ADDRESS         = @"KEY_FOR_SETTING_EMAIL_ADDRESS";
NSString *KEY_FOR_SETTING_SMS_DAILY             = @"KEY_FOR_SETTING_SMS_DAILY";
NSString *KEY_FOR_SETTING_PHONE_PREFIX          = @"KEY_FOR_SETTING_PHONE_PREFIX";
NSString *KEY_FOR_SETTING_PHONE_NUMBER          = @"KEY_FOR_SETTING_PHONE_NUMBER";

NSString *KEY_FOR_SETTING_WAKEUP_TIME_WEEKDAYS  = @"KEY_FOR_SETTING_WAKEUP_TIME_WEEKDAYS";
NSString *KEY_FOR_SETTING_WAKEUP_TIME_WEEKENDS  = @"KEY_FOR_SETTING_WAKEUP_TIME_WEEKENDS";
NSString *KEY_FOR_SETTING_TIMEZONE              = @"KEY_FOR_SETTING_TIMEZONE";
NSString *KEY_FOR_SETTING_WEEKEND_NOTIFICATION  = @"KEY_FOR_SETTING_WEEKEND_NOTIFICATION";

NSString *USER_DEFAULT_LOCATION_ID = @"/q/zmw:10001.5.99999";



@interface UserHelper ()

@property (nonatomic) NSUserDefaults *userDefaults;

@end



@implementation UserHelper

#pragma mark - Initializer

- (instancetype)init {
    self = [super init];
    if (self) {
        self.userDefaults = [NSUserDefaults standardUserDefaults];
    }
    return self;
}



#pragma mark - User registration methods

- (void)userHasAlreadyAuthorized {
    NSLog(@"UserHelper: userHasAlreadyAuthorized");
    NSNumber *authorized = [NSNumber numberWithBool:YES];
    [_userDefaults setValue:authorized forKey:USER_IS_AUTHORIZED_KEY];
}


- (void)userHasAlreadySignOut {
    NSLog(@"UserHelper: userHasAlreadySignOut");
    NSNumber *unAuthorized = [NSNumber numberWithBool:NO];
    [_userDefaults setValue:unAuthorized forKey:USER_IS_AUTHORIZED_KEY];
}


- (BOOL)isUserAuthorized {
    NSNumber *authorized = [_userDefaults valueForKey:USER_IS_AUTHORIZED_KEY];
    BOOL isAuthorized = [authorized boolValue];
    return isAuthorized;
}


- (BOOL)isAdminUser {
    NSArray  *adminList = @[@"blaukhin@plexteq.com", @"amoskvin@plexteq.com"];
    NSString *email = [self loadUserAccountEmail];
    
    return [adminList containsObject:email];
}


- (void)userDidSignOut {
    NSLog(@"UserHelper: sign out > did reset all user defaults");
    
    [self userHasAlreadySignOut];
    
    //[_userDefaults removeObjectForKey:KEY_FOR_DEVICE_TOKEN];
    //[_userDefaults removeObjectForKey:KEY_FOR_DEVICE_TOKEN_OLD];
    
    [_userDefaults removeObjectForKey:KEY_FOR_USER_ACCOUNT_NAME];
    [_userDefaults removeObjectForKey:KEY_FOR_USER_ACCOUNT_EMAIL];
    
    [_userDefaults removeObjectForKey:KEY_FOR_USER_GENETIC_FILE];
    
    [_userDefaults removeObjectForKey:KEY_FOR_USER_CURRENT_GPS_LOCATION];
    
    [_userDefaults removeObjectForKey:KEY_FOR_USER_CURRENT_LOCATION];
    [_userDefaults removeObjectForKey:KEY_FOR_USER_SELECTED_LOCATION];
    
    [_userDefaults removeObjectForKey:KEY_FOR_KNOWN_VIDEO_FILE_NAME];
    
    [_userDefaults removeObjectForKey:KEY_FOR_SETTING_TEMPERATURE_UNIT];
    [_userDefaults removeObjectForKey:KEY_FOR_SETTING_IPHONE_DAILY];
    [_userDefaults removeObjectForKey:KEY_FOR_SETTING_EMAIL_DAILY];
    [_userDefaults removeObjectForKey:KEY_FOR_SETTING_EMAIL_ADDRESS];
    [_userDefaults removeObjectForKey:KEY_FOR_SETTING_SMS_DAILY];
    [_userDefaults removeObjectForKey:KEY_FOR_SETTING_PHONE_PREFIX];
    [_userDefaults removeObjectForKey:KEY_FOR_SETTING_PHONE_NUMBER];
    
    [_userDefaults removeObjectForKey:KEY_FOR_SETTING_WAKEUP_TIME_WEEKDAYS];
    [_userDefaults removeObjectForKey:KEY_FOR_SETTING_WAKEUP_TIME_WEEKENDS];
    [_userDefaults removeObjectForKey:KEY_FOR_SETTING_TIMEZONE];
    [_userDefaults removeObjectForKey:KEY_FOR_SETTING_WEEKEND_NOTIFICATION];
}


- (void)removeAllStoredCredentials {
    NSLog(@"UserHelper: removeAllStoredCredentials");
    
    /*
    // Delete any cached URLrequests
    NSURLCache *sharedCache = [NSURLCache sharedURLCache];
    [sharedCache removeAllCachedResponses];
    
    // Also delete all stored cookies
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [cookieStorage cookies];
    id cookie;
    for (cookie in cookies) {
        [cookieStorage deleteCookie:cookie];
    }
    
    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
    
    NSDictionary *credentialsDict = [[NSURLCredentialStorage sharedCredentialStorage] allCredentials];
    if ([credentialsDict count] > 0) {
        // the credentialsDict has NSURLProtectionSpace objs as keys and dicts of userName => NSURLCredential
        NSEnumerator *protectionSpaceEnumerator = [credentialsDict keyEnumerator];
        id urlProtectionSpace;
        // iterate over all NSURLProtectionSpaces
        while (urlProtectionSpace = [protectionSpaceEnumerator nextObject]) {
            NSEnumerator *userNameEnumerator = [[credentialsDict objectForKey:urlProtectionSpace] keyEnumerator];
            id userName;
            // iterate over all usernames for this protectionspace, which are the keys for the actual NSURLCredentials
            while (userName = [userNameEnumerator nextObject]) {
                NSURLCredential *cred = [[credentialsDict objectForKey:urlProtectionSpace] objectForKey:userName];
                [[NSURLCredentialStorage sharedCredentialStorage] removeCredential:cred forProtectionSpace:urlProtectionSpace];
            }
        }
    } */
    
    // Delete any cached URLrequests!
    NSURLCache *sharedCache = [NSURLCache sharedURLCache];
    [sharedCache removeAllCachedResponses];
    
    // Also delete all stored cookies!
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [cookieStorage cookies];
    id cookie;
    for (cookie in cookies) {
        [cookieStorage deleteCookie:cookie];
    }
    
    NSDictionary *credentialsDict = [[NSURLCredentialStorage sharedCredentialStorage] allCredentials];
    if ([credentialsDict count] > 0) {
        // the credentialsDict has NSURLProtectionSpace objs as keys and dicts of userName => NSURLCredential
        NSEnumerator *protectionSpaceEnumerator = [credentialsDict keyEnumerator];
        id urlProtectionSpace;
        // iterate over all NSURLProtectionSpaces
        while (urlProtectionSpace = [protectionSpaceEnumerator nextObject]) {
            NSEnumerator *userNameEnumerator = [[credentialsDict objectForKey:urlProtectionSpace] keyEnumerator];
            id userName;
            // iterate over all usernames for this protectionspace, which are the keys for the actual NSURLCredentials
            while (userName = [userNameEnumerator nextObject]) {
                NSURLCredential *cred = [[credentialsDict objectForKey:urlProtectionSpace] objectForKey:userName];
                //NSLog(@"credentials to be removed: %@", cred);
                [[NSURLCredentialStorage sharedCredentialStorage] removeCredential:cred forProtectionSpace:urlProtectionSpace];
            }
        }
    }
}




#pragma mark -
#pragma mark Load user data

- (NSString *)loadDeviceToken {
    NSLog(@"UserHelper: loadDeviceToken");
    return [_userDefaults valueForKey:KEY_FOR_DEVICE_TOKEN];
}

- (NSString *)loadDeviceTokenOld {
    NSLog(@"UserHelper: loadDeviceTokenOld");
    return [_userDefaults valueForKey:KEY_FOR_DEVICE_TOKEN_OLD];
}


- (NSString *)loadUserAccountName {
    NSLog(@"UserHelper: loadUserAccountName");
    return [_userDefaults valueForKey:KEY_FOR_USER_ACCOUNT_NAME];
}


- (NSString *)loadUserAccountEmail {
    NSLog(@"UserHelper: loadUserAccountEmail");
    return [_userDefaults valueForKey:KEY_FOR_USER_ACCOUNT_EMAIL];
}


- (NSDictionary *)loadUserGeneticFile {
    NSLog(@"UserHelper: loadUserGeneticFile");
    NSData *fileData = [_userDefaults valueForKey:KEY_FOR_USER_GENETIC_FILE];
    NSDictionary *fileDict = [NSKeyedUnarchiver unarchiveObjectWithData:fileData];
    return fileDict;
}


- (CLLocation *)loadUserCurrentGPSLocation {
    NSLog(@"UserHelper: loadUserCurrentGPSLocation");
    NSData *locationData = [_userDefaults valueForKey:KEY_FOR_USER_CURRENT_GPS_LOCATION];
    CLLocation *currentLocation = [NSKeyedUnarchiver unarchiveObjectWithData:locationData];
    return currentLocation;
}


- (NSDictionary *)loadUserCurrentLocation {
    NSLog(@"UserHelper: loadUserCurrentLocation");
    NSData *locationData = [_userDefaults valueForKey:KEY_FOR_USER_CURRENT_LOCATION];
    NSDictionary *locationDict = [NSKeyedUnarchiver unarchiveObjectWithData:locationData];
    return locationDict;
}


- (NSDictionary *)loadUserSelectedLocation {
    NSLog(@"UserHelper: loadUserSelectedLocation");
    NSData *locationData = [_userDefaults valueForKey:KEY_FOR_USER_SELECTED_LOCATION];
    NSDictionary *locationDict = [NSKeyedUnarchiver unarchiveObjectWithData:locationData];
    return locationDict;
}


- (NSDictionary *)loadUserDefaultLocation {
    NSLog(@"UserHelper: loadUserDefaultLocation");
    NSDictionary *location = [NSDictionary dictionaryWithObjectsAndKeys:
                              DEFAULT_LOCATION_CITY,            LOCATION_CITY_DICT_KEY,
                              DEFAULT_LOCATION_STATE_COUNTRY,   LOCATION_STATE_COUNTRY_DICT_KEY,
                              DEFAULT_LOCATION_ID,              LOCATION_ID_DICT_KEY, nil];
    return location;
}


- (NSString *)loadKnownVideoFileName {
    NSLog(@"UserHelper: loadKnownVideoFileName");
    NSString *videoFileName = [_userDefaults valueForKey:KEY_FOR_KNOWN_VIDEO_FILE_NAME];
    return videoFileName;
}


- (NSNumber *)loadSettingTemperatureUnit {
    NSNumber *settingValue;
    if ([_userDefaults valueForKey:KEY_FOR_SETTING_TEMPERATURE_UNIT] != nil) {
        settingValue = [_userDefaults valueForKey:KEY_FOR_SETTING_TEMPERATURE_UNIT];
        
    } else {
        settingValue = [NSNumber numberWithInteger:0];
        [self saveSettingTemperatureUnit:settingValue];
    }
    return settingValue;
}


- (NSNumber *)loadSettingIPhoneDailyForecast {
    NSNumber *settingValue;
    if ([_userDefaults valueForKey:KEY_FOR_SETTING_IPHONE_DAILY] != nil) {
        settingValue = [_userDefaults valueForKey:KEY_FOR_SETTING_IPHONE_DAILY];
    } else {
        settingValue = [NSNumber numberWithInteger:1];
        [self saveSettingIPhoneDailyForecast:settingValue];
    }
    return settingValue;
}


- (NSNumber *)loadSettingEmailDailyForecast {
    NSNumber *settingValue;
    if ([_userDefaults valueForKey:KEY_FOR_SETTING_EMAIL_DAILY] != nil) {
        settingValue = [_userDefaults valueForKey:KEY_FOR_SETTING_EMAIL_DAILY];
    } else {
        settingValue = [NSNumber numberWithInteger:0];
        [self saveSettingEmailDailyForecast:settingValue];
    }
    return settingValue;
}


- (NSString *)loadSettingEmailAddressForForecast {
    return [_userDefaults valueForKey:KEY_FOR_SETTING_EMAIL_ADDRESS];
}


- (NSNumber *)loadSettingSMSDailyForecast {
    NSNumber *settingValue;
    if ([_userDefaults valueForKey:KEY_FOR_SETTING_SMS_DAILY] != nil) {
        settingValue = [_userDefaults valueForKey:KEY_FOR_SETTING_SMS_DAILY];
    } else {
        settingValue = [NSNumber numberWithInteger:0];
        [self saveSettingSMSDailyForecast:settingValue];
    }
    return settingValue;
}


- (NSString *)loadSettingPhonePrefixForForecast {
    return [_userDefaults valueForKey:KEY_FOR_SETTING_PHONE_PREFIX];
}


- (NSString *)loadSettingPhoneNumberForForecast {
    return [_userDefaults valueForKey:KEY_FOR_SETTING_PHONE_NUMBER];
}


- (NSString *)loadSettingWakeUpTimeWeekdays {
    NSString *wakeupTimeWeekday;
    if ([_userDefaults valueForKey:KEY_FOR_SETTING_WAKEUP_TIME_WEEKDAYS] != nil) {
        wakeupTimeWeekday = [_userDefaults valueForKey:KEY_FOR_SETTING_WAKEUP_TIME_WEEKDAYS];
    } else {
        wakeupTimeWeekday = kWakeUpTimeForWeekDays;
        [self saveSettingWakeUpTimeWeekdays:wakeupTimeWeekday];
    }
    return wakeupTimeWeekday;
}


- (NSString *)loadSettingWakeUpTimeWeekends {
    NSString *wakeupTimeWeekend;
    if ([_userDefaults valueForKey:KEY_FOR_SETTING_WAKEUP_TIME_WEEKENDS]) {
        wakeupTimeWeekend = [_userDefaults valueForKey:KEY_FOR_SETTING_WAKEUP_TIME_WEEKENDS];
    } else {
        wakeupTimeWeekend = kWakeUpTimeForWeekEnds;
        [self saveSettingWakeUpTimeWeekends:wakeupTimeWeekend];
    }
    return wakeupTimeWeekend;
}


- (NSString *)loadSettingTimezone {
    return [_userDefaults valueForKey:KEY_FOR_SETTING_TIMEZONE];
}


- (NSString *)loadSettingWeekendNotification; {
    return [_userDefaults valueForKey:KEY_FOR_SETTING_WEEKEND_NOTIFICATION];
}




#pragma mark - Save user data

- (void)saveDeviceToken:(NSString *)token {
    if ([token length] != 0) {
        NSLog(@"UserHelper: saveDeviceToken");
        [_userDefaults setValue:token forKey:KEY_FOR_DEVICE_TOKEN];
    } else {
        NSLog(@"UserHelper: device token is empty");
    }
}

- (void)saveDeviceTokenOld:(NSString *)token {
    if ([token length] != 0) {
        NSLog(@"UserHelper: saveDeviceTokenOld");
        [_userDefaults setValue:token forKey:KEY_FOR_DEVICE_TOKEN_OLD];
    } else {
        NSLog(@"UserHelper: device token old is empty");
    }
}


- (void)saveUserAccountName:(NSString *)name {
    if ([name length] != 0) {
        NSLog(@"UserHelper: saveUserAccountName %@", name);
        [_userDefaults setValue:name forKey:KEY_FOR_USER_ACCOUNT_NAME];
    } else {
        NSLog(@"UserHelper: user account name is empty");
    }
}


- (void)saveUserAccountEmail:(NSString *)email {
    if ([email length] != 0) {
        NSLog(@"UserHelper: saveUserAccountEmail %@", email);
        [_userDefaults setValue:email forKey:KEY_FOR_USER_ACCOUNT_EMAIL];
    } else {
        NSLog(@"UserHelper: user account email is empty");
    }
}


- (void)saveUserGeneticFile:(NSDictionary *)file {
    NSLog(@"file to save: %@", file);
    NSString *fileID = [file objectForKey:@"Id"];
    
    NSString *fileName;
    if ([[file objectForKey:@"FileCategory"] isEqualToString:@"Community"] ) {
        fileName = [NSString stringWithFormat:@"%@ - %@", [file objectForKey:@"FriendlyDesc1"], [file objectForKey:@"FriendlyDesc2"]];
    } else {
        fileName = [file objectForKey:@"Name"];
    }
    
    if ([fileName length] != 0 && [fileID length] != 0) {
        NSDictionary *fileDict = @{GENETIC_FILE_NAME_DICT_KEY  : fileName,
                                   GENETIC_FILE_ID_DICT_KEY    : fileID};
        NSLog(@"UserHelper: saveUserGeneticFile %@", fileDict);
        
        NSData *fileData = [NSKeyedArchiver archivedDataWithRootObject:fileDict];
        [_userDefaults setValue:fileData forKey:KEY_FOR_USER_GENETIC_FILE];
        
    } else {
        NSLog(@"UserHelper: genetic file is empty");
    }
}


- (void)saveUserCurrentGPSLocation:(CLLocation *)currentLocation {
    NSLog(@"UserHelper: saveUserCurrentGPSLocation");
    if (currentLocation) {
        NSData *locationData = [NSKeyedArchiver archivedDataWithRootObject:currentLocation];
        [_userDefaults setValue:locationData forKey:KEY_FOR_USER_CURRENT_GPS_LOCATION];
    } else {
        NSLog(@"UserHelper: currentLocation is empty");
    }
}


- (void)saveUserCurrentLocation:(NSDictionary *)location {
    if (location) {
        NSData *locationData = [NSKeyedArchiver archivedDataWithRootObject:location];
        [_userDefaults setValue:locationData forKey:KEY_FOR_USER_CURRENT_LOCATION];
        
    } else {
        NSLog(@"UserHelper: current location is empty");
    }
}


- (void)saveUserSelectedLocation:(NSDictionary *)location {
    if (location != nil) {
        NSLog(@"UserHelper: saveUserSelectedLocation %@", location);
        NSData *locationData = [NSKeyedArchiver archivedDataWithRootObject:location];
        [_userDefaults setValue:locationData forKey:KEY_FOR_USER_SELECTED_LOCATION];
    } else {
        NSLog(@"UserHelper: selected location is empty");
    }
}


- (void)saveKnownVideoFileName:(NSString *)fileName {
    if ([fileName length] != 0) {
        NSLog(@"UserHelper: saveKnownVideoFileName %@", fileName);
        [_userDefaults setValue:fileName forKey:KEY_FOR_KNOWN_VIDEO_FILE_NAME];
    } else {
        NSLog(@"UserHelper: fileName is empty");
    }
}


- (void)saveSettingTemperatureUnit:(NSNumber *)temperatureUnit {
    if (temperatureUnit != nil) {
        NSLog(@"UserHelper: saved temperatureUnit: %@", temperatureUnit);
        [_userDefaults setValue:temperatureUnit forKey:KEY_FOR_SETTING_TEMPERATURE_UNIT];
    } else {
        NSLog(@"UserHelper: temperatureUnit is empty");
    }
}


- (void)saveSettingIPhoneDailyForecast:(NSNumber *)setting {
    if (setting != nil) {
        NSLog(@"UserHelper: saveSettingiPhoneDailyForecast %@", setting);
        [_userDefaults setValue:setting forKey:KEY_FOR_SETTING_IPHONE_DAILY];
    } else {
        NSLog(@"UserHelper: SettingiPhoneDailyForecast is empty");
    }
}


- (void)saveSettingEmailDailyForecast:(NSNumber *)setting {
    if (setting != nil) {
        NSLog(@"UserHelper: saveSettingEmailDailyForecast %@", setting);
        [_userDefaults setValue:setting forKey:KEY_FOR_SETTING_EMAIL_DAILY];
    } else {
        NSLog(@"UserHelper: SettingEmailDailyForecast is empty");
    }
}


- (void)saveSettingEmailAddressForForecast:(NSString *)setting {
    if ([setting length] != 0) {
        NSLog(@"UserHelper: saveSettingEmailAddressForForecast %@", setting);
        [_userDefaults setValue:setting forKey:KEY_FOR_SETTING_EMAIL_ADDRESS];
    } else {
        NSLog(@"UserHelper: EmailAddressForForecast is empty");
    }
}


- (void)saveSettingSMSDailyForecast:(NSNumber *)setting {
    if (setting != nil) {
        NSLog(@"UserHelper: saveSettingSMSDailyForecast %@", setting);
        [_userDefaults setValue:setting forKey:KEY_FOR_SETTING_SMS_DAILY];
    } else {
        NSLog(@"UserHelper: SettingSMSDailyForecast is empty");
    }
}


- (void)saveSettingPhonePrefixForForecast:(NSString *)setting {
    if ([setting length] != 0) {
        NSLog(@"UserHelper: saveSettingPhonePrefixForForecast %@", setting);
        [_userDefaults setValue:setting forKey:KEY_FOR_SETTING_PHONE_PREFIX];
    } else {
        NSLog(@"UserHelper: PhonePrefixForForecast is empty");
    }
}


- (void)saveSettingPhoneNumberForForecast:(NSString *)setting {
    if ([setting length] != 0) {
        NSLog(@"UserHelper: saveSettingPhoneNumberForForecast %@", setting);
        [_userDefaults setValue:setting forKey:KEY_FOR_SETTING_PHONE_NUMBER];
    } else {
        NSLog(@"UserHelper: PhoneNumberForForecast is empty");
    }
}


- (void)saveSettingWakeUpTimeWeekdays:(NSString *)setting {
    if ([setting length] != 0) {
        NSString *timeValue = [self analyzeAndCorrectTimeIfNeeded:setting];
        NSLog(@"UserHelper: saveSettingWakeUpTimeWeekdays %@", timeValue);
        [_userDefaults setValue:timeValue forKey:KEY_FOR_SETTING_WAKEUP_TIME_WEEKDAYS];
    } else {
        NSLog(@"UserHelper: WakeUpTimeWeekdays is empty");
    }
}

- (void)saveSettingWakeUpTimeWeekends:(NSString *)setting {
    if ([setting length] != 0) {
        NSString *timeValue = [self analyzeAndCorrectTimeIfNeeded:setting];
        NSLog(@"UserHelper: saveSettingWakeUpTimeWeekends %@", timeValue);
        [_userDefaults setValue:timeValue forKey:KEY_FOR_SETTING_WAKEUP_TIME_WEEKENDS];
    } else {
        NSLog(@"UserHelper: WakeUpTimeWeekends is empty");
    }
}


- (void)saveSettingTimezone:(NSString *)setting {
    if ([setting length] != 0) {
        NSLog(@"UserHelper: saveSettingTimezone %@", setting);
        [_userDefaults setValue:setting forKey:KEY_FOR_SETTING_TIMEZONE];
    } else {
        NSLog(@"UserHelper: SettingTimezone is empty");
    }
}


- (void)saveSettingWeekendNotification:(NSString *)setting {
    if ([setting length] != 0) {
        NSLog(@"UserHelper: saveSettingWeekendNotification %@", setting);
        [_userDefaults setValue:setting forKey:KEY_FOR_SETTING_WEEKEND_NOTIFICATION];
    } else {
        NSLog(@"UserHelper: SettingWeekendNotification is empty");
    }
}



#pragma mark - WakeUp time helper methods

- (NSString *)analyzeAndCorrectTimeIfNeeded:(NSString *)time {
    NSString *tempTime;
    tempTime = [self checkForABsentAMPMParameter:time];
    tempTime = [self checkForAbsentColumn:[tempTime copy]];
    tempTime = [self checkForInvalidTime:[tempTime copy]];
    return tempTime;
}

- (NSString *)checkForAbsentColumn:(NSString *)time {
    if (![time containsString:@":"]) {
        NSArray *parts = [time componentsSeparatedByString:@" "];
        NSMutableString *correctedTime = [[NSMutableString alloc] init];
        [correctedTime appendString:[parts firstObject]];
        [correctedTime appendString:@":00 "];
        [correctedTime appendString:[parts lastObject]];
        return correctedTime;
    } else {
        return time;
    }
}

- (NSString *)checkForABsentAMPMParameter:(NSString *)time {
    if ([time rangeOfString:@"M"].location == NSNotFound) {
        
        NSMutableString *tempTime = [[NSMutableString alloc] init];
        [tempTime appendString:time];
        [tempTime appendString:@" AM"];
        [tempTime stringByReplacingOccurrencesOfString:@"  " withString:@" "];
        return tempTime;
        
    } else {
        return time;
    }
}

- (NSString *)checkForInvalidTime:(NSString *)time {
    NSMutableString *correctedTime = [[NSMutableString alloc] init];
    NSArray *partsFullTime = [time componentsSeparatedByString:@" "];
    NSString *tempTime = [partsFullTime firstObject];
    NSArray *partsTimeItself = [tempTime componentsSeparatedByString:@":"];
    NSString *hoursString   = [partsTimeItself firstObject];
    NSString *minutesString = [partsTimeItself lastObject];
    
    NSInteger hoursValue   = [hoursString integerValue];
    NSInteger minutesValue = [minutesString integerValue];
    NSMutableString *hoursStringCorrected = [[NSMutableString alloc] init];
    NSMutableString *minutesStringCorrected = [[NSMutableString alloc] init];
    BOOL pm = NO;
    
    if (hoursValue < 10) {
        [hoursStringCorrected appendString:@"0"];
        [hoursStringCorrected appendString:[NSString stringWithFormat:@"%d", (int)hoursValue]];
    } else if (hoursValue == 12) {
        pm = YES;
        [hoursStringCorrected appendString:[NSString stringWithFormat:@"%d", (int)hoursValue]];
    } else if (hoursValue > 12) {
        pm = YES;
        switch (hoursValue) {
            case 13: [hoursStringCorrected appendString:@"01"];
                break;
            case 14: [hoursStringCorrected appendString:@"02"];
                break;
            case 15: [hoursStringCorrected appendString:@"03"];
                break;
            case 16: [hoursStringCorrected appendString:@"04"];
                break;
            case 17: [hoursStringCorrected appendString:@"05"];
                break;
            case 18: [hoursStringCorrected appendString:@"06"];
                break;
            case 19: [hoursStringCorrected appendString:@"07"];
                break;
            case 20: [hoursStringCorrected appendString:@"08"];
                break;
            case 21: [hoursStringCorrected appendString:@"09"];
                break;
            case 22: [hoursStringCorrected appendString:@"10"];
                break;
            case 23: [hoursStringCorrected appendString:@"11"];
                break;
            case 24: {
                [hoursStringCorrected appendString:@"00"];
                pm = NO;
            }   break;
            default: [hoursStringCorrected appendString:@"07"];
                break;
        }
    } else {
        [hoursStringCorrected appendString:[NSString stringWithFormat:@"%d", (int)hoursValue]];
    }
    
    if (minutesValue <10)
        [minutesStringCorrected appendString:@"0"];
    [minutesStringCorrected appendString:[NSString stringWithFormat:@"%d", (int)minutesValue]];
    
    [correctedTime appendString:hoursStringCorrected];
    [correctedTime appendString:@":"];
    [correctedTime appendString:minutesStringCorrected];
    [correctedTime appendString:@" "];
    if (pm) {
        [correctedTime appendString:@"PM"];
    } else {
        [correctedTime appendString:[partsFullTime lastObject]];
    }
    
    return [NSString stringWithFormat:@"%@", correctedTime];
}



#pragma mark - Helper methods

- (BOOL)locationIsEmpty:(NSDictionary *)location {
    NSArray *locationAllKeys = [location allKeys];
    
    // if location is not empty
    if (location && [locationAllKeys count] > 0) {
        
        // if user location id key is present among dictionary keys
        if ([locationAllKeys containsObject:LOCATION_ID_DICT_KEY]) {
            
            // if location id is not empty
            if ([[location objectForKey:LOCATION_ID_DICT_KEY] length] > 0) {
                return NO;
                
            } else {
                NSLog(@"UserHelper: locationID is empty in location dict from userDefaults");
                return YES;
            }
        } else {
            NSLog(@"UserHelper: locationID object is absent in location dict from userDefaults");
            return YES;
        }
    } else {
        NSLog(@"UserHelper: location dict from userDefaults is empty");
        return YES;
    }
}




@end

