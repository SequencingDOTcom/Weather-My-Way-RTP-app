//
//  ProgressViewController.h
//  Copyright © 2016 Sequencing. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "LocationViewController.h"
#import <SQFileSelectorProtocol.h>
#import "UIViewControllerWithVideoBackground.h"


@interface ProgressViewController : UIViewControllerWithVideoBackground <LocationViewControllerDelegate, SQFileSelectorProtocol>

@end
