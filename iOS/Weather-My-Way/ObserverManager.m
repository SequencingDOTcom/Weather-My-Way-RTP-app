//
//  ObserverManager.m
//  Copyright © 2017 Sequencing. All rights reserved.
//


#import "ObserverManager.h"
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"
#import "DeviceDetector.h"
#import "ConstantsList.h"
#import "LoggerManager.h"
#import "InternetConnection.h"
#import "ReportManager.h"



@interface ObserverManager ()

@property (assign, nonatomic) UIBackgroundTaskIdentifier backgroundTask;
@property (strong, nonatomic) NSNumber *lastReportTimestamp;

// table of foreground sessions
@property (strong, nonatomic) NSNumber *interactionID;
@property (strong, nonatomic) NSNumber *latitude;
@property (strong, nonatomic) NSNumber *longitude;
@property (strong, nonatomic) NSString *place;
@property (strong, nonatomic) NSNumber *interactionTimestamp;
@property (strong, nonatomic) NSNumber *interactionDuration;
@property (strong, nonatomic) NSNumber *interactionConnection;

// table of service sessions
// @property (strong, nonatomic) NSNumber *interactionType;
// @property (strong, nonatomic) NSNumber *serviceType;
@property (assign, nonatomic) InteractionType interactionType;

@property (assign, nonatomic) ServiceType     wu_serviceType;
@property (strong, nonatomic) NSNumber        *wu_serviceID;
@property (strong, nonatomic) NSNumber        *wu_serviceTimestamp;
@property (strong, nonatomic) NSNumber        *wu_serviceDuration;
@property (strong, nonatomic) NSNumber        *wu_failureTimestamp;
@property (strong, nonatomic) NSString        *wu_failureDescription;

@property (assign, nonatomic) ServiceType     app_serviceType;
@property (strong, nonatomic) NSNumber        *app_serviceID;
@property (strong, nonatomic) NSNumber        *app_serviceTimestamp;
@property (strong, nonatomic) NSNumber        *app_serviceDuration;
@property (strong, nonatomic) NSNumber        *app_failureTimestamp;
@property (strong, nonatomic) NSString        *app_failureDescription;

@end




#pragma mark -
@implementation ObserverManager

+ (instancetype)sharedInstance {
    static ObserverManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ObserverManager alloc] init];
    });
    return instance;
}


- (void)startMonitoringInteractions {
    [self cleanOldInteractionData];
    [self addNotificationObserves];
    [self checkWhetherWeNeedToSendReport];
}



#pragma mark - Clean old Data
- (void)cleanOldInteractionData {
    self.interactionID          = nil;
    self.latitude               = nil;
    self.longitude              = nil;
    self.place                  = nil;
    self.interactionTimestamp   = nil;
    self.interactionDuration    = nil;
    self.interactionConnection  = nil;
    
    self.interactionType        = InteractionTypeNoData;
    [self cleanOldServiceData:ServiceTypeWunderground];
    [self cleanOldServiceData:ServiceTypeAppChains];
}

- (void)cleanOldServiceData:(ServiceType)service {
    switch (service) {
        case ServiceTypeWunderground: {
            self.wu_serviceType         = ServiceTypeNoData;
            self.wu_serviceID           = nil;
            self.wu_serviceTimestamp    = nil;
            self.wu_serviceDuration     = nil;
            self.wu_failureTimestamp    = nil;
            self.wu_failureDescription  = nil;
        }   break;
            
        case ServiceTypeAppChains: {
            self.app_serviceType        = ServiceTypeNoData;
            self.app_serviceID          = nil;
            self.app_serviceTimestamp   = nil;
            self.app_serviceDuration    = nil;
            self.app_failureTimestamp   = nil;
            self.app_failureDescription = nil;
        }   break;
        default: break;
    }
    
}




#pragma mark - 
#pragma mark - Interactions
- (void)foregroundSessionStarted {
    NSLog(@"=== foregroundSessionStarted");
    [self checkWhetherWeNeedToSendReport];
    
    if (self.interactionType == InteractionTypeForeground)
        [self closeCurrentInteractionRecord];
    
    [self cleanOldInteractionData];
    [self setStartDataForNewInteractionSession:InteractionTypeForeground];
    [self createInteractionRecord];
}


- (void)backgroundSessionStarted {
    NSLog(@"=== backgroundSessionStarted");
    if (self.interactionType == InteractionTypeForeground)
        [self saveForegroundSessionDataInBackgroundMode];
    else {
        [self cleanOldInteractionData];
        [self setStartDataForNewInteractionSession:InteractionTypeBackground];
    }
}

