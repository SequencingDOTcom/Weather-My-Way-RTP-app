//
//  UIViewControllerWithVideoBackground.h
//  Copyright © 2017 Sequencing. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "VideoHelper.h"
#import "UserHelper.h"
#import "ForecastData.h"


@interface UIViewControllerWithVideoBackground : UIViewController

@property (nonatomic) AVPlayer      *avPlayer;
@property (nonatomic) UIView        *videoPlayerView;
@property (nonatomic) AVPlayerLayer *videoLayer;

- (void)initializeAndAddVideoToView;
- (void)showVideoWithFile:(NSString *)videoFileName;
- (BOOL)shouldAlwaysCreateVideo;
- (void)deallocateAndRemoveVideoFromView;
- (void)updateVideoLayerFrame;
- (void)handleVideo:(BOOL)isWhite;
- (void)itemDidFinishPlaying:(NSNotification *)notification;
- (void)playVideo;
- (void)pauseVideo;
- (void)addNotificationObserves;
- (void)cleanup;

@end
