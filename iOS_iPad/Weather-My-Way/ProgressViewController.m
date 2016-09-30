//
//  ProgressViewController.m
//  Copyright © 2016 Sequencing. All rights reserved.
//


#import "ProgressViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreLocation/CoreLocation.h>
#import "AlertMessage.h"
#import "SQFilesAPI.h"
#import "SQAuthResult.h"
#import "SQToken.h"
#import "AppDelegate.h"
#import "UserHelper.h"
#import "WundergroundHelper.h"
#import "MBProgressHUD.h"
#import "SWRevealViewController.h"
#import "ForecastData.h"
#import "VideoHelper.h"
#import "PrepareForecastViewController.h"
#import "UserAccountHelper.h"
#import "InternetConnection.h"

#define kMainQueue dispatch_get_main_queue()


@interface ProgressViewController () <CLLocationManagerDelegate, AlertMessageDialogDelegate>

// properties for videoPlayer
@property (nonatomic) AVPlayer  *avPlayer;
@property (nonatomic) UIView    *videoPlayerView;
@property (nonatomic) AVPlayerLayer *videoLayer;

//@property (nonatomic) BOOL wasRunBefore;
@property (nonatomic) MBProgressHUD *activityProgress;

@property (weak, nonatomic) IBOutlet UILabel *activityText;
@property (weak, nonatomic) IBOutlet UIImageView *imagePreloader;

@property (assign, nonatomic) BOOL alreadyStartedUserAccountRequest;
@property (assign, nonatomic) BOOL alreadyGotLocationPoint;
@property (assign, nonatomic) BOOL alreadyGotUserGPSLocation;
@property (assign, nonatomic) BOOL alreadyGotUserAccountInfo;

@property (strong, nonatomic) UserHelper *userHelper;
@property (strong, nonatomic) UserAccountHelper *userAccountHelper;

@end



@implementation ProgressViewController {
    CLLocationManager   *locationManager;
    CLGeocoder          *geocoder;
    CLPlacemark         *placemark;
    CLLocation          *currentLocationFromLocationManager;
}

- (UserHelper *)userHelper {
    if (_userHelper == nil) {
        _userHelper = [[UserHelper alloc] init];
    }
    return _userHelper;
}

- (UserAccountHelper *)userAccountHelper {
    if (_userAccountHelper == nil) {
        _userAccountHelper = [[UserAccountHelper alloc] init];
    }
    return _userAccountHelper;
}



#pragma mark -
#pragma mark View Lyfecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // init location manager
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
    
    self.alreadyStartedUserAccountRequest = NO;
    self.alreadyGotLocationPoint = NO;
    self.alreadyGotUserGPSLocation = NO;
    self.alreadyGotUserAccountInfo = NO;
    
    // setup video and add observes
    [self initializeAndAddVideoToView];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // launch video
    [self playVideo];
    [self addNotificationObserves];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self startCubePreloader];
    _activityText.text = @"Analyzing your genes and the weather, together...";
    
    // check user account first
    if (!_alreadyStartedUserAccountRequest) {
        _alreadyStartedUserAccountRequest = YES;
        [self checkForUserAccount];
    }
}


- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self updateVideoLayerFrame];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self pauseVideo];
}


