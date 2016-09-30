//
//  ForecastViewController.m
//  Copyright © 2016 Sequencing. All rights reserved.
//


#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import "ForecastViewController.h"
#import "UserHelper.h"
#import "SQOAuth.h"
#import "ProgressEmptyViewController.h"
#import "WundergroundHelper.h"
#import "MBProgressHUD.h"
#import "SWRevealViewController.h"
#import "SidebarMenuViewController.h"
#import "ForecastData.h"
#import "LoginViewController.h"
#import "AppDelegate.h"
#import "VideoHelper.h"
#import "GeneticForecastHelper.h"
#import "RedditActivity.h"
#import "SQFilesAPI.h"
#import "UserAccountHelper.h"
#import "LocationWeatherUpdater.h"
#import "SettingsUpdater.h"
#import "AlertMessage.h"
#import "InternetConnection.h"
#import "ExtendedForecastPopoverViewController.h"
#import "ForecastLayout.h"
#import "ForecastDayObject.h"


#define kMainQueue dispatch_get_main_queue()
#define DEGREES_TO_RADIANS(x) ((x * M_PI) / 180)

// setup email templeate for Feedback menuItem
#define kEmailAddress @"feedback@sequencing.com"
#define kEmailSubject @"WeatherMyWay iOS app for iPad feedback"
#define kEmailContent @"Hello,\n"

#define kIPad_leftBarButton_width   59
#define kIPad_rightBarButton_width  55
#define kLocationNameFontSize       20
#define kLocationDateFontSize       15

dispatch_source_t CreateRotationAnimationTimerDispatch(double interval, dispatch_queue_t queue, dispatch_block_t block) {
    dispatch_source_t timerForRotationAnimation = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    if (timerForRotationAnimation) {
        dispatch_source_set_timer(timerForRotationAnimation, dispatch_time(DISPATCH_TIME_NOW, interval * NSEC_PER_SEC), interval * NSEC_PER_SEC, (1ull * NSEC_PER_SEC) / 10);
        dispatch_source_set_event_handler(timerForRotationAnimation, block);
        dispatch_resume(timerForRotationAnimation);
    }
    return timerForRotationAnimation;
}



@interface ForecastViewController () <LocationWeatherUpdaterDelegate, UIGestureRecognizerDelegate, SettingsUpdaterDelegate, UITraitEnvironment, UIPopoverPresentationControllerDelegate>

// property for ProgressView
@property (nonatomic, strong) ProgressEmptyViewController *progressView;

// properties for videoPlayer
@property (nonatomic) AVPlayer      *avPlayer;
@property (nonatomic) UIView        *videoPlayerView;
@property (nonatomic) AVPlayerLayer *videoLayer;

// properties for weather conditions and forecast
@property (weak, nonatomic) IBOutlet UIView     *grayView1;
@property (weak, nonatomic) IBOutlet UILabel    *currentWeatherTitle;
@property (weak, nonatomic) IBOutlet UILabel    *currentTemperature;
@property (weak, nonatomic) IBOutlet UIImageView *currentWeatherIcon;
@property (weak, nonatomic) IBOutlet UILabel    *currentWeatherType;
@property (weak, nonatomic) IBOutlet UILabel    *todaysTemperature;
@property (weak, nonatomic) IBOutlet UILabel    *currentWind;
@property (weak, nonatomic) IBOutlet UILabel    *currentHumidity;
@property (weak, nonatomic) IBOutlet UILabel    *currentPrecipitation;

@property (weak, nonatomic) IBOutlet UIView     *grayView2;
@property (weak, nonatomic) IBOutlet UILabel    *extendedForecastTitle;
@property (weak, nonatomic) IBOutlet UILabel    *extendedForecastText;
@property (weak, nonatomic) IBOutlet UIButton   *alertButton;
@property (weak, nonatomic) IBOutlet UIView     *alertButtonView;
@property (strong, nonatomic) NSString          *alertsTextForPopup;

@property (weak, nonatomic) IBOutlet UIView     *grayView3;
@property (weak, nonatomic) IBOutlet UILabel    *geneticForecastTitle;
@property (weak, nonatomic) IBOutlet UIImageView *sequencingLogo;
@property (weak, nonatomic) IBOutlet UILabel    *geneticForecastText;
@property (weak, nonatomic) IBOutlet UILabel    *poweredBy;

@property (weak, nonatomic) IBOutlet UIView         *grayView4;
@property (weak, nonatomic) IBOutlet UIView         *forecast1DayBlock;
@property (weak, nonatomic) IBOutlet UILabel        *day1NameLabel;
@property (weak, nonatomic) IBOutlet UIImageView    *day1Icon;
@property (weak, nonatomic) IBOutlet UILabel        *day1Temperature;

@property (weak, nonatomic) IBOutlet UIView         *forecast2DayBlock;
@property (weak, nonatomic) IBOutlet UILabel        *day2NameLabel;
@property (weak, nonatomic) IBOutlet UIImageView    *day2Icon;
@property (weak, nonatomic) IBOutlet UILabel        *day2Temperature;

@property (weak, nonatomic) IBOutlet UIView         *forecast3DayBlock;
@property (weak, nonatomic) IBOutlet UILabel        *day3NameLabel;
@property (weak, nonatomic) IBOutlet UIImageView    *day3Icon;
@property (weak, nonatomic) IBOutlet UILabel        *day3Temperature;

@property (weak, nonatomic) IBOutlet UIView         *forecast4DayBlock;
@property (weak, nonatomic) IBOutlet UILabel        *day4NameLabel;
@property (weak, nonatomic) IBOutlet UIImageView    *day4Icon;
@property (weak, nonatomic) IBOutlet UILabel        *day4Temperature;

@property (weak, nonatomic) IBOutlet UIView         *forecast5DayBlock;
@property (weak, nonatomic) IBOutlet UILabel        *day5NameLabel;
@property (weak, nonatomic) IBOutlet UIImageView    *day5Icon;
@property (weak, nonatomic) IBOutlet UILabel        *day5Temperature;

@property (weak, nonatomic) IBOutlet UIView         *forecast6DayBlock;
@property (weak, nonatomic) IBOutlet UILabel        *day6NameLabel;
@property (weak, nonatomic) IBOutlet UIImageView    *day6Icon;
@property (weak, nonatomic) IBOutlet UILabel        *day6Temperature;

@property (weak, nonatomic) IBOutlet UIView         *forecast7DayBlock;
@property (weak, nonatomic) IBOutlet UILabel        *day7NameLabel;
@property (weak, nonatomic) IBOutlet UIImageView    *day7Icon;
@property (weak, nonatomic) IBOutlet UILabel        *day7Temperature;

@property (weak, nonatomic) IBOutlet UIView         *forecast8DayBlock;
@property (weak, nonatomic) IBOutlet UILabel        *day8NameLabel;
@property (weak, nonatomic) IBOutlet UIImageView    *day8Icon;
@property (weak, nonatomic) IBOutlet UILabel        *day8Temperature;

@property (weak, nonatomic) IBOutlet UIView         *forecast9DayBlock;
@property (weak, nonatomic) IBOutlet UILabel        *day9NameLabel;
@property (weak, nonatomic) IBOutlet UIImageView    *day9Icon;
@property (weak, nonatomic) IBOutlet UILabel        *day9Temperature;

@property (weak, nonatomic) IBOutlet UIView         *forecast10DayBlock;
@property (weak, nonatomic) IBOutlet UILabel        *day10NameLabel;
@property (weak, nonatomic) IBOutlet UIImageView    *day10Icon;
@property (weak, nonatomic) IBOutlet UILabel        *day10Temperature;

@property (nonatomic) MBProgressHUD *activityProgress;
@property (assign, nonatomic) BOOL alreadyExecutingRefresh;
@property (assign, nonatomic) BOOL alreadyExecutingSettingsSyncRequest;
@property (assign, nonatomic) BOOL alreadyShownMainMessageAboutForecastAbsence;

// properties to handle changes in app parameters and settings
@property (assign, nonatomic) NSNumber      *nowUsedTemperatureUnit;
@property (assign, nonatomic) NSNumber      *currentlySelectedTemperatureUnit;
@property (strong, nonatomic) NSDictionary  *nowUsedFile;
@property (strong, nonatomic) NSDictionary  *currentlySelectedFile;
@property (strong, nonatomic) NSDictionary  *nowUsedLocation;
@property (strong, nonatomic) NSDictionary  *currentlySelectedLocation;
@property (strong, nonatomic) NSString      *nowUsedWeatherType;
@property (strong, nonatomic) NSString      *currentlyNewWeatherType;
@property (strong, nonatomic) NSString      *nowUsedVideoFileName;

// properties for extended forecast popover
@property (assign, nonatomic) int forecastDayNumber;
@property (strong, nonatomic) UINavigationController *extendedPopoverNavigationVC;


// NSLayoutConstraints to handle from code, and for iPad Pro 12.9"
// gray view 1
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *grayView1TopToContentViewTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *grayView1LeadingToContentViewLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *grayView1TrailingToContentViewTrailing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *grayView1BottomToTemperatureTodayBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *currentWeatherTopToGrayView1Top;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *currentTemperatureLeadingToGrayView1Leading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *precipitationLeadingToGrayView1Leading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *weatherIconTopToCurrentWeatherBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *weatherIconTrailingToGrayView1Trailing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *weatherTypeTopToWeatherIconBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *weatherTypeTrailingToGrayView1Trailing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *grayView1BottomToGrayView4Top;

// gray view 2
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *grayView2TopToGrayView1Bottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *grayView2LeadingToGrayView1Trailing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *grayView2TrailingToContentViewTrailing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *extendedTitleTopToGrayView2Top;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *extendedTextTopToExtendedTitleBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *extendedTitleLeadingToGrayView2Leading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *extendedTitleTrailingToGrayView2Trailing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *alertViewTrailingToGrayView2Trailing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *alertViewBottomToGrayView2Bottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *grayView2BottomToExtendedTextBottom; // for alert button for portrait mode
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *extendedTextBottomToGrayView2Bottom; // for alert button for landscape mode

// gray view 3
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *grayView3TopToGrayView2Bottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *grayView3BottomToPoweredBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *geneticTitleTopToGrayView3Top;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *geneticTitleLeadingToGrayView3Leading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *geneticTitleTrailingToGrayView3Trailing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoLeadingToGrayView3Leading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *geneticTextTopToGeneticTitleBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *geneticTextLeadingToLogoTrailing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *geneticTextBottomToPoweredTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *poweredTopToGeneticTextBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *poweredTrailingToGrayView3Trailing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *poweredBottomToGrayView3Bottom;

// gray view 4
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *grayView4TopToGrayView3Bottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *grayView4BottomToScrollViewBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *forecast1TopToGrayView4Top;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *forecast1LeadingToGrayView4Leading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *grayView4BottomToForecast1Bottom;

@end



@implementation ForecastViewController

dispatch_source_t _timerForRotationAnimation;
static double SECONDS_TO_FIRE_ROTATION_ANIMATION = 7.f; // time interval lengh in seconds

#pragma mark -
#pragma mark View Lyfecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // set navigation bar fully transpanent
    [self.navigationController.navigationBar setTranslucent:YES];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    
    // set up sidebarmenu handler
    SWRevealViewController *revealViewController = self.revealViewController;
    if (revealViewController) {
        [self.menuButton setTarget:self.revealViewController];
        [self.menuButton setAction:@selector(revealToggle:)];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
    // set up alert button
    self.alertButtonView.layer.cornerRadius = 5;
    self.alertButtonView.layer.masksToBounds = YES;
    [self.alertButtonView setHidden:YES];
    [self.alertButton setHidden:YES];
    
    // get forecast data from container
    ForecastData *forecastContainer = [[ForecastData alloc] sharedInstance];
    if (forecastContainer.forecast != nil) {
        // use forecast already received in previos step
        self.forecast = forecastContainer.forecast;
        
        // prepopulate forecast
        [self prepopulateConditionsAndForecast];
        
    } else {
        // we have an error - weather forecast is absent for some reason (server error, internet absence)
        // hide all items
        [self hideAllElements];
    }
    
    // setup video
    [self initializeAndAddVideoToView];
    
    // start the timers for updaters
    SettingsUpdater *settingsUpdater = [SettingsUpdater sharedInstance];
    [settingsUpdater startTimer];
    settingsUpdater.delegate = self;
    _alreadyExecutingSettingsSyncRequest = NO;
    
    LocationWeatherUpdater *locationWeatherUpdater = [LocationWeatherUpdater sharedInstance];
    [locationWeatherUpdater startTimer];
    locationWeatherUpdater.delegate = self;
    _alreadyExecutingRefresh = NO;
    
    [self addNotificationObserves];
    
    [self adjustExtendedForecastLabel];
    
    _alreadyShownMainMessageAboutForecastAbsence = NO;
    
    // add TapGesture for alertButtonView logo
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(alertButtonViewPressed)];
    tapGesture.numberOfTapsRequired = 1;
    [tapGesture setDelegate:self];
    _alertButtonView.userInteractionEnabled = YES;
    [_alertButtonView addGestureRecognizer:tapGesture];
    
    // add tap gestures for extended forecast days
    [self setUpGesturesForForecastDays];
    
    // set up all label font sizes for iPadPro 12.9"
    [self udjustAllTextFontSizeForIpadPro13];
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // video
    [self playVideo];
    
    [self adjustNavigationBarIfVideoIsWhite];
    [self adjustExtendedForecastLabel];
    
    // start animation
    [self animation];
    [self startAnimationTimer];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    ForecastData *forecastContainer = [[ForecastData alloc] sharedInstance];
    if (!forecastContainer.forecast && !_alreadyShownMainMessageAboutForecastAbsence) {
        _alreadyShownMainMessageAboutForecastAbsence = YES;
        AlertMessage *alertMessage = [[AlertMessage alloc] init];
        alertMessage.delegate = self;
        [alertMessage viewController:self
                  showAlertWithTitle:@"Sorry, there was an error while getting weather and genetic forecasts"
                         withMessage:@"Check your Internet connection, check whether Location services are enabled and try to refresh forecast"
                   withRefreshAction:@"Refresh"
                        withOkAction:@"Ok"];
    }
}


- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    [self updateVideoLayerFrame];
    [self adjustExtendedForecastLabel];
    [self updateLayoutsForIpadPro13];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    [self pauseVideo];
    // stop animation
    [self cancelAnimationTimer];
    [self.sequencingLogo.layer removeAllAnimations];
}


- (void)dealloc {
    NSLog(@"ForecastVC: dealloc");
    SettingsUpdater *settingsUpdater = [SettingsUpdater sharedInstance];
    [settingsUpdater cancelTimer];
    settingsUpdater.delegate = nil;
    
    LocationWeatherUpdater *locationWeatherUpdater = [LocationWeatherUpdater sharedInstance];
    [locationWeatherUpdater cancelTimer];
    locationWeatherUpdater.delegate = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self deallocateAndRemoveVideoFromView];
}



