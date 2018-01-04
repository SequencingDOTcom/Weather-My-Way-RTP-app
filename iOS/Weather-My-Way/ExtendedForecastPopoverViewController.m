//
//  ExtendedForecastPopoverViewController.m
//  Copyright © 2016 Sequencing. All rights reserved.
//


#import "ExtendedForecastPopoverViewController.h"
#import "GeneticForecastHelper.h"

#define kExtendedAbsenseError @"Sorry, can't get extended weather forecast. Try to either refresh weather forecast or select another location."


#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

#define IS_STANDARD_IPHONE_6_PLUS (IS_IPHONE && MAX([[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width) == 736.0)

#define IS_ZOOMED_IPHONE_6_PLUS (IS_IPHONE && MAX([[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width) == 667.0 && IS_OS_8_OR_LATER && [UIScreen mainScreen].nativeScale < [UIScreen mainScreen].scale)

#define IS_IPHONE_6_PLUS (IS_STANDARD_IPHONE_6_PLUS || IS_ZOOMED_IPHONE_6_PLUS)


@interface ExtendedForecastPopoverViewController ()

@property (weak, nonatomic) IBOutlet UILabel *geneticText;
@property (weak, nonatomic) IBOutlet UILabel *extendedText;

@end



@implementation ExtendedForecastPopoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // day title
    self.title = self.day;
    
    // genetic forecast
    if ([self.geneticForecast length] != 0) {
        self.geneticText.text = self.geneticForecast;
    } else {
        self.geneticText.text = kAbsentGeneticForecastMessage;
    }
    
    // extended forecast
    if ([self.extendedForecast length] != 0) {
        self.extendedText.text = self.extendedForecast;
    } else {
        self.extendedText.text = kExtendedAbsenseError;
    }
    
    
    if (IS_IPHONE_6_PLUS) {
        UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(closeButtonPressed)];
        self.navigationItem.leftBarButtonItem = closeButton;
    }
}


- (void)closeButtonPressed {
    [_delegate extendedForecastPopoverViewControllerWasClosed:self];
}



@end
