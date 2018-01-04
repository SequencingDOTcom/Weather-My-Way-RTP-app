//
//  SQMyFilesViewController.h
//  Copyright © 2017 Sequencing.com. All rights reserved
//

#import <UIKit/UIKit.h>


@protocol MyFilesViewControllerClosedProtocol <NSObject>

- (void)myFilesViewControllerClosed;

@end




@interface SQMyFilesViewController : UIViewController

@property (weak, nonatomic) id<MyFilesViewControllerClosedProtocol> viewCloseDelegate;

@end


