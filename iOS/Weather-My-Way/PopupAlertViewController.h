//
//  AlertViewController.h
//  Copyright © 2016 Sequencing. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "UIViewControllerWithVideoBackground.h"



@protocol PopupAlertViewControllerDelegate <NSObject>

- (void)popupAlertViewController:(UIViewController *)controller closeButtonPressed:(id)sender;

@end



@interface PopupAlertViewController : UIViewControllerWithVideoBackground

@property (weak, nonatomic) id <PopupAlertViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *alertsMessage;
@property (strong, nonatomic) NSString       *alertsMessageText;


@end
