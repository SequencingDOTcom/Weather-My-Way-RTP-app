//
//  AboutViewController.h
//  Copyright © 2016 Sequencing. All rights reserved.
//


#import <UIKit/UIKit.h>
@class AboutViewController;


@protocol AboutViewControllerDelegate <NSObject>

- (void)AboutViewController:(AboutViewController *)controller closeButtonPressed:(id)sender;

@end



@interface AboutViewController : UIViewController

@property (nonatomic) id <AboutViewControllerDelegate> delegate;

@end