- (void)dealloc {
    NSLog(@"ProgressVC: dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self deallocateAndRemoveVideoFromView];
}



#pragma mark -
#pragma mark Videoplayer Methods

- (void)initializeAndAddVideoToView {
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


- (void)updateVideoLayerFrame {
    // NSLog(@"LoginVC: orientationChanged");
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


- (void)deallocateAndRemoveVideoFromView {
    [_avPlayer pause];
    _avPlayer = nil;
    [_videoPlayerView removeFromSuperview];
}


- (void)addNotificationObserves {
    // add observer for video playback
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(itemDidFinishPlaying:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[self.avPlayer currentItem]];
    
    // add observer for application state (in order to play pause video or remove it)
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pauseVideo)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playVideo)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}



#pragma mark -
#pragma mark User account information

- (void)checkForUserAccount {
    SQToken *token = [self.userHelper loadUserToken];
    if ([InternetConnection internetConnectionIsAvailable] && [token.accessToken length] != 0) {
        NSString *oldDeviceToken = [self.userHelper loadDeviceTokenOld];
        NSString *newDeviceToken = [self.userHelper loadDeviceToken];
        
        NSDictionary *parameters = @{@"accessToken"   : token.accessToken,
                                     @"expiresIn"     : token.expirationDate,
                                     @"tokenType"     : token.tokenType,
                                     @"scope"         : token.scope,
                                     @"refreshToken"  : token.refreshToken,
                                     @"oldDeviceToken": ([oldDeviceToken length] != 0) ? oldDeviceToken : [NSNull null],
                                     @"newDeviceToken": ([newDeviceToken length] != 0) ? newDeviceToken : [NSNull null],
                                     @"sendPush"      : [self proccessPushSettings],
                                     @"deviceType"    : @(1)};
        
        [self.userAccountHelper retrieveUserSettings:parameters
                                      withCompletion:^(NSDictionary *userAccountSettings) {
                                          
                                          if (userAccountSettings) {
                                              [self.userAccountHelper processUserAccountSettings:userAccountSettings];
                                              
                                              if ([InternetConnection internetConnectionIsAvailable])
                                                  [self.userAccountHelper sendUserSettingsToServer];
                                              NSLog(@"[ProgressVC] send User Settings To Server");
                                              
                                              // call whatever method is needed next according to flow now
                                              [self callWhatIsNeededByGuestUserFlow];
                                              
                                          } else {
                                              // launch user location autodetection in background - as we have received no settings from server
                                              [self autodetectLocationCheckAvailabilityAndStart];
                                          }
                                      }];
    } else {
        // launch user location autodetection in background - as we have received no settings from server
        [self autodetectLocationCheckAvailabilityAndStart];
    }
}

- (NSString *)proccessPushSettings {
    NSString *pushSetting;
    NSNumber *pushSettingValue = [self.userHelper loadSettingIPhoneDailyForecast];
    if (pushSettingValue) {
        switch ([pushSettingValue intValue]) {
            case 0:
                pushSetting = @"false";
                break;
            case 1:
                pushSetting = @"true";
                break;
            default: {
                [self.userHelper saveSettingIPhoneDailyForecast:[NSNumber numberWithBool:YES]];
                pushSetting = @"true";
            }   break;
        }
    } else {
        [self.userHelper saveSettingIPhoneDailyForecast:[NSNumber numberWithBool:YES]];
        pushSetting = @"true";
    }
    return pushSetting;
}



#pragma mark -
#pragma mark Location / File / Forecast manager

- (void)callWhatIsNeededByGuestUserFlow {
    NSDictionary *currentLocation = [self.userHelper loadUserCurrentLocation];
    NSDictionary *geneticFile = [self.userHelper loadUserGeneticFile];
    
    if (![self.userHelper locationIsEmpty:currentLocation] && geneticFile) {
        // we can open prepareForecastVC now (as we have both location as genetic file known)
        self.alreadyGotUserAccountInfo = YES;
        [self showPrepareForecastViewController];
        
    } else if (![self.userHelper locationIsEmpty:currentLocation]) {
        // launch file selector as we already have user location
        [self showFileSelector];
        
    } else {
        // launch user location autodetection now (as we don't have needed information, at least location)
        [self autodetectLocationCheckAvailabilityAndStart];
    }
}




#pragma mark -
#pragma mark Auto-detect Location, CLLocationManagerDelegate, Define location details

- (void)autodetectLocationCheckAvailabilityAndStart {
    if ([CLLocationManager locationServicesEnabled]) {
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        switch (status) {
                
            case kCLAuthorizationStatusDenied: { // If the status is denied or only granted for when in use, display an alert
                [self showLocationViewController];
            } break;
                
            case kCLAuthorizationStatusNotDetermined: {
                [locationManager requestAlwaysAuthorization];
                [self launchAutodetectLocation];
            } break;
                
            case kCLAuthorizationStatusAuthorizedWhenInUse: {
                [locationManager requestAlwaysAuthorization];
                [self launchAutodetectLocation];
            } break;
                
            case kCLAuthorizationStatusAuthorizedAlways: {
                [self launchAutodetectLocation];
            } break;
                
            default: {
                [self showLocationViewController];
            } break;
        }
        
    } else {
        [self showLocationViewController];
    }
}


- (void)launchAutodetectLocation {
    self.alreadyGotLocationPoint = NO;
    [locationManager requestLocation];
}


// CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if (!self.alreadyGotLocationPoint) {
        self.alreadyGotLocationPoint = YES;
        
        dispatch_async(kMainQueue, ^{
            currentLocationFromLocationManager = nil;
            AlertMessage *alert = [[AlertMessage alloc] init];
            alert.delegate = self;
            [alert viewController:self
               showAlertWithTitle:@"Failed to get your location"
                      withMessage:@"Do you want to try auto-detect one more time or enter location manually?"
               withTryAgainAction:@"Try again"
               withManuallyAction:@"Manually"];
        });
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    if (!self.alreadyGotLocationPoint) {
        self.alreadyGotLocationPoint = YES;
        
        if (locations && [locations count] > 0) { // CLLocation is defined
            NSString *latitudeLabel = [NSString stringWithFormat:@"%.8f", [locations lastObject].coordinate.latitude];
            NSString *longitudeLabel = [NSString stringWithFormat:@"%.8f", [locations lastObject].coordinate.longitude];
            NSLog(@"latitude: %@", latitudeLabel);
            NSLog(@"longitude: %@", longitudeLabel);
            
            // let's try to define current location details
            [self defineLocationDetails:[locations lastObject]];
            
        } else { // currentLocation is nil, we can't define any information
            dispatch_async(kMainQueue, ^{
                currentLocationFromLocationManager = nil;
                AlertMessage *alert = [[AlertMessage alloc] init];
                alert.delegate = self;
                [alert viewController:self
                   showAlertWithTitle:@"Failed to get your location"
                          withMessage:@"Do you want to try auto-detect one more time or enter location manually?"
                   withTryAgainAction:@"Try again"
                   withManuallyAction:@"Manually"];
            });
        }
    } else {
        NSLog(@"ProgressVC: already got location point!!!");
    }
}


