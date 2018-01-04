//
//  ExtendedForecastPopoverViewController.h
//  Copyright © 2016 Sequencing. All rights reserved.
//


#import <UIKit/UIKit.h>
@class ExtendedForecastPopoverViewController;


@protocol ExtendedForecastPopoverViewControllerDelegate <NSObject>

- (void)extendedForecastPopoverViewControllerWasClosed:(ExtendedForecastPopoverViewController *)controller;

@end




@interface ExtendedForecastPopoverViewController : UIViewController

@property (strong, nonatomic) NSString *day;
@property (strong, nonatomic) NSString *geneticForecast;
@property (strong, nonatomic) NSString *extendedForecast;

@property (nonatomic) id <ExtendedForecastPopoverViewControllerDelegate> delegate;

@end
