//
//  UserHelper.h
//  Copyright © 2016 Sequencing. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class User;
@class SQToken;


extern NSString *KEY_FOR_TOKEN;
extern NSString *KEY_FOR_DEVICE_TOKEN;
extern NSString *KEY_FOR_DEVICE_TOKEN_OLD;

extern NSString *KEY_FOR_USER_ACCOUNT_NAME;
extern NSString *KEY_FOR_USER_ACCOUNT_EMAIL;

extern NSString *KEY_FOR_USER_GENETIC_FILE;
extern NSString *GENETIC_FILE_NAME_DICT_KEY;
extern NSString *GENETIC_FILE_ID_DICT_KEY;

extern NSString *KEY_FOR_USER_CURRENT_GPS_LOCATION;

extern NSString *KEY_FOR_USER_CURRENT_LOCATION;
extern NSString *KEY_FOR_USER_SELECTED_LOCATION;

extern NSString *LOCATION_CITY_DICT_KEY;
extern NSString *LOCATION_STATE_COUNTRY_DICT_KEY;
extern NSString *LOCATION_ID_DICT_KEY;
extern NSString *CLLOCATION_OBJECT_DICT_KEY;

extern NSString *KEY_FOR_KNOWN_VIDEO_FILE_NAME;

extern NSString *KEY_FOR_SETTING_TEMPERATURE_UNIT;
extern NSString *KEY_FOR_SETTING_IPHONE_DAILY;
extern NSString *KEY_FOR_SETTING_EMAIL_DAILY;
extern NSString *KEY_FOR_SETTING_EMAIL_ADDRESS;
extern NSString *KEY_FOR_SETTING_SMS_DAILY;
extern NSString *KEY_FOR_SETTING_PHONE_PREFIX;
extern NSString *KEY_FOR_SETTING_PHONE_NUMBER;

extern NSString *KEY_FOR_SETTING_WAKEUP_TIME_WEEKDAYS;
extern NSString *KEY_FOR_SETTING_WAKEUP_TIME_WEEKENDS;
extern NSString *KEY_FOR_SETTING_TIMEZONE;
extern NSString *KEY_FOR_SETTING_WEEKEND_NOTIFICATION;



@interface UserHelper : NSObject

// reset all user properties/data
- (void)userHasAlreadyAuthorized;
- (BOOL)isUserAuthorized;
- (BOOL)isAdminUser;
- (void)userDidSignOut;
- (void)removeAllStoredCredentials;



//
// load user data methods
//
- (NSString *)loadDeviceToken;
- (NSString *)loadDeviceTokenOld;

- (NSString *)loadUserAccountName;
- (NSString *)loadUserAccountEmail;

- (NSDictionary *)loadUserGeneticFile;

- (CLLocation *)loadUserCurrentGPSLocation;

- (NSDictionary *)loadUserCurrentLocation;
- (NSDictionary *)loadUserSelectedLocation;
- (NSDictionary *)loadUserDefaultLocation;

- (NSString *)loadKnownVideoFileName;

- (NSNumber *)loadSettingTemperatureUnit;

- (NSNumber *)loadSettingIPhoneDailyForecast;

- (NSNumber *)loadSettingEmailDailyForecast;
- (NSString *)loadSettingEmailAddressForForecast;

- (NSNumber *)loadSettingSMSDailyForecast;
- (NSString *)loadSettingPhonePrefixForForecast;
- (NSString *)loadSettingPhoneNumberForForecast;

- (NSString *)loadSettingWakeUpTimeWeekdays;
- (NSString *)loadSettingWakeUpTimeWeekends;
- (NSString *)loadSettingTimezone;
- (NSString *)loadSettingWeekendNotification;



//
// save user data methods
//
- (void)saveDeviceToken:(NSString *)token;
- (void)saveDeviceTokenOld:(NSString *)token;

- (void)saveUserAccountName:(NSString *)name;
- (void)saveUserAccountEmail:(NSString *)email;

- (void)saveUserGeneticFile:(NSDictionary *)file;

- (void)saveUserCurrentGPSLocation:(CLLocation *)currentLocation;

- (void)saveUserCurrentLocation:(NSDictionary *)location;
- (void)saveUserSelectedLocation:(NSDictionary *)location;

- (void)saveKnownVideoFileName:(NSString *)fileName;

- (void)saveSettingTemperatureUnit:(NSNumber *)temperatureUnit;

- (void)saveSettingIPhoneDailyForecast:(NSNumber *)setting;

- (void)saveSettingEmailDailyForecast:(NSNumber *)setting;
- (void)saveSettingEmailAddressForForecast:(NSString *)setting;

- (void)saveSettingSMSDailyForecast:(NSNumber *)setting;
- (void)saveSettingPhonePrefixForForecast:(NSString *)setting;
- (void)saveSettingPhoneNumberForForecast:(NSString *)setting;

- (void)saveSettingWakeUpTimeWeekdays:(NSString *)setting;
- (void)saveSettingWakeUpTimeWeekends:(NSString *)setting;
- (void)saveSettingTimezone:(NSString *)setting;
- (void)saveSettingWeekendNotification:(NSString *)setting;



//
// helper methods
//
- (BOOL)locationIsEmpty:(NSDictionary *)location;



@end
