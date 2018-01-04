//
//  PrepareForecastViewController.h
//  Copyright © 2016 Sequencing. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "UIViewControllerWithVideoBackground.h"


@interface PrepareForecastViewController : UIViewControllerWithVideoBackground

@property (assign, nonatomic) BOOL isUserFromLoginScreen;
@property (assign, nonatomic) BOOL alreadyGotUserAccountInfo;
@property (assign, nonatomic) BOOL alreadyGotUserGPSLocation;

@end
