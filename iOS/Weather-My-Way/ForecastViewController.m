//
//  ForecastViewController.m
//  Copyright © 2016 Sequencing. All rights reserved.
//


#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import "ForecastViewController.h"
#import "UserHelper.h"
#import "SQOAuth.h"
#import "SQToken.h"
#import "WundergroundHelper.h"
#import "MBProgressHUD.h"
#import "SWRevealViewController.h"
#import "SidebarMenuViewController.h"
#import "ForecastData.h"
#import "LoginViewController.h"
#import "AppDelegate.h"
#import "GeneticForecastHelper.h"
#import "RedditActivity.h"
#import "SQFilesAPI.h"
#import "UserAccountHelper.h"
#import "LocationWeatherUpdater.h"
#import "AlertMessage.h"
#import "InternetConnection.h"
#import "ExtendedForecastPopoverViewController.h"
#import "ForecastLayout.h"
#import "ForecastDayObject.h"
#import "NSLayoutConstraint+Multiplier.h"
#import "SQToken.h"
#import "CubePreloader.h"
#import "BadgeController.h"


#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

#define IS_IPHONE_4 (IS_IPHONE && (MAX([[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width) == 480.0) && ((IS_OS_8_OR_LATER && [UIScreen mainScreen].nativeScale == [UIScreen mainScreen].scale) || !IS_OS_8_OR_LATER))

#define IS_IPHONE_5 (IS_IPHONE && (MAX([[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width) == 568.0) && ((IS_OS_8_OR_LATER && [UIScreen mainScreen].nativeScale == [UIScreen mainScreen].scale) || !IS_OS_8_OR_LATER))

#define IS_STANDARD_IPHONE_6 (IS_IPHONE && MAX([[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width) == 667.0  && IS_OS_8_OR_LATER && [UIScreen mainScreen].nativeScale == [UIScreen mainScreen].scale)

#define IS_ZOOMED_IPHONE_6 (IS_IPHONE && MAX([[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width) == 568.0 && IS_OS_8_OR_LATER && [UIScreen mainScreen].nativeScale > [UIScreen mainScreen].scale)

#define IS_STANDARD_IPHONE_6_PLUS (IS_IPHONE && MAX([[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width) == 736.0)

#define IS_ZOOMED_IPHONE_6_PLUS (IS_IPHONE && MAX([[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width) == 667.0 && IS_OS_8_OR_LATER && [UIScreen mainScreen].nativeScale < [UIScreen mainScreen].scale)

#define IS_IPHONE_6 (IS_STANDARD_IPHONE_6 || IS_ZOOMED_IPHONE_6)

#define IS_IPHONE_6_PLUS (IS_STANDARD_IPHONE_6_PLUS || IS_ZOOMED_IPHONE_6_PLUS)


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



@interface ForecastViewController () <LocationWeatherUpdaterDelegate, UIGestureRecognizerDelegate, UITraitEnvironment, UIPopoverPresentationControllerDelegate, ExtendedForecastPopoverViewControllerDelegate>

// property for ProgressView
@property (weak, nonatomic) IBOutlet UIScrollView     *scrollView;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIImageView      *cubePreloader;

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

@property (weak, nonatomic) IBOutlet UIView      *grayView4;
@property (weak, nonatomic) IBOutlet UIView      *forecast1DayBlock;
@property (weak, nonatomic) IBOutlet UILabel     *day1NameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *day1Icon;
@property (weak, nonatomic) IBOutlet UILabel     *day1Temperature;

@property (weak, nonatomic) IBOutlet UIView      *forecast2DayBlock;
@property (weak, nonatomic) IBOutlet UILabel     *day2NameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *day2Icon;
@property (weak, nonatomic) IBOutlet UILabel     *day2Temperature;

@property (weak, nonatomic) IBOutlet UIView      *forecast3DayBlock;
@property (weak, nonatomic) IBOutlet UILabel     *day3NameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *day3Icon;
@property (weak, nonatomic) IBOutlet UILabel     *day3Temperature;

@property (weak, nonatomic) IBOutlet UIView      *forecast4DayBlock;
@property (weak, nonatomic) IBOutlet UILabel     *day4NameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *day4Icon;
@property (weak, nonatomic) IBOutlet UILabel     *day4Temperature;

@property (weak, nonatomic) IBOutlet UIView      *forecast5DayBlock;
@property (weak, nonatomic) IBOutlet UILabel     *day5NameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *day5Icon;
@property (weak, nonatomic) IBOutlet UILabel     *day5Temperature;

@property (weak, nonatomic) IBOutlet UIView      *forecast6DayBlock;
@property (weak, nonatomic) IBOutlet UILabel     *day6NameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *day6Icon;
@property (weak, nonatomic) IBOutlet UILabel     *day6Temperature;

@property (weak, nonatomic) IBOutlet UIView      *forecast7DayBlock;
@property (weak, nonatomic) IBOutlet UILabel     *day7NameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *day7Icon;
@property (weak, nonatomic) IBOutlet UILabel     *day7Temperature;

@property (weak, nonatomic) IBOutlet UIView      *forecast8DayBlock;
@property (weak, nonatomic) IBOutlet UILabel     *day8NameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *day8Icon;
@property (weak, nonatomic) IBOutlet UILabel     *day8Temperature;

@property (weak, nonatomic) IBOutlet UIView      *forecast9DayBlock;
@property (weak, nonatomic) IBOutlet UILabel     *day9NameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *day9Icon;
@property (weak, nonatomic) IBOutlet UILabel     *day9Temperature;

@property (weak, nonatomic) IBOutlet UIView      *forecast10DayBlock;
@property (weak, nonatomic) IBOutlet UILabel     *day10NameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *day10Icon;
@property (weak, nonatomic) IBOutlet UILabel     *day10Temperature;

@property (nonatomic) MBProgressHUD         *activityProgress;
@property (assign, nonatomic) BOOL          alreadyExecutingRefresh;
@property (assign, nonatomic) BOOL          alreadyShownMainMessageAboutForecastAbsence;
@property (assign, nonatomic) BOOL          alreadySelectedMenuItem;
@property (assign, nonatomic) BOOL          animatingRefreshButton;

// properties to handle changes in app parameters and settings
@property (strong, nonatomic) NSNumber      *currentTemperatureValue;
@property (strong, nonatomic) NSNumber      *nowUsedTemperatureUnit;
@property (strong, nonatomic) NSNumber      *currentlySelectedTemperatureUnit;
@property (strong, nonatomic) NSDictionary  *nowUsedFile;
@property (strong, nonatomic) NSDictionary  *currentlySelectedFile;
@property (strong, nonatomic) NSDictionary  *nowUsedLocation;
@property (strong, nonatomic) NSDictionary  *currentlySelectedLocation;
@property (strong, nonatomic) NSString      *nowUsedWeatherType;
@property (strong, nonatomic) NSString      *currentlyNewWeatherType;
@property (strong, nonatomic) NSString      *nowUsedVideoFileName;
@property (strong, nonatomic) NSDate        *dateOfLastRefresh;

// properties for extended forecast popover
@property (assign, nonatomic) int           forecastDayNumber;
@property (strong, nonatomic) UINavigationController    *extendedPopoverNavigationVC;


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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *weatherIconWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *weatherTypeTopToWeatherIconBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *weatherTypeTrailingToGrayView1Trailing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *temperatureTodayTopToWeatherTypeBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *humidityBottomToPrecipitationTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *windBottomToHumidityTop;
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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoIconHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *geneticTextTopToGeneticTitleBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *geneticTextLeadingToLogoTrailing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *geneticTextBottomToPoweredTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *poweredTopToGeneticTextBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *poweredTrailingToGrayView3Trailing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *poweredBottomToGrayView3Bottom;

// gray view 4
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *forecast1BlockWidth;
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
    self.alreadySelectedMenuItem = NO;
    
    // set up alert button
    self.alertButtonView.layer.cornerRadius = 5;
    self.alertButtonView.layer.masksToBounds = YES;
    [self.alertButtonView setHidden:YES];
    [self.alertButton setHidden:YES];
    
    // get forecast data from container
    ForecastData *forecastContainer = [ForecastData sharedInstance];
    if (forecastContainer.forecast != nil) {
        // use forecast already received in previos step
        self.forecast = forecastContainer.forecast;
        
        // prepopulate forecast
        [self prepopulateConditionsAndForecastFromBackground:NO];
        
    } else // we have an error - weather forecast is absent for some reason (server error, internet absence)
        [self hideAllElements];
    
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
    [self udjustAllTextFontSizeForIPhoneAndIPad];
    
    [self checkWhetherLeaveOnlyFourDaysForIPhone];
    
    [self initCubePreloader];
    
    self.dateOfLastRefresh = [NSDate date];
    /*
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(locationAndWeatherWereUpdatedInBackground)
                                                 name:@"LOCATION_AND_WEATHER_WERE_UPDATED_IN_BACKGROUND_NOTIFICATION_KEY"
                                               object:nil];*/
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self adjustExtendedForecastLabel];
    
    // start animation
    [self animation];
    [self startAnimationTimer];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    ForecastData *forecastContainer = [ForecastData sharedInstance];
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
    
    if (IS_IPHONE_6_PLUS)
        [self.scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    
    [self adjustExtendedForecastLabel];
    [self checkWhetherLeaveOnlyFourDaysForIPhone];
    [self updateLayoutsForIPhoneAndIPad];
    [self analyseIfAlertIsPresent];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    // stop animation
    [self cancelAnimationTimer];
    [self.sequencingLogo.layer removeAllAnimations];
}