- (void)saveForegroundSessionDataInBackgroundMode {
    self.backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [self endBackgroundTask];
    }];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self closeCurrentInteractionRecord];
        
        [self setStartDataForNewInteractionSession:InteractionTypeBackground];
        [self endBackgroundTask];
    });
}
- (void)endBackgroundTask {
    [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
    self.backgroundTask = UIBackgroundTaskInvalid;
}

- (void)appIsTerminated {
    if (self.interactionType == InteractionTypeForeground)
        [self saveForegroundSessionDataInBackgroundMode];
}



- (void)setStartDataForNewInteractionSession:(InteractionType)interaction {
    self.interactionType = interaction;
    
    if (interaction == InteractionTypeForeground) {
        self.interactionTimestamp  = [NSNumber numberWithLongLong:[self unixCurrentTimestamp]];
        self.interactionDuration   = [NSNumber numberWithLongLong:0];
        self.interactionConnection = [NSNumber numberWithInt:[self connectionType]];
    }
}


- (void)closeCurrentInteractionRecord {
    self.interactionDuration = [NSNumber numberWithLongLong:[self durationForTimestamp:self.interactionTimestamp]];
    [self updateInteractionRecord];
    [self cleanOldInteractionData];
}


- (void)createInteractionRecord {
    NSDictionary *interactionData = [self prepareDataForInteractionRecord];
    long long rowID = [LoggerManager saveInteraction:interactionData];
    
    if (rowID >= 0) self.interactionID = [NSNumber numberWithLongLong:rowID];
    NSLog(@"=== createInteractionRecord, recordID: %lld", rowID);
}


- (void)updateInteractionRecord {
    NSLog(@"=== updateInteractionRecord");
    NSDictionary *interactionData = [self prepareDataForInteractionRecord];
    [LoggerManager updateInteraction:interactionData];
}


- (NSDictionary *)prepareDataForInteractionRecord {
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    [data setObject:self.interactionID          ? self.interactionID        : [NSNull null] forKey:dict_interactionIDKey];
    [data setObject:self.latitude               ? self.latitude             : [NSNull null] forKey:dict_latitudeKey];
    [data setObject:self.longitude              ? self.longitude            : [NSNull null] forKey:dict_longitudeKey];
    [data setObject:self.place                  ? self.place                : [NSNull null] forKey:dict_placeKey];
    [data setObject:self.interactionTimestamp   ? self.interactionTimestamp : [NSNull null] forKey:dict_interactionTimeKey];
    [data setObject:self.interactionDuration    ? self.interactionDuration  : [NSNull null] forKey:dict_interactionDurationKey];
    [data setObject:self.interactionConnection  ? self.interactionConnection: [NSNull null] forKey:dict_connectionTypeKey];
    return [NSDictionary dictionaryWithDictionary:data];
}




#pragma mark - Interaction Events
- (void)gpsCoordinatesDetected:(NSNotification *)notification {
    if (self.interactionType == InteractionTypeForeground) {
        
        CLLocation *cllocation = [notification.userInfo objectForKey:dict_cllocationKey];
        float latitude  = cllocation.coordinate.latitude;
        float longitude = cllocation.coordinate.longitude;
        
        BOOL shouldUpdate = NO;
        if (!self.latitude || !self.longitude) shouldUpdate = YES;
        self.latitude  = [NSNumber numberWithFloat:latitude];
        self.longitude = [NSNumber numberWithFloat:longitude];
        
        if (shouldUpdate) // update interaction record
            [self updateInteractionRecord];
    }
}



- (void)locationNameDefined:(NSNotification *)notification {
    if (self.interactionType == InteractionTypeForeground) {
        
        NSString *place = [notification.userInfo objectForKey:dict_placeKey];
        CLLocation *cllocation = [notification.userInfo objectForKey:dict_cllocationKey];
        float latitude  = cllocation.coordinate.latitude;
        float longitude = cllocation.coordinate.longitude;
        
        if (!self.latitude || !self.longitude) {
            self.latitude  = [NSNumber numberWithFloat:latitude];
            self.longitude = [NSNumber numberWithFloat:longitude];
        }
        
        if (!self.place) { // update update interaction record
            self.place = place;
            [self updateInteractionRecord];
            
        } else {
            // is it the same location or new?
            // create new interaction record only if location changed
            if (![self.place isEqualToString:place]) {
                [self closeCurrentInteractionRecord];
                
                [self cleanOldInteractionData];
                [self setStartDataForNewInteractionSession:InteractionTypeForeground];
                self.latitude  = [NSNumber numberWithFloat:latitude];
                self.longitude = [NSNumber numberWithFloat:longitude];
                self.place     = place;
                [self createInteractionRecord];
            }
        }
    }
}




#pragma mark -
#pragma mark - Service events

- (void)wundergroundRequestStarted:(NSNotification *)notification {
    NSLog(@"=== wunderground started");
    [self serviceRequestStarted:ServiceTypeWunderground];
}

- (void)wundergroundRequestFinished:(NSNotification *)notification {
    NSLog(@"=== wunderground finished");
    [self serviceRequestFinished:ServiceTypeWunderground];
}

- (void)wundergroundRequestFailed:(NSNotification *)notification {
    NSLog(@"=== wunderground failed");
    [self serviceRequestFailed:ServiceTypeWunderground notification:notification];
}



- (void)appchainsRequestStarted:(NSNotification *)notification {
    NSLog(@"=== appchains started");
    [self serviceRequestStarted:ServiceTypeAppChains];
}

- (void)appchainsRequestFinished:(NSNotification *)notification {
    NSLog(@"=== appchains finished");
    [self serviceRequestFinished:ServiceTypeAppChains];
}

- (void)appchainsRequestFailed:(NSNotification *)notification {
    NSLog(@"=== appchains failed");
    [self serviceRequestFailed:ServiceTypeAppChains notification:notification];
}




- (void)serviceRequestStarted:(ServiceType)service {
    switch (service) {
        case ServiceTypeWunderground: {
            if (self.wu_serviceType != ServiceTypeNoData || self.wu_serviceID)
                [self closeCurrentServiceRecord:service];
            self.wu_serviceType = service;
        }   break;
            
        case ServiceTypeAppChains: {
            if (self.app_serviceType != ServiceTypeNoData || self.app_serviceID)
                [self closeCurrentServiceRecord:service];
            self.app_serviceType = service;
        }   break;
        default: break;
    }
    
    [self setStartDataForNewService:service];
    [self createServiceRecord:service];
}


- (void)serviceRequestFinished:(ServiceType)service {
    [self closeCurrentServiceRecord:service];
}


- (void)serviceRequestFailed:(ServiceType)service notification:(NSNotification *)notification {
    switch (service) {
        case ServiceTypeWunderground: {
            self.wu_failureTimestamp   = [NSNumber numberWithLongLong:[self unixCurrentTimestamp]];
            self.wu_failureDescription = [notification.userInfo objectForKey:dict_failureDescriptionKey];
        }   break;
            
        case ServiceTypeAppChains: {
            self.app_failureTimestamp   = [NSNumber numberWithLongLong:[self unixCurrentTimestamp]];
            self.app_failureDescription = [notification.userInfo objectForKey:dict_failureDescriptionKey];
        }   break;
        default: break;
    }
    
    [self closeCurrentServiceRecord:service];
}




#pragma mark - Save service

- (void)setStartDataForNewService:(ServiceType)service {
    switch (service) {
        case ServiceTypeWunderground: {
            self.wu_serviceTimestamp = [NSNumber numberWithLongLong:[self unixCurrentTimestamp]];
            self.wu_serviceDuration  = [NSNumber numberWithLongLong:0];
        }   break;
            
        case ServiceTypeAppChains: {
            self.app_serviceTimestamp = [NSNumber numberWithLongLong:[self unixCurrentTimestamp]];
            self.app_serviceDuration  = [NSNumber numberWithLongLong:0];
        }   break;
        default: break;
    }
}


- (void)closeCurrentServiceRecord:(ServiceType)service {
    switch (service) {
        case ServiceTypeWunderground:
            self.wu_serviceDuration  = [NSNumber numberWithLongLong:[self durationForTimestamp:self.wu_serviceTimestamp]];
            break;
            
        case ServiceTypeAppChains:
            self.app_serviceDuration = [NSNumber numberWithLongLong:[self durationForTimestamp:self.app_serviceTimestamp]];
            break;
        default: break;
    }

    [self updateServiceRecord:service];
    [self cleanOldServiceData:service];
}


- (void)createServiceRecord:(ServiceType)service {
    switch (service) {
        case ServiceTypeWunderground: {
            NSDictionary *serviceData = [self prepareDataForServiceRecord:service];
            long long rowID = [LoggerManager saveService:serviceData];
            
            if (rowID >= 0) self.wu_serviceID = [NSNumber numberWithLongLong:rowID];
            NSLog(@"=== createServiceRecord %@, recordID: %lld", [self serviceTypeToString:service], rowID);
        }   break;
            
        case ServiceTypeAppChains: {
            NSDictionary *serviceData = [self prepareDataForServiceRecord:service];
            long long rowID = [LoggerManager saveService:serviceData];
            
            if (rowID >= 0) self.app_serviceID = [NSNumber numberWithLongLong:rowID];
            NSLog(@"=== createServiceRecord %@, recordID: %lld", [self serviceTypeToString:service], rowID);
        }   break;
        default: break;
    }
}


- (void)updateServiceRecord:(ServiceType)service {
    NSDictionary *serviceData;
    switch (service) {
        case ServiceTypeWunderground: {
            NSLog(@"=== updateServiceRecord %@", [self serviceTypeToString:service]);
            serviceData = [self prepareDataForServiceRecord:service];
        }   break;
            
        case ServiceTypeAppChains: {
            NSLog(@"=== updateServiceRecord %@", [self serviceTypeToString:service]);
            serviceData = [self prepareDataForServiceRecord:service];
        }   break;
        default: break;
    }
    
    [LoggerManager updateService:serviceData];
}


- (NSDictionary *)prepareDataForServiceRecord:(ServiceType)service {
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    
    switch (service) {
        case ServiceTypeWunderground: {
            [data setObject:self.wu_serviceID           ? self.wu_serviceID           : [NSNull null]   forKey:dict_serviceIDKey];
            [data setObject:self.interactionID          ? self.interactionID          : [NSNull null]   forKey:dict_interactionIDKey];
            [data setObject:[self correctInteractionTypeDependingOnApplicationState]                    forKey:dict_interactionTypeKey];
            [data setObject:[self serviceTypeToString:service]                                          forKey:dict_serviceTypeKey];
            [data setObject:self.wu_serviceTimestamp    ? self.wu_serviceTimestamp    : [NSNull null]   forKey:dict_serviceTimeKey];
            [data setObject:self.wu_serviceDuration     ? self.wu_serviceDuration     : [NSNull null]   forKey:dict_serviceDurationKey];
            [data setObject:self.wu_failureTimestamp    ? self.wu_failureTimestamp    : [NSNull null]   forKey:dict_serviceFailureTimeKey];
            [data setObject:self.wu_failureDescription  ? self.wu_failureDescription  : [NSNull null]   forKey:dict_serviceFailureReasonKey];
        }   break;
            
        case ServiceTypeAppChains: {
            [data setObject:self.app_serviceID          ? self.app_serviceID          : [NSNull null]   forKey:dict_serviceIDKey];
            [data setObject:self.interactionID          ? self.interactionID          : [NSNull null]   forKey:dict_interactionIDKey];
            [data setObject:[self correctInteractionTypeDependingOnApplicationState]                    forKey:dict_interactionTypeKey];
            [data setObject:[self serviceTypeToString:service]                                          forKey:dict_serviceTypeKey];
            [data setObject:self.app_serviceTimestamp   ? self.app_serviceTimestamp   : [NSNull null]   forKey:dict_serviceTimeKey];
            [data setObject:self.app_serviceDuration    ? self.app_serviceDuration    : [NSNull null]   forKey:dict_serviceDurationKey];
            [data setObject:self.app_failureTimestamp   ? self.app_failureTimestamp   : [NSNull null]   forKey:dict_serviceFailureTimeKey];
            [data setObject:self.app_failureDescription ? self.app_failureDescription : [NSNull null]   forKey:dict_serviceFailureReasonKey];
        }   break;
        default: break;
    }
    
    return [NSDictionary dictionaryWithDictionary:data];
}




#pragma mark -
#pragma mark - Report methods

- (void)checkWhetherWeNeedToSendReport {
    NSNumber *lastReportTimestamp = [LoggerManager loadLastReportTime];
    
    if (!lastReportTimestamp)
        [self saveTimestampForNewReport];
    
    else if ([self calculateHoursSinseLastReport:lastReportTimestamp] >= 23) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reportSentSuccessfully)
                                                     name:LOG_REPORT_WAS_SENT_SUCCESSFULLY_NOTIFICATION_KEY
                                                   object:nil];
        [ReportManager prepareAndSendLoggingReport];
    }
}


