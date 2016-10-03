//
//  PrepareForecastViewController.m
//  Copyright © 2016 Sequencing. All rights reserved.
//


#import "PrepareForecastViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "SQToken.h"
#import "SQOAuth.h"
#import "UserHelper.h"
#import "UserAccountHelper.h"
#import "InternetConnection.h"
#import "SQServerManager.h"
#import "WundergroundHelper.h"
#import "MBProgressHUD.h"
#import "SWRevealViewController.h"
#import "ForecastData.h"
#import "VideoHelper.h"
#import "GeneticForecastHelper.h"


#define kMainQueue dispatch_get_main_queue()



@interface PrepareForecastViewController () <CLLocationManagerDelegate>

@property (nonatomic) MBProgressHUD *activityProgress;
@property (weak, nonatomic) IBOutlet UIImageView *imagePreloader;

// properties for videoPlayer
@property (nonatomic) AVPlayer  *avPlayer;
@property (nonatomic) UIView    *videoPlayerView;
@property (nonatomic) AVPlayerLayer *videoLayer;

@property (assign, nonatomic) BOOL alreadyGotLocationPoint;

@property (strong, nonatomic) UserHelper *userHelper;
@property (strong, nonatomic) UserAccountHelper *userAccountHelper;

@end



@implementation PrepareForecastViewController {
    CLLocationManager   *locationManager;
    CLGeocoder          *geocoder;
    CLPlacemark         *placemark;
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
    NSLog(@"PrepareForecastVC: viewDidLoad");
    // setup video and add observes
    [self initializeAndAddVideoToView];
    
    // init location manager
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
    self.alreadyGotLocationPoint = NO;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self playVideo];
    [self addNotificationObserves];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self startCubePreloader];
    
    // reset applicationIconBadgeNumber
    if ([UIApplication sharedApplication].applicationIconBadgeNumber > 0) {
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    }

    // processUserAccountInfo
    [self startProcessingUserAccountInfo];
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
    NSLog(@"PrepareForecastVC: dealloc");
    [self stopCubePreloader];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self deallocateAndRemoveVideoFromView];
}



#pragma mark -
#pragma mark Videoplayer Methods

- (void)initializeAndAddVideoToView {
    NSLog(@"PrepareForecastVC: initialize video player with layer");
    // set up videoPlayer with local video file
    ForecastData *forecastData = [[ForecastData alloc] sharedInstance];
    VideoHelper *videoHelper = [[VideoHelper alloc] init];
    
    NSString *videoName = [self.userHelper loadKnownVideoFileName];
    
    if ([videoName length] == 0 || !videoName) {
        if ([forecastData.weatherType length] != 0 && [forecastData.dayNight length] != 0) {
            videoName = [videoHelper getVideoNameBasedOnWeatherType:forecastData.weatherType AndDayNight:forecastData.dayNight];
        } else {
            videoName = [videoHelper getRandomVideoName];
        }
    }
    
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
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}



#pragma mark -
#pragma mark Process user account info

- (void)startProcessingUserAccountInfo {
    // we need to verify token, update it or registrate in system
    [self processTokenWithCompletion:^(BOOL success) {
        if (success) {
            if (!self.alreadyGotUserAccountInfo) {
                // retreive user account settings
                NSLog(@"[PrepareForecastVC] getting user settings");
                [self checkForUserAccountWithCompletion:^{
                    // get user account info
                    [self retreiveUserAccountNameAndEmail];
                    // get current user gps location
                    [self autodetectLocationCheckAvailabilityAndStart];
                }];
                
            } else {
                // get user account info
                [self retreiveUserAccountNameAndEmail];
                // get current user gps location
                [self autodetectLocationCheckAvailabilityAndStart];
            }
            
        } else { // processTokenWithCompletion - fail > log out
            dispatch_async(kMainQueue, ^{
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                UINavigationController *loginNavigationVC = (UINavigationController *)[storyboard instantiateInitialViewController];
                LoginViewController *loginViewController = [loginNavigationVC viewControllers][0];
                [loginViewController setMessageTextForErrorCase:@"Sorry, there was an error while getting authorized user data.\nPlease reauthorize"];
                AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                [appDelegate.window setRootViewController:loginNavigationVC];
                [appDelegate.window makeKeyAndVisible];
            });
        }
    }];
}