- (void)dealloc {
    [super cleanup];
    NSLog(@"ForecastVC: dealloc");
    LocationWeatherUpdater *locationWeatherUpdater = [LocationWeatherUpdater sharedInstance];
    locationWeatherUpdater.delegate = nil;
    // [[NSNotificationCenter defaultCenter] removeObserver:self];
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
                
                if (IS_IPHONE) {
                    
                    if (IS_IPHONE_6_PLUS) { // for iPhone Plus
                        switch (previousTraitCollection.horizontalSizeClass) {
                                
                            case UIUserInterfaceSizeClassCompact: { // portrait > landscape
                                self.forecastDayNumber++;
                                [self.extendedPopoverNavigationVC dismissViewControllerAnimated:NO completion:^{
                                    [self displayExtendedForecastPopover:self.forecastDayNumber];
                                }];
                            }   break;
                                
                            case UIUserInterfaceSizeClassRegular: { // landscape > portrait
                                if (self.forecastDayNumber <= 1 || self.forecastDayNumber >= 6) {
                                    [self.extendedPopoverNavigationVC dismissViewControllerAnimated:NO completion:nil];
                                    
                                } else {
                                    self.forecastDayNumber--;
                                    [self.extendedPopoverNavigationVC dismissViewControllerAnimated:NO completion:^{
                                        [self displayExtendedForecastPopover:self.forecastDayNumber];
                                    }];
                                }
                            }   break;
                            default: break;
                        }
                        
                    } else { // for any other iPhone
                        switch (previousTraitCollection.verticalSizeClass) {
                                
                            case UIUserInterfaceSizeClassRegular: { // portrait > landscape
                                if (self.forecastDayNumber < 1 || self.forecastDayNumber >= 4) {
                                    [self.extendedPopoverNavigationVC dismissViewControllerAnimated:YES completion:nil];
                                    
                                } else {
                                    self.forecastDayNumber++;
                                    [self.extendedPopoverNavigationVC dismissViewControllerAnimated:NO completion:^{
                                        [self displayExtendedForecastPopover:self.forecastDayNumber];
                                    }];
                                }
                            }   break;
                                
                            case UIUserInterfaceSizeClassCompact: { // landscape > portrait
                                if (self.forecastDayNumber <= 1 || self.forecastDayNumber >= 5) {
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
                    
                    
                } else if (IS_IPAD) { // for any iPad
                    switch (previousTraitCollection.horizontalSizeClass) {
                            
                        case UIUserInterfaceSizeClassCompact: { // portrait > landscape
                            self.forecastDayNumber++;
                            [self.extendedPopoverNavigationVC dismissViewControllerAnimated:NO completion:^{
                                [self displayExtendedForecastPopover:self.forecastDayNumber];
                            }];
                        }   break;
                            
                        case UIUserInterfaceSizeClassRegular: { // landscape > portrait
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
}


- (void)updateLayoutsForIPhoneAndIPad {
    if (IS_IPHONE) {
        
        if (IS_IPHONE_6_PLUS) {
            switch (self.view.traitCollection.horizontalSizeClass) {
                    
                case UIUserInterfaceSizeClassCompact: { // portrait mode iPhone 6/7 Plus
                    // gray view 1
                    _grayView1TopToContentViewTop.constant                  = kGrayView1TopToContentViewTop_IPhonePlusPortrait;
                    _grayView1LeadingToContentViewLeading.constant          = kGrayView1LeadingToContentViewLeading_IPhonePlusPortrait;
                    _grayView1TrailingToContentViewTrailing.constant        = kGrayView1TrailingToContentViewTrailing_IPhonePlusPortrait;
                    _grayView1BottomToTemperatureTodayBottom.constant       = kGrayView1BottomToTemperatureTodayBottom_IPhonePlusPortrait;
                    _currentWeatherTopToGrayView1Top.constant               = kCurrentWeatherTopToGrayView1Top_IPhonePlusPortrait;
                    _currentTemperatureLeadingToGrayView1Leading.constant   = kCurrentTemperatureLeadingToGrayView1Leading_IPhonePlusPortrait;
                    _weatherIconTopToCurrentWeatherBottom.constant          = kWeatherIconTopToCurrentWeatherBottom_IPhonePlusPortrait;
                    _weatherIconTrailingToGrayView1Trailing.constant        = kWeatherIconTrailingToGrayView1Trailing_IPhonePlusPortrait;
                    _weatherIconWidth.constant                              = kWeatherIconWidthHeight_IPhonePlus;
                    _weatherTypeTopToWeatherIconBottom.constant             = kWeatherTypeTopToWeatherIconTop_IPhonePlusPortrait;
                    _weatherTypeTrailingToGrayView1Trailing.constant        = kWeatherTypeTrailingToGrayView1Trailing_IPhonePlusPortrait;
                    _temperatureTodayTopToWeatherTypeBottom.constant        = kTemperatureTodayTopToWeatherTypeBottom_IPhonePlusPortrait;
                    _precipitationLeadingToGrayView1Leading.constant        = kPrecipitationLeadingToGrayView1Leading_IPhonePlusPortrait;
                    _humidityBottomToPrecipitationTop.constant              = kHumidityBottomToPrecipitationTop_IPhonePlusPortrait;
                    _windBottomToHumidityTop.constant                       = kWindBottomToHumidityTop_IPhonePlusPortrait;
                    
                    // gray view 2
                    _grayView2TopToGrayView1Bottom.constant             = kGrayView2TopToGrayView1Bottom_IPhonePlusPortrait;
                    _extendedTitleTopToGrayView2Top.constant            = kExtendedTitleTopToGrayView2Top_IPhonePlusPortrait;
                    _extendedTextTopToExtendedTitleBottom.constant      = kExtendedTextTopToExtendedTitleBottom_IPhonePlusPortrait;
                    _extendedTitleLeadingToGrayView2Leading.constant    = kExtendedTitleLeadingToGrayView2Leading_IPhonePlusPortrait;
                    _extendedTitleTrailingToGrayView2Trailing.constant  = kExtendedTitleTrailing2GrayView2Trailing_IPhonePlusPortrait;
                    _alertViewTrailingToGrayView2Trailing.constant      = kAlertViewTrailingToGrayView2Trailing_IPhonePlusPortrait;
                    _alertViewBottomToGrayView2Bottom.constant          = kAlertViewBottomToGrayView2Bottom_IPhonePlusPortrait;
                    
                    // gray view 3
                    _grayView3TopToGrayView2Bottom.constant             = kGrayView3TopToGrayView2Bottom_IPhonePlusPortrait;
                    _grayView3BottomToPoweredBottom.constant            = kGrayView3BottomToPoweredBottom_IPhonePlusPortrait;
                    _geneticTitleTopToGrayView3Top.constant             = kGeneticTitleTopToGrayView3Top_IPhonePlusPortrait;
                    _geneticTitleLeadingToGrayView3Leading.constant     = kGeneticTitleLeadingToGrayView3Leading_IPhonePlusPortrait;
                    _geneticTitleTrailingToGrayView3Trailing.constant   = kGeneticTitleTrailingToGrayView3Trailing_IPhonePlusPortrait;
                    _logoLeadingToGrayView3Leading.constant             = kLogoLeadingToGrayView3Leading_IPhonePlusPortrait;
                    _logoIconHeight.constant                            = kLogoIconWidth_IPhonePlusPortrait;
                    _geneticTextTopToGeneticTitleBottom.constant        = kGeneticTextTopToGeneticTitleBottom_IPhonePlusPortrait;
                    _geneticTextLeadingToLogoTrailing.constant          = kGeneticTextLeadingToLogoTrailing_IPhonePlusPortrait;
                    _poweredTopToGeneticTextBottom.constant             = kPoweredTopToGeneticTextBottom_IPhonePlusPortrait;
                    _poweredTrailingToGrayView3Trailing.constant        = kPoweredTrailingToGrayView3Trailing_IPhonePlusPortrait;
                    
                    // gray view 4
                    _grayView4TopToGrayView3Bottom.constant         = kGrayView4TopToGrayView3Bottom_IPhonePlusPortrait;
                    _forecast1TopToGrayView4Top.constant            = kForecast1TopToGrayView4Top_IPhonePlusPortrait;
                    _forecast1LeadingToGrayView4Leading.constant    = kForecast1LeadingToGrayView4Leading_IPhonePlusPortrait;
                    _grayView4BottomToForecast1Bottom.constant      = kGrayView4BottomToForecast1Bottom_IPhonePlusPortrait;
                    
                    CGRect gray4Frame   = self.view.frame;
                    CGFloat newWidth    = (gray4Frame.size.width - 40) * kForecast1WidthMultiplier_IPhonePlusPortrait;
                    _forecast1BlockWidth.constant = newWidth;
                }   break;
                
                case UIUserInterfaceSizeClassRegular: { // landscape mode iPhone 6/7 Plus
                    // gray view 1
                    _grayView1TopToContentViewTop.constant = kGrayView1TopToContentViewTop_IPhonePlusLandscape;
                    _grayView1LeadingToContentViewLeading.constant = kGrayView1LeadingToContentViewLeading_IPhonePlusLandscape;
                    _currentWeatherTopToGrayView1Top.constant = kCurrentWeatherTopToGrayView1Top_IPhonePlusLandscape;
                    _currentTemperatureLeadingToGrayView1Leading.constant = kCurrentTemperatureLeadingToGrayView1Leading_IPhonePlusLandscape;
                    _precipitationLeadingToGrayView1Leading.constant = kPrecipitationLeadingToGrayView1Leading_IPhonePlusLandscape;
                    _weatherIconTopToCurrentWeatherBottom.constant = kWeatherIconTopToCurrentWeatherBottom_IPhonePlusLandscape;
                    _weatherIconTrailingToGrayView1Trailing.constant = kWeatherIconTrailingToGrayView1Trailing_IPhonePlusLandscape;
                    _weatherTypeTrailingToGrayView1Trailing.constant = kWeatherTypeTrailingToGrayView1Trailing_IPhonePlusLandscape;
                    _grayView1BottomToGrayView4Top.constant = kGrayView1BottomToGrayView4Top_IPhonePlusLandscape;
                    
                    // gray view 2
                    _grayView2LeadingToGrayView1Trailing.constant = kGrayView2LeadingToGrayView1Trailing_IPhonePlusLandscape;
                    _grayView2TrailingToContentViewTrailing.constant = kGrayView2TrailingToContentViewTrailing_IPhonePlusLandscape;
                    _extendedTitleTopToGrayView2Top.constant = kExtendedTitleTopToGrayView2Top_IPhonePlusLandscape;
                    _extendedTextTopToExtendedTitleBottom.constant = kExtendedTextTopToExtendedTitleBottom_IPhonePlusLandscape;
                    _extendedTitleLeadingToGrayView2Leading.constant = kExtendedTitleLeadingToGrayView2Leading_IPhonePlusLandscape;
                    _extendedTitleTrailingToGrayView2Trailing.constant = kExtendedTitleTrailing2GrayView2Trailing_IPhonePlusLandscape;
                    _alertViewTrailingToGrayView2Trailing.constant = kAlertViewTrailingToGrayView2Trailing_IPhonePlusLandscape;
                    _alertViewBottomToGrayView2Bottom.constant = kAlertViewBottomToGrayView2Bottom_IPhonePlusLandscape;
                    
                    // gray view 3
                    _grayView3TopToGrayView2Bottom.constant = kGrayView3TopToGrayView2Bottom_IPhonePlusLandscape;
                    _geneticTitleTopToGrayView3Top.constant = kGeneticTitleTopToGrayView3Top_IPhonePlusLandscape;
                    _geneticTitleLeadingToGrayView3Leading.constant = kGeneticTitleLeadingToGrayView3Leading_IPhonePlusLandscape;
                    _geneticTitleTrailingToGrayView3Trailing.constant = kGeneticTitleTrailingToGrayView3Trailing_IPhonePlusLandscape;
                    _logoLeadingToGrayView3Leading.constant = kLogoLeadingToGrayView3Leading_IPhonePlusLandscape;
                    _geneticTextTopToGeneticTitleBottom.constant = kGeneticTextTopToGeneticTitleBottom_IPhonePlusLandscape;
                    _geneticTextLeadingToLogoTrailing.constant = kGeneticTextLeadingToLogoTrailing_IPhonePlusLandscape;
                    _geneticTextBottomToPoweredTop.constant = kGeneticTextBottomToPoweredTop_IPhonePlusLandscape;
                    _poweredTrailingToGrayView3Trailing.constant = kPoweredTrailingToGrayView3Trailing_IPhonePlusLandscape;
                    _poweredBottomToGrayView3Bottom.constant = kPoweredBottomToGrayView3Bottom_IPhonePlusLandscape;
                    
                    // gray view 4
                    _grayView4BottomToScrollViewBottom.constant = kGrayView4BottomToScrollViewBottom_IPhonePlusLandscape;
                    _forecast1TopToGrayView4Top.constant = kForecast1TopToGrayView4Top_IPhonePlusLandscape;
                    _forecast1LeadingToGrayView4Leading.constant = kForecast1LeadingToGrayView4Leading_IPhonePlusLandscape;
                    _grayView4BottomToForecast1Bottom.constant = kGrayView4BottomToForecast1Bottom_IPhonePlusLandscape;
                    
                    CGRect gray4Frame = self.view.frame;
                    CGFloat newWidth = (gray4Frame.size.width - 40) * kForecast1WidthMultiplier_IPhonePlusLandscape;
                    _forecast1BlockWidth.constant = newWidth;
                    
                }   break;
                default: break;
            }
            
        } else {    // any other iPhone (4S/5/6/7)
            switch (self.view.traitCollection.verticalSizeClass) {
                case UIUserInterfaceSizeClassRegular: { // portrait mode iPhone
                    // gray view 1
                    [_currentWeatherTitle setHidden:YES];
                    _grayView1TopToContentViewTop.constant = kGrayView1TopToContentViewTop_IPhonePortrait;
                    _grayView1LeadingToContentViewLeading.constant = kGrayView1LeadingToContentViewLeading_IPhonePortrait;
                    _grayView1TrailingToContentViewTrailing.constant = kGrayView1TrailingToContentViewTrailing_IPhonePortrait;
                    _grayView1BottomToTemperatureTodayBottom.constant = kGrayView1BottomToTemperatureTodayBottom_IPhonePortrait;
                    _currentWeatherTopToGrayView1Top.constant = kCurrentWeatherTopToGrayView1Top_IPhonePortrait;
                    _currentTemperatureLeadingToGrayView1Leading.constant = kCurrentTemperatureLeadingToGrayView1Leading_IPhonePortrait;
                    _weatherIconTopToCurrentWeatherBottom.constant = kWeatherIconTopToCurrentWeatherBottom_IPhonePortrait;
                    _weatherIconTrailingToGrayView1Trailing.constant = kWeatherIconTrailingToGrayView1Trailing_IPhonePortrait;
                    _weatherIconWidth.constant = kWeatherIconWidthHeight_IPhone;
                    _weatherTypeTopToWeatherIconBottom.constant = kWeatherTypeTopToWeatherIconTop_IPhonePortrait;
                    _weatherTypeTrailingToGrayView1Trailing.constant = kWeatherTypeTrailingToGrayView1Trailing_IPhonePortrait;
                    _temperatureTodayTopToWeatherTypeBottom.constant = kTemperatureTodayTopToWeatherTypeBottom_IPhonePortrait;
                    _precipitationLeadingToGrayView1Leading.constant = kPrecipitationLeadingToGrayView1Leading_IPhonePortrait;
                    _humidityBottomToPrecipitationTop.constant = kHumidityBottomToPrecipitationTop_IPhonePortrait;
                    _windBottomToHumidityTop.constant = kWindBottomToHumidityTop_IPhonePortrait;
                    
                    // gray view 2
                    _grayView2TopToGrayView1Bottom.constant = kGrayView2TopToGrayView1Bottom_IPhonePortrait;
                    _extendedTitleTopToGrayView2Top.constant = kExtendedTitleTopToGrayView2Top_IPhonePortrait;
                    _extendedTextTopToExtendedTitleBottom.constant = kExtendedTextTopToExtendedTitleBottom_IPhonePortrait;
                    _extendedTitleLeadingToGrayView2Leading.constant = kExtendedTitleLeadingToGrayView2Leading_IPhonePortrait;
                    _extendedTitleTrailingToGrayView2Trailing.constant = kExtendedTitleTrailing2GrayView2Trailing_IPhonePortrait;
                    _alertViewTrailingToGrayView2Trailing.constant = kAlertViewTrailingToGrayView2Trailing_IPhonePortrait;
                    _alertViewBottomToGrayView2Bottom.constant = kAlertViewBottomToGrayView2Bottom_IPhonePortrait;
                    
                    // gray view 3
                    _grayView3TopToGrayView2Bottom.constant = kGrayView3TopToGrayView2Bottom_IPhonePortrait;
                    _grayView3BottomToPoweredBottom.constant = kGrayView3BottomToPoweredBottom_IPhonePortrait;
                    _geneticTitleTopToGrayView3Top.constant = kGeneticTitleTopToGrayView3Top_IPhonePortrait;
                    _geneticTitleLeadingToGrayView3Leading.constant = kGeneticTitleLeadingToGrayView3Leading_IPhonePortrait;
                    _geneticTitleTrailingToGrayView3Trailing.constant = kGeneticTitleTrailingToGrayView3Trailing_IPhonePortrait;
                    _logoLeadingToGrayView3Leading.constant = kLogoLeadingToGrayView3Leading_IPhonePortrait;
                    _logoIconHeight.constant = kLogoIconWidth_IPhonePortrait;
                    _geneticTextTopToGeneticTitleBottom.constant = kGeneticTextTopToGeneticTitleBottom_IPhonePortrait;
                    _geneticTextLeadingToLogoTrailing.constant = kGeneticTextLeadingToLogoTrailing_IPhonePortrait;
                    _poweredTopToGeneticTextBottom.constant = kPoweredTopToGeneticTextBottom_IPhonePortrait;
                    _poweredTrailingToGrayView3Trailing.constant = kPoweredTrailingToGrayView3Trailing_IPhonePortrait;
                    
                    // gray view 4
                    _grayView4TopToGrayView3Bottom.constant = kGrayView4TopToGrayView3Bottom_IPhonePortrait;
                    _forecast1TopToGrayView4Top.constant = kForecast1TopToGrayView4Top_IPhonePortrait;
                    _grayView4BottomToForecast1Bottom.constant = kGrayView4BottomToForecast1Bottom_IPhonePortrait;
                    
                    CGRect gray4Frame = self.view.frame;
                    CGFloat newWidth;
                    if (IS_IPHONE_4) {
                        newWidth = gray4Frame.size.width * kForecast1WidthMultiplier_IPhone4Portrait;
                        _forecast1LeadingToGrayView4Leading.constant = kForecast1LeadingToGrayView4Leading_IPhone4Portrait;
                    } else if (IS_IPHONE_5) {
                        newWidth = gray4Frame.size.width * kForecast1WidthMultiplier_IPhone5Portrait;
                        _forecast1LeadingToGrayView4Leading.constant = kForecast1LeadingToGrayView4Leading_IPhone5Portrait;
                    } else if (IS_IPHONE_6) {
                        newWidth = gray4Frame.size.width * kForecast1WidthMultiplier_IPhone6Portrait;
                        _forecast1LeadingToGrayView4Leading.constant = kForecast1LeadingToGrayView4Leading_IPhone6Portrait;
                    }
                    _forecast1BlockWidth.constant = newWidth;
                }   break;
                
                case UIUserInterfaceSizeClassCompact: { // landscape mode iPhone
                    // gray view 1
                    [_currentWeatherTitle setHidden:YES];
                    _grayView1TopToContentViewTop.constant = kGrayView1TopToContentViewTop_IPhoneLandscape;
                    if (IS_IPHONE_6) {
                        _grayView1LeadingToContentViewLeading.constant = kGrayView1LeadingToContentViewLeading_IPhone6Landscape;
                        _grayView1TrailingToContentViewTrailing.constant = kGrayView1TrailingToContentViewTrailing_IPhone6Landscape;
                        _currentTemperatureLeadingToGrayView1Leading.constant = kCurrentTemperatureLeadingToGrayView1Leading_IPhone6Landscape;
                        _precipitationLeadingToGrayView1Leading.constant = kPrecipitationLeadingToGrayView1Leading_IPhone6Landscape;
                        _weatherIconTrailingToGrayView1Trailing.constant = kWeatherIconTrailingToGrayView1Trailing_IPhone6Landscape;
                        _weatherTypeTrailingToGrayView1Trailing.constant = kWeatherTypeTrailingToGrayView1Trailing_IPhone6Landscape;
                    } else {
                        _grayView1LeadingToContentViewLeading.constant = kGrayView1LeadingToContentViewLeading_IPhoneLandscape;
                        _grayView1TrailingToContentViewTrailing.constant = kGrayView1TrailingToContentViewTrailing_IPhoneLandscape;
                        _currentTemperatureLeadingToGrayView1Leading.constant = kCurrentTemperatureLeadingToGrayView1Leading_IPhoneLandscape;
                        _precipitationLeadingToGrayView1Leading.constant = kPrecipitationLeadingToGrayView1Leading_IPhoneLandscape;
                        _weatherIconTrailingToGrayView1Trailing.constant = kWeatherIconTrailingToGrayView1Trailing_IPhoneLandscape;
                        _weatherTypeTrailingToGrayView1Trailing.constant = kWeatherTypeTrailingToGrayView1Trailing_IPhoneLandscape;
                    }
                    _grayView1BottomToTemperatureTodayBottom.constant = kGrayView1BottomToTemperatureTodayBottom_IPhoneLandscape;
                    _currentWeatherTopToGrayView1Top.constant = kCurrentWeatherTopToGrayView1Top_IPhoneLandscape;
                    _weatherIconTopToCurrentWeatherBottom.constant = kWeatherIconTopToCurrentWeatherBottom_IPhoneLandscape;
                    _weatherIconWidth.constant = kWeatherIconWidthHeight_IPhone;
                    _weatherTypeTopToWeatherIconBottom.constant = kWeatherTypeTopToWeatherIconTop_IPhoneLandscape;
                    _temperatureTodayTopToWeatherTypeBottom.constant = kTemperatureTodayTopToWeatherTypeBottom_IPhoneLandscape;
                    _humidityBottomToPrecipitationTop.constant = kHumidityBottomToPrecipitationTop_IPhoneLandscape;
                    _windBottomToHumidityTop.constant = kWindBottomToHumidityTop_IPhoneLandscape;
                    
                    // gray view 2
                    _grayView2TopToGrayView1Bottom.constant = kGrayView2TopToGrayView1Bottom_IPhoneLandscape;
                    _extendedTitleTopToGrayView2Top.constant = kExtendedTitleTopToGrayView2Top_IPhoneLandscape;
                    _extendedTextTopToExtendedTitleBottom.constant = kExtendedTextTopToExtendedTitleBottom_IPhoneLandscape;
                    _extendedTitleLeadingToGrayView2Leading.constant = kExtendedTitleLeadingToGrayView2Leading_IPhoneLandscape;
                    _extendedTitleTrailingToGrayView2Trailing.constant = kExtendedTitleTrailing2GrayView2Trailing_IPhoneLandscape;
                    _alertViewTrailingToGrayView2Trailing.constant = kAlertViewTrailingToGrayView2Trailing_IPhoneLandscape;
                    _alertViewBottomToGrayView2Bottom.constant = kAlertViewBottomToGrayView2Bottom_IPhoneLandscape;
                    
                    // gray view 3
                    _grayView3TopToGrayView2Bottom.constant = kGrayView3TopToGrayView2Bottom_IPhoneLandscape;
                    _grayView3BottomToPoweredBottom.constant = kGrayView3BottomToPoweredBottom_IPhoneLandscape;
                    _geneticTitleTopToGrayView3Top.constant = kGeneticTitleTopToGrayView3Top_IPhoneLandscape;
                    _geneticTitleLeadingToGrayView3Leading.constant = kGeneticTitleLeadingToGrayView3Leading_IPhoneLandscape;
                    _geneticTitleTrailingToGrayView3Trailing.constant = kGeneticTitleTrailingToGrayView3Trailing_IPhoneLandscape;
                    _logoLeadingToGrayView3Leading.constant = kLogoLeadingToGrayView3Leading_IPhoneLandscape;
                    _logoIconHeight.constant = kLogoIconWidth_IPhoneLandscape;
                    _geneticTextTopToGeneticTitleBottom.constant = kGeneticTextTopToGeneticTitleBottom_IPhonePlusLandscape;
                    _geneticTextLeadingToLogoTrailing.constant = kGeneticTextLeadingToLogoTrailing_IPhoneLandscape;
                    _poweredTopToGeneticTextBottom.constant = kPoweredTopToGeneticTextBottom_IPhoneLandscape;
                    _poweredTrailingToGrayView3Trailing.constant = kPoweredTrailingToGrayView3Trailing_IPhoneLandscape;
                    
                    // gray view 4
                    _grayView4TopToGrayView3Bottom.constant = kGrayView4TopToGrayView3Bottom_IPhoneLandscape;
                    _forecast1TopToGrayView4Top.constant = kForecast1TopToGrayView4Top_IPhoneLandscape;
                    _grayView4BottomToForecast1Bottom.constant = kGrayView4BottomToForecast1Bottom_IPhoneLandscape;
                    
                    CGRect gray4Frame = self.view.frame;
                    CGFloat newWidth;
                    if (IS_IPHONE_4) {
                        newWidth = gray4Frame.size.width * kForecast1WidthMultiplier_IPhone4Landscape;
                        _forecast1LeadingToGrayView4Leading.constant = kForecast1LeadingToGrayView4Leading_IPhone4Landscape;
                    } else if (IS_IPHONE_5) {
                        newWidth = gray4Frame.size.width * kForecast1WidthMultiplier_IPhone5Landscape;
                        _forecast1LeadingToGrayView4Leading.constant = kForecast1LeadingToGrayView4Leading_IPhone5Landscape;
                    } else if (IS_IPHONE_6) {
                        newWidth = gray4Frame.size.width * kForecast1WidthMultiplier_IPhone6Landscape;
                        _forecast1LeadingToGrayView4Leading.constant = kForecast1LeadingToGrayView4Leading_IPhone6Landscape;
                    }
                    _forecast1BlockWidth.constant = newWidth;
                }   break;
                default: break;
            }
        }
        
        
    } else if (IS_IPAD) {
        
        if ([self isIPadPro13inches]) {  // iPad Pro 13"
            switch (self.view.traitCollection.horizontalSizeClass) {
                    
                case UIUserInterfaceSizeClassCompact: { // iPad Pro 13 portrait mode
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
                    
                    CGRect gray4Frame = self.view.frame;
                    CGFloat newWidth = (gray4Frame.size.width - 80) * kForecast1WidthMultiplier_IPadProPortrait;
                    _forecast1BlockWidth.constant = newWidth;
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
                    
                    CGRect gray4Frame = self.view.frame;
                    CGFloat newWidth = (gray4Frame.size.width - 80) * kForecast1WidthMultiplier_IPadProLandscape;
                    _forecast1BlockWidth.constant = newWidth;
                }   break;
                default: break;
            }
            
        } else { // any other iPad 9.7" & 7.9"
            switch (self.view.traitCollection.horizontalSizeClass) {
                    
                case UIUserInterfaceSizeClassCompact: { // portrait mode
                    CGRect gray4Frame = self.view.frame;
                    CGFloat newWidth = (gray4Frame.size.width - 40) * kForecast1WidthMultiplier_IPadPortrait;
                    _forecast1BlockWidth.constant = newWidth;
                }   break;
                    
                case UIUserInterfaceSizeClassRegular: { // landscape mode
                    CGRect gray4Frame = self.view.frame;
                    CGFloat newWidth = (gray4Frame.size.width - 40) * kForecast1WidthMultiplier_IPadLandscape;
                    _forecast1BlockWidth.constant = newWidth;
                }   break;
                default: break;
            }
        }
    }
    [self.view setNeedsUpdateConstraints];
}


- (void)udjustAllTextFontSizeForIPhoneAndIPad {
    if (IS_IPHONE) {
        if (IS_IPHONE_6_PLUS) { // iPhone 6/7 Plus
            // Gray View 1
            _currentWeatherTitle.font = [_currentWeatherTitle.font fontWithSize:kGrayViewTitleFontSize_IPhonePlus];
            
            // currentTemperature font size adjusted here: [self prepopulateCurrentTemperatureBasedOnCurrentObservation]
            _currentWeatherType.font = [_currentWeatherType.font fontWithSize:kTodaysTemperatureAndWeatherTypeFontSize_IPhonePlus];
            // todaysTemperature font size adjusted here: [self prepopulateTodaysHighAndLowTemperatureBasedOnForecastSection]
            _currentWind.font = [_currentWind.font fontWithSize:kWindHumidityAndPrecipitationFontSize_IPhonePlus];
            _currentHumidity.font = [_currentHumidity.font fontWithSize:kWindHumidityAndPrecipitationFontSize_IPhonePlus];
            _currentPrecipitation.font = [_currentPrecipitation.font fontWithSize:kWindHumidityAndPrecipitationFontSize_IPhonePlus];
            
            // Gray View 2
            _extendedForecastTitle.font = [_extendedForecastTitle.font fontWithSize:kGrayViewTitleFontSize_IPhonePlus];
            _extendedForecastText.font = [_extendedForecastText.font fontWithSize:kExtendedTextFontSize_IPhonePlus];
            _alertButton.titleLabel.font = [_alertButton.titleLabel.font fontWithSize:kAlertButtonFontSize_IPhonePlus];
            
            // Gray View 3
            _geneticForecastTitle.font = [_geneticForecastTitle.font fontWithSize:kGrayViewTitleFontSize_IPhonePlus];
            // _sequencingLogo
            _geneticForecastText.font = [_geneticForecastText.font fontWithSize:kGeneticForecastTextFontSize_IPhonePlus];
            _poweredBy.font = [_poweredBy.font fontWithSize:kPoweredByFontSize_IPhonePlus];
            
            // Gray View 4
            _day1NameLabel.font  = [_day1NameLabel.font fontWithSize:kForecastDayName_IPhonePlus];
            _day2NameLabel.font  = [_day2NameLabel.font fontWithSize:kForecastDayName_IPhonePlus];
            _day3NameLabel.font  = [_day3NameLabel.font fontWithSize:kForecastDayName_IPhonePlus];
            _day4NameLabel.font  = [_day4NameLabel.font fontWithSize:kForecastDayName_IPhonePlus];
            _day5NameLabel.font  = [_day5NameLabel.font fontWithSize:kForecastDayName_IPhonePlus];
            _day6NameLabel.font  = [_day6NameLabel.font fontWithSize:kForecastDayName_IPhonePlus];
            _day7NameLabel.font  = [_day7NameLabel.font fontWithSize:kForecastDayName_IPhonePlus];
            _day8NameLabel.font  = [_day8NameLabel.font fontWithSize:kForecastDayName_IPhonePlus];
            _day9NameLabel.font  = [_day9NameLabel.font fontWithSize:kForecastDayName_IPhonePlus];
            _day10NameLabel.font = [_day10NameLabel.font fontWithSize:kForecastDayName_IPhonePlus];
            
        } else { // any other iPhone 4S/5/6/7
            // Gray View 1
            _currentWeatherTitle.font = [_currentWeatherTitle.font fontWithSize:kGrayViewTitleFontSize_IPhone];
            [_currentWeatherTitle setHidden:YES];
            
            // currentTemperature font size adjusted here: [self prepopulateCurrentTemperatureBasedOnCurrentObservation]
            _currentWeatherType.font = [_currentWeatherType.font fontWithSize:kTodaysTemperatureAndWeatherTypeFontSize_IPhone];
            // todaysTemperature font size adjusted here: [self prepopulateTodaysHighAndLowTemperatureBasedOnForecastSection]
            _currentWind.font = [_currentWind.font fontWithSize:kWindHumidityAndPrecipitationFontSize_IPhone];
            _currentHumidity.font = [_currentHumidity.font fontWithSize:kWindHumidityAndPrecipitationFontSize_IPhone];
            _currentPrecipitation.font = [_currentPrecipitation.font fontWithSize:kWindHumidityAndPrecipitationFontSize_IPhone];
            
            // Gray View 2
            _extendedForecastTitle.font = [_extendedForecastTitle.font fontWithSize:kGrayViewTitleFontSize_IPhone];
            _extendedForecastText.font = [_extendedForecastText.font fontWithSize:kExtendedTextFontSize_IPhone];
            _alertButton.titleLabel.font = [_alertButton.titleLabel.font fontWithSize:kAlertButtonFontSize_IPhone];
            
            // Gray View 3
            _geneticForecastTitle.font = [_geneticForecastTitle.font fontWithSize:kGrayViewTitleFontSize_IPhone];
            // _sequencingLogo
            _geneticForecastText.font = [_geneticForecastText.font fontWithSize:kGeneticForecastTextFontSize_IPhone];
            _poweredBy.font = [_poweredBy.font fontWithSize:kPoweredByFontSize_IPhone];
            
            // Gray View 4
            _day1NameLabel.font  = [_day1NameLabel.font fontWithSize:kForecastDayName_IPhone];
            _day2NameLabel.font  = [_day2NameLabel.font fontWithSize:kForecastDayName_IPhone];
            _day3NameLabel.font  = [_day3NameLabel.font fontWithSize:kForecastDayName_IPhone];
            _day4NameLabel.font  = [_day4NameLabel.font fontWithSize:kForecastDayName_IPhone];
            _day5NameLabel.font  = [_day5NameLabel.font fontWithSize:kForecastDayName_IPhone];
            _day6NameLabel.font  = [_day6NameLabel.font fontWithSize:kForecastDayName_IPhone];
            _day7NameLabel.font  = [_day7NameLabel.font fontWithSize:kForecastDayName_IPhone];
            _day8NameLabel.font  = [_day8NameLabel.font fontWithSize:kForecastDayName_IPhone];
            _day9NameLabel.font  = [_day9NameLabel.font fontWithSize:kForecastDayName_IPhone];
            _day10NameLabel.font = [_day10NameLabel.font fontWithSize:kForecastDayName_IPhone];
        }
        
    } else if ([self isIPadPro13inches]) { // iPad Pro 13"
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
        _day1NameLabel.font  = [_day1NameLabel.font fontWithSize:kForecastDayName_IPadPro];
        _day2NameLabel.font  = [_day2NameLabel.font fontWithSize:kForecastDayName_IPadPro];
        _day3NameLabel.font  = [_day3NameLabel.font fontWithSize:kForecastDayName_IPadPro];
        _day4NameLabel.font  = [_day4NameLabel.font fontWithSize:kForecastDayName_IPadPro];
        _day5NameLabel.font  = [_day5NameLabel.font fontWithSize:kForecastDayName_IPadPro];
        _day6NameLabel.font  = [_day6NameLabel.font fontWithSize:kForecastDayName_IPadPro];
        _day7NameLabel.font  = [_day7NameLabel.font fontWithSize:kForecastDayName_IPadPro];
        _day8NameLabel.font  = [_day8NameLabel.font fontWithSize:kForecastDayName_IPadPro];
        _day9NameLabel.font  = [_day9NameLabel.font fontWithSize:kForecastDayName_IPadPro];
        _day10NameLabel.font = [_day10NameLabel.font fontWithSize:kForecastDayName_IPadPro];
    }
}


- (void)checkWhetherLeaveOnlyFourDaysForIPhone {
    if (IS_IPHONE) {
        if (IS_IPHONE_6_PLUS) { // includes iPhone 6/7 Plus only
            switch (self.traitCollection.horizontalSizeClass) {
                    
                case UIUserInterfaceSizeClassCompact: {
                    [_forecast5DayBlock setHidden:YES];
                    [_day5NameLabel     setHidden:YES];
                    [_day5Icon          setHidden:YES];
                    [_day5Temperature   setHidden:YES];
                    
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
                } break;
                    
                case UIUserInterfaceSizeClassRegular: {
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
                } break;
                default: break;
            }
            
        } else { // includes iPhone 4/5/6/7 (not Plus)
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
        }
    }
}



#pragma mark - Videoplayer Methods

- (void)initializeAndAddVideoToView {
    UserHelper   *userHelper    = [[UserHelper alloc] init];
    VideoHelper  *videoHelper   = [[VideoHelper alloc] init];
    ForecastData *forecastData  = [ForecastData sharedInstance];
    NSString *videoName;
    
    if ([forecastData.weatherType length] != 0 && [forecastData.dayNight length] != 0)
        videoName = [videoHelper getVideoNameBasedOnWeatherType:forecastData.weatherType AndDayNight:forecastData.dayNight];
    else
        videoName = [videoHelper getRandomVideoName];
    [userHelper saveKnownVideoFileName:videoName];
    
    // check whether it's the same video again, in order not to reitinialize the same video again
    if ([_nowUsedVideoFileName length] == 0 || ![videoName isEqualToString:_nowUsedVideoFileName]) {
        
        [self showVideoWithFile:videoName];
        
        NSString *filepath = [[NSBundle mainBundle] pathForResource:videoName ofType:nil inDirectory:@"Video"];
        if (!filepath) return;
        _nowUsedVideoFileName = videoName;
    }
}


- (void)addNotificationObserves {
    // add observer for video playback
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(itemDidFinishPlaying:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[self.avPlayer currentItem]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(menuItemSelected:)
                                                 name:MENU_ITEM_SELECTED_NOTIFICATION_KEY
                                               object:nil];
    [self addNotificationObservesForAppStates];
}


- (void)addNotificationObservesForAppStates {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActiveNotification)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActiveNotification)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void)removeNotificationObservesForAppStates {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}




- (UIStatusBarStyle)preferredStatusBarStyle {
    // UIStatusBarStyleLightContent
    // UIStatusBarStyleDefault
    return UIStatusBarStyleLightContent;
}



#pragma mark - SequencingLogo animation

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
    dispatch_async(kMainQueue, ^{
        if (!self.alreadySelectedMenuItem) {
            
            NSNumber *object = notification.object;
            NSInteger menuItemTag = [object integerValue];
            
            switch (menuItemTag) {
                case 1: { // About menuItem selected
                    self.alreadySelectedMenuItem = YES;
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"About" bundle:nil];
                    UINavigationController *aboutNavigationVC = (UINavigationController *)[storyboard instantiateInitialViewController];
                    aboutNavigationVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                    AboutViewController *aboutVC = [aboutNavigationVC viewControllers][0];
                    aboutVC.delegate = self;
                    [self removeNotificationObservesForAppStates];
                    [self presentViewController:aboutNavigationVC animated:YES completion:nil];
                } break;
                    
                    
                case 2: { // Settings menuItem selected
                    self.alreadySelectedMenuItem = YES;
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Settings" bundle:nil];
                    UINavigationController *settingsNavigationVC = (UINavigationController *)[storyboard instantiateInitialViewController];
                    settingsNavigationVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                    SettingsViewController *settingsVC = [settingsNavigationVC viewControllers][0];
                    settingsVC.delegate = self;
                    [self removeNotificationObservesForAppStates];
                    [self presentViewController:settingsNavigationVC animated:YES completion:nil];
                } break;
                    
                    
                case 3: { // Location menuItem selected
                    self.alreadySelectedMenuItem = YES;
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Location" bundle:nil];
                    UINavigationController *locationNavigationVC = (UINavigationController *)[storyboard instantiateInitialViewController];
                    locationNavigationVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                    LocationViewController *locationVC = [locationNavigationVC viewControllers][0];
                    locationVC.backButton = YES;
                    locationVC.delegate = self;
                    [self removeNotificationObservesForAppStates];
                    [self presentViewController:locationNavigationVC animated:YES completion:nil];
                } break;
                    
                    
                case 4: { // Share menuItem selected
                    self.alreadySelectedMenuItem = YES;
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
                    [self presentViewController:controller animated:YES completion:^{
                        self.alreadySelectedMenuItem = NO;
                    }];
                    
                } break;
                    
                    
                case 5: { // Feedback menuItem selected
                    self.alreadySelectedMenuItem = YES;
                    NSString *emailAddressURL = [kEmailAddress stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                    NSString *emailSubjectURL = [kEmailSubject stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                    NSString *emailContentURL = [kEmailContent stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                    NSURL *emailTempleate = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"mailto:%@?subject=%@&body=%@",
                                                                           emailAddressURL, emailSubjectURL, emailContentURL]];
                    [[UIApplication sharedApplication] openURL:emailTempleate];
                    self.alreadySelectedMenuItem = NO;
                } break;
                    
                    
                case 6: { // Sign out menuItem selected
                    self.alreadySelectedMenuItem = YES;
                    AlertMessage *alertMessage = [[AlertMessage alloc] init];
                    alertMessage.delegate = self;
                    [alertMessage viewController:self
                            showAlertWithMessage:@"Are you sure you want to sign out?"
                                   withYesAction:@"Confirm"
                                    withNoAction:@"Cancel"];
                    self.alreadySelectedMenuItem = NO;
                } break;
                default: break;
            }
        }
    });
}



#pragma mark - AlertMessageDialogDelegate
- (void)yesButtonPressed {
    UserHelper *userHelper = [[UserHelper alloc] init];
    if ([InternetConnection internetConnectionIsAvailable]) { // disable device push notifications
        [[SQOAuth sharedInstance] token:^(SQToken *token, NSString *accessToken) {
            if (token && [token.accessToken length] > 0) {
                NSDictionary *parameters = @{@"pushCheck"  : @"false",
                                             @"deviceType" : @(1),
                                             @"deviceToken": ([[userHelper loadDeviceToken] length] != 0) ? [userHelper loadDeviceToken] : @"",
                                             @"accessToken": token.accessToken};
                [[[UserAccountHelper alloc] init] sendSignOutRequestWithParameters:parameters];
            }
        }];
    }
    
    [[SQOAuth sharedInstance] userDidSignOut];
    [userHelper userDidSignOut];
    [userHelper removeAllStoredCredentials];
    [BadgeController removeBadgeWithTemperature];
    
    ForecastData *forecastData = [ForecastData sharedInstance];
    forecastData.forecast = nil;
    forecastData.geneticForecast = nil;
    forecastData.weatherType = nil;
    forecastData.dayNight = nil;
    forecastData.locationForForecast = nil;
    forecastData.alertType = nil;
    
    LocationWeatherUpdater *locationWeatherUpdater = [LocationWeatherUpdater sharedInstance];
    locationWeatherUpdater.delegate = self;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // open Login view/flow
    dispatch_async(kMainQueue, ^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *loginNavigationVC = (UINavigationController *)[storyboard instantiateInitialViewController];
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate.window setRootViewController:loginNavigationVC];
        [appDelegate.window makeKeyAndVisible];
    });
}



#pragma mark - AboutViewControllerDelegate
- (void)AboutViewController:(AboutViewController *)controller closeButtonPressed:(id)sender {
    dispatch_async(kMainQueue, ^{
        controller.delegate = nil;
        [controller dismissViewControllerAnimated:YES completion:nil];
        self.alreadySelectedMenuItem = NO;
        [self addNotificationObservesForAppStates];
    });
}



#pragma mark - SettingsViewControllerDelegate
- (void)settingsViewControllerWasClosed:(UIViewController *)controller
                    withTemperatureUnit:(NSNumber *)temperatureUnit
                           selectedFile:(NSDictionary *)file
                    andSelectedLocation:(NSDictionary *)location {
    dispatch_async(kMainQueue, ^{
        [controller dismissViewControllerAnimated:NO completion:nil];
        _currentlySelectedTemperatureUnit = temperatureUnit;
        _currentlySelectedFile = file;
        _currentlySelectedLocation = location;
        [self analyseIfAnyRefreshIsNeeded];
        self.alreadySelectedMenuItem = NO;
        [self addNotificationObservesForAppStates];
    });
}


- (void)settingsViewControllerUserDidSignOut:(UIViewController *)controller {
    dispatch_async(kMainQueue, ^{
        [controller dismissViewControllerAnimated:NO completion:nil];
        [self yesButtonPressed];
    });
}



#pragma mark - LocationViewControllerDelegate
- (void)locationViewController:(UIViewController *)controller didSelectLocation:(NSDictionary *)location {
    dispatch_async(kMainQueue, ^{
        [controller dismissViewControllerAnimated:NO completion:nil];
        self.alreadySelectedMenuItem = NO;
        [self addNotificationObservesForAppStates];
        
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
            [[SQOAuth sharedInstance] token:^(SQToken *token, NSString *accessToken) {
                if (token && [token.accessToken length] > 0) {
                    
                    NSString *locationID = [_currentlySelectedLocation objectForKey:LOCATION_ID_DICT_KEY];
                    NSDictionary *parameters = @{@"city" : locationID,
                                                 @"token": token.accessToken};
                    [[[UserAccountHelper alloc] init] sendSelectedLocationInfoWithParameters:parameters];
                }
            }];
        }
        
        // refresh UI if needed
        [self analyseIfAnyRefreshIsNeeded];
    });
}


- (void)locationViewController:(UIViewController *)controller backButtonPressed:(id)sender {
    dispatch_async(kMainQueue, ^{
        [controller dismissViewControllerAnimated:YES completion:nil];
        self.alreadySelectedMenuItem = NO;
    });
};



#pragma mark - Prepopulate conditions and forecast

- (void)prepopulateConditionsAndForecastFromBackground:(BOOL)fromBackground {
    ForecastData *forecastData = [ForecastData sharedInstance];
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
            [self prepopulateGeneticForecast:fromBackground];
            
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
    ForecastData *forecastData = [ForecastData sharedInstance];
    
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
        } else {
            if ([[[current_observationSection objectForKey:@"display_location"] allKeys] containsObject:@"city"]) {
                NSString *locationValue = [[current_observationSection objectForKey:@"display_location"] objectForKey:@"city"];
                if ([locationValue length] != 0) {
                    locationInfo = locationValue;
                }
            }
        }
    }
    
    // day and time
    NSString *dateInfo;
    if ([[forecastSection allKeys] containsObject:@"simpleforecast"]) {
        id forecastDayToUse = [[[forecastSection objectForKey:@"simpleforecast"] objectForKey:@"forecastday"] objectAtIndex:0];
        if (forecastDayToUse != nil && [forecastDayToUse isKindOfClass:[NSDictionary class]]) {
            NSDictionary *forecastDay0 = (NSDictionary *)forecastDayToUse;
            
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
    }
    // in case our date is still empty > get local date
    if ([dateInfo length] == 0) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"EEEE, MMMM dd, yyyy"];
        dateInfo = [dateFormatter stringFromDate:[NSDate date]];
    }
    
    // prepare title label
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    if (IS_IPHONE) {
        if (IS_IPHONE_6_PLUS)
            [titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:kLocationNameFontSize_IPhonePlus]];
        else
            [titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:kLocationNameFontSize]];
    } else if (IS_IPAD) {
        if ([self isIPadPro13inches])
            [titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:kLocationNameFontSize]];
        else
            [titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:kLocationNameFontSize]];
    }
    titleLabel.text = [self adjustLocationNameLenghIfNeeded:locationInfo];
    [titleLabel sizeToFit];
    
    // prepare subtitle label
    UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 0, 0)];
    subtitleLabel.backgroundColor = [UIColor clearColor];
    subtitleLabel.textColor = [UIColor whiteColor];
    if (IS_IPHONE) {
        if (IS_IPHONE_6_PLUS)
            [subtitleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:kLocationDateFontSize_IPhonePlus]];
        else
            [subtitleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:kLocationDateFontSize]];
    } else if (IS_IPAD) {
        if ([self isIPadPro13inches])
            [subtitleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:kLocationDateFontSize]];
        else
            [subtitleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:kLocationDateFontSize]];
    }
    subtitleLabel.text = dateInfo;
    [subtitleLabel sizeToFit];
    
    UIView *twoLineTitleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MAX(subtitleLabel.frame.size.width, titleLabel.frame.size.width), 26)];
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
    NSString *temperature;
    
    if (temperatureType == 1) { // °C value
        degreeCharacter = @"°C";
        if ([[current_observationSection allKeys] containsObject:@"temp_c"]) {
            id temp = [current_observationSection objectForKey:@"temp_c"];
            temperature = [NSString stringWithFormat:@"%@", temp];
            
            if ([temperature length] != 0) {
                double temperatureValue = [temperature doubleValue];
                int temperatureValueRounded = (int)lroundf(temperatureValue);
                NSNumber *temperatureNumber = [NSNumber numberWithInteger:temperatureValueRounded];
                self.currentTemperatureValue = temperatureNumber;
                temperatureStringValue = [NSString stringWithFormat:@"%@", [temperatureNumber stringValue]];
            }
        }
        
    } else { // °F value
        degreeCharacter = @"°F";
        if ([[current_observationSection allKeys] containsObject:@"temp_f"]) {
            id temp = [current_observationSection objectForKey:@"temp_f"];
            temperature = [NSString stringWithFormat:@"%@", temp];
            
            if ([temperature length] != 0) {
                double temperatureValue = [temperature doubleValue];
                int temperatureValueRounded = (int)lroundf(temperatureValue);
                NSNumber *temperatureNumber = [NSNumber numberWithInteger:temperatureValueRounded];
                self.currentTemperatureValue = temperatureNumber;
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
    if (IS_IPHONE) {
        if (IS_IPHONE_6_PLUS) { // iPhone 6/7 Plus
            currentTemperatureFontSize = kCurrentTemperatureFontSize_IPhonePlus;
            currentTemperatureUnitFontSize = kCurrentTemperatureUnitFontSize_IPhonePlus;
            baselineOffset = kCurrentTemperatureUnitBaselineOffset_IPhonePlus;
        } else { // any other iPhone
            if ([temperature intValue] >= 100)
                currentTemperatureFontSize = kCurrentTemperatureFontSizeLess_IPhone;
            else
                currentTemperatureFontSize = kCurrentTemperatureFontSize_IPhone;
            currentTemperatureUnitFontSize = kCurrentTemperatureUnitFontSize_IPhone;
            baselineOffset = kCurrentTemperatureUnitBaselineOffset_IPhone;
        }
        
    } else if (IS_IPAD) {
        if ([self isIPadPro13inches]) { // iPad Pro 13"
            if ([temperature intValue] >= 100)
                currentTemperatureFontSize = kCurrentTemperatureFontSizeLess_IPadPro;
            else
                currentTemperatureFontSize = kCurrentTemperatureFontSize_IPadPro;
            currentTemperatureUnitFontSize = kCurrentTemperatureUnitFontSize_IPadPro;
            baselineOffset = kCurrentTemperatureUnitBaselineOffset_IPadPro;
        } else { // any other iPad
            currentTemperatureFontSize = kCurrentTemperatureFontSize_IPad;
            currentTemperatureUnitFontSize = kCurrentTemperatureUnitFontSize_IPad;
            baselineOffset = kCurrentTemperatureUnitBaselineOffset_IPad;
        }
    }
    
    NSDictionary *attrDictForValue = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:currentTemperatureFontSize],
                                       NSForegroundColorAttributeName: [UIColor whiteColor]};
    NSDictionary *attrDictForDegree = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:currentTemperatureUnitFontSize],
                                        NSForegroundColorAttributeName: [UIColor whiteColor],
                                        NSBaselineOffsetAttributeName: [NSNumber numberWithUnsignedInteger:baselineOffset]};
    
    [attributedString addAttributes:attrDictForValue  range:NSMakeRange(0, [temperatureStringValue length])];
    [attributedString addAttributes:attrDictForDegree range:NSMakeRange([temperatureStringValue length], [degreeCharacter length])];
    
    _currentTemperature.attributedText = [attributedString copy];
    
    // update Badge with temperature value
    [BadgeController showTheBadgeWithTemperatureFromForecast:_forecast];
}