// Define location details
- (void)defineLocationDetails:(CLLocation *)currentLocation {
    currentLocationFromLocationManager = currentLocation;
    if (_imagePreloader == nil) {
        [self startCubePreloader];
    }
    // try to define location details by wunderground service
    if ([InternetConnection internetConnectionIsAvailable]) {
        WundergroundHelper *wundergroundHelper = [[WundergroundHelper alloc] init];
        [wundergroundHelper wundergroundGeolookupDefineLocationDetailsBasedOnLocationCoordinates:currentLocation withResult:^(NSDictionary *location) {
            
            if (location != nil && [[location objectForKey:@"id"] length] != 0) { // location details are defined
                NSString *locationCity = [location objectForKey:@"city"];
                NSString *locationStateOrCountry = @"";
                NSString *locationID = [location objectForKey:@"id"];
                
                if ([[location objectForKey:@"state"] length] != 0) {
                    locationStateOrCountry = [location objectForKey:@"state"];
                } else {
                    locationStateOrCountry = [location objectForKey:@"country"];
                }
                
                // save defined location details into userDefaults
                NSDictionary *location = [NSDictionary dictionaryWithObjectsAndKeys:
                                          locationCity,             LOCATION_CITY_DICT_KEY,
                                          locationStateOrCountry,   LOCATION_STATE_COUNTRY_DICT_KEY,
                                          locationID,               LOCATION_ID_DICT_KEY, nil];
                [self.userHelper saveUserCurrentLocation:location];
                self.alreadyGotUserGPSLocation = YES;
                
                // send selected location to user account on server
                if ([InternetConnection internetConnectionIsAvailable])
                    [self sendLocationInfoToServer:location];
                
                // show File Selector now in UI or already show prepareforecast
                [self callFileSelectorIfNeededOrPrepareForecastVC];
                
            } else { // wunderground service returned an error > time to show alert message
                dispatch_async(kMainQueue, ^{
                    AlertMessage *alert = [[AlertMessage alloc] init];
                    alert.delegate = self;
                    [alert viewController:self
                       showAlertWithTitle:@"Failed to get your location details"
                              withMessage:@"Do you want to try auto-detect or enter location manually?"
                       withTryAgainAction:@"Try again"
                       withManuallyAction:@"Manually"];
                });
            }
        }];
        
    } else {
        AlertMessage *alert = [[AlertMessage alloc] init];
        alert.delegate = self;
        [alert viewController:self
           showAlertWithTitle:NO_INTERNET_CONNECTION_TEXT
                  withMessage:@"Check your internet connection and either try auto-detect one more time or enter location manually"
           withTryAgainAction:@"Try again"
           withManuallyAction:@"Manually"];
    }
}



#pragma mark -
#pragma mark AlertMessageDialogDelegate

