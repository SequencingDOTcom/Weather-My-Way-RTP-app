//
//  LoginViewController.m
//  Copyright © 2016 Sequencing. All rights reserved.
//


#import "LoginViewController.h"
#import "AppDelegate.h"
#import "SQOAuth.h"
#import "SQFilesAPI.h"
#import "SQToken.h"
#import "UserHelper.h"
#import "AlertMessage.h"
#import "ProgressViewController.h"
#import "AboutViewController.h"
#import "ForecastData.h"
#import "InternetConnection.h"
#import "EmailHelper.h"
#import "UserAccountHelper.h"
#import "MBProgressHUD.h"
#import <SQAuthorizationProtocol.h>
#import "SQConnectTo.h"


#define kMainQueue dispatch_get_main_queue()


@interface LoginViewController () <UIGestureRecognizerDelegate, AboutViewControllerDelegate, AlertMessageDialogDelegate, SQAuthorizationProtocol>

@property (weak, nonatomic) IBOutlet UIImageView *myWayLogo;
@property (assign, nonatomic) BOOL  alreadyShownAlertMessage;
@property (nonatomic) MBProgressHUD *activityProgress;

@end



@implementation LoginViewController

#pragma mark - View Lyfecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // eraseAnyUserData just for a case
    [self eraseAnyUserData];
    
    // set navigation bar fully transpanent
    [self.navigationController.navigationBar setTranslucent:YES];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    
    // set up title
    [self prepopulateTitleWith2RowsText];
    
    // add TapGesture for weatherMyWay logo
    _myWayLogo.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGestureSequencing = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(aboutButtonPressed:)];
    tapGestureSequencing.numberOfTapsRequired = 1;
    [tapGestureSequencing setDelegate:self];
    [_myWayLogo addGestureRecognizer:tapGestureSequencing];
    
    _alreadyShownAlertMessage = NO;
    
    [[SQOAuth sharedInstance] registerApplicationParametersCliendID:nil
                                                       clientSecret:nil
                                                        redirectUri:nil
                                                              scope:nil
                                                           delegate:self
                                             viewControllerDelegate:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([self.messageTextForErrorCase length] != 0 && !_alreadyShownAlertMessage) {
        _alreadyShownAlertMessage = YES;
        
        AlertMessage *alertMessage = [[AlertMessage alloc] init];
        alertMessage.delegate = self;
        [alertMessage viewController:self showAlertWithTitle:self.messageTextForErrorCase withMessage:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)dealloc {
    NSLog(@"LoginVC: dealloc");
    [super cleanup];
    [[SQOAuth sharedInstance] setDelegate:nil];
}



#pragma mark - preferredStatusBarStyle
- (UIStatusBarStyle)preferredStatusBarStyle {
    // UIStatusBarStyleLightContent
    // UIStatusBarStyleDefault
    return UIStatusBarStyleLightContent;
}



#pragma mark - prepopulate Title
- (void)prepopulateTitleWith2RowsText {
    NSString *title     = @"Weather My Way";
    NSString *subtitle  = @"with Real-Time Personalization®";
    
    // prepare title label
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    [titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:19.0]];
    titleLabel.text = title;
    [titleLabel sizeToFit];
    
    // prepare subtitle label
    UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 22, 0, 0)];
    subtitleLabel.backgroundColor = [UIColor clearColor];
    subtitleLabel.textColor = [UIColor whiteColor];
    [subtitleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14.0]];
    subtitleLabel.text = subtitle;
    [subtitleLabel sizeToFit];
    
    UIView *twoLineTitleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MAX(subtitleLabel.frame.size.width, titleLabel.frame.size.width), 30)];
    [twoLineTitleView addSubview:titleLabel];
    [twoLineTitleView addSubview:subtitleLabel];
    
    float widthDiff = subtitleLabel.frame.size.width - titleLabel.frame.size.width;
    
    if (widthDiff > 0) {
        CGRect frame = titleLabel.frame;
        frame.origin.x = widthDiff / 2;
        titleLabel.frame = CGRectIntegral(frame);
    } else{
        CGRect frame = subtitleLabel.frame;
        frame.origin.x = fabs(widthDiff) / 2;
        subtitleLabel.frame = CGRectIntegral(frame);
    }
    
    self.navigationItem.titleView = twoLineTitleView;
}



#pragma mark - Actions

// authorize
- (IBAction)loginButtonPressed:(id)sender {
    if ([InternetConnection internetConnectionIsAvailable]) {
        
        self.view.userInteractionEnabled = NO;
        [[SQOAuth sharedInstance] authorizeUser];
        
    } else
        [[[AlertMessage alloc] init] viewController:self
                                 showAlertWithTitle:@"Can't authorize user"
                                        withMessage:NO_INTERNET_CONNECTION_TEXT];
}


// register/reset
- (IBAction)registerAccountButtonPressed:(id)sender {
    [[SQOAuth sharedInstance] callRegisterResetAccountFlow];
}




- (IBAction)aboutButtonPressed:(id)sender {
    dispatch_async(kMainQueue, ^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"About" bundle:nil];
        UINavigationController *aboutNavigationVC = (UINavigationController *)[storyboard instantiateInitialViewController];
        aboutNavigationVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        AboutViewController *aboutVC = [aboutNavigationVC viewControllers][0];
        aboutVC.delegate = self;
        [self presentViewController:aboutNavigationVC animated:YES completion:nil];
    });
}



#pragma mark - SQAuthorizationProtocol

- (void)userIsSuccessfullyAuthorized:(SQToken *)token {
    dispatch_async(kMainQueue, ^{
        NSLog(@"[userIsSuccessfullyAuthorized] token: %@", token.accessToken);
        [[[UserHelper alloc] init] userHasAlreadyAuthorized];
        
        self.view.userInteractionEnabled = YES;
        [self presentProgressViewController];
    });
}

- (void)userIsNotAuthorized {
    dispatch_async(kMainQueue, ^{
        self.view.userInteractionEnabled = YES;
        [[[AlertMessage alloc] init] viewController:self showAlertWithMessage:@"Server connection error\nCan't authorize user"];
    });
}

- (void)userDidCancelAuthorization {
    dispatch_async(kMainQueue, ^{
        self.view.userInteractionEnabled = YES;
    });
}



#pragma mark - Navigation

- (void)presentProgressViewController {
    dispatch_async(kMainQueue, ^{
        // remove self as delegate
        [[SQOAuth sharedInstance] setDelegate:nil];
        
        // open ProgressViewController
        ProgressViewController *progressVC = [[ProgressViewController alloc] initWithNibName:@"ProgressViewController" bundle:nil];
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate.window setRootViewController:progressVC];
        [appDelegate.window makeKeyAndVisible];
    });
}

#pragma mark - AboutViewControllerDelegate

- (void)AboutViewController:(UIViewController *)controller closeButtonPressed:(id)sender {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark Other Methods

- (void)eraseAnyUserData {
    [[SQOAuth sharedInstance] userDidSignOut];
    UserHelper *userHelper = [[UserHelper alloc] init];
    [userHelper userDidSignOut];
    [userHelper removeAllStoredCredentials];
    
    ForecastData *forecastData = [ForecastData sharedInstance];
    forecastData.forecast = nil;
    forecastData.geneticForecast = nil;
    forecastData.weatherType = nil;
    forecastData.dayNight = nil;
    forecastData.locationForForecast = nil;
    forecastData.alertType = nil;
}



#pragma mark -
#pragma mark Memory handler

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



@end