- (void)prepopulateTodaysHighAndLowTemperatureBasedOnForecastSection:(NSDictionary *)forecastSection
                                                  andTemperatureType:(int)temperatureType {
    NSString *tempH = [self pullHightTemperatureFromForecastDay:0
                                         basedOnForecastSection:forecastSection
                                     dependingOnTemperatureType:temperatureType];
    NSString *tempL = [self pullLowTemperatureFromForecastDay:0
                                       basedOnForecastSection:forecastSection
                                   dependingOnTemperatureType:temperatureType];
    
    
    CGFloat todaysTemperatureFontSize = 16.f;
    if (IS_IPHONE) {
        if (IS_IPHONE_6_PLUS)
            todaysTemperatureFontSize = kTodaysTemperatureAndWeatherTypeFontSize_IPhonePlus;
        else
            todaysTemperatureFontSize = kTodaysTemperatureAndWeatherTypeFontSize_IPhone;
        
    } else if (IS_IPAD) {
        if ([self isIPadPro13inches])
            todaysTemperatureFontSize = kTodaysTemperatureAndWeatherTypeFontSize_IPadPro;
        else
            todaysTemperatureFontSize = kTodaysTemperatureFontSize_IPad;
    }
    
    if ([tempH length] != 0 && [tempL length] != 0) {
        _todaysTemperature.attributedText = [self prepareAttributedTempteratureStringBasedOnHighTemperature:tempH
                                                                                             lowTemperature:tempL
                                                                                                andFontSize:todaysTemperatureFontSize];
    }
}


