//
//  SQLoginViewController.h
//  Copyright © 2015-2016 Sequencing.com. All rights reserved
//

#import <UIKit/UIKit.h>

typedef void(^LoginCompletionBlock)(NSMutableDictionary *response);

@interface SQLoginViewController : UIViewController

- (id)initWithURL:(NSURL *)url andCompletionBlock:(LoginCompletionBlock)completionBlock;

@end
