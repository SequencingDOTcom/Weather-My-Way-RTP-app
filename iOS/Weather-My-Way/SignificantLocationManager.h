//
//  SignificantLocationManager.h
//  Copyright © 2017 Sequencing. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>



@interface SignificantLocationManager : NSObject

+ (instancetype)sharedInstance;
- (void)startMonitoringSignificantLocationChange;

@end
