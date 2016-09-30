//
//  SettingsViewController.h
//  Copyright © 2016 Sequencing. All rights reserved.
//


#import <UIKit/UIKit.h>
@class SettingsViewController;

typedef NS_ENUM(NSInteger, TemperatureUnit) {
    Fahrenheit,
    Celsius
};


@protocol SettingsViewControllerDelegate <NSObject>

- (void)settingsViewControllerWasClosed:(SettingsViewController *)controller
                    withTemperatureUnit:(NSNumber *)temperatureUnit
                           selectedFile:(NSDictionary *)file
                    andSelectedLocation:(NSDictionary *)location;

- (void)settingsViewControllerUserDidSignOut:(SettingsViewController *)controller;

@end



@interface SettingsViewController : UIViewController

@property (nonatomic) id <SettingsViewControllerDelegate> delegate;
@property (assign, nonatomic) BOOL alreadyExecutingSettingsSyncRequest;

@end
