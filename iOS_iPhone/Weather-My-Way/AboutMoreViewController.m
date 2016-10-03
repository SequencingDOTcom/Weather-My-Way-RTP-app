//
//  AboutMoreViewController.m
//  Copyright © 2016 Sequencing. All rights reserved.
//


#import <AVFoundation/AVFoundation.h>
#import "AboutMoreViewController.h"
#import "ForecastData.h"
#import "VideoHelper.h"
#import "UserHelper.h"

#define kMainQueue dispatch_get_main_queue()


@interface AboutMoreViewController () <UIGestureRecognizerDelegate>
// properties for videoPlayer
@property (nonatomic) AVPlayer  *avPlayer;
@property (nonatomic) UIView    *videoPlayerView;
@property (nonatomic) AVPlayerLayer *videoLayer;

@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (strong, nonatomic) NSString *aboutMoreText;

@property (weak, nonatomic) IBOutlet UIImageView *sequencing_logo;
@property (weak, nonatomic) IBOutlet UIImageView *github_logo;

@end


@implementation AboutMoreViewController

#pragma mark -
#pragma mark View Lyfecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"AboutMoreVC: viewDidLoad");
    
    // set navigation bar fully transpanent
    [self.navigationController.navigationBar setTranslucent:YES];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    
    // set up title
    self.title = @"About Weather My Way +RTP";
    [self.navigationController.navigationBar setTitleTextAttributes:@{ NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:19.0],
                                                                       NSForegroundColorAttributeName: [UIColor whiteColor]
                                                                       }];
    
    // prepare text lable
    [self prepareText];
    
    // add tapGesture
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    singleTap.numberOfTapsRequired = 1;
    [singleTap setDelegate:self];
    _textLabel.userInteractionEnabled = YES;
    [_textLabel addGestureRecognizer:singleTap];
    
    // add gesture to logos
    UITapGestureRecognizer *tapGestureSequencing = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sequencing_logoPressed)];
    tapGestureSequencing.numberOfTapsRequired = 1;
    [tapGestureSequencing setDelegate:self];
    _sequencing_logo.userInteractionEnabled = YES;
    [_sequencing_logo addGestureRecognizer:tapGestureSequencing];
    
    UITapGestureRecognizer *tapGestureGithub = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(github_logoPressed)];
    tapGestureGithub.numberOfTapsRequired = 1;
    [tapGestureGithub setDelegate:self];
    _github_logo.userInteractionEnabled = YES;
    [_github_logo addGestureRecognizer:tapGestureGithub];
    
    // setup video and add observes
    [self initializeAndAddVideoToView];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self addNotificationObserves];
    [self playVideo];
    
    // set transpanent grey background for navigation bar in case when video with white part is used now
    if ([VideoHelper isVideoWhite]) {
        [self.navigationController.navigationBar setBackgroundImage:[VideoHelper greyTranspanentImage] forBarMetrics:UIBarMetricsDefault];
    } else {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    }
}


- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self updateVideoLayerFrame];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    NSLog(@"LoginVC: will Disappear");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self pauseVideo];
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self deallocateAndRemoveVideoFromView];
    NSLog(@"AboutMoreVC: dealloc");
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
    NSLog(@"LoginVC: video vas removed");
    [_avPlayer pause];
    _avPlayer = nil;
    [_videoPlayerView removeFromSuperview];
}


- (void)updateVideoLayerFrame {
    [_avPlayer pause];
    _videoLayer.frame = self.view.bounds;
    [_videoLayer setNeedsDisplay]; // or  setNeedsLayout
    [_avPlayer play];
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:[self.avPlayer currentItem]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseVideo) name:UIApplicationWillResignActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playVideo) name:UIApplicationDidBecomeActiveNotification object:nil];
}


- (int)randomNumberBetween:(int)min maxNumber:(int)max {
    return min + arc4random_uniform(max - min + 1);
}


- (UIStatusBarStyle)preferredStatusBarStyle {
    // UIStatusBarStyleLightContent
    // UIStatusBarStyleDefault
    return UIStatusBarStyleLightContent;
}



#pragma mark -
#pragma mark Prepare text

- (void)prepareText {
    NSString *originalText = [_textLabel.text copy];
    _aboutMoreText = [_textLabel.text copy];
    _textLabel.text = nil;
    NSString *urlPhrase = @"register for a free account";
    
    // set attributed string
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:originalText];
    
    NSDictionary *textPart = @{NSFontAttributeName:           [UIFont fontWithName:@"HelveticaNeue-Light" size:18.f],
                               NSForegroundColorAttributeName:[UIColor whiteColor]};
    NSDictionary *urlPart = @{NSFontAttributeName:           [UIFont fontWithName:@"HelveticaNeue-Medium" size:18.f],
                              NSForegroundColorAttributeName:[UIColor colorWithRed:0 green:140.0/255.0 blue:255.0/255.0 alpha:1.0]};
    
    NSRange firstTextPart = NSMakeRange(0, [originalText length] - 1);
    NSRange urlTextPart = [originalText rangeOfString:urlPhrase];
    
    [attributedString addAttributes:textPart range:firstTextPart];
    [attributedString addAttributes:urlPart  range:urlTextPart];
    _textLabel.attributedText = [attributedString copy];
}



#pragma mark -
#pragma mark UITapGestureRecognizer

- (void)handleTap:(UITapGestureRecognizer *)tapRecognizer {
    CGPoint touchPoint = [tapRecognizer locationInView:_textLabel];
    NSString *urlPhrase = @"register for a free account";
    NSRange urlTextRange = [_aboutMoreText rangeOfString:urlPhrase];
    CGRect urlRect = [self boundingRectForCharacterRange:urlTextRange];
    
    if (CGRectContainsPoint(urlRect, touchPoint)) {
        NSURL *url = [NSURL URLWithString:@"https://sequencing.com/user/register"];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}


- (CGRect)boundingRectForCharacterRange:(NSRange)range {
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:_textLabel.attributedText];
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    [textStorage addLayoutManager:layoutManager];
    
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:_textLabel.bounds.size]; // 
    textContainer.lineFragmentPadding = 0;
    [layoutManager addTextContainer:textContainer];
    
    NSRange glyphRange;
    [layoutManager characterRangeForGlyphRange:range actualGlyphRange:&glyphRange];
    
    return [layoutManager boundingRectForGlyphRange:glyphRange inTextContainer:textContainer];
}




#pragma mark -
#pragma mark Actions

- (void)sequencing_logoPressed {
    NSURL *url = [NSURL URLWithString:@"https://sequencing.com/"];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}


- (void)github_logoPressed {
    NSURL *url = [NSURL URLWithString:@"https://github.com/SequencingDOTcom/Weather-My-Way-RTP-app"];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}



#pragma mark -
#pragma mark Mamory handler

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



@end
