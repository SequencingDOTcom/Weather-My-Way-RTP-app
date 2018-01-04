//
//  SettingsViewController.h
//  Copyright © 2016 Sequencing. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "UIViewControllerWithVideoBackground.h"


typedef NS_ENUM(NSInteger, TemperatureUnit) {
    Fahrenheit,
    Celsius
};



@protocol SettingsViewControllerDelegate <NSObject>

- (void)settingsViewControllerWasClosed:(UIViewController *)controller
                    withTemperatureUnit:(NSNumber *)temperatureUnit
                           selectedFile:(NSDictionary *)file
                    andSelectedLocation:(NSDictionary *)location;

- (void)settingsViewControllerUserDidSignOut:(UIViewController *)controller;

@end



@interface SettingsViewController : UIViewControllerWithVideoBackground

@property (nonatomic) id <SettingsViewControllerDelegate> delegate;
@property (assign, nonatomic) BOOL alreadyExecutingSettingsSyncRequest;

@end