#pragma mark -
#pragma mark UITraitEnvironment Methods

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    if (previousTraitCollection.horizontalSizeClass != 0 && previousTraitCollection.verticalSizeClass != 0) {
        UserHelper *userHelper = [[UserHelper alloc] init];
        int temperatureType = [[userHelper loadSettingTemperatureUnit] unsignedShortValue];
        NSDictionary *forecastSection = [_forecast objectForKey:@"forecast"];
        NSDictionary *current_observationSection = [_forecast objectForKey:@"current_observation"];
        NSString *iconAbbreviation = [self identifyIconAbbreviationBasedOnForecasDataAndCurrentObservation:current_observationSection];
        
        if (current_observationSection && forecastSection) {
            // update forecast for 7/10 days
            [self prepopulateForecastDaysBasedOnForecastSection:forecastSection temperatureType:temperatureType iconAbbreviation:iconAbbreviation];
            
            // update location title
            [self prepopulateTitleBasedOnCurrentObservation:current_observationSection andForecastSection:forecastSection];
            
            // update extended forecast day popover
            if (self.extendedPopoverNavigationVC.isViewLoaded) {
                switch (previousTraitCollection.horizontalSizeClass) {
                        
                    case UIUserInterfaceSizeClassCompact: {
                        self.forecastDayNumber++;
                        [self.extendedPopoverNavigationVC dismissViewControllerAnimated:NO completion:^{
                            [self displayExtendedForecastPopover:self.forecastDayNumber];
                        }];
                    }   break;
                        
                    case UIUserInterfaceSizeClassRegular: {
                        if (self.forecastDayNumber <= 1 || self.forecastDayNumber >= 9) {
                            [self.extendedPopoverNavigationVC dismissViewControllerAnimated:YES completion:nil];
                            
                        } else {
                            self.forecastDayNumber--;
                            [self.extendedPopoverNavigationVC dismissViewControllerAnimated:NO completion:^{
                                [self displayExtendedForecastPopover:self.forecastDayNumber];
                            }];
                        }
                    }   break;
                    default: break;
                }
            }
        }
    }
}


- (void)updateLayoutsForIpadPro13 {
    if ([self isIpadPro13inches]) {
        switch (self.view.traitCollection.horizontalSizeClass) {
                
            case UIUserInterfaceSizeClassCompact: { // portrait mode
                // gray view 1
                _grayView1TopToContentViewTop.constant = kGrayView1TopToContentViewTop_IPadProPortrait;
                _grayView1LeadingToContentViewLeading.constant = kGrayView1LeadingToContentViewLeading_IPadProPortrait;
                _grayView1TrailingToContentViewTrailing.constant = kGrayView1TrailingToContentViewTrailing_IPadProPortrait;
                _grayView1BottomToTemperatureTodayBottom.constant = kGrayView1BottomToTemperatureTodayBottom_IPadProPortrait;
                _currentWeatherTopToGrayView1Top.constant = kCurrentWeatherTopToGrayView1Top_IPadProPortrait;
                _currentTemperatureLeadingToGrayView1Leading.constant = kCurrentTemperatureLeadingToGrayView1Leading_IPadProPortrait;
                _precipitationLeadingToGrayView1Leading.constant = kPrecipitationLeadingToGrayView1Leading_IPadProPortrait;
                _weatherIconTopToCurrentWeatherBottom.constant = kWeatherIconTopToCurrentWeatherBottom_IPadProPortrait;
                _weatherIconTrailingToGrayView1Trailing.constant = kWeatherIconTrailingToGrayView1Trailing_IPadProPortrait;
                _weatherTypeTopToWeatherIconBottom.constant = kWeatherTypeTopToWeatherIconTop_IPadProPortrait;
                _weatherTypeTrailingToGrayView1Trailing.constant = kWeatherTypeTrailingToGrayView1Trailing_IPadProPortrait;
                
                // gray view 2
                _grayView2TopToGrayView1Bottom.constant = kGrayView2TopToGrayView1Bottom_IPadProPortrait;
                _extendedTitleTopToGrayView2Top.constant = kExtendedTitleTopToGrayView2Top_IPadProPortrait;
                _extendedTextTopToExtendedTitleBottom.constant = kExtendedTextTopToExtendedTitleBottom_IPadProPortrait;
                _extendedTitleLeadingToGrayView2Leading.constant = kExtendedTitleLeadingToGrayView2Leading_IPadProPortrait;
                _extendedTitleTrailingToGrayView2Trailing.constant = kExtendedTitleTrailing2GrayView2Trailing_IPadProPortrait;
                _alertViewTrailingToGrayView2Trailing.constant = kAlertViewTrailingToGrayView2Trailing_IPadProPortrait;
                _alertViewBottomToGrayView2Bottom.constant = kAlertViewBottomToGrayView2Bottom_IPadProPortrait;
                
                // gray view 3
                _grayView3TopToGrayView2Bottom.constant = kGrayView3TopToGrayView2Bottom_IPadProPortrait;
                _grayView3BottomToPoweredBottom.constant = kGrayView3BottomToPoweredBottom_IPadProPortrait;
                _geneticTitleTopToGrayView3Top.constant = kGeneticTitleTopToGrayView3Top_IPadProPortrait;
                _geneticTitleLeadingToGrayView3Leading.constant = kGeneticTitleLeadingToGrayView3Leading_IPadProPortrait;
                _geneticTitleTrailingToGrayView3Trailing.constant = kGeneticTitleTrailingToGrayView3Trailing_IPadProPortrait;
                _logoLeadingToGrayView3Leading.constant = kLogoLeadingToGrayView3Leading_IPadProPortrait;
                _geneticTextTopToGeneticTitleBottom.constant = kGeneticTextTopToGeneticTitleBottom_IPadProPortrait;
                _geneticTextLeadingToLogoTrailing.constant = kGeneticTextLeadingToLogoTrailing_IPadProPortrait;
                _poweredTopToGeneticTextBottom.constant = kPoweredTopToGeneticTextBottom_IPadProPortrait;
                _poweredTrailingToGrayView3Trailing.constant = kPoweredTrailingToGrayView3Trailing_IPadProPortrait;
                
                // gray view 4
                _grayView4TopToGrayView3Bottom.constant = kGrayView4TopToGrayView3Bottom_IPadProPortrait;
                _forecast1TopToGrayView4Top.constant = kForecast1TopToGrayView4Top_IPadProPortrait;
                _forecast1LeadingToGrayView4Leading.constant = kForecast1LeadingToGrayView4Leading_IPadProPortrait;
                _grayView4BottomToForecast1Bottom.constant = kGrayView4BottomToForecast1Bottom_IPadProPortrait;
            }   break;
                
            case UIUserInterfaceSizeClassRegular: { // landscape mode
                // gray view 1
                _grayView1TopToContentViewTop.constant = kGrayView1TopToContentViewTop_IPadProLandscape;
                _grayView1LeadingToContentViewLeading.constant = kGrayView1LeadingToContentViewLeading_IPadProLandscape;
                _currentWeatherTopToGrayView1Top.constant = kCurrentWeatherTopToGrayView1Top_IPadProLandscape;
                _currentTemperatureLeadingToGrayView1Leading.constant = kCurrentTemperatureLeadingToGrayView1Leading_IPadProLandscape;
                _precipitationLeadingToGrayView1Leading.constant = kPrecipitationLeadingToGrayView1Leading_IPadProLandscape;
                _weatherIconTopToCurrentWeatherBottom.constant = kWeatherIconTopToCurrentWeatherBottom_IPadProLandscape;
                _weatherIconTrailingToGrayView1Trailing.constant = kWeatherIconTrailingToGrayView1Trailing_IPadProLandscape;
                _weatherTypeTrailingToGrayView1Trailing.constant = kWeatherTypeTrailingToGrayView1Trailing_IPadProLandscape;
                _grayView1BottomToGrayView4Top.constant = kGrayView1BottomToGrayView4Top_IPadProLandscape;
                
                // gray view 2
                _grayView2LeadingToGrayView1Trailing.constant = kGrayView2LeadingToGrayView1Trailing_IPadProLandscape;
                _grayView2TrailingToContentViewTrailing.constant = kGrayView2TrailingToContentViewTrailing_IPadProLandscape;
                _extendedTitleTopToGrayView2Top.constant = kExtendedTitleTopToGrayView2Top_IPadProLandscape;
                _extendedTextTopToExtendedTitleBottom.constant = kExtendedTextTopToExtendedTitleBottom_IPadProLandscape;
                _extendedTitleLeadingToGrayView2Leading.constant = kExtendedTitleLeadingToGrayView2Leading_IPadProLandscape;
                _extendedTitleTrailingToGrayView2Trailing.constant = kExtendedTitleTrailing2GrayView2Trailing_IPadProLandscape;
                _alertViewTrailingToGrayView2Trailing.constant = kAlertViewTrailingToGrayView2Trailing_IPadProLandscape;
                _alertViewBottomToGrayView2Bottom.constant = kAlertViewBottomToGrayView2Bottom_IPadProLandscape;
                
                // gray view 3
                _grayView3TopToGrayView2Bottom.constant = kGrayView3TopToGrayView2Bottom_IPadProLandscape;
                _geneticTitleTopToGrayView3Top.constant = kGeneticTitleTopToGrayView3Top_IPadProLandscape;
                _geneticTitleLeadingToGrayView3Leading.constant = kGeneticTitleLeadingToGrayView3Leading_IPadProLandscape;
                _geneticTitleTrailingToGrayView3Trailing.constant = kGeneticTitleTrailingToGrayView3Trailing_IPadProLandscape;
                _logoLeadingToGrayView3Leading.constant = kLogoLeadingToGrayView3Leading_IPadProLandscape;
                _geneticTextTopToGeneticTitleBottom.constant = kGeneticTextTopToGeneticTitleBottom_IPadProLandscape;
                _geneticTextLeadingToLogoTrailing.constant = kGeneticTextLeadingToLogoTrailing_IPadProLandscape;
                _geneticTextBottomToPoweredTop.constant = kGeneticTextBottomToPoweredTop_IPadProLandscape;
                _poweredTrailingToGrayView3Trailing.constant = kPoweredTrailingToGrayView3Trailing_IPadProLandscape;
                _poweredBottomToGrayView3Bottom.constant = kPoweredBottomToGrayView3Bottom_IPadProLandscape;

                // gray view 4
                _grayView4BottomToScrollViewBottom.constant = kGrayView4BottomToScrollViewBottom_IPadProLandscape;
                _forecast1TopToGrayView4Top.constant = kForecast1TopToGrayView4Top_IPadProLandscape;
                _forecast1LeadingToGrayView4Leading.constant = kForecast1LeadingToGrayView4Leading_IPadProLandscape;
                _grayView4BottomToForecast1Bottom.constant = kGrayView4BottomToForecast1Bottom_IPadProLandscape;
            }   break;
                
            default: break;
        }
        [self.view setNeedsUpdateConstraints];
    }
}


- (void)udjustAllTextFontSizeForIpadPro13 {
    if ([self isIpadPro13inches]) {
        // Gray View 1
        _currentWeatherTitle.font = [_currentWeatherTitle.font fontWithSize:kGrayViewTitleFontSize_IPadPro];
        // currentTemperature font size adjusted here: [self prepopulateCurrentTemperatureBasedOnCurrentObservation]
        _currentWeatherType.font = [_currentWeatherType.font fontWithSize:kTodaysTemperatureAndWeatherTypeFontSize_IPadPro];
        // todaysTemperature font size adjusted here: [self prepopulateTodaysHighAndLowTemperatureBasedOnForecastSection]
        _currentWind.font = [_currentWind.font fontWithSize:kWindHumidityAndPrecipitationFontSize_IPadPro];
        _currentHumidity.font = [_currentHumidity.font fontWithSize:kWindHumidityAndPrecipitationFontSize_IPadPro];
        _currentPrecipitation.font = [_currentPrecipitation.font fontWithSize:kWindHumidityAndPrecipitationFontSize_IPadPro];
        
        // Gray View 2
        _extendedForecastTitle.font = [_extendedForecastTitle.font fontWithSize:kGrayViewTitleFontSize_IPadPro];
        _extendedForecastText.font = [_extendedForecastText.font fontWithSize:kExtendedTextFontSize_IPadPro];
        _alertButton.titleLabel.font = [_alertButton.titleLabel.font fontWithSize:kAlertButtonFontSize_IPadPro];
        
        // Gray View 3
        _geneticForecastTitle.font = [_geneticForecastTitle.font fontWithSize:kGrayViewTitleFontSize_IPadPro];
        // _sequencingLogo
        _geneticForecastText.font = [_geneticForecastText.font fontWithSize:kGeneticForecastTextFontSize_IPadPro];
        _poweredBy.font = [_poweredBy.font fontWithSize:kPoweredByFontSize_IPadPro];
        
        // Gray View 4
        _day1NameLabel.font = [_day1NameLabel.font fontWithSize:kForecastDayName_IPadPro];
        _day2NameLabel.font = [_day2NameLabel.font fontWithSize:kForecastDayName_IPadPro];
        _day3NameLabel.font = [_day3NameLabel.font fontWithSize:kForecastDayName_IPadPro];
        _day4NameLabel.font = [_day4NameLabel.font fontWithSize:kForecastDayName_IPadPro];
        _day5NameLabel.font = [_day5NameLabel.font fontWithSize:kForecastDayName_IPadPro];
        _day6NameLabel.font = [_day6NameLabel.font fontWithSize:kForecastDayName_IPadPro];
        _day7NameLabel.font = [_day7NameLabel.font fontWithSize:kForecastDayName_IPadPro];
        _day8NameLabel.font = [_day8NameLabel.font fontWithSize:kForecastDayName_IPadPro];
        _day9NameLabel.font = [_day9NameLabel.font fontWithSize:kForecastDayName_IPadPro];
        _day10NameLabel.font = [_day10NameLabel.font fontWithSize:kForecastDayName_IPadPro];
    }
}



#pragma mark -
#pragma mark Videoplayer Methods

- (void)initializeAndAddVideoToView {
    // set up video
    UserHelper *userHelper = [[UserHelper alloc] init];
    ForecastData *forecastData = [[ForecastData alloc] sharedInstance];
    VideoHelper *videoHelper = [[VideoHelper alloc] init];
    NSString *videoName;
    
    if ([forecastData.weatherType length] != 0 && [forecastData.dayNight length] != 0) {
        videoName = [videoHelper getVideoNameBasedOnWeatherType:forecastData.weatherType AndDayNight:forecastData.dayNight];
    } else {
        videoName = [videoHelper getRandomVideoName];
    }
    
    [userHelper saveKnownVideoFileName:videoName];
    
    // check whether it's the same video again, in order not to reitinialize the same video again
    if ([_nowUsedVideoFileName length] == 0 || ![videoName isEqualToString:_nowUsedVideoFileName]) {
        [self deallocateAndRemoveVideoFromView];
        // save current video file name to property
        _nowUsedVideoFileName = videoName;
        
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
}


- (void)deallocateAndRemoveVideoFromView {
    if (_avPlayer) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [_avPlayer pause];
        _avPlayer = nil;
        [_videoPlayerView removeFromSuperview];
    }
}


- (void)updateVideoLayerFrame {
    _videoLayer.frame = self.view.bounds;
    [_videoLayer setNeedsDisplay]; // or setNeedsDisplay setNeedsLayout
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
                                             selector:@selector(applicationWillResignActiveNotification)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActiveNotification)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(menuItemSelected:)
                                                 name:MENU_ITEM_SELECTED_NOTIFICATION_KEY
                                               object:nil];
}


