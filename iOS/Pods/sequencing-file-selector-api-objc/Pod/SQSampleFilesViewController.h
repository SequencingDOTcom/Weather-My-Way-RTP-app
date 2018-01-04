//
//  SQSampleFilesViewController.h
//  Copyright © 2017 Sequencing.com. All rights reserved
//

#import <UIKit/UIKit.h>


@protocol SampleFilesViewControllerClosedProtocol <NSObject>

- (void)sampleFilesViewControllerClosed;

@end


@interface SQSampleFilesViewController : UIViewController

@property (weak, nonatomic) id<SampleFilesViewControllerClosedProtocol> viewCloseDelegate;

@end
