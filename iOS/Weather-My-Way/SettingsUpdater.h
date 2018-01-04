//
//  SettingsUpdater.h
//  Copyright © 2016 Sequencing. All rights reserved.
//


#import <Foundation/Foundation.h>


@protocol SettingsUpdaterDelegate <NSObject>

- (void)settingsSyncRequestStarted;
- (void)settingsSyncRequestFinished;

@end



@interface SettingsUpdater : NSObject

@property (weak, nonatomic) id <SettingsUpdaterDelegate> delegate;

// designated initializer
+ (instancetype)sharedInstance;

- (void)startTimer;
- (void)cancelTimer;
- (void)retrieveUserSettings;

@end