#pragma mark -
#pragma mark User account information

- (void)checkForUserAccountWithCompletion:(void (^)(void))completion {
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
                                          if (userAccountSettings)
                                              [self.userAccountHelper processUserAccountSettings:userAccountSettings];
                                          completion();
                                      }];
    } else {
        completion();
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
#pragma mark Token related methods

- (void)processTokenWithCompletion:(void (^)(BOOL success))completion {
    if ([self isTokenUpToDay]) {
        NSLog(@"PrepareForecastVC: token is valid > registrate token in system and launch timer updater");
        // registrate token in system and launch timer updater
        [self registrateUserTokenAndLaunchUpdaterTimerWithCompletion:^(BOOL success) {
            if (success) {
                completion(YES);
            } else {
                completion(NO);
            }
        }];
        
    } else {
        NSLog(@"PrepareForecastVC: token is expired > execute refresh token request");
        if ([InternetConnection internetConnectionIsAvailable]) {
            // execute refresh token request
            [self updateUserTokenWithCompletion:^(BOOL success) {
                if (success) {
                    completion(YES);
                } else {
                    completion(NO);
                }
            }];
        } else {
            // no internet connection
            completion(NO);
        }
    }
}


- (BOOL)isTokenUpToDay {
    SQToken *token = [self.userHelper loadUserToken];
    NSDate *nowDate = [NSDate date];
    NSDate *expDate = token.expirationDate;
    
    if ([nowDate compare:expDate] == NSOrderedDescending) {
        // token is expired
        return NO;
    } else {
        // token is valid
        return YES;
    }
}


- (void)updateUserTokenWithCompletion:(void (^)(BOOL success))completion {
    NSLog(@"PrepareForecastVC: updateUserTokenWithCompletion");
    SQToken *token = [self.userHelper loadUserToken];
    
    // verify if old token is valid before refresh token request
    if (token.refreshToken != nil) {
        
        // old token is valid > can execute refresh token request
        [[SQOAuth sharedInstance] withRefreshToken:token updateAccessToken:^(SQToken *updatedToken) {
            // verify if updated token is valid before save it into userDefaults
            if (updatedToken.accessToken != nil) {
                if (updatedToken.refreshToken != nil) {
                    // updatedToken is valid > save updatedToken into userDefaults
                    [self.userHelper saveUserToken:updatedToken];
                    NSLog(@"PrepareForecastVC: updatedToken is valid > saved updatedToken into user defaults");
                    completion(YES);
                    
                } else {    // updatedToken.refreshToken is nil
                    NSLog(@"PrepareForecastVC: updatedToken.refreshToken is nil! Can't save updatedToken");
                    completion(NO);
                }
            } else {    // updatedToken.accessToken is nil
                NSLog(@"PrepareForecastVC: updatedToken.accessToken is nil! Can't save updatedToken");
                completion(NO);
            }
        }];
    } else {    // token.refreshToken is nil
        NSLog(@"PrepareForecastVC: old token.refreshToken is nil! Can't execute refresh token request");
        completion(NO);
    }
}


- (void)registrateUserTokenAndLaunchUpdaterTimerWithCompletion:(void (^)(BOOL success))completion {
    NSLog(@"PrepareForecastVC: registrateUserTokenAndLaunchUpdaterTimerWithCompletion");
    SQToken *token = [self.userHelper loadUserToken];
    // verify if token is valid before registrate it in system
    if (token.accessToken != nil) {
        if (token.refreshToken != nil) {
            NSLog(@"token.accessToken: %@", token.accessToken);
            NSLog(@"token.refreshToken: %@", token.refreshToken);
            
            // token is valid > registrate it and launch updater timer
            NSLog(@"PrepareForecastVC: access token is valid > launch token timer updater");
            [[SQOAuth sharedInstance] launchTokenTimerUpdateWithToken:token];
            completion(YES);
            
        } else {    // token.refreshToken is nil
            NSLog(@"PrepareForecastVC: token.refreshToken is nil! Can't registrate token");
            completion(NO);
        }
    } else {    // token.accessToken is nil
        NSLog(@"PrepareForecastVC: token.accessToken is nil! Can't registrate token");
        completion(NO);
    }
}



#pragma mark -
#pragma mark Retreive User Account Name and Email

- (void)retreiveUserAccountNameAndEmail {
    NSLog(@"PrepareForecastVC: processUserAccountInfo");
    if ([InternetConnection internetConnectionIsAvailable]) {
        NSString *emailAddressForForecast = [self.userHelper loadSettingEmailAddressForForecast];
        
        [self requestForUserAccountInformation:^(NSDictionary *accountInfo) {
            if (accountInfo) {
                [self.userHelper saveUserAccountEmail:[accountInfo objectForKey:@"email"]];
                
                if ([emailAddressForForecast length] == 0) {
                    [self.userHelper saveSettingEmailAddressForForecast:[accountInfo objectForKey:@"email"]];
                }
            }
        }];
    }
}

- (void)requestForUserAccountInformation:(void (^)(NSDictionary *accountInfo))completion {
    NSLog(@"PrepareForecastVC: requestForUserAccountInformation");
    SQToken *token = [self.userHelper loadUserToken];
    if ([token.accessToken length] != 0) {
        [self.userAccountHelper requestForUserAccountInformationWithAccessToken:token.accessToken withResult:^(NSDictionary *accountInfo) {
            NSLog(@"%@", accountInfo);
            NSArray *accountInfoAllKeys = [accountInfo allKeys];
            
            if (accountInfo && [accountInfoAllKeys containsObject:@"username"] && [accountInfoAllKeys containsObject:@"email"]) {
                completion(accountInfo);
            } else {
                NSLog(@"PrepareForecastVC: accountInfo request result server is not valid");
                completion(nil);
            }
        }];
    } else {
        NSLog(@"PrepareForecastVC: access token is empty");
        completion(nil);
    }
}




#pragma mark -
#pragma mark Auto-detect Location, CLLocationManagerDelegate, Define location details

- (void)autodetectLocationCheckAvailabilityAndStart {
    NSLog(@"[PrepareForecastVC] identify user gps location");
    if ([CLLocationManager locationServicesEnabled]) {
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        switch (status) {
                
            case kCLAuthorizationStatusDenied: {
                // skip getting current gps location > start getting weather and genetic forecast
                [self manageWeatherAndGeneticForecasts];
            }   break;
                
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
                // skip getting current gps location > start getting weather and genetic forecast
                [self manageWeatherAndGeneticForecasts];
            } break;
        }
    } else {
        // skip getting current gps location > start getting weather and genetic forecast
        [self manageWeatherAndGeneticForecasts];
    }
}