- (UIStatusBarStyle)preferredStatusBarStyle {
    // UIStatusBarStyleLightContent
    // UIStatusBarStyleDefault
    return UIStatusBarStyleLightContent;
}



#pragma mark -
#pragma mark SequencingLogo animation

- (void)startAnimationTimer {
    dispatch_queue_t queueRotation = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _timerForRotationAnimation = CreateRotationAnimationTimerDispatch(SECONDS_TO_FIRE_ROTATION_ANIMATION, queueRotation, ^{
        dispatch_async(kMainQueue, ^{
            [self rotateLogoFirst180Degrees];
            [self rotateLogoSecond180Degrees];
        });
    });
}

- (void)cancelAnimationTimer {
    if (_timerForRotationAnimation) {
        dispatch_source_cancel(_timerForRotationAnimation);
        _timerForRotationAnimation = nil;
    }
}

- (void)animation {
    dispatch_async(kMainQueue, ^{
        [self startScaleAnimation];
    });
}

- (void)startScaleAnimation {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation.duration = 2;
    animation.repeatCount = HUGE_VAL;
    animation.autoreverses = YES;
    animation.fromValue = [NSNumber numberWithFloat:1.f];
    animation.toValue = [NSNumber numberWithFloat:1.3f];
    [self.sequencingLogo.layer addAnimation:animation forKey:@"scale"];
}

- (void)rotateLogoFirst180Degrees {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.duration = 1;
    animation.additive = NO;
    animation.removedOnCompletion = YES;
    animation.fillMode = kCAFillModeForwards;
    animation.fromValue = [NSNumber numberWithFloat:DEGREES_TO_RADIANS(0)];
    animation.toValue = [NSNumber numberWithFloat:DEGREES_TO_RADIANS(180)];
    [self.sequencingLogo.layer addAnimation:animation forKey:@"first180Rotation"];
}

- (void)rotateLogoSecond180Degrees {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.duration = 1;
    animation.additive = YES;
    animation.removedOnCompletion = YES;
    animation.fillMode = kCAFillModeForwards;
    animation.fromValue = [NSNumber numberWithFloat:DEGREES_TO_RADIANS(0)];
    animation.toValue = [NSNumber numberWithFloat:DEGREES_TO_RADIANS(180)];
    [self.sequencingLogo.layer addAnimation:animation forKey:@"second180Rotation"];
}



#pragma mark -
#pragma mark SidebarMenuViewControllerDelegate

- (void)menuItemSelected:(NSNotification *)notification {
    NSNumber *object = notification.object;
    NSInteger menuItemTag = [object integerValue];
    
    switch (menuItemTag) {
            
        case 1: { // About menuItem selected
            dispatch_async(kMainQueue, ^{
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"About" bundle:nil];
                UINavigationController *aboutNavigationVC = (UINavigationController *)[storyboard instantiateInitialViewController];
                aboutNavigationVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                AboutViewController *aboutVC = [aboutNavigationVC viewControllers][0];
                aboutVC.delegate = self;
                [self presentViewController:aboutNavigationVC animated:YES completion:nil];
            });
        } break;
            
        case 2: { // Settings menuItem selected
            dispatch_async(kMainQueue, ^{
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Settings" bundle:nil];
                UINavigationController *settingsNavigationVC = (UINavigationController *)[storyboard instantiateInitialViewController];
                settingsNavigationVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                SettingsViewController *settingsVC = [settingsNavigationVC viewControllers][0];
                settingsVC.delegate = self;
                if (_alreadyExecutingSettingsSyncRequest)
                    settingsVC.alreadyExecutingSettingsSyncRequest = YES;
                [self presentViewController:settingsNavigationVC animated:YES completion:nil];
            });
        } break;
            
        case 3: { // Location menuItem selected
            dispatch_async(kMainQueue, ^{
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Location" bundle:nil];
                UINavigationController *locationNavigationVC = (UINavigationController *)[storyboard instantiateInitialViewController];
                locationNavigationVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                LocationViewController *locationVC = [locationNavigationVC viewControllers][0];
                locationVC.backButton = YES;
                locationVC.delegate = self;
                [self presentViewController:locationNavigationVC animated:YES completion:nil];
            });
        } break;
            
        case 4: { // Share menuItem selected
            dispatch_async(kMainQueue, ^{
                // identifying rect for popover
                CGRect pointRect = [[notification.userInfo objectForKey:@"cellRect"] CGRectValue];
                CGRect sourceRect = CGRectMake(pointRect.origin.x, pointRect.origin.y + pointRect.size.height, 5, 5);
                UIView *sourceView = [[UIView alloc] initWithFrame:sourceRect];
                [self.view addSubview:sourceView];
                
                // preparing text to share
                NSString *textToShare;
                if (![_geneticForecastText.text containsString:@"Sorry,"]) {
                    textToShare = _geneticForecastText.text;
                } else {
                    textToShare = @"Check this out. Weather My Way +RTP app for getting genetically tailored forecast with weather forecast.";
                }
                NSURL *webSite = [NSURL URLWithString:@"https://sequencing.com/weather-my-way-rtp"];
                UIImage *image = [UIImage imageNamed:@"myway_large_logo"];
                NSArray *itemToShare = @[textToShare, webSite, image];
                
                // initializing popover
                RedditActivity *reddit = [[RedditActivity alloc] init];
                UIActivityViewController *controller = [[UIActivityViewController alloc]
                                                        initWithActivityItems:itemToShare
                                                        applicationActivities:[NSArray arrayWithObjects:reddit, nil]];
                if ( [controller respondsToSelector:@selector(popoverPresentationController)] ) {
                    controller.popoverPresentationController.sourceView = sourceView;
                }
                
                controller.excludedActivityTypes = @[UIActivityTypePostToWeibo,
                                                     UIActivityTypePrint,
                                                     UIActivityTypeAssignToContact,
                                                     UIActivityTypeSaveToCameraRoll,
                                                     UIActivityTypeAddToReadingList,
                                                     UIActivityTypePostToFlickr,
                                                     UIActivityTypePostToVimeo,
                                                     UIActivityTypePostToTencentWeibo,
                                                     UIActivityTypeAirDrop,
                                                     UIActivityTypeOpenInIBooks];
                [self presentViewController:controller animated:YES completion:nil];
            });
        } break;
            
        case 5: { // Feedback menuItem selected
            dispatch_async(kMainQueue, ^{
                NSString *emailAddressURL = [kEmailAddress stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                NSString *emailSubjectURL = [kEmailSubject stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                NSString *emailContentURL = [kEmailContent stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                NSURL *emailTempleate = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"mailto:%@?subject=%@&body=%@",
                                                                       emailAddressURL, emailSubjectURL, emailContentURL]];
                [[UIApplication sharedApplication] openURL:emailTempleate];
            });
        } break;
            
            
        case 6: { // Sign out menuItem selected
            dispatch_async(kMainQueue, ^{
                AlertMessage *alertMessage = [[AlertMessage alloc] init];
                alertMessage.delegate = self;
                [alertMessage viewController:self showAlertWithMessage:@"Are you sure you want to sign out?"
                               withYesAction:@"Confirm" withNoAction:@"Cancel"];
            });
        } break;
            
        default: break;
    }
}



#pragma mark -
#pragma mark AlertMessageDialogDelegate

- (void)yesButtonqPressed {
    UserHelper *userHelper = [[UserHelper alloc] init];
    UserAccountHelper *userAccountHelper = [[UserAccountHelper alloc] init];
    
    // disable device push notifications
    NSDictionary *parameters = @{@"pushCheck"   : @"false",
                                 @"deviceType"  : @(1),
                                 @"deviceToken" : ([[userHelper loadDeviceToken] length] != 0) ? [userHelper loadDeviceToken] : @"",
                                 @"accessToken" : [userHelper loadUserToken].accessToken};
    if ([InternetConnection internetConnectionIsAvailable])
        [userAccountHelper sendSignOutRequestWithParameters:parameters];
    
    [[SQOAuth sharedInstance] userDidSignOut];
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
    
    SettingsUpdater *settingsUpdater = [SettingsUpdater sharedInstance];
    [settingsUpdater cancelTimer];
    settingsUpdater.delegate = nil;
    
    LocationWeatherUpdater *locationWeatherUpdater = [LocationWeatherUpdater sharedInstance];
    locationWeatherUpdater.delegate = self;
    [locationWeatherUpdater cancelTimer];
    
    // open Login view/flow
    dispatch_async(kMainQueue, ^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *loginNavigationVC = (UINavigationController *)[storyboard instantiateInitialViewController];
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate.window setRootViewController:loginNavigationVC];
        [appDelegate.window makeKeyAndVisible];
    });
}



#pragma mark -
#pragma mark AboutViewControllerDelegate

- (void)AboutViewController:(AboutViewController *)controller closeButtonPressed:(id)sender {
    dispatch_async(kMainQueue, ^{
        controller.delegate = nil;
        [controller dismissViewControllerAnimated:YES completion:nil];
    });
}



#pragma mark -
#pragma mark SettingsViewControllerDelegate

- (void)settingsViewControllerWasClosed:(SettingsViewController *)controller
                    withTemperatureUnit:(NSNumber *)temperatureUnit
                           selectedFile:(NSDictionary *)file
                    andSelectedLocation:(NSDictionary *)location {
    dispatch_async(kMainQueue, ^{
        controller.delegate = nil;
        [controller dismissViewControllerAnimated:NO completion:nil];
        
        _currentlySelectedTemperatureUnit = temperatureUnit;
        _currentlySelectedFile = file;
        _currentlySelectedLocation = location;
        
        [self analyseIfAnyRefreshIsNeeded];
        
        SettingsUpdater *settingsUpdater = [SettingsUpdater sharedInstance];
        settingsUpdater.delegate = self;
        _alreadyExecutingSettingsSyncRequest = NO;
    });
}


- (void)settingsViewControllerUserDidSignOut:(SettingsViewController *)controller {
    dispatch_async(kMainQueue, ^{
        controller.delegate = nil;
        [controller dismissViewControllerAnimated:NO completion:nil];
        [self yesButtonPressed];
    });
}



#pragma mark -
#pragma mark LocationViewControllerDelegate

- (void)locationViewController:(LocationViewController *)controller didSelectLocation:(NSDictionary *)location {
    dispatch_async(kMainQueue, ^{
        controller.delegate = nil;
        [controller dismissViewControllerAnimated:NO completion:nil];
    });
    UserHelper *userHelper = [[UserHelper alloc] init];
    
    if ([[location objectForKey:LOCATION_CITY_DICT_KEY] length] != 0) {
        [userHelper saveUserSelectedLocation:location];
        _currentlySelectedLocation = location;
        
    } else {
        NSDictionary *currentLocation   = [userHelper loadUserCurrentLocation];
        NSDictionary *selectedLocation  = [userHelper loadUserSelectedLocation];
        NSDictionary *defaultLocation   = [userHelper loadUserDefaultLocation];
        
        if (![userHelper locationIsEmpty:currentLocation]) {
            [userHelper saveUserSelectedLocation:currentLocation];
            _currentlySelectedLocation = currentLocation;
            
        } else if (![userHelper locationIsEmpty:selectedLocation]) {
            _currentlySelectedLocation = selectedLocation;
            
        } else {
            [userHelper saveUserSelectedLocation:defaultLocation];
            _currentlySelectedLocation = defaultLocation;
        }
    }
    
    // send selected location to user account on server
    if ([InternetConnection internetConnectionIsAvailable]) {
        NSString *locationID = [_currentlySelectedLocation objectForKey:LOCATION_ID_DICT_KEY];
        NSDictionary *parameters = @{@"city"  : locationID,
                                     @"token" : [userHelper loadUserToken].accessToken};
        UserAccountHelper *userAccountHelper = [[UserAccountHelper alloc] init];
        [userAccountHelper sendSelectedLocationInfoWithParameters:parameters];
        NSLog(@"sendSelectedLocationInfoWithParameters");
    }
    
    // refresh UI if needed
    [self analyseIfAnyRefreshIsNeeded];
}


- (void)locationViewController:(LocationViewController *)controller backButtonPressed:(id)sender {
    dispatch_async(kMainQueue, ^{
        controller.delegate = nil;
        [controller dismissViewControllerAnimated:YES completion:nil];
    });
};



#pragma mark -
#pragma mark Prepopulate conditions and forecast

- (void)prepopulateConditionsAndForecast {
    ForecastData *forecastData = [[ForecastData alloc] sharedInstance];
    if (!_forecast && forecastData.forecast) {
        _forecast = forecastData.forecast;
    }
    
    if (_forecast != nil) {
        UserHelper *userHelper = [[UserHelper alloc] init];
        NSDictionary *current_observationSection = [[NSDictionary alloc] init];
        NSDictionary *forecastSection = [[NSDictionary alloc] init];
        if ([[_forecast allKeys] containsObject:@"current_observation"]) {
            current_observationSection = [_forecast objectForKey:@"current_observation"];
        }
        if ([[_forecast allKeys] containsObject:@"forecast"]) {
            forecastSection = [_forecast objectForKey:@"forecast"];
        }
        
        if (current_observationSection && forecastSection) {
            // temperature type value
            int temperatureType = [[userHelper loadSettingTemperatureUnit] unsignedShortValue];
            
            // iconAbbreviation (daytime part: day vs night) identify
            NSString *iconAbbreviation = [self identifyIconAbbreviationBasedOnForecasDataAndCurrentObservation:current_observationSection];
            
            // location name and current day/time info
            [self prepopulateTitleBasedOnCurrentObservation:current_observationSection andForecastSection:forecastSection];
            
            // current temperature
            [self prepopulateCurrentTemperatureBasedOnCurrentObservation:current_observationSection andTemperatureType:temperatureType];
            
            // today's high and low temperature
            [self prepopulateTodaysHighAndLowTemperatureBasedOnForecastSection:forecastSection andTemperatureType:temperatureType];
            
            // today's weather type
            [self prepopulateCurrentWeatherTypeBasedOnCurrentObservation:current_observationSection andForecastSection:forecastSection];
            
            // today's weather icon
            [self prepopulateCurrentWeatherIconBasedOnCurrentObservation:current_observationSection forecastSection:forecastSection andIconAbbreviation:iconAbbreviation];
            
            // today's wind
            [self prepopulateTodaysWindBasedOnCurrentObservation:current_observationSection andTemperatureType:temperatureType];
            
            // today's humidity
            [self prepopulateTodaysHumidityBasedOnCurrentObservation:current_observationSection];
            
            // today's chance of precipitation
            [self prepopulateTodaysChanceOfRainBasedOnForecastSection:forecastSection];
            
            // today's genetic forecast
            [self prepopulateGeneticForecast];
            
            // today's extended weather forecast
            [self prepopulateTodaysExtendedForecastBasedOnForecastSection:forecastSection temperatureType:temperatureType iconAbbreviation:iconAbbreviation];
            
            // forecast for 7/10 days
            [self prepopulateForecastDaysBasedOnForecastSection:forecastSection temperatureType:temperatureType iconAbbreviation:iconAbbreviation];
            
            // analyse Alerts
            [self analyseIfAlertIsPresent];
        }
    }
    
    // saveCurrentParameters
    [self saveCurrentParameters];
}


