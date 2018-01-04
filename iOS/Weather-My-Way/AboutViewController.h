//
//  AboutViewController.h
//  Copyright © 2016 Sequencing. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "UIViewControllerWithVideoBackground.h"


@protocol AboutViewControllerDelegate <NSObject>

- (void)AboutViewController:(UIViewController *)controller closeButtonPressed:(id)sender;

@end



@interface AboutViewController : UIViewControllerWithVideoBackground

@property (nonatomic) id <AboutViewControllerDelegate> delegate;

@end
