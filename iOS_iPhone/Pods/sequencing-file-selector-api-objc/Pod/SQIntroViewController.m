//
//  SQIntroViewController.m
//  Copyright © 2015-2016 Sequencing.com. All rights reserved//
//

#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import "SQIntroViewController.h"
#import "SQPopoverInfoViewController.h"
#import "SQFilesAPI.h"


#define FILES_CONTROLLER_SEGUE_ID @"SHOW_FILES_SEGUE_ID"


@interface SQIntroViewController () <UIGestureRecognizerDelegate, UIPopoverPresentationControllerDelegate>

// info button
@property (strong, nonatomic) UIBarButtonItem *infoButton;

@property (weak, nonatomic) IBOutlet UIView *grayView;
@property (weak, nonatomic) IBOutlet UILabel *introLabel;

// my files button
@property (weak, nonatomic) IBOutlet UIView *myFilesButton;
@property (weak, nonatomic) IBOutlet UIImageView *myFilesIcon;
@property (weak, nonatomic) IBOutlet UILabel *myFilesLabel;

// sample files button
@property (weak, nonatomic) IBOutlet UIView *sampleFilesButton;
@property (weak, nonatomic) IBOutlet UIImageView *sampleFilesIcon;
@property (weak, nonatomic) IBOutlet UILabel *sampleFilesLabel;

// properties for videoPlayer
@property (nonatomic) AVPlayer  *avPlayer;
@property (nonatomic) UIView    *videoPlayerView;
@property (nonatomic) AVPlayerLayer *videoLayer;

@end



@implementation SQIntroViewController

#pragma mark -
#pragma mark View Lyfecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // set navigation bar fully transpanent
    [self.navigationController.navigationBar setTranslucent:YES];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    
    SQFilesAPI *filesAPI = [SQFilesAPI sharedInstance];
    UIColor *defaultTextColor = [UIColor blackColor];
    
    if ([filesAPI.videoFileName length] != 0) {
        defaultTextColor = [UIColor whiteColor];
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        self.view.backgroundColor = [UIColor blackColor];
        _introLabel.textColor = [UIColor whiteColor];
    } else {
        _grayView.backgroundColor = [UIColor clearColor];
    }
    
    // set up font font title
    self.title = @"Select a file";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:            [UIFont fontWithName:@"HelveticaNeue-Light" size:19.0],
                                                                      NSForegroundColorAttributeName: defaultTextColor}];
    
    // closeButton
    if (filesAPI.closeButton) {
        UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                                     target:self
                                                                                     action:@selector(closeButtonPressed)];
        [self.navigationItem setLeftBarButtonItem:closeButton animated:NO];
    }
    
    // infoButton
    UIButton *button = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [button addTarget:self action:@selector(showInfoPopover) forControlEvents:UIControlEventTouchUpInside];
    self.infoButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    // rightBarButtonItems
    NSArray *rightButtonsArray = [[NSArray alloc] initWithObjects:self.infoButton, nil];
    self.navigationItem.rightBarButtonItems = rightButtonsArray;
    
    
    // setup myFiles button
    self.myFilesButton.layer.cornerRadius = 5;
    self.myFilesButton.layer.masksToBounds = YES;
    
    UITapGestureRecognizer *myFilesIconTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(myFilesButtonPressed)];
    myFilesIconTapGesture.numberOfTapsRequired = 1;
    [myFilesIconTapGesture setDelegate:self];
    _myFilesIcon.userInteractionEnabled = YES;
    [_myFilesIcon addGestureRecognizer:myFilesIconTapGesture];
    
    UITapGestureRecognizer *myFilesLabelTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(myFilesButtonPressed)];
    myFilesLabelTapGesture.numberOfTapsRequired = 1;
    [myFilesLabelTapGesture setDelegate:self];
    _myFilesLabel.userInteractionEnabled = YES;
    [_myFilesLabel addGestureRecognizer:myFilesLabelTapGesture];
    
    
    // set up sampleFiles button
    self.sampleFilesButton.layer.cornerRadius = 5;
    self.sampleFilesButton.layer.masksToBounds = YES;
    
    UITapGestureRecognizer *sampleFilesIconTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(myFilesButtonPressed)];
    sampleFilesIconTapGesture.numberOfTapsRequired = 1;
    [sampleFilesIconTapGesture setDelegate:self];
    _sampleFilesButton.userInteractionEnabled = YES;
    [_sampleFilesButton addGestureRecognizer:sampleFilesIconTapGesture];
    
    UITapGestureRecognizer *sampleFilesLabelTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(myFilesButtonPressed)];
    sampleFilesLabelTapGesture.numberOfTapsRequired = 1;
    [sampleFilesLabelTapGesture setDelegate:self];
    _sampleFilesIcon.userInteractionEnabled = YES;
    [_sampleFilesIcon addGestureRecognizer:sampleFilesLabelTapGesture];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    SQFilesAPI *filesAPI = [SQFilesAPI sharedInstance];
    
    if ([filesAPI.videoFileName length] != 0) {
        // setup video and add observes
        [self initializeAndAddVideoToView];
        
        // set transpanent grey background for navigation bar in case when video with white part is used now
        if ([self isVideoWhite]) {
            [self.navigationController.navigationBar setBackgroundImage:[self greyTranspanentImage] forBarMetrics:UIBarMetricsDefault];
        }
        
        // video
        [self playVideo];
        [self addNotificationObserves];
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
    [self deallocateAndRemoveVideoFromView];
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self deallocateAndRemoveVideoFromView];
}



