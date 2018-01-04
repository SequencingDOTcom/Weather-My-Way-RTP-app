//
//  DeviceDetector.m
//  Copyright © 2017 Sequencing. All rights reserved.
//


#import "DeviceDetector.h"


@implementation DeviceDetector


+ (NSString *)osName {
    return @"iOS";
}


+ (NSString *)osVersion {
    return [[UIDevice currentDevice] systemVersion];
}


+ (NSString *)deviceUUID {
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}


+ (NSString *)appVersion {
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *build   = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    return [NSString stringWithFormat:@"v%@(%@)", version, build];
}



+ (NSString *)cpuArchitecture {
    NSMutableString *cpu = [[NSMutableString alloc] init];
    size_t size;
    cpu_type_t type;
    cpu_subtype_t subtype;
    size = sizeof(type);
    sysctlbyname("hw.cputype", &type, &size, NULL, 0);
    
    size = sizeof(subtype);
    sysctlbyname("hw.cpusubtype", &subtype, &size, NULL, 0);
    
    // values for cputype and cpusubtype defined in mach/machine.h
    if (type == CPU_TYPE_X86_64) {
        [cpu appendString:@"x86_64"];
        
    } else if (type == CPU_TYPE_X86) {
        [cpu appendString:@"x86"];
        
    } else if (type == CPU_TYPE_ARM) {
        [cpu appendString:@"ARM"];
        
        switch (subtype) {
            case CPU_SUBTYPE_ARM_V6:
                [cpu appendString:@"v6"];
                break;
            case CPU_SUBTYPE_ARM_V7:
                [cpu appendString:@"v7"];
                break;
            case CPU_SUBTYPE_ARM_V8:
                [cpu appendString:@"v8"];
                break;
        }
        
    } else if (type == CPU_TYPE_I386) {
        [cpu appendString:@"i386"];
        
    } else {
        [cpu appendString:@"unknown"];
    }
    
    return cpu;
}



+ (NSString *)deviceModel {
    struct utsname systemInfo;
    uname(&systemInfo);
    
    NSString *code = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    static NSDictionary *deviceNamesByCode = nil;
    
    if (!deviceNamesByCode) {
        deviceNamesByCode = @{@"i386"      :@"Simulator",
                              @"x86_64"    :@"Simulator",
                              
                              @"iPod1,1"   :@"iPod Touch",        // (Original)
                              @"iPod2,1"   :@"iPod Touch 2",      // (Second Generation)
                              @"iPod3,1"   :@"iPod Touch 3",      // (Third Generation)
                              @"iPod4,1"   :@"iPod Touch 4",      // (Fourth Generation)
                              @"iPod7,1"   :@"iPod Touch 6",      // (6th Generation)
                              
                              @"iPhone1,1" :@"iPhone",            // (Original)
                              @"iPhone1,2" :@"iPhone 3G",         // (3G)
                              @"iPhone2,1" :@"iPhone 3GS",        // (3GS)
                              @"iPhone3,1" :@"iPhone 4",          // (GSM)
                              @"iPhone3,3" :@"iPhone 4",          // (CDMA/Verizon/Sprint)
                              @"iPhone4,1" :@"iPhone 4S",         //
                              @"iPhone5,1" :@"iPhone 5",          // (model A1428, AT&T/Canada)
                              @"iPhone5,2" :@"iPhone 5",          // (model A1429, everything else)
                              @"iPhone5,3" :@"iPhone 5C",         // (model A1456, A1532 | GSM)
                              @"iPhone5,4" :@"iPhone 5C",         // (model A1507, A1516, A1526 (China), A1529 | Global)
                              @"iPhone6,1" :@"iPhone 5S",         // (model A1433, A1533 | GSM)
                              @"iPhone6,2" :@"iPhone 5S",         // (model A1457, A1518, A1528 (China), A1530 | Global)
                              @"iPhone7,1" :@"iPhone 6 Plus",     //
                              @"iPhone7,2" :@"iPhone 6",          //
                              @"iPhone8,1" :@"iPhone 6S",         //
                              @"iPhone8,2" :@"iPhone 6S Plus",    //
                              @"iPhone8,4" :@"iPhone SE",         //
                              @"iPhone9,1" :@"iPhone 7",          //
                              @"iPhone9,2" :@"iPhone 7 Plus",     //
                              @"iPhone9,3" :@"iPhone 7",          //
                              @"iPhone9,4" :@"iPhone 7 Plus",     //
                              
                              @"iPad1,1"   :@"iPad",              // (Original)
                              @"iPad2,1"   :@"iPad 2",            //
                              @"iPad2,5"   :@"iPad Mini",         // (Original)
                              @"iPad3,1"   :@"iPad 3",            // (3rd Generation)
                              @"iPad3,4"   :@"iPad 4",            // (4th Generation)
                              @"iPad4,1"   :@"iPad Air",          // 5th Generation iPad (iPad Air) - Wifi
                              @"iPad4,2"   :@"iPad Air",          // 5th Generation iPad (iPad Air) - Cellular
                              @"iPad4,4"   :@"iPad Mini 2",       // (2nd Generation iPad Mini - Wifi)
                              @"iPad4,5"   :@"iPad Mini 2",       // (2nd Generation iPad Mini - Cellular)
                              @"iPad4,7"   :@"iPad Mini 3",       // (3rd Generation iPad Mini - Wifi (model A1599))
                              @"iPad6,3"   :@"iPad Pro (9.7\")",  // iPad Pro 9.7 inches - (model A1673)
                              @"iPad6,4"   :@"iPad Pro (9.7\")",  // iPad Pro 9.7 inches - (models A1674 and A1675)
                              @"iPad6,7"   :@"iPad Pro (12.9\")", // iPad Pro 12.9 inches - (model A1584)
                              @"iPad6,8"   :@"iPad Pro (12.9\")"  // iPad Pro 12.9 inches - (model A1652)
                              };
    }
    
    NSString *deviceName = [deviceNamesByCode objectForKey:code];
    
    if (!deviceName) {
        // Not found on database. At least guess main device type from string contents:
        if ([code rangeOfString:@"iPod"].location != NSNotFound) {
            deviceName = @"iPod Touch";
            
        } else if([code rangeOfString:@"iPad"].location != NSNotFound) {
            deviceName = @"iPad";
            
        } else if([code rangeOfString:@"iPhone"].location != NSNotFound) {
            deviceName = @"iPhone";
            
        } else {
            deviceName = @"Unknown device";
        }
    }
    
    return deviceName;
}



@end
