//
//  AlertMessage.h
//  Copyright © 2016 Sequencing. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@protocol AlertMessageDialogDelegate <NSObject>

@optional
- (void)yesButtonPressed;
- (void)noButtonPressed;
- (void)cancelButtonPressed;
- (void)settingsButtonPressed;
- (void)tryAgainButtonPressed;
- (void)manuallyButtonPressed;

- (void)refreshButtonPressed;
- (void)okButtonPressed;

@end


@interface AlertMessage : NSObject

- (void)viewController:(UIViewController *)controller
  showAlertWithMessage:(NSString *)message;

- (void)viewController:(UIViewController *)controller
    showAlertWithTitle:(NSString *)title
           withMessage:(NSString *)message;

- (void)viewController:(UIViewController *)controller
  showAlertWithMessage:(NSString *)message
         withYesAction:(NSString *)yesButtonName
          withNoAction:(NSString *)noButtonName;

- (void)viewController:(UIViewController *)controller
    showAlertWithTitle:(NSString *)title
           withMessage:(NSString *)message
      withCancelAction:(NSString *)cancelButtonName
    withSettingsAction:(NSString *)settingsButtonName;

- (void)viewController:(UIViewController *)controller
    showAlertWithTitle:(NSString *)title
           withMessage:(NSString *)message
    withSettingsAction:(NSString *)settingsButtonName;

- (void)viewController:(UIViewController *)controller
    showAlertWithTitle:(NSString *)title
           withMessage:(NSString *)message
    withTryAgainAction:(NSString *)cancelButtonName
    withManuallyAction:(NSString *)settingsButtonName;

- (void)viewController:(UIViewController *)controller
    showAlertWithTitle:(NSString *)title
           withMessage:(NSString *)message
     withRefreshAction:(NSString *)refreshButtonName
          withOkAction:(NSString *)okButtonName;

@property (nonatomic) id<AlertMessageDialogDelegate> delegate;

@end
