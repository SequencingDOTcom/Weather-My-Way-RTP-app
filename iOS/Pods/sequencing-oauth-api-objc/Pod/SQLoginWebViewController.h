//
//  SQLoginWebViewController.h
//  Copyright © 2015-2016 Sequencing.com. All rights reserved
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>


typedef void(^LoginCompletionBlock)(NSMutableDictionary *response);


@interface SQLoginWebViewController : UIViewController

- (id)initWithURL:(NSURL *)url andCompletionBlock:(LoginCompletionBlock)completionBlock;

@end
