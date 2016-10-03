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
    
    if (networkStatus == NotReachable) {
        // NSLog(@"There IS NO internet connection");
        return NO;
    } else {
        // NSLog(@"There IS internet connection");
        return YES;
    }
}

@end
