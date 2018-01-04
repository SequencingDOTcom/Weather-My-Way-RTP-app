//
//  AlertViewController.m
//  Copyright © 2016 Sequencing. All rights reserved.
//


#import "PopupAlertViewController.h"


#define kMainQueue dispatch_get_main_queue()



@implementation PopupAlertViewController

#pragma mark - View Lyfecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // set navigation bar fully transpanent
    [self.navigationController.navigationBar setTranslucent:YES];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    
    // set up title
    self.title = @"Alert";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Bold" size:19.0],
                                                                      NSForegroundColorAttributeName: [UIColor redColor]}];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    if ([_alertsMessageText length] != 0) {
        _alertsMessage.text = _alertsMessageText;
    } else {
        _alertsMessage.text = @"Sorry, there is an error while getting alerts message";
    }
}



- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)dealloc {
    NSLog(@"AlertVC: dealloc");
    [super cleanup];
}



#pragma mark - Actions

- (IBAction)backButtonPressed:(id)sender {
    [_delegate popupAlertViewController:self closeButtonPressed:nil];
}


- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^ __nullable)(void))completion {
    [super dismissViewControllerAnimated:flag completion:completion];
    _delegate = nil;
}




#pragma mark - Memory handler

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



@end