- (NSString *)identifyIconAbbreviationBasedOnForecasDataAndCurrentObservation:(NSDictionary *)current_observationSection {
    NSString *iconAbbreviation;
    ForecastData *forecastData = [[ForecastData alloc] sharedInstance];
    
    if ([forecastData.dayNight length] != 0) { // get daytime from forecast container
        iconAbbreviation = forecastData.dayNight;
        
    } else { // manually identify daytime from forecast
        int hour;
        if ([[current_observationSection allKeys] containsObject:@"local_time_rfc822"]) {
            NSString *time = [current_observationSection objectForKey:@"local_time_rfc822"];
            
            if ([time length] != 0) {
                NSRange rangeForColumn = [time rangeOfString:@":"];
                NSRange rangeForHour = NSMakeRange(rangeForColumn.location - 2, 2);
                NSString *hourRow = [time substringWithRange:rangeForHour];
                hour = [hourRow intValue];
            }
        } else {
            hour = 10;
        }
        
        if (hour >= 20 || hour <= 5) {
            iconAbbreviation = @"night";
        } else {
            iconAbbreviation = @"day";
        }
    }
    return iconAbbreviation;
}


- (void)prepopulateTitleBasedOnCurrentObservation:(NSDictionary *)current_observationSection
                               andForecastSection:(NSDictionary *)forecastSection {
    // location
    NSString *locationInfo;
    if ([[[current_observationSection objectForKey:@"display_location"] allKeys] containsObject:@"full"]) {
        NSString *locationValue = [[current_observationSection objectForKey:@"display_location"] objectForKey:@"full"];
        if ([locationValue length] != 0) {
            locationInfo = locationValue;
        }
    }
    
    // day and time
    NSString *dateInfo;
    if ([[forecastSection allKeys] containsObject:@"simpleforecast"]) {
        NSDictionary *forecastDay0 = [[[forecastSection objectForKey:@"simpleforecast"] objectForKey:@"forecastday"] objectAtIndex:0];
        
        if ([[forecastDay0 allKeys] containsObject:@"date"]) {
            NSString *weekday = [[forecastDay0 objectForKey:@"date"] objectForKey:@"weekday_short"];
            NSString *month =   [[forecastDay0 objectForKey:@"date"] objectForKey:@"monthname_short"];
            
            id dayRowValue =  [[forecastDay0 objectForKey:@"date"] objectForKey:@"day"];
            id yearRowValue = [[forecastDay0 objectForKey:@"date"] objectForKey:@"year"];
            NSInteger dayValue =  [dayRowValue integerValue];
            NSInteger yearValue = [yearRowValue integerValue];
            NSNumber *dayNumber =  [NSNumber numberWithInteger:dayValue];
            NSNumber *yearNumber = [NSNumber numberWithInteger:yearValue];
            NSString *day =  [dayNumber stringValue];
            NSString *year = [yearNumber stringValue];
            
            if ([weekday length] != 0 && [month length] != 0 && [day length] != 0 && [year length] != 0) {
                dateInfo = [NSString stringWithFormat:@"%@, %@ %@, %@", weekday, month, day, year];
            }
        }
    }
    
    // prepare title label
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    [titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:kLocationNameFontSize]];
    titleLabel.text = [self adjustLocationNameLenghIfNeeded:locationInfo];
    [titleLabel sizeToFit];
    
    // prepare subtitle label
    UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 22, 0, 0)];
    subtitleLabel.backgroundColor = [UIColor clearColor];
    subtitleLabel.textColor = [UIColor whiteColor];
    [subtitleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:kLocationDateFontSize]];
    subtitleLabel.text = dateInfo;
    [subtitleLabel sizeToFit];
    
    UIView *twoLineTitleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MAX(subtitleLabel.frame.size.width, titleLabel.frame.size.width), 28)];
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


- (void)prepopulateCurrentTemperatureBasedOnCurrentObservation:(NSDictionary *)current_observationSection
                                            andTemperatureType:(int)temperatureType {
    NSString *temperatureStringValue;
    NSString *degreeCharacter;
    
    if (temperatureType == 1) { // °C value
        degreeCharacter = @"°C";
        if ([[current_observationSection allKeys] containsObject:@"temp_c"]) {
            id temp = [current_observationSection objectForKey:@"temp_c"];
            NSString *temperature = [NSString stringWithFormat:@"%@", temp];
            
            if ([temperature length] != 0) {
                double temperatureValue = [temperature doubleValue];
                int temperatureValueRounded = (int)lroundf(temperatureValue);
                NSNumber *temperatureNumber = [NSNumber numberWithInteger:temperatureValueRounded];
                temperatureStringValue = [NSString stringWithFormat:@"%@", [temperatureNumber stringValue]];
            }
        }
        
    } else { // °F value
        degreeCharacter = @"°F";
        if ([[current_observationSection allKeys] containsObject:@"temp_f"]) {
            id temp = [current_observationSection objectForKey:@"temp_f"];
            NSString *temperature = [NSString stringWithFormat:@"%@", temp];
            
            if ([temperature length] != 0) {
                double temperatureValue = [temperature doubleValue];
                int temperatureValueRounded = (int)lroundf(temperatureValue);
                NSNumber *temperatureNumber = [NSNumber numberWithInteger:temperatureValueRounded];
                temperatureStringValue = [NSString stringWithFormat:@"%@", [temperatureNumber stringValue]];
            }
        }
    }
    
    // set attributed string
    NSString *temperatureStringWithDegree = [NSString stringWithFormat:@"%@%@", temperatureStringValue, degreeCharacter];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:temperatureStringWithDegree];
    
    CGFloat     currentTemperatureFontSize;
    CGFloat     currentTemperatureUnitFontSize;
    NSUInteger  baselineOffset;
    if ([self isIpadPro13inches]) {
        currentTemperatureFontSize = kCurrentTemperatureFontSize_IPadPro;
        currentTemperatureUnitFontSize = kCurrentTemperatureUnitFontSize_IPadPro;
        baselineOffset = kCurrentTemperatureUnitBaselineOffset_IPadPro;
    } else {
        currentTemperatureFontSize = kCurrentTemperatureFontSize;
        currentTemperatureUnitFontSize = kCurrentTemperatureUnitFontSize;
        baselineOffset = kCurrentTemperatureUnitBaselineOffset;
    }
    
    NSDictionary *attrDictForValue = @{NSFontAttributeName:           [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:currentTemperatureFontSize],
                                       NSForegroundColorAttributeName:[UIColor whiteColor]};
    NSDictionary *attrDictForDegree = @{NSFontAttributeName:           [UIFont fontWithName:@"HelveticaNeue-Light" size:currentTemperatureUnitFontSize],
                                        NSForegroundColorAttributeName:[UIColor whiteColor],
                                        NSBaselineOffsetAttributeName:  [NSNumber numberWithUnsignedInteger:baselineOffset]};
    
    [attributedString addAttributes:attrDictForValue  range:NSMakeRange(0, [temperatureStringValue length])];
    [attributedString addAttributes:attrDictForDegree range:NSMakeRange([temperatureStringValue length], [degreeCharacter length])];
    
    _currentTemperature.attributedText = [attributedString copy];
}


- (void)prepopulateTodaysHighAndLowTemperatureBasedOnForecastSection:(NSDictionary *)forecastSection
                                                  andTemperatureType:(int)temperatureType {
    NSString *tempH = [self pullHightTemperatureFromForecastDay:0
                                         basedOnForecastSection:forecastSection
                                     dependingOnTemperatureType:temperatureType];
    NSString *tempL = [self pullLowTemperatureFromForecastDay:0
                                       basedOnForecastSection:forecastSection
                                   dependingOnTemperatureType:temperatureType];
    
    CGFloat todaysTemperatureFontSize;
    if ([self isIpadPro13inches]) {
        todaysTemperatureFontSize = kTodaysTemperatureAndWeatherTypeFontSize_IPadPro;
    } else {
        todaysTemperatureFontSize = kTodaysTemperatureFontSize;
    }
    
    if ([tempH length] != 0 && [tempL length] != 0) {
        _todaysTemperature.attributedText = [self prepareAttributedTempteratureStringBasedOnHighTemperature:tempH
                                                                                             lowTemperature:tempL
                                                                                                andFontSize:todaysTemperatureFontSize];
    }
}


- (void)prepopulateCurrentWeatherTypeBasedOnCurrentObservation:(NSDictionary *)current_observationSection
                                            andForecastSection:(NSDictionary *)forecastSection {
    ForecastData *forecastData = [[ForecastData alloc] sharedInstance];
    
    if ([forecastData.weatherType length] != 0) { // we have weather type stored in forecastdata container
        _currentWeatherType.text = [forecastData.weatherType capitalizedString];
        
    } else { // let's get weather type manually
        NSString *weatherType;
        if ([[current_observationSection allKeys] containsObject:@"weather"]) {
            // try to get weather type info from current_observation section
            weatherType = [current_observationSection objectForKey:@"weather"];
        }
        
        if ([weatherType length] != 0) { // use weather info if it's valid in current_observation section
            _currentWeatherType.text = weatherType;
            forecastData.weatherType = [weatherType lowercaseString];
            NSLog(@"ForecastVC: weatherType: %@", weatherType);
            
        } else { // let's try to get weather type info from forecastday[0] in forecast section
            if ([[forecastSection allKeys] containsObject:@"simpleforecast"]) {
                NSDictionary *forecastDay0 = [[[forecastSection objectForKey:@"simpleforecast"] objectForKey:@"forecastday"] objectAtIndex:0];
                
                if (forecastDay0 && [[forecastDay0 allKeys] containsObject:@"conditions"]) {
                    weatherType = [forecastDay0 objectForKey:@"conditions"];
                }
                
                if ([weatherType length] != 0) {
                    _currentWeatherType.text = weatherType;
                    forecastData.weatherType = [weatherType lowercaseString];
                    NSLog(@"ForecastVC: weatherType: %@", weatherType);
                }
            }
        }
    } // end of else "manually getting"
}


- (void)prepopulateCurrentWeatherIconBasedOnCurrentObservation:(NSDictionary *)current_observationSection
                                               forecastSection:(NSDictionary *)forecastSection
                                           andIconAbbreviation:(NSString *)iconAbbreviation {
    NSString *weatherType;
    NSString *weatherTypeCorrected;
    NSString *weatherIconString;
    UIImage  *weatherIcon;
    
    // let's try to get icon from forecast section based on icon name
    weatherIcon = [self pullIconFromForecastDay:0 basedOnForecastSection:forecastSection andIconAbbreviation:iconAbbreviation];
    if (weatherIcon) {
        // our weather icon is identified successfully based on icon name from forecast section
        [self assingCurrentWeatherIcon:weatherIcon];
        
    } else { // let's try to get icon based on weather type from forecastdata container
        ForecastData *forecastData = [[ForecastData alloc] sharedInstance];
        if ([forecastData.weatherType length] != 0) {
            weatherType = [forecastData.weatherType lowercaseString];
            weatherTypeCorrected = [weatherType stringByReplacingOccurrencesOfString:@" " withString:@""];
            weatherIconString = [NSString stringWithFormat:@"%@ %@", iconAbbreviation, weatherTypeCorrected];
            weatherIcon = [UIImage imageNamed:weatherIconString];
            if (weatherIcon) {
                // our weather icon is identified successfully based on weather type from forecastdata container
                [self assingCurrentWeatherIcon:weatherIcon];
            }
        }
    }
    
    // if we still don't have identified weather icon let's use N/A icon
    if (!weatherIcon && !_currentWeatherIcon.image) {
        weatherIcon = [UIImage imageNamed:[NSString stringWithFormat:@"%@ unknown", iconAbbreviation]];
        if (weatherIcon) {
            [self assingCurrentWeatherIcon:weatherIcon];
            NSLog(@"icon not found for weather type: %@", weatherType);
        }
    }
}


- (void)assingCurrentWeatherIcon:(UIImage *)image {
    if (![self isIpadPro13inches]) {
        _currentWeatherIcon.image = [self imageWithImage:image scaledToSize:CGSizeMake(kWeatherIconWidthHeight_IPad, kWeatherIconWidthHeight_IPad)];
        
    } else {
        _currentWeatherIcon.image = [self imageWithImage:image scaledToSize:CGSizeMake(kWeatherIconWidthHeight_IPadPro, kWeatherIconWidthHeight_IPadPro)];
    }
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}



- (void)prepopulateTodaysWindBasedOnCurrentObservation:(NSDictionary *)current_observationSection
                                    andTemperatureType:(int)temperatureType {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.roundingIncrement = [NSNumber numberWithDouble:0.01];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    NSString *windDirection;
    
    if ([[current_observationSection allKeys] containsObject:@"wind_dir"]) {
        id temp = [current_observationSection objectForKey:@"wind_dir"];
        windDirection = [NSString stringWithFormat:@"%@", temp];
    }
    
    if (temperatureType == 1) { // metric value
        if ([[current_observationSection allKeys] containsObject:@"wind_kph"]) {
            id temp = [current_observationSection objectForKey:@"wind_kph"];
            NSString *speed = [NSString stringWithFormat:@"%@", temp];
            
            if ([speed length] != 0) {
                double speedValue = [speed doubleValue];
                if (speedValue < 0) {
                    speedValue = 0.f;
                }
                NSNumber *windSpeed = [NSNumber numberWithDouble:speedValue];
                _currentWind.text = [NSString stringWithFormat:@"wind: %@ km/h, %@", [formatter stringFromNumber:windSpeed], windDirection];
            }
        }
        
    } else { // british value
        if ([[current_observationSection allKeys] containsObject:@"wind_mph"]) {
            id temp = [current_observationSection objectForKey:@"wind_mph"];
            NSString *speed = [NSString stringWithFormat:@"%@", temp];
            
            if ([speed length] != 0) {
                double speedValue = [speed doubleValue];
                if (speedValue < 0) {
                    speedValue = 0.f;
                }
                NSNumber *windSpeed = [NSNumber numberWithDouble:speedValue];
                _currentWind.text = [NSString stringWithFormat:@"wind: %@ MPH, %@", [formatter stringFromNumber:windSpeed], windDirection];
            }
        }
    }
    formatter = nil;
}


- (void)prepopulateTodaysHumidityBasedOnCurrentObservation:(NSDictionary *)current_observationSection {
    if ([[current_observationSection allKeys] containsObject:@"relative_humidity"]) {
        id temp = [current_observationSection objectForKey:@"relative_humidity"];
        NSString *humidityValue = [NSString stringWithFormat:@"%@", temp];
        
        if ([humidityValue length] != 0) {
            NSString *humidityString = [NSString stringWithFormat:@"humidity: %@", humidityValue];
            _currentHumidity.text = humidityString;
        }
    }
}


- (void)prepopulateGeneticForecast {
    ForecastData *forecastContainer = [[ForecastData alloc] sharedInstance];
    if ([forecastContainer.geneticForecast length] != 0) {
        _geneticForecastText.text = forecastContainer.geneticForecast;
    }
}


