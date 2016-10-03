//
//  AboutViewController.h
//  Copyright © 2016 Sequencing. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "AboutMoreViewController.h"

@class AboutViewController;


@protocol AboutViewControllerDelegate <NSObject>

- (void)AboutViewController:(AboutViewController *)controller closeButtonPressed:(id)sender;

@end


@interface AboutViewController : UIViewController <AboutMoreViewControllerDelegate>

@property (nonatomic) id <AboutViewControllerDelegate> delegate;

@end
