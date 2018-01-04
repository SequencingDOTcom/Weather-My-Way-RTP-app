//
//  SQConnectTo.m
//  Copyright © 2017 Sequencing.com. All rights reserved
//

#import "SQConnectTo.h"
#import "SQServerManager.h"
#import "SQEmailHelper.h"
#import "SQConnectToHelper.h"


@implementation SQConnectTo

- (void)connectToSequencingWithCliendSecret:(id<SQClientSecretAccessProtocol>)clientSecretProvider
                                  userEmail:(NSString *)emailAddress
                                 filesArray:(NSArray *)filesArray
                     viewControllerDelegate:(UIViewController *)viewControllerDelegate {
    
    if (!viewControllerDelegate) {
        UIViewController *mainVC = [[[[UIApplication sharedApplication] windows] firstObject] rootViewController];
        [self viewController:mainVC showAlertWithTitle:@"Connect To Sequencing" withMessage:@"UI delegate is missing. Please register all app parameters"];
        return;
    }
    
    [viewControllerDelegate.view setUserInteractionEnabled:NO];
    
    NSString *client_secret = [clientSecretProvider clientSecret];
    if (!client_secret || [client_secret length] == 0) {
        [self viewController:viewControllerDelegate
          showAlertWithTitle:@"Connect To Sequencing"
                 withMessage:@"Client_ID and Client_Secret are missing. Please register all app parameters"];
        [viewControllerDelegate.view setUserInteractionEnabled:YES];
        return;
    }
    
    if (!emailAddress || [emailAddress length] == 0) {
        [self viewController:viewControllerDelegate
          showAlertWithTitle:@"Connect To Sequencing"
                 withMessage:@"Email address is empty. Please provide valid email address."];
        [viewControllerDelegate.view setUserInteractionEnabled:YES];
        return;
    }
    
    if (![SQEmailHelper isEmailValid:emailAddress]) {
        [self viewController:viewControllerDelegate
          showAlertWithTitle:@"Connect To Sequencing"
                 withMessage:@"Invalid email address was entered. Please provide valid email address."];
        [viewControllerDelegate.view setUserInteractionEnabled:YES];
        return;
    }
    
    if (!filesArray || [filesArray count] == 0) {
        [self viewController:viewControllerDelegate
          showAlertWithTitle:@"Connect To Sequencing"
                 withMessage:@"Empty files array was provided. Please provide valid NSArray with files as NSDictionary objects."];
        [viewControllerDelegate.view setUserInteractionEnabled:YES];
        return;
    }
    
    NSString *filesAreInvalidReason = [SQConnectToHelper checkIfFilesAreValid:filesArray];
    if (filesAreInvalidReason && [filesAreInvalidReason length] > 0) {
        [self viewController:viewControllerDelegate showAlertWithTitle:@"Connect To Sequencing" withMessage:filesAreInvalidReason];
        [viewControllerDelegate.view setUserInteractionEnabled:YES];
        return;
    }
    
    // let's proceed futher > all parameters are valid
    [[SQServerManager sharedInstance] connectToSequencingWithClient_id:client_secret
                                                             userEmail:emailAddress
                                                            filesArray:filesArray
                                                viewControllerDelegate:viewControllerDelegate];
}





#pragma mark - Alert popup

- (void)viewController:(UIViewController *)controller showAlertWithTitle:(NSString *)title withMessage:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *close = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:close];
    [controller presentViewController:alert animated:YES completion:nil];
}



@end