- (void)prepopulateTodaysChanceOfRainBasedOnForecastSection:(NSDictionary *)forecastSection {
    if ([[forecastSection allKeys] containsObject:@"simpleforecast"]) {
        NSDictionary *forecastDay0 = [[[forecastSection objectForKey:@"simpleforecast"] objectForKey:@"forecastday"] objectAtIndex:0];
        
        if ([[forecastDay0 allKeys] containsObject:@"pop"]) {
            id temp = [forecastDay0 objectForKey:@"pop"];
            NSString *chanceOfRainValue = [NSString stringWithFormat:@"%@", temp];
            
            if ([chanceOfRainValue length] != 0) {
                NSString *chanceOfRainString = [NSString stringWithFormat:@"chance of precipitation: %@%%", chanceOfRainValue];
                _currentPrecipitation.text = chanceOfRainString;
            }
        }
    }
}


- (void)prepopulateTodaysExtendedForecastBasedOnForecastSection:(NSDictionary *)forecastSection
                                                temperatureType:(int)temperatureType
                                               iconAbbreviation:(NSString *)iconAbbreviation {
    if ([iconAbbreviation containsString:@"day"]) {
        _extendedForecastText.text = [self pullExtendedForecastBasedOnForecastSection:forecastSection
                                                                      temperatureType:temperatureType
                                                                          forecastDay:0];
    } else {
        _extendedForecastText.text = [self pullExtendedForecastBasedOnForecastSection:forecastSection
                                                                      temperatureType:temperatureType
                                                                          forecastDay:1];
    }
}


- (NSString *)pullExtendedForecastBasedOnForecastSection:(NSDictionary *)forecastSection
                                         temperatureType:(int)temperatureType
                                             forecastDay:(int)forecastDayNumber {
    NSString *extendedWeatherForecast;
    if ([[forecastSection allKeys] containsObject:@"txt_forecast"]) {
        NSDictionary *forecastDay = [[[forecastSection objectForKey:@"txt_forecast"] objectForKey:@"forecastday"] objectAtIndex:forecastDayNumber];
        
        if (temperatureType == 1) { // metric value
            if ([[forecastDay allKeys] containsObject:@"fcttext_metric"]) {
                id temp = [forecastDay objectForKey:@"fcttext_metric"];
                NSString *extForecast = [NSString stringWithFormat:@"%@", temp];
                if ([extForecast length] != 0) {
                    extendedWeatherForecast = extForecast;
                }
            }
            
        } else { // british value
            if ([[forecastDay allKeys] containsObject:@"fcttext"]) {
                id temp = [forecastDay objectForKey:@"fcttext"];
                NSString *extForecast = [NSString stringWithFormat:@"%@", temp];
                if ([extForecast length] != 0) {
                    extendedWeatherForecast = extForecast;
                }
            }
        }
    }
    return extendedWeatherForecast;
}


- (void)prepopulateForecastDaysBasedOnForecastSection:(NSDictionary *)forecastSection
                                      temperatureType:(int)temperatureType
                                     iconAbbreviation:(NSString *)iconAbbreviation {
    CGFloat fontSize;
    if ([self isIpadPro13inches]) {
        fontSize = kForecastDayTemperature_IPadPro;
    } else {
        fontSize = kForecastDayTemperature;
    }
    
    int lastDay;
    BOOL landscapeMode;
    if (self.view.frame.size.height > self.view.frame.size.width) {
        // portrait mode
        lastDay  = 8;
        landscapeMode = NO;
    } else {
        // landscape mode
        lastDay  = 11;
        landscapeMode = YES;
    }
    
    for (int i = 1; i < lastDay; i++) {
        int dayInForecast;
        if (landscapeMode) {
            dayInForecast = i - 1;
        } else {
            dayInForecast = i;
        }
        
        // day name
        NSString *weekday = [self pullShortWeekdayFromForecastDay:dayInForecast
                                           basedOnForecastSection:forecastSection];
        // icon
        UIImage *icon = [self pullIconFromForecastDay:dayInForecast
                               basedOnForecastSection:forecastSection
                                  andIconAbbreviation:@"day"];
        // temperature
        NSString *tempH = [self pullHightTemperatureFromForecastDay:dayInForecast
                                             basedOnForecastSection:forecastSection
                                         dependingOnTemperatureType:temperatureType];
        
        NSString *tempL = [self pullLowTemperatureFromForecastDay:dayInForecast
                                           basedOnForecastSection:forecastSection
                                       dependingOnTemperatureType:temperatureType];
        
        switch (i) {
                
            case 1: {
                if ([weekday containsString:@"Sat"] || [weekday containsString:@"Sun"]) {
                    _day1NameLabel.attributedText = [self prepareAttributedWeekday:weekday];
                } else {
                    _day1NameLabel.text = weekday;
                }
                if (icon) {
                    _day1Icon.image = icon;
                } else {
                    _day1Icon.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@ unknown", @"day"]];
                }
                _day1Temperature.attributedText = [self prepareAttributedTempteratureStringBasedOnHighTemperature:tempH
                                                                                                   lowTemperature:tempL
                                                                                                      andFontSize:fontSize];
            } break;
                
            case 2: {
                if ([weekday containsString:@"Sat"] || [weekday containsString:@"Sun"]) {
                    _day2NameLabel.attributedText = [self prepareAttributedWeekday:weekday];
                } else {
                    _day2NameLabel.text = weekday;
                }
                if (icon) {
                    _day2Icon.image = icon;
                } else {
                    _day2Icon.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@ unknown", @"day"]];
                }
                _day2Temperature.attributedText = [self prepareAttributedTempteratureStringBasedOnHighTemperature:tempH
                                                                                                   lowTemperature:tempL
                                                                                                      andFontSize:fontSize];
            } break;
                
            case 3: {
                if ([weekday containsString:@"Sat"] || [weekday containsString:@"Sun"]) {
                    _day3NameLabel.attributedText = [self prepareAttributedWeekday:weekday];
                } else {
                    _day3NameLabel.text = weekday;
                }
                if (icon) {
                    _day3Icon.image = icon;
                } else {
                    _day3Icon.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@ unknown", @"day"]];
                }
                _day3Temperature.attributedText = [self prepareAttributedTempteratureStringBasedOnHighTemperature:tempH
                                                                                                   lowTemperature:tempL
                                                                                                      andFontSize:fontSize];
            } break;
                
            case 4: {
                if ([weekday containsString:@"Sat"] || [weekday containsString:@"Sun"]) {
                    _day4NameLabel.attributedText = [self prepareAttributedWeekday:weekday];
                } else {
                    _day4NameLabel.text = weekday;
                }
                if (icon) {
                    _day4Icon.image = icon;
                } else {
                    _day4Icon.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@ unknown", @"day"]];
                }
                _day4Temperature.attributedText = [self prepareAttributedTempteratureStringBasedOnHighTemperature:tempH
                                                                                                   lowTemperature:tempL
                                                                                                      andFontSize:fontSize];
            } break;
                
            case 5: {
                if ([weekday containsString:@"Sat"] || [weekday containsString:@"Sun"]) {
                    _day5NameLabel.attributedText = [self prepareAttributedWeekday:weekday];
                } else {
                    _day5NameLabel.text = weekday;
                }
                if (icon) {
                    _day5Icon.image = icon;
                } else {
                    _day5Icon.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@ unknown", @"day"]];
                }
                _day5Temperature.attributedText = [self prepareAttributedTempteratureStringBasedOnHighTemperature:tempH
                                                                                                   lowTemperature:tempL
                                                                                                      andFontSize:fontSize];
            } break;
                
            case 6: {
                if ([weekday containsString:@"Sat"] || [weekday containsString:@"Sun"]) {
                    _day6NameLabel.attributedText = [self prepareAttributedWeekday:weekday];
                } else {
                    _day6NameLabel.text = weekday;
                }
                if (icon) {
                    _day6Icon.image = icon;
                } else {
                    _day6Icon.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@ unknown", @"day"]];
                }
                _day6Temperature.attributedText = [self prepareAttributedTempteratureStringBasedOnHighTemperature:tempH
                                                                                                   lowTemperature:tempL
                                                                                                      andFontSize:fontSize];
            } break;
                
            case 7: {
                if ([weekday containsString:@"Sat"] || [weekday containsString:@"Sun"]) {
                    _day7NameLabel.attributedText = [self prepareAttributedWeekday:weekday];
                } else {
                    _day7NameLabel.text = weekday;
                }
                if (icon) {
                    _day7Icon.image = icon;
                } else {
                    _day7Icon.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@ unknown", @"day"]];
                }
                _day7Temperature.attributedText = [self prepareAttributedTempteratureStringBasedOnHighTemperature:tempH
                                                                                                   lowTemperature:tempL
                                                                                                      andFontSize:fontSize];
            } break;
                
            case 8: {
                if ([weekday containsString:@"Sat"] || [weekday containsString:@"Sun"]) {
                    _day8NameLabel.attributedText = [self prepareAttributedWeekday:weekday];
                } else {
                    _day8NameLabel.text = weekday;
                }
                if (icon) {
                    _day8Icon.image = icon;
                } else {
                    _day8Icon.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@ unknown", @"day"]];
                }
                _day8Temperature.attributedText = [self prepareAttributedTempteratureStringBasedOnHighTemperature:tempH
                                                                                                   lowTemperature:tempL
                                                                                                      andFontSize:fontSize];
            } break;
                
            case 9: {
                if ([weekday containsString:@"Sat"] || [weekday containsString:@"Sun"]) {
                    _day9NameLabel.attributedText = [self prepareAttributedWeekday:weekday];
                } else {
                    _day9NameLabel.text = weekday;
                }
                if (icon) {
                    _day9Icon.image = icon;
                } else {
                    _day9Icon.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@ unknown", @"day"]];
                }
                _day9Temperature.attributedText = [self prepareAttributedTempteratureStringBasedOnHighTemperature:tempH
                                                                                                   lowTemperature:tempL
                                                                                                      andFontSize:fontSize];
            } break;
                
            case 10: {
                if ([weekday containsString:@"Sat"] || [weekday containsString:@"Sun"]) {
                    _day10NameLabel.attributedText = [self prepareAttributedWeekday:weekday];
                } else {
                    _day10NameLabel.text = weekday;
                }
                if (icon) {
                    _day10Icon.image = icon;
                } else {
                    _day10Icon.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@ unknown", @"day"]];
                }
                _day10Temperature.attributedText = [self prepareAttributedTempteratureStringBasedOnHighTemperature:tempH
                                                                                                    lowTemperature:tempL
                                                                                                       andFontSize:fontSize];
            } break;
            default: break;
        } // end of switch
    } // end for cycle
}


- (NSString *)pullShortWeekdayFromForecastDay:(int)forecastDayNumber basedOnForecastSection:(NSDictionary *)forecastSection {
    NSString *weekday = [self pullWeekdayFromForecastDay:forecastDayNumber
                                         fullWeekdayName:NO
                                  basedOnForecastSection:forecastSection];
    return weekday;
}

- (NSString *)pullFullWeekdayFromForecastDay:(int)forecastDayNumber basedOnForecastSection:(NSDictionary *)forecastSection {
    NSString *weekday = [self pullWeekdayFromForecastDay:forecastDayNumber
                                         fullWeekdayName:YES
                                  basedOnForecastSection:forecastSection];
    return weekday;
}


- (NSString *)pullWeekdayFromForecastDay:(int)forecastDayNumber fullWeekdayName:(BOOL)fullWeekdayName basedOnForecastSection:(NSDictionary *)forecastSection {
    NSString *weekday;
    if ([[forecastSection allKeys] containsObject:@"simpleforecast"]) {
        
        NSArray *daysArray = [[forecastSection objectForKey:@"simpleforecast"] objectForKey:@"forecastday"];
        int arrayCount = (int)[daysArray count];
        if (forecastDayNumber < arrayCount) {
            
            NSDictionary *forecastDay = [[[forecastSection objectForKey:@"simpleforecast"] objectForKey:@"forecastday"] objectAtIndex:forecastDayNumber];
            if ([[forecastDay allKeys] containsObject:@"date"]) {
                NSString *weekdayName;
                NSString *monthName;
                
                // weekdayName, monthName
                if (fullWeekdayName) {
                    weekdayName = [[forecastDay objectForKey:@"date"] objectForKey:@"weekday"];
                    monthName = [[forecastDay objectForKey:@"date"] objectForKey:@"monthname"];
                } else {
                    weekdayName = [[forecastDay objectForKey:@"date"] objectForKey:@"weekday_short"];
                }
                
                // month value
                id monthTemp = [[forecastDay objectForKey:@"date"] objectForKey:@"month"];
                NSString *monthValue = [NSString stringWithFormat:@"%@", monthTemp];
                
                // day value
                NSString *dayValue;
                id monthDay = [[forecastDay objectForKey:@"date"] objectForKey:@"day"];
                NSString *monthDayTempStringValue = [NSString stringWithFormat:@"%@", monthDay];
                int dayIntValue = [monthDayTempStringValue intValue];
                if (dayIntValue < 10 && !fullWeekdayName) {
                    dayValue = [NSString stringWithFormat:@"0%@", monthDay];
                } else {
                    dayValue = [NSString stringWithFormat:@"%@", monthDay];
                }
                
                // result
                if (fullWeekdayName) {
                    weekday = [NSString stringWithFormat:@"%@, %@ %@", weekdayName, monthName, dayValue];
                    
                } else {
                    weekday = [NSString stringWithFormat:@"%@ %@/%@", weekdayName, monthValue, dayValue];
                }
            }
        } else {
            weekday = @"";
            NSLog(@"!!! array contains only: %d items", arrayCount);
            NSLog(@"!!! array:\n%@", daysArray);
        }
    }
    return weekday;
}


- (NSAttributedString *)prepareAttributedWeekday:(NSString *)weekday {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:weekday];
    CGFloat fontSize;
    if ([self isIpadPro13inches]) {
        fontSize = kForecastDayName_IPadPro;
    } else {
        fontSize = kForecastDayName;
    }
    NSDictionary *attrDict = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:fontSize],
                               NSForegroundColorAttributeName: [UIColor greenColor]};
    // [UIColor colorWithRed:255.0/255.0 green:69.0/255.0 blue:0.0/255.0 alpha:1.0]
    [attributedString addAttributes:attrDict range:NSMakeRange(0, [weekday length])];
    return [attributedString copy];
}


- (UIImage *)pullIconFromForecastDay:(int)forecastDayNumber basedOnForecastSection:(NSDictionary *)forecastSection andIconAbbreviation:(NSString *)iconAbbreviation {
    UIImage *icon;
    if ([[forecastSection allKeys] containsObject:@"simpleforecast"]) {
        NSDictionary *forecastDay = [[[forecastSection objectForKey:@"simpleforecast"] objectForKey:@"forecastday"] objectAtIndex:forecastDayNumber];
        
        if ([[forecastDay allKeys] containsObject:@"icon"]) {
            NSString *weather = [forecastDay objectForKey:@"icon"];
            NSString *weatherType = [weather lowercaseString];
            NSString *weatherIcon = [NSString stringWithFormat:@"%@ %@", iconAbbreviation, weatherType];
            icon = [UIImage imageNamed:weatherIcon];
        }
    }
    return icon;
}


