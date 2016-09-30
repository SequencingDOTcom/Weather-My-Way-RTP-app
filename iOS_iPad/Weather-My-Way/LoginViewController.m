//
//  LoginViewController.m
//  Copyright © 2016 Sequencing. All rights reserved.
//


#import "LoginViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"
#import "SQOAuth.h"
#import "SQFilesAPI.h"
#import "UserHelper.h"
#import "AlertMessage.h"
#import "ProgressViewController.h"
#import "VideoHelper.h"
#import "AboutViewController.h"
#import "ForecastData.h"
#import "InternetConnection.h"

#define kMainQueue dispatch_get_main_queue()


@interface LoginViewController () <UIGestureRecognizerDelegate, AboutViewControllerDelegate, AlertMessageDialogDelegate>

// properties for videoPlayer
@property (nonatomic) AVPlayer  *avPlayer;
@property (nonatomic) UIView    *videoPlayerView;
@property (nonatomic) AVPlayerLayer *videoLayer;

@property (weak, nonatomic) IBOutlet UIImageView *myWayLogo;
@property (assign, nonatomic) BOOL alreadyShownAlertMessage;

@end



@implementation LoginViewController

#pragma mark -
#pragma mark View Lyfecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"LoginVC: viewDidLoad");
    
    // eraseAnyUserData just for a case
    [self eraseAnyUserData];
    
    // subscribe self as delegate to SQAuthorizationProtocol
    SQOAuth *authorizationAPI = [SQOAuth sharedInstance];
    [authorizationAPI setAuthorizationDelegate:self];
    
    // set navigation bar fully transpanent
    [self.navigationController.navigationBar setTranslucent:YES];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    
    // set up title
    [self prepopulateTitleWith2RowsText];
    
    // setup video and add observes
    [self initializeAndAddVideoToView];
    
    // add TapGesture for weatherMyWay logo
    _myWayLogo.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGestureSequencing = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(myWayLogoPressed)];
    tapGestureSequencing.numberOfTapsRequired = 1;
    [tapGestureSequencing setDelegate:self];
    [_myWayLogo addGestureRecognizer:tapGestureSequencing];
    
    _alreadyShownAlertMessage = NO;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    // video
    [self playVideo];
    [self addNotificationObserves];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([self.messageTextForErrorCase length] != 0 && !_alreadyShownAlertMessage) {
        _alreadyShownAlertMessage = YES;
        
        AlertMessage *alertMessage = [[AlertMessage alloc] init];
        alertMessage.delegate = self;
        [alertMessage viewController:self
                  showAlertWithTitle:self.messageTextForErrorCase
                         withMessage:nil];
    }
}


- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self updateVideoLayerFrame];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self pauseVideo];
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self deallocateAndRemoveVideoFromView];
    NSLog(@"LoginVC: dealloc");
}



#pragma mark -
#pragma mark Videoplayer Methods

- (void)initializeAndAddVideoToView {
    NSLog(@"LoginVC: initialize video player with layer");
    
    // set up videoPlayer with local video file
    VideoHelper *videoHelper = [[VideoHelper alloc] init];
    NSString *videoName = [videoHelper getRandomVideoName];
    
    NSString *filepath = [[NSBundle mainBundle] pathForResource:videoName ofType:nil inDirectory:@"Video"];
    NSURL *fileURL = [NSURL fileURLWithPath:filepath];
    _avPlayer = [AVPlayer playerWithURL:fileURL];
    _avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    
    // set up videoLayer that will include video player
    _videoLayer = [AVPlayerLayer playerLayerWithPlayer:self.avPlayer];
    _videoLayer.frame = self.view.bounds;
    _videoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    // set up separate uiview in order to add it later to the back in views hierarchy
    _videoPlayerView = [[UIView alloc] init];
    [self.videoPlayerView.layer addSublayer:_videoLayer];
    [self.view addSubview:_videoPlayerView];
    [self.view sendSubviewToBack:_videoPlayerView];
    [self.avPlayer play];
}


- (void)deallocateAndRemoveVideoFromView {
    [_avPlayer pause];
    _avPlayer = nil;
    [_videoPlayerView removeFromSuperview];
}


- (void)updateVideoLayerFrame {
    _videoLayer.frame = self.view.bounds;
    [_videoLayer setNeedsDisplay]; // or  setNeedsLayout
}


- (void)itemDidFinishPlaying:(NSNotification *)notification {
    AVPlayerItem *player = [notification object];
    [player seekToTime:kCMTimeZero];
}