- (void)tryAgainButtonPressed {
    [self launchAutodetectLocation];
}


- (void)manuallyButtonPressed {
    [self showLocationViewController];
}



#pragma mark -
#pragma mark LocationVC, LocationViewControllerDelegate

- (void)showLocationViewController {
    dispatch_async(kMainQueue, ^{
        [self stopCubePreloader];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Location" bundle:nil];
        UINavigationController *navigationVC = (UINavigationController *)[storyboard instantiateInitialViewController];
        navigationVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        LocationViewController *locationVC = [navigationVC viewControllers][0];
        locationVC.backButton = NO;
        locationVC.delegate = self;
        [self presentViewController:navigationVC animated:YES completion:nil];
    });
}


- (void)locationViewController:(LocationViewController *)controller didSelectLocation:(NSDictionary *)location {
    dispatch_async(kMainQueue, ^{
        controller.delegate = nil;
        [self stopCubePreloader];
        [self startCubePreloader];
        
        // send selected location to user account on server
        if ([InternetConnection internetConnectionIsAvailable])
            [self sendLocationInfoToServer:location];
        
        // dissmiss Location view
        [controller dismissViewControllerAnimated:NO completion:^{
            // show File Selector now in UI or already show prepareforecast
            [self callFileSelectorIfNeededOrPrepareForecastVC];
        }];
    });
}


- (void)sendLocationInfoToServer:(NSDictionary *)location {
    NSLog(@"sendSelectedLocationInfoWithParameters");
    if (location) {
        NSString    *locationID = [location objectForKey:LOCATION_ID_DICT_KEY];
        NSDictionary *parameters = @{@"city" : locationID,
                                     @"token": [self.userHelper loadUserToken].accessToken};
        [self.userAccountHelper sendSelectedLocationInfoWithParameters:parameters];
    }
}




#pragma mark -
#pragma mark FileSelector, SQFileSelectorProtocol

- (void)callFileSelectorIfNeededOrPrepareForecastVC {
    NSDictionary *geneticFile = [self.userHelper loadUserGeneticFile];
    
    if (!geneticFile) {
        // launch file selector as we have no information about genetic file
        [self showFileSelector];
        
    } else {
        // we can open prepareForecastVC now (as we have already have genetic file known)
        [self showPrepareForecastViewController];
    }
}


- (void)showFileSelector {
    if (_imagePreloader == nil) {
        [self startCubePreloader];
    }
    
    // load files assigned to user account from server
    SQFilesAPI *filesAPI = [SQFilesAPI sharedInstance];
    [filesAPI setFileSelectedHandler:self];
    filesAPI.closeButton = NO;
    
    if ([InternetConnection internetConnectionIsAvailable]) {
        SQToken *token = [self.userHelper loadUserToken];
        
        if (token.accessToken != nil) { // token is valid > can proceed with files
            [filesAPI withToken:token.accessToken loadFiles:^(BOOL success) {
                
                dispatch_async(kMainQueue, ^{
                    if (success) {
                        // assign video file name for file selector
                        VideoHelper *videoHelper = [[VideoHelper alloc] init];
                        NSString *videoName = [videoHelper getRandomVideoName];
                        filesAPI.videoFileName = videoName;
                        
                        // open file selector view
                        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TabbarFileSelector" bundle:nil];
                        UINavigationController *fileSelectorVC = (UINavigationController *)[storyboard instantiateInitialViewController];
                        fileSelectorVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                        [self presentViewController:fileSelectorVC animated:YES completion:nil];
                        
                    } else { // error while files loading
                        NSLog(@"ProgressVC: !Error: Can't load files assigned to account from server");
                        [filesAPI setFileSelectedHandler:nil];
                        
                        // open prepareForecastVC
                        [self showPrepareForecastViewController];
                    }
                });
            }];
        } else { // token is corrupted > can't proceed with files
            NSLog(@"ProgressVC: !Error: token.accessToken is empty. Can't load files");
            [filesAPI setFileSelectedHandler:nil];
            
            // open prepareForecastVC
            [self showPrepareForecastViewController];
        }
    } else { // token is corrupted > can't proceed with files
        NSLog(@"ProgressVC: !Error: no internet connection. Can't load genetic files");
        [filesAPI setFileSelectedHandler:nil];
        
        // open prepareForecastVC
        [self showPrepareForecastViewController];
    }
}