- (NSString *)pullHightTemperatureFromForecastDay:(int)forecastDayNumber basedOnForecastSection:(NSDictionary *)forecastSection dependingOnTemperatureType:(int)temperatureType {
    NSString *temperature;
    if ([[forecastSection allKeys] containsObject:@"simpleforecast"]) {
        NSDictionary *forecastDay0 = [[[forecastSection objectForKey:@"simpleforecast"] objectForKey:@"forecastday"] objectAtIndex:forecastDayNumber];
        
        if (temperatureType == 1) { // °C value
            id tempH;
            if ([[forecastDay0 allKeys] containsObject:@"high"]) {
                tempH = [[forecastDay0 objectForKey:@"high"] objectForKey:@"celsius"];
            }
            NSString *temperatureH = [NSString stringWithFormat:@"%@", tempH];
            
            if ([temperatureH length] != 0 ) {
                double temperatureHValue = [temperatureH doubleValue];
                int temperatureHValueRounded = (int)lroundf(temperatureHValue);
                NSNumber *temperatureHNumber = [NSNumber numberWithInteger:temperatureHValueRounded];
                
                temperature = [NSString stringWithFormat:@"%@", [temperatureHNumber stringValue]];
            }
            
        } else { // °F value
            id tempH;
            if ([[forecastDay0 allKeys] containsObject:@"high"]) {
                tempH = [[forecastDay0 objectForKey:@"high"] objectForKey:@"fahrenheit"];
            }
            NSString *temperatureH = [NSString stringWithFormat:@"%@", tempH];
            
            if ([temperatureH length] != 0) {
                double temperatureHValue = [temperatureH doubleValue];
                int temperatureHValueRounded = (int)lroundf(temperatureHValue);
                NSNumber *temperatureHNumber = [NSNumber numberWithInteger:temperatureHValueRounded];
                
                temperature = [NSString stringWithFormat:@"%@", [temperatureHNumber stringValue]];
            }
        }
    }
    return temperature;
}


- (NSString *)pullLowTemperatureFromForecastDay:(int)forecastDayNumber basedOnForecastSection:(NSDictionary *)forecastSection dependingOnTemperatureType:(int)temperatureType {
    NSString *temperature;
    if ([[forecastSection allKeys] containsObject:@"simpleforecast"]) {
        NSDictionary *forecastDay0 = [[[forecastSection objectForKey:@"simpleforecast"] objectForKey:@"forecastday"] objectAtIndex:forecastDayNumber];
        
        if (temperatureType == 1) { // °C value
            id tempL;
            if ([[forecastDay0 allKeys] containsObject:@"low"]) {
                tempL = [[forecastDay0 objectForKey:@"low"] objectForKey:@"celsius"];
            }
            NSString *temperatureL = [NSString stringWithFormat:@"%@", tempL];
            
            if ([temperatureL length] != 0) {
                double temperatureLValue = [temperatureL doubleValue];
                int temperatureLValueRounded = (int)lroundf(temperatureLValue);
                NSNumber *temperatureLNumber = [NSNumber numberWithInteger:temperatureLValueRounded];
                
                temperature = [NSString stringWithFormat:@"%@", [temperatureLNumber stringValue]];
            }
            
        } else { // °F value
            id tempL;
            if ([[forecastDay0 allKeys] containsObject:@"low"]) {
                tempL = [[forecastDay0 objectForKey:@"low"] objectForKey:@"fahrenheit"];
            }
            NSString *temperatureL = [NSString stringWithFormat:@"%@", tempL];
            
            if ([temperatureL length] != 0) {
                double temperatureLValue = [temperatureL doubleValue];
                int temperatureLValueRounded = (int)lroundf(temperatureLValue);
                NSNumber *temperatureLNumber = [NSNumber numberWithInteger:temperatureLValueRounded];
                
                temperature = [NSString stringWithFormat:@"%@", [temperatureLNumber stringValue]];
            }
        }
    }
    return temperature;
}


- (NSAttributedString *)prepareAttributedTempteratureStringBasedOnHighTemperature:(NSString *)tempH lowTemperature:(NSString *)tempL andFontSize:(CGFloat)fontSize {
    NSString *highTemperatureText = [NSString stringWithFormat:@"H %@°", tempH];
    NSString *lowTemperatureText = [NSString stringWithFormat:@"L %@°", tempL];
    
    NSString *preliminaryTemperatureString = [NSString stringWithFormat:@"%@ %@", highTemperatureText, lowTemperatureText];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:preliminaryTemperatureString];
    
    NSDictionary *attrDictForHigh = @{NSFontAttributeName:           [UIFont fontWithName:@"HelveticaNeue-Light" size:fontSize],
                                      NSForegroundColorAttributeName:[UIColor whiteColor]};
    
    NSDictionary *attrDictForLow = @{NSFontAttributeName:           [UIFont fontWithName:@"HelveticaNeue-Light" size:fontSize],
                                     NSForegroundColorAttributeName:[UIColor colorWithRed:140.0/255.0 green:197.0/255.0 blue:255.0/255.0 alpha:1.0]};
    
    [attributedString addAttributes:attrDictForHigh range:NSMakeRange(0, [highTemperatureText length])];
    [attributedString addAttributes:attrDictForLow range:NSMakeRange([highTemperatureText length] + 1, [lowTemperatureText length])];
    
    return [attributedString copy];
}



#pragma mark -
#pragma mark Extended popover methods

- (void)setUpGesturesForForecastDays {
    void (^addGestureToForecastDay)(UIView *, int) = ^(UIView *view, int tag) {
        UITapGestureRecognizer *tapGestureSequencing = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(forecastDayPressed:)];
        tapGestureSequencing.numberOfTapsRequired = 1;
        [tapGestureSequencing setDelegate:self];
        view.tag = tag;
        view.userInteractionEnabled = YES;
        [view addGestureRecognizer:tapGestureSequencing];
    };
    
    addGestureToForecastDay(self.forecast1DayBlock, 1);
    addGestureToForecastDay(self.forecast2DayBlock, 2);
    addGestureToForecastDay(self.forecast3DayBlock, 3);
    addGestureToForecastDay(self.forecast4DayBlock, 4);
    addGestureToForecastDay(self.forecast5DayBlock, 5);
    addGestureToForecastDay(self.forecast6DayBlock, 6);
    addGestureToForecastDay(self.forecast7DayBlock, 7);
    addGestureToForecastDay(self.forecast8DayBlock, 8);
    addGestureToForecastDay(self.forecast9DayBlock, 9);
    addGestureToForecastDay(self.forecast10DayBlock, 10);
}


- (void)forecastDayPressed:(id)sender {
    self.forecastDayNumber = (int)[(UIGestureRecognizer *)sender view].tag;
    [self displayExtendedForecastPopover:self.forecastDayNumber];
}


- (void)displayExtendedForecastPopover:(int)dayNumber {
    // prepare data to show
    UserHelper *userHelper = [[UserHelper alloc] init];
    int temperatureType = [[userHelper loadSettingTemperatureUnit] unsignedShortValue];
    NSDictionary *forecastSection = [_forecast objectForKey:@"forecast"];
    ForecastData *forecastContainer = [[ForecastData alloc] sharedInstance];
    
    int dayInForecastJSON;
    if (self.view.frame.size.height > self.view.frame.size.width) {
        // portrait mode
        dayInForecastJSON = dayNumber;
    } else {
        // landscape mode
        dayInForecastJSON = --dayNumber;
    }
    
    NSString *dayTitle = [self pullFullWeekdayFromForecastDay:dayInForecastJSON
                                       basedOnForecastSection:forecastSection];
    
    NSString *geneticallyTailoredForecast;
    if (dayInForecastJSON < [forecastContainer.forecastDayObjectsListFor10DaysArray count]) {
        ForecastDayObject *forecastDayObject = forecastContainer.forecastDayObjectsListFor10DaysArray[dayInForecastJSON];
        geneticallyTailoredForecast = forecastDayObject.geneticForecast;
    } else {
        geneticallyTailoredForecast = @"";
    }
    
    NSString *extendedWeatherForecast = [self pullExtendedForecastBasedOnForecastSection:forecastSection
                                                                         temperatureType:temperatureType
                                                                             forecastDay:(dayInForecastJSON + dayInForecastJSON)];
    
    // init popover to show
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ExtendedForecastPopover" bundle:nil];
    self.extendedPopoverNavigationVC = (UINavigationController *)[storyboard instantiateInitialViewController];
    
    ExtendedForecastPopoverViewController *extendedPopoverVC = [self.extendedPopoverNavigationVC viewControllers][0];
    extendedPopoverVC.day = dayTitle;
    if ([geneticallyTailoredForecast length] != 0) {
        extendedPopoverVC.geneticForecast = geneticallyTailoredForecast;
    }
    extendedPopoverVC.extendedForecast = extendedWeatherForecast;
    
    self.extendedPopoverNavigationVC.preferredContentSize = CGSizeMake(450, 240.f);
    self.extendedPopoverNavigationVC.modalPresentationStyle = UIModalPresentationPopover;
    self.extendedPopoverNavigationVC.popoverPresentationController.delegate = self;
    
    CGRect dayPoint = [self frameForForecastDay:self.forecastDayNumber];
    UIView *sourceView = [[UIView alloc] initWithFrame:dayPoint];
    [self.view addSubview:sourceView];
    self.extendedPopoverNavigationVC.popoverPresentationController.sourceView = sourceView;
    
    [self presentViewController:self.extendedPopoverNavigationVC animated:YES completion:^{
        [sourceView removeFromSuperview];
    }];
}


- (CGRect)frameForForecastDay:(int)forecastDay {
    UIView *view;
    switch (forecastDay) {
        case 1: view = self.forecast1DayBlock;
            break;
        case 2: view = self.forecast2DayBlock;
            break;
        case 3: view = self.forecast3DayBlock;
            break;
        case 4: view = self.forecast4DayBlock;
            break;
        case 5: view = self.forecast5DayBlock;
            break;
        case 6: view = self.forecast6DayBlock;
            break;
        case 7: view = self.forecast7DayBlock;
            break;
        case 8: view = self.forecast8DayBlock;
            break;
        case 9: view = self.forecast9DayBlock;
            break;
        case 10: view = self.forecast10DayBlock;
            break;
        default:
            break;
    }
    
    CGFloat x = view.frame.origin.x;
    CGFloat y = view.frame.origin.y;
    CGFloat width = view.frame.size.width;
    CGFloat height = view.frame.size.height;
    CGRect point = CGRectMake(x + (width / 2) - 1, y + (height / 2) - 20, 2.f, 1.f);
    return point;
}


// UIPopoverPresentationControllerDelegate
- (void)prepareForPopoverPresentation:(UIPopoverPresentationController *)popoverPresentationController {
    popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionDown;
}



#pragma mark -
#pragma mark Refresh Control methods

- (IBAction)refreshButtonPressed:(id)sender {
    dispatch_async(kMainQueue, ^{
        if ([InternetConnection internetConnectionIsAvailable]) {
            if (!_alreadyExecutingRefresh) {
                _alreadyExecutingRefresh = YES;
                [self addProgressView];
                LocationWeatherUpdater *locationWeatherUpdater = [LocationWeatherUpdater sharedInstance];
                [locationWeatherUpdater checkLocationAvailabilityAndStart];
                
            } else {
                NSLog(@"already executing refresh");
            }
        } else {
            AlertMessage *alert = [[AlertMessage alloc] init];
            [alert viewController:self
               showAlertWithTitle:@"Can't refresh forecast"
                      withMessage:NO_INTERNET_CONNECTION_TEXT];
        }
    });
}


- (void)analyseIfAnyRefreshIsNeeded {
    ForecastData *forecastData = [[ForecastData alloc] sharedInstance];
    if (!forecastData.forecast) {
        // let's execute full refresh
        [self refreshButtonPressed:nil];
        
    } else { // execute refresh according to what was changed
        
        // check if temperatureUnit changed
        if ([self didTemperatureUnitSettingChange] && ![self didLocationChange] && ![self didGeneticFileChange]) {
            // temperature unit changed only > let's populate forecaset in UI again
            dispatch_async(kMainQueue, ^{
                _nowUsedTemperatureUnit = _currentlySelectedTemperatureUnit;
                [self prepopulateConditionsAndForecast];
            });
            
        // check if location changed
        } else if ([self didLocationChange] && !_alreadyExecutingRefresh) {
            if ([InternetConnection internetConnectionIsAvailable]) {
                dispatch_async(kMainQueue, ^{
                    _alreadyExecutingRefresh = YES;
                    [self addProgressView];
                    
                    // location was changed > let's refresh weather forecast
                    _nowUsedLocation = _currentlySelectedLocation;
                    forecastData.locationForForecast = _nowUsedLocation;
                    
                    [self refreshWeatherForecastForLocation:_nowUsedLocation withCompletion:^{
                        dispatch_async(kMainQueue, ^{
                            if (![self didWeatherTypeChange] && ![self didGeneticFileChange]) {
                                
                                [self removeProgressView];
                                dispatch_async(kMainQueue, ^{
                                    // refresh UI, refresh weather forecast prepopulation, as weather type is not changed
                                    [self prepopulateConditionsAndForecast];
                                    
                                    // refresh video in background
                                    [self initializeAndAddVideoToView];
                                    [self addNotificationObserves];
                                    _alreadyExecutingRefresh = NO;
                                });
                                
                            } else {
                                if ([InternetConnection internetConnectionIsAvailable]) {
                                    if ([_currentlyNewWeatherType length] != 0) {
                                        _nowUsedWeatherType = _currentlyNewWeatherType;
                                    }
                                    if (_currentlySelectedFile) {
                                        _nowUsedFile = _currentlySelectedFile;
                                    }
                                    
                                    // run genetic forecast request
                                    [self requestForGeneticForecastWithGeneticFile:_nowUsedFile
                                                                    withCompletion:^(NSString *geneticForecast) {
                                                                        dispatch_async(kMainQueue, ^{
                                                                            if ([geneticForecast length] != 0) {
                                                                                _geneticForecastText.text = geneticForecast;
                                                                                forecastData.geneticForecast = geneticForecast;
                                                                                
                                                                            } else {
                                                                                forecastData.geneticForecast = kAbsentGeneticForecastMessage;
                                                                            }
                                                                            
                                                                            [self removeProgressView];
                                                                            
                                                                            dispatch_async(kMainQueue, ^{
                                                                                // refresh UI, refresh weather forecast prepopulation, as weather type is not changed
                                                                                [self prepopulateConditionsAndForecast];
                                                                                
                                                                                // refresh video in background
                                                                                [self initializeAndAddVideoToView];
                                                                                [self addNotificationObserves];
                                                                                _alreadyExecutingRefresh = NO;
                                                                            });
                                                                        });
                                                                    }]; // end requestGeneticForecast
                                } else {
                                    dispatch_async(kMainQueue, ^{
                                        [self removeProgressView];
                                        
                                        dispatch_async(kMainQueue, ^{
                                            // refresh UI, refresh weather forecast prepopulation, as weather type is not changed
                                            [self prepopulateConditionsAndForecast];
                                            
                                            // refresh video in background
                                            [self initializeAndAddVideoToView];
                                            [self addNotificationObserves];
                                            _alreadyExecutingRefresh = NO;
                                            
                                            AlertMessage *alert = [[AlertMessage alloc] init];
                                            [alert viewController:self
                                               showAlertWithTitle:@"Can't refresh genetically tailored forecast"
                                                      withMessage:NO_INTERNET_CONNECTION_TEXT];
                                        });
                                    });
                                } // end of internet check
                            }
                        }); // end of dispatch
                    }]; // end refreshWeatherForecast
                }); // end of dispatch
            } else {
                AlertMessage *alert = [[AlertMessage alloc] init];
                [alert viewController:self
                   showAlertWithTitle:@"Can't refresh forecast"
                          withMessage:NO_INTERNET_CONNECTION_TEXT];
            } // end of internet check
            
            
        // check if file changed
        } else if ([self didGeneticFileChange] && !_alreadyExecutingRefresh) {
            if ([InternetConnection internetConnectionIsAvailable]) {
                dispatch_async(kMainQueue, ^{
                    _alreadyExecutingRefresh = YES;
                    [self addProgressView];
                });
                
                if (_currentlySelectedFile) {
                    _nowUsedFile = _currentlySelectedFile;
                }
                
                // run genetic forecast request
                [self requestForGeneticForecastWithGeneticFile:_nowUsedFile
                                                withCompletion:^(NSString *geneticForecast) {
                                                    dispatch_async(kMainQueue, ^{
                                                        if ([geneticForecast length] != 0) {
                                                            _geneticForecastText.text = geneticForecast;
                                                            forecastData.geneticForecast = geneticForecast;
                                                            
                                                        } else {
                                                            forecastData.geneticForecast = kAbsentGeneticForecastMessage;
                                                        }
                                                        
                                                        [self removeProgressView];
                                                        
                                                        dispatch_async(kMainQueue, ^{
                                                            // refresh UI, refresh weather forecast prepopulation, as weather type is not changed
                                                            [self prepopulateConditionsAndForecast];
                                                            
                                                            // refresh video in background
                                                            [self initializeAndAddVideoToView];
                                                            [self addNotificationObserves];
                                                            _alreadyExecutingRefresh = NO;
                                                        });
                                                    });
                                                }];
            } else {
                AlertMessage *alert = [[AlertMessage alloc] init];
                [alert viewController:self
                   showAlertWithTitle:@"Can't refresh genetically tailored forecast"
                          withMessage:NO_INTERNET_CONNECTION_TEXT];
            }
        } // end of file changed
        
        [self adjustExtendedForecastLabel];
    }
}


