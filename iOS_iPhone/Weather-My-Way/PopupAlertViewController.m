//
//  AlertViewController.m
//  Copyright © 2016 Sequencing. All rights reserved.
//


#import <AVFoundation/AVFoundation.h>
#import "PopupAlertViewController.h"
#import "ForecastData.h"
#import "VideoHelper.h"
#import "UserHelper.h"


#define kMainQueue dispatch_get_main_queue()



@interface PopupAlertViewController ()

@property (weak, nonatomic) IBOutlet UILabel *alertsMessage;

// properties for videoPlayer
@property (nonatomic) AVPlayer      *avPlayer;
@property (nonatomic) UIView        *videoPlayerView;
@property (nonatomic) AVPlayerLayer *videoLayer;

@end



@implementation PopupAlertViewController

#pragma mark -
#pragma mark View Lyfecycle

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
    
    if ([_alertsMessageText length] != 0) {
        _alertsMessage.text = _alertsMessageText;
    } else {
        _alertsMessage.text = @"Sorry, there is an error while getting alerts message";
    }
    
    // setup video and add observes
    [self initializeAndAddVideoToView];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    [self addNotificationObserves];
    [self playVideo];
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
    NSLog(@"AlertVC: dealloc");
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self deallocateAndRemoveVideoFromView];
}



#pragma mark -
#pragma mark Videoplayer Methods

- (void)initializeAndAddVideoToView {
    NSLog(@"LoginVC: initialize video player with layer");
    // set up video
    UserHelper *userHelper = [[UserHelper alloc] init];
    ForecastData *forecastData = [[ForecastData alloc] sharedInstance];
    VideoHelper *videoHelper = [[VideoHelper alloc] init];
    NSString *videoName = [userHelper loadKnownVideoFileName];
    
    if ([videoName length] == 0 || !videoName) {
        if ([forecastData.weatherType length] != 0 && [forecastData.dayNight length] != 0) {
            videoName = [videoHelper getVideoNameBasedOnWeatherType:forecastData.weatherType AndDayNight:forecastData.dayNight];
        } else {
            videoName = [videoHelper getRandomVideoName];
        }
    }
    
    // set up videoPlayer with local video file
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


- (UIStatusBarStyle)preferredStatusBarStyle {
    // UIStatusBarStyleLightContent
    // UIStatusBarStyleDefault
    return UIStatusBarStyleLightContent;
}



#pragma mark -
#pragma mark Actions

- (IBAction)backButtonPressed:(id)sender {
    [_delegate popupAlertViewController:self closeButtonPressed:nil];
}




#pragma mark -
#pragma mark Memory handler

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
