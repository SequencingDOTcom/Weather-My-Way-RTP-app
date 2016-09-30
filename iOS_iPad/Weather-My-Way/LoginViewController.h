//
//  LoginViewController.h
//  Copyright © 2016 Sequencing. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <SQAuthorizationProtocol.h>


@interface LoginViewController : UIViewController <SQAuthorizationProtocol>

@property (strong, nonatomic, readwrite) NSString *messageTextForErrorCase;

@end