- (BOOL)didTemperatureUnitSettingChange {
    BOOL isChanged = NO;
    
    if (![_nowUsedTemperatureUnit isEqual:_currentlySelectedTemperatureUnit]) {
        isChanged = YES;
    }
    return isChanged;
}


- (BOOL)didLocationChange {
    BOOL isChanged = NO;
    
    if (_currentlySelectedLocation && ![_nowUsedLocation isEqual:_currentlySelectedLocation]) {
        isChanged = YES;
    }
    return isChanged;
}


- (BOOL)didWeatherTypeChange {
    BOOL isChanged = YES;
    /*
     ForecastData *forecastContainer = [[ForecastData alloc] sharedInstance];
     
     if (([_currentlyNewWeatherType length] != 0 && ![[_nowUsedWeatherType lowercaseString] isEqualToString:[_currentlyNewWeatherType lowercaseString]])
     || [forecastContainer.alertType length] != 0) {
     
     isChanged = YES;
     }*/
    return isChanged;
}


- (BOOL)didGeneticFileChange {
    BOOL isChanged = NO;
    
    if (_currentlySelectedFile && ![_nowUsedFile isEqual:_currentlySelectedFile]) {
        isChanged = YES;
    }
    return isChanged;
}


- (void)saveCurrentParameters {
    UserHelper *userHelper = [[UserHelper alloc] init];
    ForecastData *forecastData = [[ForecastData alloc] sharedInstance];
    
    // save now used temperatureUnit setting
    _nowUsedTemperatureUnit = [userHelper loadSettingTemperatureUnit];
    
    // save now selected fileID
    _nowUsedFile = [userHelper loadUserGeneticFile];
    
    // save now used weather type
    if ([_currentWeatherType.text length] != 0) {
        _nowUsedWeatherType = _currentWeatherType.text;
    } else {
        _nowUsedWeatherType = [forecastData.weatherType capitalizedString];
    }
    
    // save now used location
    if (forecastData.locationForForecast != nil) {
        _nowUsedLocation = forecastData.locationForForecast;
        
    } else {
        NSDictionary *currentLocation   = [userHelper loadUserCurrentLocation];
        NSDictionary *selectedLocation  = [userHelper loadUserSelectedLocation];
        NSDictionary *defaultLocation   = [userHelper loadUserDefaultLocation];
        
        if (![userHelper locationIsEmpty:currentLocation]) {
            [userHelper saveUserSelectedLocation:currentLocation];
            _nowUsedLocation = currentLocation;
            forecastData.locationForForecast = currentLocation;
            
        } else if (![userHelper locationIsEmpty:selectedLocation]) {
            _nowUsedLocation = selectedLocation;
            forecastData.locationForForecast = selectedLocation;
            
        } else {
            [userHelper saveUserSelectedLocation:defaultLocation];
            _nowUsedLocation = defaultLocation;
            forecastData.locationForForecast = defaultLocation;
        }
    }
}


- (NSString *)pullWeatherTypeFromForecastContainer {
    ForecastData *forecastData = [[ForecastData alloc] sharedInstance];
    NSString *weatherType;
    if (!_forecast && forecastData.forecast) {
        _forecast = forecastData.forecast;
    }
    
    if ([forecastData.weatherType length] != 0) {
        // we have weather type stored in forecastdata container
        weatherType = [forecastData.weatherType capitalizedString];
        
    } else if (_forecast) {
        if ([[[_forecast objectForKey:@"current_observation"] allKeys] containsObject:@"weather"]) {
            // get forecast from current observation section
            weatherType = [[_forecast objectForKey:@"current_observation"] objectForKey:@"weather"];
        }
        
        if ([weatherType length] == 0) {
            // get weather from forecastday[0]
            if ([[_forecast allKeys] containsObject:@"forecast"]) {
                
                NSDictionary *forecastDay0 = [[[[_forecast objectForKey:@"forecast"] objectForKey:@"simpleforecast"] objectForKey:@"forecastday"] objectAtIndex:0];
                if (forecastDay0 && [[forecastDay0 allKeys] containsObject:@"conditions"]) {
                    weatherType = [forecastDay0 objectForKey:@"conditions"];
                }
            }
        }
        
    }
    return weatherType;
}



#pragma mark -
#pragma mark Weather Forecast methods

- (void)refreshWeatherForecastForLocation:(NSDictionary *)location withCompletion:(void (^)(void))completion {
    UserHelper *userHelper = [[UserHelper alloc] init];
    NSString *locationID;
    if (![userHelper locationIsEmpty:location]) {
        locationID = [location objectForKey:LOCATION_ID_DICT_KEY];
    }
    
    if ([locationID length] != 0) {
        // get forecast with Wunderground service
        WundergroundHelper *wundergroundHelper = [[WundergroundHelper alloc] init];
        [wundergroundHelper wundergroundForecast10dayConditionsDefineByLocationID:locationID withResult:^(NSDictionary *forecast) {
            
            if (forecast) {
                dispatch_async(kMainQueue, ^{
                    // save forecast info into local property and into container property
                    ForecastData *forecastContainer = [[ForecastData alloc] sharedInstance];
                    [forecastContainer setForecast:forecast];
                    [self setForecast:forecast];
                    
                    // save new weather type
                    NSString *weatherType = forecastContainer.weatherType;
                    if ([weatherType length] != 0) {
                        _currentlyNewWeatherType = weatherType;
                    }
                    completion();
                });
            } else {
                NSLog(@"error: forecast from weather server is empty");
                completion();
            }
        }];
    } else {
        NSLog(@"error: locationID from userDefaults is empty");
        completion();
    }
}



#pragma mark -
#pragma mark Genetic Forecast methods

- (void)requestForGeneticForecastWithGeneticFile:(NSDictionary *)file withCompletion:(void (^)(NSString *geneticForecast))completion {
    ForecastData *forecastContainer = [[ForecastData alloc] sharedInstance];
    GeneticForecastHelper *gfHelper = [[GeneticForecastHelper alloc] sharedInstance];
    UserHelper *userHelper = [[UserHelper alloc] init];
    
    if (!file) {
        UserHelper *userHelper = [[UserHelper alloc] init];
        file = [userHelper loadUserGeneticFile];
    }
    NSString *fileID;
    NSString *fileIDRawValue = [file objectForKey:GENETIC_FILE_ID_DICT_KEY];
    if ([fileIDRawValue containsString:@":"]) {
        NSArray *arrayFileID = [fileIDRawValue componentsSeparatedByString:@":"];
        if ([arrayFileID count] > 1) {
            fileID = [arrayFileID lastObject];
        }
    } else {
        fileID = fileIDRawValue;
    }
    SQToken *token = [userHelper loadUserToken];
    
    if (forecastContainer.forecastDayObjectsListFor10DaysArray && [forecastContainer.forecastDayObjectsListFor10DaysArray count] > 0) {
        if ([fileID length] != 0) {
            if ([token.accessToken length] != 0) {
                
                [gfHelper requestForGeneticDataForFileID:fileID
                                             accessToken:token.accessToken
                                          withCompletion:^(BOOL success) {
                                              if (success) {
                                                  forecastContainer.vitaminDValue     = [gfHelper.vitaminDValue copy];
                                                  forecastContainer.melanomaRiskValue = [gfHelper.melanomaRiskValue copy];
                                                  
                                                  [gfHelper requestForGeneticForecastsWithToken:token.accessToken
                                                                                 withCompletion:^(NSArray *geneticForecastsArray) {
                                                                                     if (geneticForecastsArray != nil) {
                                                                                         [forecastContainer populateDayObjectsWithGeneticForecasts:geneticForecastsArray];
                                                                                         completion([geneticForecastsArray[0] objectForKey:@"gtForecast"]);
                                                                                         
                                                                                     } else {
                                                                                         completion(kAbsentGeneticForecastMessage);
                                                                                     }
                                                                                 }];
                                              } else {
                                                  completion(kAbsentGeneticForecastMessage);
                                              }
                                          }];
            } else {
                completion(kAbsentGeneticForecastMessage);
            }
        } else {
            completion(kAbsentGeneticForecastMessage);
        }
    } else {
        completion(kAbsentGeneticForecastMessage);
    }
}



#pragma mark -
#pragma mark Alert popup

- (void)analyseIfAlertIsPresent {
    NSArray *alertsArray;
    NSString *alertsText;
    
    if ([[_forecast allKeys] containsObject:@"alerts"]) {
        alertsArray = [_forecast objectForKey:@"alerts"];
    }
    if (alertsArray && [alertsArray count] > 0) {
        alertsText = [self prepareAlertsTextBasedOnAlertsArray:alertsArray];
    }
    
    if ([alertsText length] != 0) {
        // alert is present
        [self.alertButtonView setHidden:NO];
        [self.alertButton setHidden:NO];
        _alertsTextForPopup = alertsText;
        
        // update layout
        if (![self isIpadPro13inches]) { // in landscape mode
            _grayView2BottomToExtendedTextBottom.constant = kGrayView2BottomToExtendedTextBottomWithAlert_IPadPortrait;
            _extendedTextBottomToGrayView2Bottom.constant = kExtendedTextBottomToGrayView2BottomWithAlert_IPadLandscape;
        } else {
            _grayView2BottomToExtendedTextBottom.constant = kGrayView2BottomToExtendedTextBottomWithAlert_IPadProPortrait;
            _extendedTextBottomToGrayView2Bottom.constant = kExtendedTextBottomToGrayView2BottomWithAlert_IPadProLandscape;
        }
        [self.view setNeedsUpdateConstraints];
        
    } else {
        // alert is absent
        [self.alertButtonView setHidden:YES];
        [self.alertButton setHidden:YES];
        _alertsTextForPopup = nil;
        
        // update layout
        if (![self isIpadPro13inches]) {
            _grayView2BottomToExtendedTextBottom.constant = kGrayView2BottomToExtendedTextBottomWithNoAlert_IPadPortrait;
            _extendedTextBottomToGrayView2Bottom.constant = kExtendedTextBottomToGrayView2BottomWithNoAlert_IPadLandscape;
        } else {
            _grayView2BottomToExtendedTextBottom.constant = kGrayView2BottomToExtendedTextBottomWithNoAlert_IPadProPortrait;
            _extendedTextBottomToGrayView2Bottom.constant = kExtendedTextBottomToGrayView2BottomWithNoAlert_IPadProLandscape;
        }
        [self.view setNeedsUpdateConstraints];
    }
}


- (NSString *)prepareAlertsTextBasedOnAlertsArray:(NSArray *)alertsArray {
    NSMutableString *alertsPreparedText = [[NSMutableString alloc] init];
    for (NSDictionary *alert in alertsArray) {
        
        // for meteo alarm type and level
        if ([[alert allKeys] containsObject:@"wtype_meteoalarm_name"]) {
            [alertsPreparedText appendString:[NSString stringWithFormat:@"Meteo alarm type: %@\n", [alert objectForKey:@"wtype_meteoalarm_name"]]];
            
            if ([[alert allKeys] containsObject:@"level_meteoalarm_name"]) {
                [alertsPreparedText appendString:[NSString stringWithFormat:@"Meteo alarm level: %@\n\n", [alert objectForKey:@"level_meteoalarm_name"]]];
            }
            if ([[alert allKeys] containsObject:@"level_meteoalarm_description"]) {
                [alertsPreparedText appendString:[NSString stringWithFormat:@"Short description:\n%@\n\n", [alert objectForKey:@"level_meteoalarm_description"]]];
            }
            if ([[alert allKeys] containsObject:@"description"]) {
                NSString *descriptionText = [[alert objectForKey:@"description"] stringByReplacingOccurrencesOfString:@"\t" withString:@""];
                [descriptionText stringByReplacingOccurrencesOfString:@"\n \n" withString:@"\n"];
                [descriptionText stringByReplacingOccurrencesOfString:@"\n\n" withString:@"\n"];
                [alertsPreparedText appendString:[NSString stringWithFormat:@"Extended description:\n%@\n", descriptionText]];
            }
            
        // for description and message
        } else if ([[alert allKeys] containsObject:@"description"] && [[alert allKeys] containsObject:@"message"]) {
            [alertsPreparedText appendString:[NSString stringWithFormat:@"Description: %@\n\n", [alert objectForKey:@"description"]]];
            
            if ([[alert allKeys] containsObject:@"date"]) {
                [alertsPreparedText appendString:[NSString stringWithFormat:@"Date: %@\n\n", [alert objectForKey:@"date"]]];
            }
            if ([[alert allKeys] containsObject:@"expires"]) {
                [alertsPreparedText appendString:[NSString stringWithFormat:@"Expires: %@\n\n", [alert objectForKey:@"expires"]]];
            }
            if ([[alert allKeys] containsObject:@"message"]) {
                [alertsPreparedText appendString:[NSString stringWithFormat:@"Message: %@\n", [alert objectForKey:@"message"]]];
            }
            
            // for simple message (if we don't know type of alarm)
        } else if ([[alert allKeys] containsObject:@"message"]) {
            [alertsPreparedText appendString:[NSString stringWithFormat:@"%@\n", [alert objectForKey:@"message"]]];
        }
        
        [alertsPreparedText appendString:@"------------------------------\n\n\n"];
    }
    return [NSString stringWithString:[alertsPreparedText copy]];
}


