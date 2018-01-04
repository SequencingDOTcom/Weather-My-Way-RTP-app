//
//  UIViewControllerWithVideoBackground.m
//  Copyright © 2017 Sequencing. All rights reserved.
//


#import "UIViewControllerWithVideoBackground.h"


@implementation UIViewControllerWithVideoBackground

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initializeAndAddVideoToView];
    [self addNotificationObserves];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self playVideo];
    [self handleVideo:[VideoHelper isVideoWhite]];
}


- (void)handleVideo:(BOOL)isWhite {
    if (isWhite)
        [self.navigationController.navigationBar setBackgroundImage:[VideoHelper greyTranspanentImage] forBarMetrics:UIBarMetricsDefault];
    else
        [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
}


- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self updateVideoLayerFrame];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self pauseVideo];
}


- (void)cleanup {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self deallocateAndRemoveVideoFromView];
}


- (void)initializeAndAddVideoToView {
    UserHelper   *userHelper    = [[UserHelper alloc] init];
    VideoHelper  *videoHelper   = [[VideoHelper alloc] init];
    ForecastData *forecastData  = [ForecastData sharedInstance];
    NSString     *knownVideoName = [userHelper loadKnownVideoFileName];
    NSString     *newVideoName;
    
    if ([forecastData.weatherType length] > 0 && [forecastData.dayNight length] > 0) // create new video file name
        newVideoName = [videoHelper getVideoNameBasedOnWeatherType:forecastData.weatherType AndDayNight:forecastData.dayNight];
    else
        newVideoName = [videoHelper getRandomVideoName];
        
    
    if ([self shouldAlwaysCreateVideo]) { // case for all VC's
        if (!knownVideoName || [knownVideoName length] == 0)
            [self showVideoWithFile:newVideoName];
        else
            [self showVideoWithFile:knownVideoName];
    }
}


- (void)showVideoWithFile:(NSString *)videoFileName {
    NSString *filepath = [[NSBundle mainBundle] pathForResource:videoFileName ofType:nil inDirectory:@"Video"];
    if (!filepath) return;
    
    [self deallocateAndRemoveVideoFromView];
    
    NSURL *fileURL = [NSURL fileURLWithPath:filepath];
    self.avPlayer = [AVPlayer playerWithURL:fileURL];
    self.avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    
    // set up videoLayer that will include video player
    self.videoLayer = [AVPlayerLayer playerLayerWithPlayer:self.avPlayer];
    self.videoLayer.frame = self.view.bounds;
    self.videoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    // set up separate uiview in order to add it later to the back in views hierarchy
    self.videoPlayerView = [[UIView alloc] init];
    [self.videoPlayerView.layer addSublayer:self.videoLayer];
    [self.view addSubview:self.videoPlayerView];
    [self.view sendSubviewToBack:self.videoPlayerView];
    
    [self.avPlayer play];
}


- (BOOL)shouldAlwaysCreateVideo {
    return YES;
}


- (void)updateVideoLayerFrame {
    _videoLayer.frame = self.view.frame;
    [_videoLayer setNeedsLayout]; // or  setNeedsLayout setNeedsDisplay
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


- (void)deallocateAndRemoveVideoFromView {
    [_avPlayer pause];
    _avPlayer = nil;
    [_videoPlayerView removeFromSuperview];
}


@end