// SQFileSelectorProtocol
- (void)handleFileSelected:(NSDictionary *)file {
    [self dismissViewControllerAnimated:YES completion:nil];
    SQFilesAPI *fileAPI = [SQFilesAPI sharedInstance];
    [fileAPI setFileSelectedHandler:nil];
    
    // save selected file into user defaults
    [self.userHelper saveUserGeneticFile:file];
    NSLog(@"ProgressVC: saved selected file into userDefaults");
    
    // send selected file into user account on server
    if ([InternetConnection internetConnectionIsAvailable] && file && [[file objectForKey:@"Id"] length] != 0) {
        NSString *fileName;
        if ([[file objectForKey:@"FileCategory"] isEqualToString:@"Community"] ) {
            fileName = [NSString stringWithFormat:@"%@ - %@", [file objectForKey:@"FriendlyDesc1"], [file objectForKey:@"FriendlyDesc2"]];
        } else {
            fileName = [file objectForKey:@"Name"];
        }
        NSDictionary *parameters = @{@"selectedId"  : [file objectForKey:@"Id"],
                                     @"selectedName": [fileName stringByReplacingOccurrencesOfString: @" " withString: @"%20"],
                                     @"token"       : [self.userHelper loadUserToken].accessToken};
        [self.userAccountHelper sendSelectedGeneticFileInfoWithParameters:parameters];
        NSLog(@"sendSelectedGeneticFileInfoWithParameters");
    }
    
    // open prepareForecastVC
    [self showPrepareForecastViewController];
}



#pragma mark -
#pragma mark Show PrepareForecastViewController

- (void)showPrepareForecastViewController {
    dispatch_async(kMainQueue, ^{
        [self stopCubePreloader];
        PrepareForecastViewController *prepareForecastVC = [[PrepareForecastViewController alloc] initWithNibName:@"PrepareForecastViewController" bundle:nil];
        if (self.alreadyGotUserAccountInfo)
            prepareForecastVC.alreadyGotUserAccountInfo = YES;
        if (self.alreadyGotUserGPSLocation)
            prepareForecastVC.alreadyGotUserGPSLocation = YES;
        
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate.window setRootViewController:prepareForecastVC];
        [appDelegate.window makeKeyAndVisible];
    });
}



#pragma mark -
#pragma mark Preloader

- (void)startCubePreloader {
    NSArray *imageNames = @[@"PR_3_00000", @"PR_3_00001", @"PR_3_00002", @"PR_3_00003", @"PR_3_00004",
                            @"PR_3_00005", @"PR_3_00006", @"PR_3_00007", @"PR_3_00008", @"PR_3_00009",
                            @"PR_3_00010", @"PR_3_00011", @"PR_3_00012", @"PR_3_00013", @"PR_3_00014",
                            @"PR_3_00015", @"PR_3_00016", @"PR_3_00017", @"PR_3_00018", @"PR_3_00019",
                            @"PR_3_00020", @"PR_3_00021", @"PR_3_00022", @"PR_3_00023", @"PR_3_00024",
                            @"PR_3_00025", @"PR_3_00026", @"PR_3_00027", @"PR_3_00028", @"PR_3_00029",
                            @"PR_3_00030", @"PR_3_00031", @"PR_3_00032", @"PR_3_00033", @"PR_3_00034",
                            @"PR_3_00035", @"PR_3_00036", @"PR_3_00037", @"PR_3_00038", @"PR_3_00039",
                            @"PR_3_00040", @"PR_3_00041", @"PR_3_00042", @"PR_3_00043", @"PR_3_00044",
                            @"PR_3_00045", @"PR_3_00046", @"PR_3_00047", @"PR_3_00048", @"PR_3_00049",
                            @"PR_3_00050", @"PR_3_00051"];
    
    NSMutableArray *images = [[NSMutableArray alloc] init];
    for (int i = 0; i < imageNames.count; i++) {
        [images addObject:[UIImage imageNamed:[imageNames objectAtIndex:i]]];
    }
    
    dispatch_async(kMainQueue, ^{
        _imagePreloader.animationImages = images;
        _imagePreloader.animationDuration = 2;
        [_imagePreloader startAnimating];
    });
}

- (void)stopCubePreloader {
    dispatch_async(kMainQueue, ^{
        [_imagePreloader stopAnimating];
        _imagePreloader.animationImages = nil;
    });
}



#pragma mark -
#pragma mark Memory handler

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



@end
