//
//  ChangeNotificationHelper.h
//  Copyright © 2016 Sequencing. All rights reserved.
//


#import <Foundation/Foundation.h>


typedef void (^HttpCallback)(NSString *responseText, NSURLResponse *response, NSError *error);

typedef enum {
    WeekendNotificationsSMS,
    WeekendNotificationsEmail,
    WeekendNotificationsEmailAndSMS,
    WeekendNotificationsNone,
    WeekendNotificationsiPhone,
    WeekendNotificationsiPhoneAndEmail,
    WeekendNotificationsiPhoneAndSMS,
    WeekendNotificationsAll
    
} WeekendNotifications;


#define kWakeUpTimeForWeekDays  @"07:00 AM"
#define kWakeUpTimeForWeekEnds  @"08:00 AM"
#define kDefaultTimeZoneName    @"America/Los_Angeles"
#define kDefaultCountry         @"United States"



@interface UserAccountHelper : NSObject

- (void)execHttpRequestWithUrl:(NSString *)url method:(NSString *)method JSONparameters:(NSDictionary *)parameters withCompletion:(HttpCallback)completion;

- (void)retrieveGeneticForecastsArrayWithParameters:(NSDictionary *)parameters withCompletion:(void (^)(NSArray *geneticForecastsArray))completion;
- (void)requestForUserAccountInformationWithAccessToken:(NSString *)accessToken withResult:(void (^)(NSDictionary *accountInfo))result;

// user account methods
- (void)sendEmailSmsAndSettingsInfoWithParameters:(NSDictionary *)parameters;
- (void)sendDevicePushNotificationsSettingsWithParameters:(NSDictionary *)parameters;
- (void)sendSelectedGeneticFileInfoWithParameters:(NSDictionary *)parameters;
- (void)sendSelectedLocationInfoWithParameters:(NSDictionary *)parameters;
- (void)sendSignOutRequestWithParameters:(NSDictionary *)parameters;

// sync settings methods
- (void)retrieveUserSettings:(NSDictionary *)parameters withCompletion:(void (^)(NSDictionary *userAccountSettings))completion;
- (void)sendUserSettingsToServer;
- (void)processUserAccountSettings:(NSDictionary *)userAccountSettings;
- (BOOL)areUserAccountSettingsValid:(NSDictionary *)userAccountSettings;


// settings helper methods for phone number
- (NSString *)encodePhoneNumber:(NSString *)phoneNumber;
- (NSString *)correctPhoneNumber:(NSString *)phoneNumber;

// settings helper methods for weekend notifications
- (NSString *)stringValueOfEnumWeekendNotifications:(WeekendNotifications)notification;
- (int)intValueOfWeekendNotification:(NSString *)stringValue;

// settings helper methods for time zone
- (NSString *)localTimeZoneName;
- (NSDictionary *)availableTimeZones;
- (NSArray *)timeZonesArrayFiltered;
- (NSString *)formatTimeBasedOnSeconds:(NSInteger)seconds;
- (NSString *)convertTimeZoneIntoStringGMTValueByLongTimeZoneName:(NSString *)selectedTimeZone;
- (NSString *)convertTimeZoneNameWithUnderscore:(NSString *)selectedTimeZone;
- (NSString *)convertTimeZoneNameWithoutUnderscore:(NSString *)timeZone;

@end