- (void)reportSentSuccessfully {
    [LoggerManager cleanInteractionsAndServices];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LOG_REPORT_WAS_SENT_SUCCESSFULLY_NOTIFICATION_KEY object:nil];
    [self saveTimestampForNewReport];
}


- (void)saveTimestampForNewReport {
    [LoggerManager saveNewReportTime:[NSNumber numberWithLongLong:[self unixCurrentTimestamp]]];
}


- (float)calculateHoursSinseLastReport:(NSNumber *)timestamp {
    long long durationMilliseconds = [self durationForTimestamp:timestamp];
    float durationHours = (((durationMilliseconds / 1000.0) / 60.0) / 60.0);
    return durationHours;
}




#pragma mark -
#pragma mark - Helper methods

- (long long)unixCurrentTimestamp {
    return (long long)([[NSDate date] timeIntervalSince1970] * 1000);
}


- (long long)durationForTimestamp:(NSNumber *)unixTimestamp {
    return ([self unixCurrentTimestamp] - [unixTimestamp longLongValue]);
}





#pragma mark - Defice info

- (int)connectionType {
    switch ([InternetConnection detectInternetConnectionType]) {
        case InteractionConnectionTypeWiFi: return 0; break;
        case InteractionConnectionType2G:   return 1; break;
        case InteractionConnectionType3G:   return 2; break;
        case InteractionConnectionType4G:   return 3; break;
        default: return 4; break;
    }
}




