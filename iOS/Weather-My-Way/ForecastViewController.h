//
//  ForecastViewController.h
//  Copyright © 2016 Sequencing. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "SidebarMenuViewController.h"
#import "AboutViewController.h"
#import "SettingsViewController.h"
#import "LocationViewController.h"
#import "AlertMessage.h"
#import "PopupAlertViewController.h"
#import "TraitCollectionOverrideViewController.h"


@interface ForecastViewController : TraitCollectionOverrideViewController <AboutViewControllerDelegate, SettingsViewControllerDelegate, AlertMessageDialogDelegate, LocationViewControllerDelegate, PopupAlertViewControllerDelegate>

@property (nonatomic, weak) IBOutlet UIBarButtonItem *menuButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *refreshButton;
@property (nonatomic, strong) NSDictionary *forecast;

@end
