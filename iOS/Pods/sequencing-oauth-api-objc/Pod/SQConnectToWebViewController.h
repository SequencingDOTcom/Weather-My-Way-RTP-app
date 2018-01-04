//
//  SQConnectToWebViewController.h
//  Copyright © 2017 Sequencing.com. All rights reserved
//
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>


typedef void(^ConnectToCompletionBlock)(BOOL success, BOOL didCancel, NSString *error);


@interface SQConnectToWebViewController : UIViewController

- (id)initWithURL:(NSURL *)url andCompletionBlock:(ConnectToCompletionBlock)completionBlock;

@end