- (void)alertButtonViewPressed {
    [self alertButtonPressed:nil];
}

- (IBAction)alertButtonPressed:(id)sender {
    dispatch_async(kMainQueue, ^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Alert" bundle:nil];
        UINavigationController *alertNavigationVC = (UINavigationController *)[storyboard instantiateInitialViewController];
        alertNavigationVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        PopupAlertViewController *alertVC = [alertNavigationVC viewControllers][0];
        alertVC.alertsMessageText = _alertsTextForPopup;
        alertVC.delegate = self;
        [self presentViewController:alertNavigationVC animated:YES completion:nil];
    });
}

// PopupAlertViewControllerDelegate
- (void)popupAlertViewController:(PopupAlertViewController *)controller closeButtonPressed:(id)sender {
    dispatch_async(kMainQueue, ^{
        controller.delegate = nil;
        [controller dismissViewControllerAnimated:YES completion:nil];
    });
}



#pragma mark -
#pragma mark UIApplication states

- (void)applicationDidBecomeActiveNotification {
    dispatch_async(kMainQueue, ^{
        NSLog(@"applicationDidBecomeActiveNotification");
        [self playVideo];
        
        // start animation
        [self animation];
        [self startAnimationTimer];
        
        LocationWeatherUpdater *locationWeatherUpdater = [LocationWeatherUpdater sharedInstance];
        SettingsUpdater *settingsUpdater = [SettingsUpdater sharedInstance];
        
        if ([InternetConnection internetConnectionIsAvailable]) {
            if (!_alreadyExecutingRefresh) {
                _alreadyExecutingRefresh = YES;
                [locationWeatherUpdater checkLocationAvailabilityAndStart];
            } else {
                NSLog(@"already executing forecast refresh");
            }
            
            if (!_alreadyExecutingSettingsSyncRequest) {
                _alreadyExecutingSettingsSyncRequest = YES;
                [settingsUpdater retrieveUserSettings];
            } else {
                NSLog(@"already executing settings sync");
            }
            
        } else {
            NSLog(@"no internet connection");
        }
        
        // start timer as we are in foreground
        [locationWeatherUpdater startTimer];
        [settingsUpdater startTimer];
        
        // reset applicationIconBadgeNumber
        if ([UIApplication sharedApplication].applicationIconBadgeNumber > 0) {
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
        }
    });
}


- (void)applicationWillResignActiveNotification {
    [self pauseVideo];
    
    // stop timers as we are now in background (app is no active)
    LocationWeatherUpdater *locationWeatherUpdater = [LocationWeatherUpdater sharedInstance];
    [locationWeatherUpdater cancelTimer];
    
    SettingsUpdater *settingsUpdater = [SettingsUpdater sharedInstance];
    [settingsUpdater cancelTimer];
    
    // stop animation
    [self cancelAnimationTimer];
    [self.sequencingLogo.layer removeAllAnimations];
}




#pragma mark -
#pragma mark LocationWeatherUpdaterDelegate

- (void)locationAndWeatherWereUpdated {
    NSLog(@"ForecastVC: locationAndWeatherWereUpdated");
    dispatch_async(kMainQueue, ^{
        // get forecast data from container
        ForecastData *forecastContainer = [[ForecastData alloc] sharedInstance];
        if (forecastContainer.forecast != nil) {
            self.forecast = forecastContainer.forecast;
            [self showAllElements];
            
            // prepopulate forecast
            [self prepopulateConditionsAndForecast];
        }
        
        [self removeProgressView];
        
        dispatch_async(kMainQueue, ^{
            [self initializeAndAddVideoToView];
            [self addNotificationObserves];
            [self adjustNavigationBarIfVideoIsWhite];
            _alreadyExecutingRefresh = NO;
        });
    });
}


- (void)startedRefreshing {
    dispatch_async(kMainQueue, ^{
        _alreadyExecutingRefresh = YES;
    });
}


- (void)finishedRefreshWithError {
    NSLog(@"ForecastVC: finishedRefreshWithError");
    dispatch_async(kMainQueue, ^{
        [self removeProgressView];
        
        dispatch_async(kMainQueue, ^{
            [self playVideo];
            [self addNotificationObserves];
            [self adjustNavigationBarIfVideoIsWhite];
            _alreadyExecutingRefresh = NO;
            
            AlertMessage *alert = [[AlertMessage alloc] init];
            [alert viewController:self
               showAlertWithTitle:@"There was an error while refreshing forecast, can't refresh forecast"
                      withMessage:nil];
        });
    });
}



#pragma mark -
#pragma mark SettingsUpdaterDelegate

- (void)settingsSyncRequestStarted {
    dispatch_async(kMainQueue, ^{
        _alreadyExecutingSettingsSyncRequest = YES;
    });
}

- (void)settingsSyncRequestFinished {
    dispatch_async(kMainQueue, ^{
        _alreadyExecutingSettingsSyncRequest = NO;
    });
}




#pragma mark -
#pragma mark Show / Hide elements

- (void)hideAllElements {
    dispatch_async(kMainQueue, ^{
        [_grayView1 setHidden:YES];
        [_currentWeatherTitle setHidden:YES];
        [_currentTemperature setHidden:YES];
        [_currentWeatherIcon setHidden:YES];
        [_currentWeatherType setHidden:YES];
        [_todaysTemperature setHidden:YES];
        [_currentWind setHidden:YES];
        [_currentHumidity setHidden:YES];
        [_currentPrecipitation setHidden:YES];
        
        [_grayView2 setHidden:YES];
        [_extendedForecastTitle setHidden:YES];
        [_extendedForecastText setHidden:YES];
        [_alertButton setHidden:YES];
        [_alertButtonView setHidden:YES];
        
        [_grayView3 setHidden:YES];
        [_geneticForecastTitle setHidden:YES];
        [_sequencingLogo setHidden:YES];
        [_geneticForecastText setHidden:YES];
        [_poweredBy setHidden:YES];
        
        [_grayView4 setHidden:YES];
        [_forecast1DayBlock setHidden:YES];
        [_day1NameLabel setHidden:YES];
        [_day1Icon setHidden:YES];
        [_day1Temperature setHidden:YES];
        
        [_forecast2DayBlock setHidden:YES];
        [_day2NameLabel setHidden:YES];
        [_day2Icon setHidden:YES];
        [_day2Temperature setHidden:YES];
        
        [_forecast3DayBlock setHidden:YES];
        [_day3NameLabel setHidden:YES];
        [_day3Icon setHidden:YES];
        [_day3Temperature setHidden:YES];
        
        [_forecast4DayBlock setHidden:YES];
        [_day4NameLabel setHidden:YES];
        [_day4Icon setHidden:YES];
        [_day4Temperature setHidden:YES];
        
        [_forecast5DayBlock setHidden:YES];
        [_day5NameLabel setHidden:YES];
        [_day5Icon setHidden:YES];
        [_day5Temperature setHidden:YES];
        
        [_forecast6DayBlock setHidden:YES];
        [_day6NameLabel setHidden:YES];
        [_day6Icon setHidden:YES];
        [_day6Temperature setHidden:YES];
        
        [_forecast7DayBlock setHidden:YES];
        [_day7NameLabel setHidden:YES];
        [_day7Icon setHidden:YES];
        [_day7Temperature setHidden:YES];
        
        [_forecast8DayBlock setHidden:YES];
        [_day8NameLabel setHidden:YES];
        [_day8Icon setHidden:YES];
        [_day8Temperature setHidden:YES];
        
        [_forecast9DayBlock setHidden:YES];
        [_day9NameLabel setHidden:YES];
        [_day9Icon setHidden:YES];
        [_day9Temperature setHidden:YES];
        
        [_forecast10DayBlock setHidden:YES];
        [_day10NameLabel setHidden:YES];
        [_day10Icon setHidden:YES];
        [_day10Temperature setHidden:YES];
    });
}


- (void)showAllElements {
    dispatch_async(kMainQueue, ^{
        [_grayView1 setHidden:NO];
        [_currentWeatherTitle setHidden:NO];
        [_currentTemperature setHidden:NO];
        [_currentWeatherIcon setHidden:NO];
        [_currentWeatherType setHidden:NO];
        [_todaysTemperature setHidden:NO];
        [_currentWind setHidden:NO];
        [_currentHumidity setHidden:NO];
        [_currentPrecipitation setHidden:NO];
        
        [_grayView2 setHidden:NO];
        [_extendedForecastTitle setHidden:NO];
        [_extendedForecastText setHidden:NO];
        
        [_grayView3 setHidden:NO];
        [_geneticForecastTitle setHidden:NO];
        [_sequencingLogo setHidden:NO];
        [_geneticForecastText setHidden:NO];
        [_poweredBy setHidden:NO];
        
        [_grayView4 setHidden:NO];
        [_forecast1DayBlock setHidden:NO];
        [_day1NameLabel setHidden:NO];
        [_day1Icon setHidden:NO];
        [_day1Temperature setHidden:NO];
        
        [_forecast2DayBlock setHidden:NO];
        [_day2NameLabel setHidden:NO];
        [_day2Icon setHidden:NO];
        [_day2Temperature setHidden:NO];
        
        [_forecast3DayBlock setHidden:NO];
        [_day3NameLabel setHidden:NO];
        [_day3Icon setHidden:NO];
        [_day3Temperature setHidden:NO];
        
        [_forecast4DayBlock setHidden:NO];
        [_day4NameLabel setHidden:NO];
        [_day4Icon setHidden:NO];
        [_day4Temperature setHidden:NO];
        
        [_forecast5DayBlock setHidden:NO];
        [_day5NameLabel setHidden:NO];
        [_day5Icon setHidden:NO];
        [_day5Temperature setHidden:NO];
        
        [_forecast6DayBlock setHidden:NO];
        [_day6NameLabel setHidden:NO];
        [_day6Icon setHidden:NO];
        [_day6Temperature setHidden:NO];
        
        [_forecast7DayBlock setHidden:NO];
        [_day7NameLabel setHidden:NO];
        [_day7Icon setHidden:NO];
        [_day7Temperature setHidden:NO];
        
        [_forecast8DayBlock setHidden:NO];
        [_day8NameLabel setHidden:NO];
        [_day8Icon setHidden:NO];
        [_day8Temperature setHidden:NO];
        
        [_forecast9DayBlock setHidden:NO];
        [_day9NameLabel setHidden:NO];
        [_day9Icon setHidden:NO];
        [_day9Temperature setHidden:NO];
        
        [_forecast10DayBlock setHidden:NO];
        [_day10NameLabel setHidden:NO];
        [_day10Icon setHidden:NO];
        [_day10Temperature setHidden:NO];
    });
}



#pragma mark -
#pragma mark AlertMessageDialogDelegate

- (void)refreshButtonPressed {
    [self refreshButtonPressed:nil];
}



#pragma mark -
#pragma mark Location name adjustment helper methods

- (NSString *)adjustLocationNameLenghIfNeeded:(NSString *)location {
    CGFloat titleAllowedWidth = [self defineTitleAllowedWidthByDeviceScreenWidth];
    NSString *adjustedLocationTitle = [location copy];
    CGFloat locationWidth = [self defineLocationLabelWidthByLocationTitle:adjustedLocationTitle];
    
    while (locationWidth > titleAllowedWidth) {
        NSMutableString *locationAdjusted = [[NSMutableString alloc] init];
        if ([adjustedLocationTitle containsString:@","]) {
            NSArray *parts = [adjustedLocationTitle componentsSeparatedByString:@","];
            [locationAdjusted appendString:[self substitudeLast3CharactersWithDots:[parts firstObject]]];
            [locationAdjusted appendString:@","];
            [locationAdjusted appendString:[parts lastObject]];
        } else {
            [locationAdjusted appendString:[self substitudeLast3CharactersWithDots:location]];
        }
        
        adjustedLocationTitle = [NSString stringWithString:locationAdjusted];
        locationWidth = [self defineLocationLabelWidthByLocationTitle:adjustedLocationTitle];
    }
    return adjustedLocationTitle;
}

- (CGFloat)defineTitleAllowedWidthByDeviceScreenWidth {
    CGFloat titleAllowedWidth = self.view.frame.size.width - (kIPad_leftBarButton_width + kIPad_rightBarButton_width);
    return titleAllowedWidth;
}

- (CGFloat)defineLocationLabelWidthByLocationTitle:(NSString *)locationTitle {
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    [titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:kLocationNameFontSize]];
    titleLabel.text = locationTitle;
    [titleLabel sizeToFit];
    CGFloat locationWidth = titleLabel.frame.size.width;
    return locationWidth;
}

- (NSString *)substitudeLast3CharactersWithDots:(NSString *)location {
    NSRange locationAdjustedLength = NSMakeRange(0, [location length] - 4);
    NSMutableString *locationAdjusted = [[NSMutableString alloc] init];
    [locationAdjusted appendString:[location substringWithRange:locationAdjustedLength]];
    [locationAdjusted appendString:@"..."];
    return [NSString stringWithString:locationAdjusted];
}



#pragma mark -
#pragma mark NavigationBar helper methods

- (void)adjustNavigationBarIfVideoIsWhite {
    // set transpanent grey background for navigation bar in case when video with white part is used now
    if ([VideoHelper isVideoWhite]) {
        [self.navigationController.navigationBar setBackgroundImage:[VideoHelper greyTranspanentImage] forBarMetrics:UIBarMetricsDefault];
    } else {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    }
}



#pragma mark -
#pragma mark Extended Forecast helper methods

- (void)adjustExtendedForecastLabel {
    dispatch_async(kMainQueue, ^{
        NSInteger numberOfLines = floor(ceilf(CGRectGetHeight(self.extendedForecastText.frame)) / self.extendedForecastText.font.lineHeight);
        if (numberOfLines > 1) {
            self.extendedForecastText.textAlignment = NSTextAlignmentLeft;
        } else {
            self.extendedForecastText.textAlignment = NSTextAlignmentCenter;
        }
    });
}



#pragma mark -
#pragma mark Other helper methods

- (void)addProgressView {
    dispatch_async(kMainQueue, ^{
        self.progressView = [[ProgressEmptyViewController alloc] initWithNibName:@"ProgressEmptyViewController" bundle:nil];
        self.progressView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:self.progressView animated:NO completion:nil];
    });
}

- (void)removeProgressView {
    dispatch_async(kMainQueue, ^{
        [self.progressView dismissViewControllerAnimated:NO completion:nil];
        _progressView.view = nil;
    });
}


- (BOOL)isIpadPro13inches {
    CGFloat screenWidth = self.view.frame.size.width;
    CGFloat screenHeight = self.view.frame.size.height;
    
    if (([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) &&
        ((screenWidth == 1024 && screenHeight == 1366) ||
         (screenWidth == 1366 && screenHeight == 1024))) {
            return YES;
    } else {
        return NO;
    }
}




#pragma mark -
#pragma mark Memory handler

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