- (void)launchAutodetectLocation {
    [locationManager requestLocation];
}


// CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if (!self.alreadyGotLocationPoint) {
        self.alreadyGotLocationPoint = YES;
        // skip getting current gps location > start getting weather and genetic forecast
        [self manageWeatherAndGeneticForecasts];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    if (!self.alreadyGotLocationPoint) {
        self.alreadyGotLocationPoint = YES;
        
        if (locations && [locations count] > 0) {
            NSString *latitudeLabel = [NSString stringWithFormat:@"%.8f", [locations lastObject].coordinate.latitude];
            NSString *longitudeLabel = [NSString stringWithFormat:@"%.8f", [locations lastObject].coordinate.longitude];
            NSLog(@"latitude: %@", latitudeLabel);
            NSLog(@"longitude: %@", longitudeLabel);
            
            // let's try to define current location details
            [self defineLocationDetails:[locations lastObject]];
            
        } else {
            // currentLocation is nil, we can't define any information > start getting weather and genetic forecast
            [self manageWeatherAndGeneticForecasts];
        }
    } else {
        NSLog(@"PrepareForecastVC: already got location point!!!");
    }
}


// Define location details
- (void)defineLocationDetails:(CLLocation *)currentLocation {
    if ([InternetConnection internetConnectionIsAvailable]) {
        // try to define location details by wunderground service
        WundergroundHelper *wundergroundHelper = [[WundergroundHelper alloc] init];
        [wundergroundHelper wundergroundGeolookupDefineLocationDetailsBasedOnLocationCoordinates:currentLocation withResult:^(NSDictionary *location) {
            
            if (location != nil && [[location objectForKey:@"id"] length] != 0) {   // location details are defined
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
                
                // send selected location to user account on server
                if ([InternetConnection internetConnectionIsAvailable])
                    [self sendLocationInfoToServer:location];
                
                // start getting weather and genetic forecasts
                [self manageWeatherAndGeneticForecasts];
                
            } else {    // wunderground service returned an error > time to show alert message
                [self manageWeatherAndGeneticForecasts];
            }
        }];
    } else {    // skip defining current location > start getting weather and genetic forecast
        [self manageWeatherAndGeneticForecasts];
    }
}




