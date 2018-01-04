//
//  InternetConnection.m
//  Copyright © 2016 Sequencing. All rights reserved.
//


#import "InternetConnection.h"

NSString *NO_INTERNET_CONNECTION_TEXT = @"No internet connection available";


@implementation InternetConnection


+ (BOOL)internetConnectionIsAvailable {
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    
    if (networkStatus == NotReachable)
        // NSLog(@"There IS NO internet connection");
        return NO;
    else
        // NSLog(@"There IS internet connection");
        return YES;
}


+ (InternetConnectionType)detectInternetConnectionType {
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [reachability currentReachabilityStatus];
    switch (status) {
        case NotReachable: return -1; break;
            
        case ReachableViaWiFi:
            return InteractionConnectionTypeWiFi; break;
            
        case ReachableViaWWAN: {
            CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
            // NSString *carrier = [[netinfo subscriberCellularProvider] carrierName];
            NSArray *accessTechnology = @[CTRadioAccessTechnologyGPRS,
                                          CTRadioAccessTechnologyEdge,
                                          CTRadioAccessTechnologyCDMA1x,
                                          CTRadioAccessTechnologyWCDMA,
                                          CTRadioAccessTechnologyHSDPA,
                                          CTRadioAccessTechnologyHSUPA,
                                          CTRadioAccessTechnologyCDMAEVDORev0,
                                          CTRadioAccessTechnologyCDMAEVDORevA,
                                          CTRadioAccessTechnologyCDMAEVDORevB,
                                          CTRadioAccessTechnologyeHRPD,
                                          CTRadioAccessTechnologyLTE];
            int index = (int)[accessTechnology indexOfObject:netinfo.currentRadioAccessTechnology];
            
            switch (index) {
                case 0:
                case 1:
                case 2:
                    return InteractionConnectionType2G; break;
                case 3:
                case 4:
                case 5:
                case 6:
                case 7:
                case 8:
                case 9:
                    return InteractionConnectionType3G; break;
                case 10:
                    return InteractionConnectionType4G; break;
                default: return -1; break;
            }
        } break;
            
        default: return -1; break;
    }
}

@end