- (void)prepopulateCurrentWeatherTypeBasedOnCurrentObservation:(NSDictionary *)current_observationSection
                                            andForecastSection:(NSDictionary *)forecastSection {
    ForecastData *forecastData = [ForecastData sharedInstance];
    
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
        ForecastData *forecastData = [ForecastData sharedInstance];
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
    if (IS_IPHONE) {
        if (IS_IPHONE_6_PLUS) { // iPhone 6/7 Plus
            _currentWeatherIcon.image = [self imageWithImage:image scaledToSize:CGSizeMake(kWeatherIconWidthHeight_IPhonePlus, kWeatherIconWidthHeight_IPhonePlus)];
        } else { // any other iPhone
            _currentWeatherIcon.image = [self imageWithImage:image scaledToSize:CGSizeMake(kWeatherIconWidthHeight_IPhone, kWeatherIconWidthHeight_IPhone)];
        }
        
    } else if (IS_IPAD) {
        if ([self isIPadPro13inches]) { // iPad Pro 13"
            _currentWeatherIcon.image = [self imageWithImage:image scaledToSize:CGSizeMake(kWeatherIconWidthHeight_IPadPro, kWeatherIconWidthHeight_IPadPro)];
        } else { // any other iPad
            _currentWeatherIcon.image = [self imageWithImage:image scaledToSize:CGSizeMake(kWeatherIconWidthHeight_IPad, kWeatherIconWidthHeight_IPad)];
        }
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


- (void)prepopulateGeneticForecast:(BOOL)fromBackground {
    ForecastData *forecastData  = [ForecastData sharedInstance];
    if (forecastData.geneticForecast && [forecastData.geneticForecast length] > 0)
        self.geneticForecastText.text = forecastData.geneticForecast;
    else
        if (!fromBackground) [self fillGeneticForecast];
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
    CGFloat fontSize = 14.f;
    if (IS_IPHONE) {
        if (IS_IPHONE_6_PLUS)
            fontSize = kForecastDayTemperature_IPhonePlus;
        else
            fontSize = kForecastDayTemperature_IPhone;
        
    } else if (IS_IPAD) {
        if ([self isIPadPro13inches])
            fontSize = kForecastDayTemperature_IPadPro;
        else
            fontSize = kForecastDayTemperature_IPad;
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
        
        if (IS_IPHONE && [tempL intValue] < -10 ) {
            if (IS_IPHONE_6_PLUS)
                fontSize = kForecastDayTemperatureSmall_IPhonePlus;
            else
                fontSize = kForecastDayTemperatureSmall_IPhone;
        }
        
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
    if (IS_IPHONE) {
        if (IS_IPHONE_6_PLUS)
            fontSize = kForecastDayName_IPhonePlus;
        else
            fontSize = kForecastDayName_IPhone;
        
    } else if (IS_IPAD) {
        if ([self isIPadPro13inches])
            fontSize = kForecastDayName_IPadPro;
        else
            fontSize = kForecastDayName_IPad;
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
                NSNumber *temperatureHNumberCorrected = [self correctHiTemperature:temperatureHNumber forDayNumber:forecastDayNumber];
                temperature = [NSString stringWithFormat:@"%@", [temperatureHNumberCorrected stringValue]];
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
                NSNumber *temperatureHNumberCorrected = [self correctHiTemperature:temperatureHNumber forDayNumber:forecastDayNumber];
                temperature = [NSString stringWithFormat:@"%@", [temperatureHNumberCorrected stringValue]];
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
                NSNumber *temperatureLNumberCorrected = [self correctLowTemperature:temperatureLNumber forDayNumber:forecastDayNumber];
                temperature = [NSString stringWithFormat:@"%@", [temperatureLNumberCorrected stringValue]];
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
                NSNumber *temperatureLNumberCorrected = [self correctLowTemperature:temperatureLNumber forDayNumber:forecastDayNumber];
                temperature = [NSString stringWithFormat:@"%@", [temperatureLNumberCorrected stringValue]];
            }
        }
    }
    return temperature;
}


- (NSNumber *)correctHiTemperature:(NSNumber *)hiTemperatue forDayNumber:(int)dayNumber {
    NSNumber *correctedTemperatureValue = hiTemperatue;
    if (dayNumber == 0 && ([hiTemperatue integerValue] < [self.currentTemperatureValue integerValue]))
        correctedTemperatureValue = self.currentTemperatureValue;
    return correctedTemperatureValue;
}


- (NSNumber *)correctLowTemperature:(NSNumber *)lowTemperatue forDayNumber:(int)dayNumber {
    NSNumber *correctedTemperatureValue = lowTemperatue;
    if (dayNumber == 0 && ([lowTemperatue integerValue] > [self.currentTemperatureValue integerValue]))
        correctedTemperatureValue = self.currentTemperatureValue;
    return correctedTemperatureValue;
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



#pragma mark - Extended popover methods

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
    ForecastData *forecastContainer = [ForecastData sharedInstance];
    
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
    if (IS_IPHONE_6_PLUS)
        extendedPopoverVC.delegate = self;
    
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
    
    CGRect dayViewActualLocation = [self.view convertRect:view.frame fromView:view.superview];
    CGFloat actualY = dayViewActualLocation.origin.y;
    
    CGRect point;
    if (IS_IPHONE) // for iPhone
        point = CGRectMake(x + (width / 2) - 1, actualY - 10, 2.f, 1.f);
    else // for iPad
        point = CGRectMake(x + (width / 2) - 1, y + (height / 2) - 10, 2.f, 1.f);
    
    return point;
}


// UIPopoverPresentationControllerDelegate
- (void)prepareForPopoverPresentation:(UIPopoverPresentationController *)popoverPresentationController {
    popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionDown;
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}


// ExtendedForecastPopoverViewControllerDelegate
- (void)extendedForecastPopoverViewControllerWasClosed:(ExtendedForecastPopoverViewController *)controller {
    dispatch_async(kMainQueue, ^{
        controller.delegate = nil;
        [controller dismissViewControllerAnimated:YES completion:nil];
    });
}




#pragma mark - Refresh button

- (IBAction)refreshButtonPressed:(id)sender {
    dispatch_async(kMainQueue, ^{
        if (![InternetConnection internetConnectionIsAvailable]) {
            AlertMessage *alert = [[AlertMessage alloc] init];
            [alert viewController:self showAlertWithTitle:@"Can't refresh forecast" withMessage:NO_INTERNET_CONNECTION_TEXT];
            [self stopAnimatingCubePreloader];
            self.alreadyExecutingRefresh = NO;
            return;
        }
        
        if (self.alreadyExecutingRefresh && ![self.cubePreloader isAnimating]) return;
            
        self.alreadyExecutingRefresh = YES;
        [self stopAnimatingCubePreloader];
        LocationWeatherUpdater *locationWeatherUpdater = [LocationWeatherUpdater sharedInstance];
        locationWeatherUpdater.delegate = self;
        [locationWeatherUpdater checkLocationAvailabilityAndStart];
    });
}



#pragma mark - LocationWeatherUpdaterDelegate
- (void)startedRefreshing {
    dispatch_async(kMainQueue, ^{
        self.alreadyExecutingRefresh = YES;
        [self startSpinningRefreshButton];
    });
}


- (void)locationAndWeatherWereUpdated {
    NSLog(@"ForecastVC: locationAndWeatherWereUpdated");
    dispatch_async(kMainQueue, ^{
        LocationWeatherUpdater *locationWeatherUpdater = [LocationWeatherUpdater sharedInstance];
        locationWeatherUpdater.delegate = nil;
        
        [self stopSpinningRefreshButton];
        
        self.forecast = [ForecastData sharedInstance].forecast;
        [self showAllElements];
        
        [self prepopulateConditionsAndForecastFromBackground:NO];
        [self fillGeneticForecast];
        [self adjustExtendedForecastLabel];
        
        [self initializeAndAddVideoToView];
        [self handleVideo:[VideoHelper isVideoWhite]];
        [self addNotificationObserves];
        self.dateOfLastRefresh = [NSDate date];
    });
}


- (void)weatherForecastUpdated:(NSDictionary *)weatherForecast {
    dispatch_async(kMainQueue, ^{
        LocationWeatherUpdater *locationWeatherUpdater = [LocationWeatherUpdater sharedInstance];
        locationWeatherUpdater.delegate = nil;
        
        [self stopSpinningRefreshButton];
        
        ForecastData *forecastContainer = [ForecastData sharedInstance];
        [forecastContainer setForecast:weatherForecast];
        self.forecast = weatherForecast;
        
        NSString *weatherType = forecastContainer.weatherType;
        if (weatherType && [weatherType length] > 0) {
            _currentlyNewWeatherType = weatherType;
            _nowUsedWeatherType = _currentlyNewWeatherType;
        }
        
        [self showAllElements];
        
        [self prepopulateConditionsAndForecastFromBackground:NO];
        [self fillGeneticForecast];
        [self adjustExtendedForecastLabel];
        
        [self initializeAndAddVideoToView];
        [self handleVideo:[VideoHelper isVideoWhite]];
        [self addNotificationObserves];
        self.dateOfLastRefresh = [NSDate date];
    });
}


- (void)finishedRefreshWithError {
    NSLog(@"ForecastVC: finishedRefreshWithError");
    dispatch_async(kMainQueue, ^{
        LocationWeatherUpdater *locationWeatherUpdater = [LocationWeatherUpdater sharedInstance];
        locationWeatherUpdater.delegate = nil;
        
        [self stopSpinningRefreshButton];
        
        [self playVideo];
        [self addNotificationObserves];
        self.alreadyExecutingRefresh = NO;
        
        AlertMessage *alert = [[AlertMessage alloc] init];
        [alert viewController:self showAlertWithTitle:@"There was an error while refreshing forecast, can't refresh forecast" withMessage:nil];
    });
}


// Refresh after Settings or Location
- (void)analyseIfAnyRefreshIsNeeded {
    ForecastData *forecastData = [ForecastData sharedInstance];
    UserHelper *userHelper = [[UserHelper alloc] init];
    
    if (!forecastData.forecast) { // let's execute full refresh
        [self refreshButtonPressed:nil];
        return;
    }
    
    // execute refresh according to what was changed
    
    // 1. temperature unit changed only > let's populate forecaset in UI again
    if ([self didTemperatureUnitSettingChange] && ![self didLocationChange] && ![self didGeneticFileChange]) {
        if (self.alreadyExecutingRefresh) return;
        
        self.alreadyExecutingRefresh = YES;
        _nowUsedTemperatureUnit = _currentlySelectedTemperatureUnit;
        [self prepopulateConditionsAndForecastFromBackground:NO];
        self.alreadyExecutingRefresh = NO;
        return;
    }
    
    
    // 2. check if genetic file changed
    if ([self didGeneticFileChange] && ![self didLocationChange]) {
        if (self.alreadyExecutingRefresh) return;
        if (![InternetConnection internetConnectionIsAvailable]) {
            AlertMessage *alert = [[AlertMessage alloc] init];
            [alert viewController:self showAlertWithTitle:@"Can't refresh forecast" withMessage:NO_INTERNET_CONNECTION_TEXT];
            return;
        }
        
        self.alreadyExecutingRefresh = YES;
        if (_currentlySelectedFile) {
            _nowUsedFile = _currentlySelectedFile;
            [userHelper saveUserGeneticFile:_nowUsedFile];
        }
        [self fillGeneticForecast];
        return;
    }
    
    
    // 3. refresh all (weather + genetic forecasts)
    if (self.alreadyExecutingRefresh) return;
    if (![InternetConnection internetConnectionIsAvailable]) {
        AlertMessage *alert = [[AlertMessage alloc] init];
        [alert viewController:self showAlertWithTitle:@"Can't refresh forecast" withMessage:NO_INTERNET_CONNECTION_TEXT];
        return;
    }
    
    self.alreadyExecutingRefresh = YES;
    _nowUsedLocation = _currentlySelectedLocation;
    forecastData.locationForForecast = _nowUsedLocation;
    
    if (_currentlySelectedFile) {
        _nowUsedFile = _currentlySelectedFile;
        [userHelper saveUserGeneticFile:_nowUsedFile];
    }
    
    LocationWeatherUpdater *locationWeatherUpdater = [LocationWeatherUpdater sharedInstance];
    locationWeatherUpdater.delegate = self;
    [locationWeatherUpdater refreshWeatherForecastForLocation:_nowUsedLocation];
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


- (BOOL)didGeneticFileChange {
    BOOL isChanged = NO;
    
    if (_currentlySelectedFile && ![_nowUsedFile isEqual:_currentlySelectedFile]) {
        isChanged = YES;
    }
    return isChanged;
}


- (void)saveCurrentParameters {
    UserHelper *userHelper = [[UserHelper alloc] init];
    ForecastData *forecastData = [ForecastData sharedInstance];
    
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
    ForecastData *forecastData = [ForecastData sharedInstance];
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



#pragma mark - Genetic Forecast method

- (void)fillGeneticForecast {
    dispatch_async(kMainQueue, ^{
        NSLog(@">>>>> fillGeneticForecast");
        self.geneticForecastText.text = @"";
        ForecastData *forecastData  = [ForecastData sharedInstance];
        UserHelper   *userHelper    = [[UserHelper alloc] init];
        LocationWeatherUpdater *locationWeatherUpdater = [LocationWeatherUpdater sharedInstance];
        NSDictionary *geneticFile   = [userHelper loadUserGeneticFile];
        [self startAnimatingCubePreloader];
        
        [locationWeatherUpdater requestForGeneticForecastWithGeneticFile:geneticFile
                                                          withCompletion:^(NSString *geneticForecast) {
                                                              dispatch_async(kMainQueue, ^{
                                                                  [self stopGeneticTextActivityIndicator];
                                                                  self.alreadyExecutingRefresh = NO;
                                                                  
                                                                  if (geneticForecast && [geneticForecast length] != 0) {
                                                                      self.geneticForecastText.text = geneticForecast;
                                                                      
                                                                      if (![geneticForecast isEqualToString:kAbsentGeneticForecastMessage])
                                                                          forecastData.geneticForecast  = geneticForecast;
                                                                      
                                                                  } else {
                                                                      self.geneticForecastText.text = kAbsentGeneticForecastMessage;
                                                                  }
                                                              });
                                                          }];
    });
}


- (void)fillGeneticForecastInBackground {
    dispatch_async(kMainQueue, ^{
        ForecastData *forecastData  = [ForecastData sharedInstance];
        UserHelper   *userHelper    = [[UserHelper alloc] init];
        NSDictionary *geneticFile   = [userHelper loadUserGeneticFile];
        LocationWeatherUpdater *locationWeatherUpdater = [LocationWeatherUpdater sharedInstance];
        
        [locationWeatherUpdater requestForGeneticForecastWithGeneticFile:geneticFile
                                                          withCompletion:^(NSString *geneticForecast) {
                                                              dispatch_async(kMainQueue, ^{
                                                                  self.alreadyExecutingRefresh = NO;
                                                                  
                                                                  if (geneticForecast && [geneticForecast length] != 0) {
                                                                      self.geneticForecastText.text = geneticForecast;
                                                                      
                                                                      if (![geneticForecast isEqualToString:kAbsentGeneticForecastMessage])
                                                                          forecastData.geneticForecast  = geneticForecast;
                                                                      
                                                                  } else {
                                                                      self.geneticForecastText.text = kAbsentGeneticForecastMessage;
                                                                  }
                                                              });
                                                          }];
    });
}




#pragma mark - Alert popup

- (void)analyseIfAlertIsPresent {
    NSArray *alertsArray;
    NSString *alertsText;
    
    if ([[_forecast allKeys] containsObject:@"alerts"]) {
        alertsArray = [_forecast objectForKey:@"alerts"];
    }
    if (alertsArray && [alertsArray count] > 0) {
        alertsText = [self prepareAlertsTextBasedOnAlertsArray:alertsArray];
    }
    
    if ([alertsText length] != 0) { // alert is present
        [self.alertButtonView setHidden:NO];
        [self.alertButton setHidden:NO];
        _alertsTextForPopup = alertsText;
        
        // update layout
        if (IS_IPHONE) {
            if (IS_IPHONE_6_PLUS) {
                _grayView2BottomToExtendedTextBottom.constant = kGrayView2BottomToExtendedTextBottomWithAlert_IPhonePlusPortrait;
                _extendedTextBottomToGrayView2Bottom.constant = kExtendedTextBottomToGrayView2BottomWithAlert_IPhonePlusLandscape;
            } else
                _grayView2BottomToExtendedTextBottom.constant = kGrayView2BottomToExtendedTextBottomWithAlert_IPhonePortrait;
            
        } else if (IS_IPAD) {
            if ([self isIPadPro13inches]) {
                _grayView2BottomToExtendedTextBottom.constant = kGrayView2BottomToExtendedTextBottomWithAlert_IPadProPortrait;
                _extendedTextBottomToGrayView2Bottom.constant = kExtendedTextBottomToGrayView2BottomWithAlert_IPadProLandscape;
            } else {
                _grayView2BottomToExtendedTextBottom.constant = kGrayView2BottomToExtendedTextBottomWithAlert_IPadPortrait;
                _extendedTextBottomToGrayView2Bottom.constant = kExtendedTextBottomToGrayView2BottomWithAlert_IPadLandscape;
            }
        }
        [self.view setNeedsUpdateConstraints];
        
    } else { // alert is absent
        [self.alertButtonView setHidden:YES];
        [self.alertButton setHidden:YES];
        _alertsTextForPopup = nil;
        
        // update layout
        if (IS_IPHONE) {
            if (IS_IPHONE_6_PLUS) {
                _grayView2BottomToExtendedTextBottom.constant = kGrayView2BottomToExtendedTextBottomWithNoAlert_IPhonePlusPortrait;
                _extendedTextBottomToGrayView2Bottom.constant = kExtendedTextBottomToGrayView2BottomWithNoAlert_IPhonePlusLandscape;
            } else
                _grayView2BottomToExtendedTextBottom.constant = kGrayView2BottomToExtendedTextBottomWithNoAlert_IPhonePortrait;
            
        } else if ([self isIPadPro13inches]) {
            _grayView2BottomToExtendedTextBottom.constant = kGrayView2BottomToExtendedTextBottomWithNoAlert_IPadProPortrait;
            _extendedTextBottomToGrayView2Bottom.constant = kExtendedTextBottomToGrayView2BottomWithNoAlert_IPadProLandscape;
        } else {
            _grayView2BottomToExtendedTextBottom.constant = kGrayView2BottomToExtendedTextBottomWithNoAlert_IPadPortrait;
            _extendedTextBottomToGrayView2Bottom.constant = kExtendedTextBottomToGrayView2BottomWithNoAlert_IPadLandscape;
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
- (void)popupAlertViewController:(UIViewController *)controller closeButtonPressed:(id)sender {
    dispatch_async(kMainQueue, ^{
        [controller dismissViewControllerAnimated:YES completion:nil];
    });
}



#pragma mark - UIApplication states
- (void)applicationDidBecomeActiveNotification {
    dispatch_async(kMainQueue, ^{
        NSLog(@"applicationDidBecomeActiveNotification");
        //[[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:@"LOCATION_AND_WEATHER_WERE_UPDATED_IN_BACKGROUND_NOTIFICATION_KEY"];
        [self playVideo];
        [self animation];
        [self startAnimationTimer];
        
        if (!self.dateOfLastRefresh)
            [self launchFullRefresh];
        else {
            NSDate *currentDate = [NSDate date];
            NSInteger seconds   = [currentDate timeIntervalSinceDate:self.dateOfLastRefresh];
            NSInteger minutes   = (int)(floor(seconds / 60));
            if (minutes > 15)
                [self launchFullRefresh];
        }
    });
}

- (void)launchFullRefresh {
    LocationWeatherUpdater *locationWeatherUpdater = [LocationWeatherUpdater sharedInstance];
    if (![InternetConnection internetConnectionIsAvailable]) return;
    if (self.alreadyExecutingRefresh) return;
    
    self.alreadyExecutingRefresh = YES;
    locationWeatherUpdater.delegate = self;
    [locationWeatherUpdater checkLocationAvailabilityAndStart];
}


- (void)applicationWillResignActiveNotification {
    [self pauseVideo];
    
    [self cancelAnimationTimer];
    [self.sequencingLogo.layer removeAllAnimations];
}



// method to update UI in background only
- (void)locationAndWeatherWereUpdatedInBackground {
    dispatch_async(kMainQueue, ^{
        NSLog(@">>> ForecastVC: locationAndWeatherWereUpdatedInBackground");
        
        self.forecast = [ForecastData sharedInstance].forecast;
        [self showAllElements];
        
        [self prepopulateConditionsAndForecastFromBackground:YES];
        [self adjustExtendedForecastLabel];
        
        [self initializeAndAddVideoToView];
        [self handleVideo:[VideoHelper isVideoWhite]];
        
        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
            [self playVideo];
            [self fillGeneticForecast];
            
        } else {
            [self pauseVideo];
            // [self fillGeneticForecastInBackground];
        }
    });
}




#pragma mark - Show / Hide elements
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



#pragma mark - AlertMessageDialogDelegate
- (void)refreshButtonPressed {
    [self refreshButtonPressed:nil];
}



#pragma mark - Location name adjustment helper methods
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




#pragma mark - Extended Forecast helper methods

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




#pragma mark - Other helper methods

- (BOOL)isIPadPro13inches {
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




#pragma mark - Refresh Button Animation

- (void)startSpinningRefreshButton {
    dispatch_async(kMainQueue, ^{
        if (!self.animatingRefreshButton) {
            self.animatingRefreshButton = YES;
            [self spinningRefreshButtonWithOptions:UIViewAnimationOptionCurveEaseIn];
        }
        
        if (self.cubePreloader.animating) [self stopAnimatingCubePreloader];
    });
}

- (void)stopSpinningRefreshButton {
    // set the flag to stop spinning after one last 90 degree increment
    self.animatingRefreshButton = NO;
}

- (void)spinningRefreshButtonWithOptions:(UIViewAnimationOptions)options {
    UIView *itemView = [self.navigationItem.rightBarButtonItem performSelector:@selector(view)];
    UIImageView *refreshButton = [itemView.subviews firstObject];
    refreshButton.contentMode = UIViewContentModeCenter;
    refreshButton.autoresizingMask = UIViewAutoresizingNone;
    refreshButton.clipsToBounds = NO;
    
    [UIView animateWithDuration:1
                          delay:0
                        options:options
                     animations:^{
                         refreshButton.transform = CGAffineTransformRotate(refreshButton.transform, DEGREES_TO_RADIANS(180));
                         refreshButton.transform = CGAffineTransformRotate(refreshButton.transform, DEGREES_TO_RADIANS(180));
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             
                             if (self.animatingRefreshButton) {
                                 // if flag still set, keep spinning with constant speed
                                 [self spinningRefreshButtonWithOptions:UIViewAnimationOptionCurveLinear];
                                 
                             } else {
                                 // one last spin, with deceleration
                                 refreshButton.transform = CGAffineTransformIdentity;
                                 // [self spinningWithOptions:UIViewAnimationOptionCurveEaseOut];
                             }
                         }
                     }];
}




#pragma mark - Genetic text Cube Animation

- (void)initCubePreloader {
    [self.cubePreloader setAnimationImages:[CubePreloader arrayWithUIImages]];
    [self.cubePreloader setAnimationDuration:2];
}

- (void)startAnimatingCubePreloader {
    dispatch_async(kMainQueue, ^{
        if (self.cubePreloader.animating) [self stopAnimatingCubePreloader];
        
        self.geneticForecastText.text = @"\n\n";
        [self.sequencingLogo setHidden:YES];
        [self.poweredBy setHidden:YES];

        [self.cubePreloader startAnimating];
    });
}


- (void)stopGeneticTextActivityIndicator {
    dispatch_async(kMainQueue, ^{
        [self.sequencingLogo setHidden:NO];
        [self.poweredBy setHidden:NO];
        [self stopAnimatingCubePreloader];
    });
}


- (void)stopAnimatingCubePreloader {
    [self.cubePreloader stopAnimating];
}





#pragma mark - Memory handler

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
