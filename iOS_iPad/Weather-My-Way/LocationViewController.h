//
//  LocationViewController.h
//  Copyright © 2016 Sequencing. All rights reserved.
//


#import <UIKit/UIKit.h>
@class LocationViewController;


@protocol LocationViewControllerDelegate <NSObject>

- (void)locationViewController:(LocationViewController *)controller didSelectLocation:(NSDictionary *)location;

@optional
- (void)locationViewController:(LocationViewController *)controller backButtonPressed:(id)sender;

@end


@interface LocationViewController : UIViewController

@property (nonatomic) BOOL backButton;
@property (nonatomic) id <LocationViewControllerDelegate> delegate;

@end
