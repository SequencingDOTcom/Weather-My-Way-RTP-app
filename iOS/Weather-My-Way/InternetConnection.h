//
//  InternetConnection.h
//  Copyright © 2016 Sequencing. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "Reachability.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>


typedef NS_ENUM(NSInteger, InternetConnectionType) {
    InteractionConnectionTypeWiFi,
    InteractionConnectionType2G,
    InteractionConnectionType3G,
    InteractionConnectionType4G
};

extern NSString *NO_INTERNET_CONNECTION_TEXT;



@interface InternetConnection : NSObject

+ (BOOL)internetConnectionIsAvailable;
+ (InternetConnectionType)detectInternetConnectionType;


@end
