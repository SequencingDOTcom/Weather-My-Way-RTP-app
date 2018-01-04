//
//  LoggerManager.h
//  Copyright © 2017 Sequencing. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface LoggerManager : NSObject

+ (long long)saveInteraction:(NSDictionary *)interaction;
+ (void)updateInteraction:   (NSDictionary *)interaction;

+ (long long)saveService:(NSDictionary *)service;
+ (void)updateService:   (NSDictionary *)service;

+ (NSNumber *)loadLastReportTime;
+ (void)saveNewReportTime:(NSNumber *)reportTime;

+ (void)cleanInteractionsAndServices;

+ (NSDictionary *)loadBackgroundWundergroundServices;
+ (NSDictionary *)loadBackgroundAppchainsServices;


+ (NSDictionary *)loadForegroundInteractions;
+ (NSDictionary *)loadForegroundWundergroundServicesByInteractionID:(NSNumber *)interactionID;
+ (NSDictionary *)loadForegroundAppchainsServicesByInteractionID:   (NSNumber *)interactionID;

@end
