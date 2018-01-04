//
//  SQConnectTo.h
//  Copyright © 2017 Sequencing.com. All rights reserved
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SQClientSecretAccessProtocol.h"


@interface SQConnectTo : NSObject

// connect to sequencing
- (void)connectToSequencingWithCliendSecret:(id<SQClientSecretAccessProtocol>)clientSecretProvider
                                  userEmail:(NSString *)emailAddress
                                 filesArray:(NSArray *)filesArray
                     viewControllerDelegate:(UIViewController *)viewControllerDelegate;

@end