#pragma mark -
#pragma mark Videoplayer Methods

- (void)initializeAndAddVideoToView {
    SQFilesAPI *filesAPI = [SQFilesAPI sharedInstance];
    
    // set up videoPlayer with local video file
    NSString *filepath = [[NSBundle mainBundle] pathForResource:filesAPI.videoFileName ofType:nil inDirectory:@"Video"];
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
    [_videoLayer setNeedsDisplay];
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
    SQFilesAPI *filesAPI = [SQFilesAPI sharedInstance];
    if ([filesAPI.videoFileName length] != 0) {
        return UIStatusBarStyleLightContent;
    } else {
        return UIStatusBarStyleDefault;
    }
}



#pragma mark -
#pragma mark Action

- (void)myFilesButtonPressed {
    [self performSegueWithIdentifier:FILES_CONTROLLER_SEGUE_ID sender:@0];
}


- (void)sampleFilesButtonPressed {
    [self performSegueWithIdentifier:FILES_CONTROLLER_SEGUE_ID sender:@1];
}


// close button tapped
- (void)closeButtonPressed {
    SQFilesAPI *filesAPI = [SQFilesAPI sharedInstance];
    if ([filesAPI.fileSelectedHandler respondsToSelector:@selector(closeButtonPressed)]) {
        SQFilesAPI *filesAPI = [SQFilesAPI sharedInstance];
        filesAPI.selectedFileID = nil;
        [filesAPI.fileSelectedHandler closeButtonPressed];
    }
}




#pragma mark -
#pragma mark Popover

- (void)showInfoPopover {
    UIViewController *popoverContentController = [[UIViewController alloc] initWithNibName:@"SQPopoverInfoViewController" bundle:nil];
    
    CGFloat height = [SQPopoverInfoViewController heightForPopoverWidth:self.view.bounds.size.width - 30];
    popoverContentController.preferredContentSize = CGSizeMake(self.view.bounds.size.width - 30, height);
    
    // Set the presentation style to modal and delegate so that the below methods get called
    popoverContentController.modalPresentationStyle = UIModalPresentationPopover;
    popoverContentController.popoverPresentationController.delegate = self;
    
    [self presentViewController:popoverContentController animated:YES completion:nil];
}

- (void)prepareForPopoverPresentation:(UIPopoverPresentationController *)popoverPresentationController {
    popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    popoverPresentationController.barButtonItem = self.infoButton;
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}



#pragma mark -
#pragma mark Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:FILES_CONTROLLER_SEGUE_ID]) {
        NSNumber *indexToShow = sender;
        UITabBarController *tabBar = segue.destinationViewController;
        [tabBar setSelectedIndex:indexToShow.unsignedIntegerValue];
    }
}



#pragma mark -
#pragma mark White video issue helper

- (BOOL)isVideoWhite {
    BOOL videoFileIsWhite = NO;
    SQFilesAPI *filesAPI = [SQFilesAPI sharedInstance];
    
    NSArray *arrayOfVideoFilesWithWhiteBarInTheTop = @[@"shutterstock_v120847.mp4",
                                                       @"shutterstock_v1126162.mp4",
                                                       @"shutterstock_v3036661.mp4",
                                                       @"shutterstock_v4314167.mp4",
                                                       @"shutterstock_v3753200.mp4",
                                                       @"shutterstock_v4627466.mp4",
                                                       @"shutterstock_v5468858.mp4"];
    
    if ([arrayOfVideoFilesWithWhiteBarInTheTop containsObject:filesAPI.videoFileName]) {
        videoFileIsWhite = YES;
    }
    return videoFileIsWhite;
}


- (UIImage *)greyTranspanentImage {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIColor *greyTranspanentColor = [UIColor colorWithRed:85.0/255.0 green:85.0/255.0 blue:85.0/255.0 alpha:0.6];
    CGContextSetFillColorWithColor(context, [greyTranspanentColor CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark -
#pragma mark Other methods

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
