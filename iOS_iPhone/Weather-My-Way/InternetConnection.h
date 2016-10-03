//
//  InternetConnection.h
//  Copyright © 2016 Sequencing. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "Reachability.h"


extern NSString *NO_INTERNET_CONNECTION_TEXT;


@interface InternetConnection : NSObject

+ (BOOL)internetConnectionIsAvailable;

@end