- (void)playVideo {
    [_avPlayer play];
}

- (void)pauseVideo {
    [_avPlayer pause];
}


- (void)addNotificationObserves {
    // add observer for video playback
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(itemDidFinishPlaying:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[self.avPlayer currentItem]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pauseVideo)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playVideo)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}



#pragma mark -
#pragma mark preferredStatusBarStyle

- (UIStatusBarStyle)preferredStatusBarStyle {
    // UIStatusBarStyleLightContent
    // UIStatusBarStyleDefault
    return UIStatusBarStyleLightContent;
}



#pragma mark -
#pragma mark prepopulate Title

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



#pragma mark -
#pragma mark Actions

- (IBAction)loginButtonPressed:(id)sender {
    if ([InternetConnection internetConnectionIsAvailable]) {
        self.view.userInteractionEnabled = NO;
        [[SQOAuth sharedInstance] authorizeUser];
        
    } else {
        AlertMessage *alert = [[AlertMessage alloc] init];
        [alert viewController:self
           showAlertWithTitle:@"Can't authorize user"
                  withMessage:NO_INTERNET_CONNECTION_TEXT];
    }
}


- (IBAction)registerAccountButtonPressed:(id)sender {
    NSURL *url = [NSURL URLWithString:@"https://sequencing.com/user/register/"];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}


- (IBAction)aboutButtonPressed:(id)sender {
    [self myWayLogoPressed];
}

- (void)myWayLogoPressed {
    dispatch_async(kMainQueue, ^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"About" bundle:nil];
        UINavigationController *aboutNavigationVC = (UINavigationController *)[storyboard instantiateInitialViewController];
        aboutNavigationVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        AboutViewController *aboutVC = [aboutNavigationVC viewControllers][0];
        aboutVC.delegate = self;
        [self presentViewController:aboutNavigationVC animated:YES completion:nil];
    });
}



#pragma mark -
#pragma mark AboutViewControllerDelegate

- (void)AboutViewController:(AboutViewController *)controller closeButtonPressed:(id)sender {
    controller.delegate = nil;
    [controller dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark -
#pragma mark SQAuthorizationProtocol

- (void)userIsSuccessfullyAuthorized:(SQToken *)token {
    dispatch_async(kMainQueue, ^{
        UserHelper *userHelper = [[UserHelper alloc] init];
        
        if ((token.accessToken != nil) && (token.refreshToken != nil)) {
            [userHelper saveUserToken:token];
            NSLog(@"LoginVC: Token was saved into userDefaults");
            
            // opening ProgressViewController now
            NSLog(@"LoginVC: User is logged in successfuly");
            self.view.userInteractionEnabled = YES;
            [self presentProgressViewController];
            
        } else {
            NSLog(@"LoginVC: Token is nil! Can't save to userDefaults");
            AlertMessage *alert = [[AlertMessage alloc] init];
            [alert viewController:self showAlertWithMessage:@"Can't authorize user. Token is nil"];
        }
    });
}

- (void)userIsNotAuthorized {
    dispatch_async(kMainQueue, ^{
        self.view.userInteractionEnabled = YES;
        AlertMessage *alert = [[AlertMessage alloc] init];
        [alert viewController:self showAlertWithMessage:@"Server connection error\nCan't authorize user"];
    });
}

- (void)userDidCancelAuthorization {
    dispatch_async(kMainQueue, ^{
        self.view.userInteractionEnabled = YES;
    });
}



#pragma mark -
#pragma mark Navigation

- (void)presentProgressViewController {
    // remove delegate self
    SQOAuth *authorizationAPI = [SQOAuth sharedInstance];
    [authorizationAPI setAuthorizationDelegate:nil];
    
    // open ProgressViewController
    ProgressViewController *progressVC = [[ProgressViewController alloc] initWithNibName:@"ProgressViewController" bundle:nil];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.window setRootViewController:progressVC];
    [appDelegate.window makeKeyAndVisible];
}



#pragma mark -
#pragma mark Other Methods

- (void)eraseAnyUserData {
    [[SQOAuth sharedInstance] userDidSignOut];
    UserHelper *userHelper = [[UserHelper alloc] init];
    [userHelper userDidSignOut];
    [userHelper removeAllStoredCredentials];
    
    SQFilesAPI *filesAPI = [SQFilesAPI sharedInstance];
    filesAPI.selectedFileID = nil;
    
    ForecastData *forecastData = [[ForecastData alloc] sharedInstance];
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
