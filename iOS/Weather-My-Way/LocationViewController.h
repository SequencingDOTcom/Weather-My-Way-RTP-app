//
//  LocationViewController.h
//  Copyright © 2016 Sequencing. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "UIViewControllerWithVideoBackground.h"



@protocol LocationViewControllerDelegate <NSObject>

- (void)locationViewController:(UIViewController *)controller didSelectLocation:(NSDictionary *)location;

@optional
- (void)locationViewController:(UIViewController *)controller backButtonPressed:(id)sender;

@end



@interface LocationViewController : UIViewControllerWithVideoBackground

@property (nonatomic) BOOL backButton;
@property (nonatomic) id <LocationViewControllerDelegate> delegate;

@end
