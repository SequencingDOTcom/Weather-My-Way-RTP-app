//
//  AboutMoreViewController.h
//  Copyright © 2016 Sequencing. All rights reserved.
//


#import <UIKit/UIKit.h>

@class AboutMoreViewController;


@protocol AboutMoreViewControllerDelegate <NSObject>

- (void)AboutMoreViewController:(AboutMoreViewController *)controller backButtonPressed:(id)sender;

@end


@interface AboutMoreViewController : UIViewController

@property (nonatomic) id <AboutMoreViewControllerDelegate> delegate;

@end
