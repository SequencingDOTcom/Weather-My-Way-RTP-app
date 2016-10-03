//
//  AlertMessage.m
//  Copyright © 2016 Sequencing. All rights reserved.
//


#import "AlertMessage.h"


@implementation AlertMessage

#pragma mark -
#pragma mark Alert with message only

- (void)viewController:(UIViewController *)controller showAlertWithMessage:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *close = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:close];
    
    [controller presentViewController:alert animated:YES completion:nil];
}


- (void)viewController:(UIViewController *)controller showAlertWithTitle:(NSString *)title withMessage:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *close = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:close];
    
    [controller presentViewController:alert animated:YES completion:nil];
}



#pragma mark -
#pragma mark Alert with message, Yes No actions

- (void)viewController:(UIViewController *)controller
  showAlertWithMessage:(NSString *)message
         withYesAction:(NSString *)yesButtonName
         withNoAction:(NSString *)noButtonName {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:yesButtonName style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if ([_delegate respondsToSelector:@selector(yesButtonPressed)]) {
            [_delegate yesButtonPressed];
        }
    }];
    
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:noButtonName style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if ([_delegate respondsToSelector:@selector(noButtonPressed)]) {
            [_delegate noButtonPressed];
        }
    }];
    
    [alert addAction:noAction];
    [alert addAction:yesAction];
    
    [controller presentViewController:alert animated:YES completion:nil];
}



#pragma mark -
#pragma mark Alert with message, Cancel Settings actions

- (void)viewController:(UIViewController *)controller
    showAlertWithTitle:(NSString *)title
           withMessage:(NSString *)message
      withCancelAction:(NSString *)cancelButtonName
    withSettingsAction:(NSString *)settingsButtonName {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonName style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if ([_delegate respondsToSelector:@selector(cancelButtonPressed)]) {
            [_delegate cancelButtonPressed];
        }
    }];
    
    UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:settingsButtonName style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if ([_delegate respondsToSelector:@selector(settingsButtonPressed)]) {
            [_delegate settingsButtonPressed];
        }
    }];
    
    [alert addAction:cancelAction];
    [alert addAction:settingsAction];
    
    [controller presentViewController:alert animated:YES completion:nil];
}



#pragma mark -
#pragma mark Alert with message, Settings actions

- (void)viewController:(UIViewController *)controller
    showAlertWithTitle:(NSString *)title
           withMessage:(NSString *)message
    withSettingsAction:(NSString *)settingsButtonName {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:settingsButtonName style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if ([_delegate respondsToSelector:@selector(settingsButtonPressed)]) {
            [_delegate settingsButtonPressed];
        }
    }];
    
    [alert addAction:settingsAction];
    
    [controller presentViewController:alert animated:YES completion:nil];
}



#pragma mark -
#pragma mark Alert with message, TryAgain Manually actions

- (void)viewController:(UIViewController *)controller
    showAlertWithTitle:(NSString *)title
           withMessage:(NSString *)message
    withTryAgainAction:(NSString *)tryAgainButtonName
    withManuallyAction:(NSString *)manuallyButtonName {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *tryAgainAction = [UIAlertAction actionWithTitle:tryAgainButtonName style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if ([_delegate respondsToSelector:@selector(tryAgainButtonPressed)]) {
            [_delegate tryAgainButtonPressed];
        }
    }];
    
    UIAlertAction *manuallyAction = [UIAlertAction actionWithTitle:manuallyButtonName style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if ([_delegate respondsToSelector:@selector(manuallyButtonPressed)]) {
            [_delegate manuallyButtonPressed];
        }
    }];
    
    [alert addAction:tryAgainAction];
    [alert addAction:manuallyAction];
    
    [controller presentViewController:alert animated:YES completion:nil];
}



#pragma mark -
#pragma mark Alert with message, Refresh Ok actions


- (void)viewController:(UIViewController *)controller
    showAlertWithTitle:(NSString *)title
           withMessage:(NSString *)message
     withRefreshAction:(NSString *)refreshButtonName
          withOkAction:(NSString *)okButtonName {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *refreshAction = [UIAlertAction actionWithTitle:refreshButtonName style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if ([_delegate respondsToSelector:@selector(refreshButtonPressed)]) {
            [_delegate refreshButtonPressed];
        }
    }];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:okButtonName style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if ([_delegate respondsToSelector:@selector(okButtonPressed)]) {
            [_delegate okButtonPressed];
        }
    }];
    
    [alert addAction:refreshAction];
    [alert addAction:okAction];
    
    [controller presentViewController:alert animated:YES completion:nil];
}



@end
