//
//  ProgressViewController.h
//  Copyright © 2016 Sequencing. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "LocationViewController.h"
#import <SQFileSelectorProtocol.h>


@interface ProgressViewController : UIViewController <LocationViewControllerDelegate, SQFileSelectorProtocol>

@end
