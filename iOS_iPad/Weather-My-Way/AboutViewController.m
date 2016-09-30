//
//  AboutViewController.m
//  Copyright © 2016 Sequencing. All rights reserved.
//


#import <AVFoundation/AVFoundation.h>
#import "AboutViewController.h"
#import "ForecastData.h"
#import "VideoHelper.h"
#import "UserHelper.h"


#define kMainQueue dispatch_get_main_queue()

#define kSequencingURL      @"https://sequencing.com/"
#define kGithubURL          @"https://github.com/SequencingDOTcom/Weather-My-Way-RTP-app"
#define kRegisterPhrase     @"register for a free account"
#define kRegisterAccountURL @"https://sequencing.com/user/register"



@interface AboutViewController () <UIGestureRecognizerDelegate>

// properties for videoPlayer
@property (nonatomic) AVPlayer  *avPlayer;
@property (nonatomic) UIView    *videoPlayerView;
@property (nonatomic) AVPlayerLayer *videoLayer;

@property (weak, nonatomic) IBOutlet UILabel    *aboutText;
@property (strong, nonatomic) NSString          *aboutTempText;

@property (weak, nonatomic) IBOutlet UILabel *poweredLogo;
@property (weak, nonatomic) IBOutlet UIImageView *sequencingLogo;
@property (weak, nonatomic) IBOutlet UIImageView *wundergroundLogo;
@property (weak, nonatomic) IBOutlet UIImageView *githubLogo;

@end



@implementation AboutViewController

#pragma mark -
#pragma mark View Lyfecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"AboutVC: viewDidLoad");
    
    // set navigation bar fully transpanent
    [self.navigationController.navigationBar setTranslucent:YES];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    
    // set up title
    self.title = @"About Weather My Way +RTP";
    [self.navigationController.navigationBar setTitleTextAttributes:@{ NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:19.0],
                                                                       NSForegroundColorAttributeName: [UIColor whiteColor]
                                                                       }];
    
    // rename "Back" button
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    [[self navigationItem] setBackBarButtonItem:newBackButton];
    
    
    // add gesture to logos
    UITapGestureRecognizer *tapGestureSequencing = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sequencingLogoPressed)];
    tapGestureSequencing.numberOfTapsRequired = 1;
    [tapGestureSequencing setDelegate:self];
    _sequencingLogo.userInteractionEnabled = YES;
    [_sequencingLogo addGestureRecognizer:tapGestureSequencing];
    
    UITapGestureRecognizer *tapGestureSequencing2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sequencingLogoPressed)];
    tapGestureSequencing2.numberOfTapsRequired = 1;
    [tapGestureSequencing2 setDelegate:self];
    _poweredLogo.userInteractionEnabled = YES;
    [_poweredLogo addGestureRecognizer:tapGestureSequencing2];
    
    UITapGestureRecognizer *tapGestureGithub = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(githubLogoPressed)];
    tapGestureGithub.numberOfTapsRequired = 1;
    [tapGestureGithub setDelegate:self];
    _githubLogo.userInteractionEnabled = YES;
    [_githubLogo addGestureRecognizer:tapGestureGithub];
    
    // prepare text lable
    [self prepareText];
    
    // add tapGesture for text
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnText:)];
    singleTap.numberOfTapsRequired = 1;
    [singleTap setDelegate:self];
    _aboutText.userInteractionEnabled = YES;
    [_aboutText addGestureRecognizer:singleTap];
    
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self pauseVideo];
}


- (void)dealloc {
    NSLog(@"AboutVC: dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self deallocateAndRemoveVideoFromView];
}



#pragma mark -
#pragma mark Videoplayer Methods

- (void)initializeAndAddVideoToView {
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


- (UIStatusBarStyle)preferredStatusBarStyle {
    // UIStatusBarStyleLightContent
    // UIStatusBarStyleDefault
    return UIStatusBarStyleLightContent;
}



#pragma mark -
#pragma mark Prepare text

- (void)prepareText {
    NSString *originalText = [_aboutText.text copy];
    _aboutTempText = [_aboutText.text copy];
    _aboutText.text = nil;
    NSString *urlPhrase = kRegisterPhrase;
    
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
    
    _aboutText.attributedText = [attributedString copy];
}



#pragma mark -
#pragma mark UITapGestureRecognizer

- (void)handleTapOnText:(UITapGestureRecognizer *)tapRecognizer {
    CGPoint touchPoint = [tapRecognizer locationInView:_aboutText];
    
    NSString *urlPhrase = kRegisterPhrase;
    NSRange urlTextRange = [_aboutTempText rangeOfString:urlPhrase];
    CGRect urlRect = [self boundingRectForCharacterRange:urlTextRange];
    
    if (CGRectContainsPoint(urlRect, touchPoint)) {
        NSURL *url = [NSURL URLWithString:kRegisterAccountURL];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}

- (CGRect)boundingRectForCharacterRange:(NSRange)range {
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:_aboutText.attributedText];
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    [textStorage addLayoutManager:layoutManager];
    
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:_aboutText.bounds.size]; //
    textContainer.lineFragmentPadding = 0;
    [layoutManager addTextContainer:textContainer];
    
    NSRange glyphRange;
    [layoutManager characterRangeForGlyphRange:range actualGlyphRange:&glyphRange];
    
    return [layoutManager boundingRectForGlyphRange:glyphRange inTextContainer:textContainer];
}



#pragma mark -
#pragma mark Actions

- (IBAction)backButtonPressed:(id)sender {
    [_delegate AboutViewController:self closeButtonPressed:nil];
}


- (void)sequencingLogoPressed {
    NSURL *url = [NSURL URLWithString:kSequencingURL];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}


- (void)githubLogoPressed {
    NSURL *url = [NSURL URLWithString:kGithubURL];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}



#pragma mark -
#pragma mark Memory handler

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