#pragma mark - Getter / Setter

- (id)interactionTypeToString {
    switch (self.interactionType) {
        case InteractionTypeForeground: return foregroundInteractionType; break;
        case InteractionTypeBackground: return backgroundInteractionType; break;
        default: return [NSNull null]; break;
    }
}


- (NSString *)correctInteractionTypeDependingOnApplicationState {
    UIApplicationState applicationState = [[UIApplication sharedApplication] applicationState];
    
    if (applicationState == UIApplicationStateActive)
        return foregroundInteractionType;
    else
        return backgroundInteractionType;
}


- (InteractionType)stringToInteractionType:(NSString *)string {
    if ([string containsString:foregroundInteractionType])
        return InteractionTypeForeground;
    
    else if ([string containsString:backgroundInteractionType])
        return InteractionTypeBackground;
    
    else
        return InteractionTypeNoData;
}


- (id)serviceTypeToString:(ServiceType)service {
    switch (service) {
        case ServiceTypeWunderground: return wundergroundServiceType; break;
        case ServiceTypeAppChains:    return appChainsServiceType; break;
        default: return [NSNull null]; break;
    }
}


- (ServiceType)stringToServiceType:(NSString *)string {
    if ([string containsString:wundergroundServiceType])
        return ServiceTypeWunderground;
    
    else if ([string containsString:appChainsServiceType])
        return ServiceTypeAppChains;
    else
        return ServiceTypeNoData;
}




