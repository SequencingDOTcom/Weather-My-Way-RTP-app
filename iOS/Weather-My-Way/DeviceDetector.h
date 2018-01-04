//
//  DeviceDetector.h
//  Copyright © 2017 Sequencing. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import <sys/utsname.h>
#include <sys/sysctl.h>
#include <sys/types.h>
#include <mach/machine.h>



@interface DeviceDetector : NSObject

+ (NSString *)osName;
+ (NSString *)osVersion;

+ (NSString *)cpuArchitecture;
+ (NSString *)deviceModel;
+ (NSString *)deviceUUID;

+ (NSString *)appVersion;

@end
