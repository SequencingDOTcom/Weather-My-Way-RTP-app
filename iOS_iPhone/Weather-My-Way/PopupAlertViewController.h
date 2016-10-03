//
//  AlertViewController.h
//  Copyright © 2016 Sequencing. All rights reserved.
//


#import <UIKit/UIKit.h>

@class PopupAlertViewController;


@protocol PopupAlertViewControllerDelegate <NSObject>

- (void)popupAlertViewController:(PopupAlertViewController *)controller closeButtonPressed:(id)sender;

@end



@interface PopupAlertViewController : UIViewController

@property (strong, nonatomic) NSString *alertsMessageText;
@property (weak, nonatomic) id <PopupAlertViewControllerDelegate> delegate;

@end
