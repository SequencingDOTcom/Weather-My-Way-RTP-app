//
//  ObserverManager.h
//  Copyright © 2017 Sequencing. All rights reserved.
//


#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, InteractionType) {
    InteractionTypeNoData = -1,
    InteractionTypeForeground,
    InteractionTypeBackground
};

typedef NS_ENUM(NSInteger, ServiceType) {
    ServiceTypeNoData = -1,
    ServiceTypeWunderground,
    ServiceTypeAppChains
};


@interface ObserverManager : NSObject

+ (instancetype)sharedInstance;
- (void)startMonitoringInteractions;


@end
