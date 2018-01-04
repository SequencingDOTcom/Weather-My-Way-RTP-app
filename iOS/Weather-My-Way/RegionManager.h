//
//  RegionManager.h
//  Copyright © 2017 Sequencing. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface RegionManager : NSObject

+ (instancetype)sharedInstance;
- (void)startMonitoringForGPSDetection;

@end
