//
//  SQTokenUpdater.h
//  Copyright © 2015-2016 Sequencing.com. All rights reserved
//

#import <Foundation/Foundation.h>

@interface SQTokenUpdater : NSObject

// designated initializer
+ (instancetype)sharedInstance;

// start timer should be launched once user is authorized, in order to start access_token being automatically refreshed
- (void)startTimer;

// cancelTimer should be launched when user is loged out, in order to stop refreshing access_token
- (void)cancelTimer;


@end