#pragma mark -
#pragma mark Forecast manager

- (void)manageWeatherAndGeneticForecasts {
    if ([InternetConnection internetConnectionIsAvailable]) {
        // get weather forecast
        [self requestForForecast:^(NSDictionary *forecast) {
            if (forecast != nil) {
                dispatch_async(kMainQueue, ^{
                    // save forecast into data container at once
                    ForecastData *forecastContainer = [[ForecastData alloc] sharedInstance];
                    [forecastContainer setForecast:forecast];
                    
                    // request for genetic forecast based on appchain job result
                    if ([InternetConnection internetConnectionIsAvailable]) {
                        [self requestForGeneticForecast:^(NSString *geneticForecast) {
                            if ([geneticForecast length] != 0) {
                                forecastContainer.geneticForecast = geneticForecast;
                                NSLog(@"[PrepareForecastVC] genetic forecast: %@", geneticForecast);
                            } else {
                                forecastContainer.geneticForecast = kAbsentGeneticForecastMessage;
                                NSLog(@"[PrepareForecastVC] request for genetic forecast finished with no results");
                            }
                            
                            // show forecast
                            [self showForecastScreen];
                        }];
                    } else {    // no internet connection, show forecast (will be empty)
                        NSLog(@"!!! [PrepareForecastVC] No internet connection");
                        forecastContainer.geneticForecast = kAbsentGeneticForecastMessage;
                        [self showForecastScreen];
                    }
                });
            } else {    // we have an error from weatherforecast (wunderground), show forecast (will be empty)
                NSLog(@"!!! [PrepareForecastVC] Error while getting weather forecast");
                [self showForecastScreenWithEmptyWeatherData];
            }
        }]; // end forecast request
    } else {    // no internet connection, show forecast (will be empty)
        NSLog(@"!!! [PrepareForecastVC] No internet connection");
        [self showForecastScreenWithEmptyWeatherData];
    }
}


#pragma mark -
#pragma mark Request for weather forecast