#pragma mark - Notification Observes
- (void)addNotificationObserves {
    // app is in foreground
    // UIApplicationDidBecomeActiveNotification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(foregroundSessionStarted)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    // app is in background
    // UIApplicationDidEnterBackgroundNotification
    // UIApplicationWillResignActiveNotification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(backgroundSessionStarted)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    // app is terminated
    // UIApplicationWillTerminateNotification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appIsTerminated)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
    
    // interaction events
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gpsCoordinatesDetected:)
                                                 name:GPS_COORDINATES_DETECTED_NOTIFICATION_KEY
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(locationNameDefined:)
                                                 name:LOCATION_NAME_DEFINED_NOTIFICATION_KEY
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(wundergroundRequestStarted:)
                                                 name:WUNDERGROUND_FORECAST_REQUEST_STARTED_NOTIFICATION_KEY
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(wundergroundRequestFinished:)
                                                 name:WUNDERGROUND_FORECAST_REQUEST_FINISHED_NOTIFICATION_KEY
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(wundergroundRequestFailed:)
                                                 name:WUNDERGROUND_FORECAST_REQUEST_FAILED_NOTIFICATION_KEY
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appchainsRequestStarted:)
                                                 name:APPCHAINS_REQUEST_STARTED_NOTIFICATION_KEY
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appchainsRequestFinished:)
                                                 name:APPCHAINS_REQUEST_FINISHED_NOTIFICATION_KEY
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appchainsRequestFailed:)
                                                 name:APPCHAINS_REQUEST_FAILED_NOTIFICATION_KEY
                                               object:nil];
}


@end
