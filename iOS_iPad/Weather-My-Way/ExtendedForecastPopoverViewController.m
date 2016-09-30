//
//  ExtendedForecastPopoverViewController.m
//  Copyright © 2016 Sequencing. All rights reserved.
//


#import "ExtendedForecastPopoverViewController.h"
#import "GeneticForecastHelper.h"

#define kExtendedAbsenseError @"Sorry, can't get extended weather forecast. Try to either refresh weather forecast or select another location."


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
}


@end