- (void)requestForForecast:(void (^)(NSDictionary *forecast))completion {
    NSLog(@"PrepareForecastVC: requestForForecast");
    ForecastData *forecastContainer = [[ForecastData alloc] sharedInstance];
    NSDictionary *currentLocation   = [self.userHelper loadUserCurrentLocation];
    NSDictionary *selectedLocation  = [self.userHelper loadUserSelectedLocation];
    NSDictionary *defaultLocation   = [self.userHelper loadUserDefaultLocation];
    NSString *locationID;
    NSDictionary *locationForServer;
    
    if (![self.userHelper locationIsEmpty:currentLocation]) {
        [self.userHelper saveUserSelectedLocation:currentLocation];
        // try to get forecast for current location
        locationID = [currentLocation objectForKey:LOCATION_ID_DICT_KEY];
        forecastContainer.locationForForecast = currentLocation;
        locationForServer = [currentLocation copy];
        
    } else if (![self.userHelper locationIsEmpty:selectedLocation]) {
        // try to get forecast for selected location
        locationID = [selectedLocation objectForKey:LOCATION_ID_DICT_KEY];
        forecastContainer.locationForForecast = selectedLocation;
        locationForServer = [selectedLocation copy];
        
    } else {
        [self.userHelper saveUserSelectedLocation:defaultLocation];
        // try to get forecast for default location
        locationID = [defaultLocation objectForKey:LOCATION_ID_DICT_KEY];
        forecastContainer.locationForForecast = defaultLocation;
        locationForServer = [defaultLocation copy];
    }
    
    // update location on Server (user account)
    [self sendLocationInfoToServer:locationForServer];
    
    // get forecast with Wunderground service
    WundergroundHelper *wundergroundHelper = [[WundergroundHelper alloc] init];
    [wundergroundHelper wundergroundForecast10dayConditionsDefineByLocationID:locationID withResult:^(NSDictionary *forecast) {
        if (forecast) {
            completion(forecast);
            
        } else {
            NSLog(@"PrepareForecastVC: !Error: forecast from wunderground server is empty");
            completion(nil);
        }
    }];
}


- (void)sendLocationInfoToServer:(NSDictionary *)location {
    NSLog(@"sendSelectedLocationInfoWithParameters");
    NSString    *locationID = [location objectForKey:LOCATION_ID_DICT_KEY];
    NSDictionary *parameters = @{@"city"  : locationID,
                                 @"token" : [self.userHelper loadUserToken].accessToken};
    [self.userAccountHelper sendSelectedLocationInfoWithParameters:parameters];
}


#pragma mark -
#pragma mark Genetic forecast

- (void)requestForGeneticForecast:(void (^)(NSString *geneticForecast))completion {
    GeneticForecastHelper *gfHelper = [[GeneticForecastHelper alloc] sharedInstance];
    ForecastData *forecastContainer = [[ForecastData alloc] sharedInstance];
    
    NSString *fileID;
    NSString *fileIDRawValue = [[self.userHelper loadUserGeneticFile] objectForKey:GENETIC_FILE_ID_DICT_KEY];
    if ([fileIDRawValue containsString:@":"]) {
        NSArray *arrayFileID = [fileIDRawValue componentsSeparatedByString:@":"];
        if ([arrayFileID count] > 1) {
            fileID = [arrayFileID lastObject];
        }
    } else {
        fileID = fileIDRawValue;
    }
    SQToken *token = [self.userHelper loadUserToken];
    
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
    
    _imagePreloader.animationImages = images;
    _imagePreloader.animationDuration = 2;
    [_imagePreloader startAnimating];
}

- (void)stopCubePreloader {
    [_imagePreloader stopAnimating];
    _imagePreloader.animationImages = nil;
}



#pragma mark -
#pragma mark Show Weather Forecast screen

- (void)showForecastScreenWithEmptyWeatherData {
    dispatch_async(kMainQueue, ^{
        // save empty weather forecast into data container
        ForecastData *forecastContainer = [[ForecastData alloc] sharedInstance];
        [forecastContainer setForecast:nil];
        
        // showForecastScreen now
        [self showForecastScreen];
    });
}

- (void)showForecastScreen {
    dispatch_async(kMainQueue, ^{
        // show main screen with sidebarmenu via storyboard
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Forecast" bundle:nil];
        SWRevealViewController *revealViewController = (SWRevealViewController *)[storyboard instantiateInitialViewController];
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate.window setRootViewController:revealViewController];
        [appDelegate.window makeKeyAndVisible];
    });
}



#pragma mark -
#pragma mark Mamory handler

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
