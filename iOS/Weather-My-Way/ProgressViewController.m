//
//  ProgressViewController.m
//  Copyright © 2016 Sequencing. All rights reserved.
//


#import "ProgressViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "AlertMessage.h"
#import "SQFilesAPI.h"
#import "SQOAuth.h"
#import "SQToken.h"
#import "AppDelegate.h"
#import "UserHelper.h"
#import "WundergroundHelper.h"
#import "MBProgressHUD.h"
#import "SWRevealViewController.h"
#import "PrepareForecastViewController.h"
#import "UserAccountHelper.h"
#import "InternetConnection.h"
#import "ConstantsList.h"


#define kMainQueue dispatch_get_main_queue()



@interface ProgressViewController () <CLLocationManagerDelegate, AlertMessageDialogDelegate>

@property (weak, nonatomic) IBOutlet UILabel     *activityText;
@property (weak, nonatomic) IBOutlet UIImageView *imagePreloader;

@property (assign, nonatomic) BOOL alreadyStartedUserAccountRequest;
@property (assign, nonatomic) BOOL alreadyGotLocationPoint;
@property (assign, nonatomic) BOOL alreadyGotUserGPSLocation;
@property (assign, nonatomic) BOOL alreadyGotUserAccountInfo;

@property (nonatomic) MBProgressHUD             *activityProgress;
@property (strong, nonatomic) UserHelper        *userHelper;
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



#pragma mark - View Lyfecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"[ProgressViewController] viewDidLoad");
    
    // init location manager
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
    
    self.alreadyStartedUserAccountRequest = NO;
    self.alreadyGotLocationPoint = NO;
    self.alreadyGotUserGPSLocation = NO;
    self.alreadyGotUserAccountInfo = NO;
    
    // check user account first
    if (!_alreadyStartedUserAccountRequest) {
        _alreadyStartedUserAccountRequest = YES;
        [self checkForUserAccount];
    }
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self startCubePreloader];
    _activityText.text = @"Analyzing your genes and the weather, together...";
}



- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)dealloc {
    [super cleanup];
    NSLog(@"ProgressVC: dealloc");
}




#pragma mark - User account information
- (void)checkForUserAccount {
    if ([InternetConnection internetConnectionIsAvailable]) {
        
        [self requestForUserAccountInformation:^(NSDictionary *accountInfo) {
            if (accountInfo) {
                [self.userHelper saveUserAccountEmail:[accountInfo objectForKey:@"email"]];
                [self.userHelper saveSettingEmailAddressForForecast:[accountInfo objectForKey:@"email"]];
            }
            
            [self requestForUserSettingsInformation:^(BOOL success) {
                if (success) {
                    
                    if ([InternetConnection internetConnectionIsAvailable]) {
                        NSLog(@">>>>> [ProgressViewController]: send User Settings To Server after processing");
                        [self.userAccountHelper sendUserSettingsToServer];
                    }
                    
                    // call whatever method is needed next according to flow now
                    [self callWhatIsNeededByGuestUserFlow];
                    
                } else // launch user location autodetection in background - as we have received no settings from server
                    [self autodetectLocationCheckAvailabilityAndStart];
            }];
        }];
    } else // launch user location autodetection in background - as we have received no settings from server
        [self autodetectLocationCheckAvailabilityAndStart];
}



- (void)requestForUserSettingsInformation:(void (^)(BOOL success))completion {
    if ([InternetConnection internetConnectionIsAvailable]) {
        [[SQOAuth sharedInstance] token:^(SQToken *token, NSString *accessToken) {
            NSLog(@">>>>> [ProgressViewController]: retrieve User Settings, token: %@", token.accessToken);
            if (token && [token.accessToken length] != 0) {
                
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
                                             @"deviceType"    : @(1),
                                             @"appVersion"    : [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]};
                
                [self.userAccountHelper retrieveUserSettings:parameters
                                              withCompletion:^(NSDictionary *userAccountSettings) {
                                                  
                                                  if ([self.userAccountHelper areUserAccountSettingsValid:userAccountSettings]) {
                                                      [self.userAccountHelper processUserAccountSettings:userAccountSettings];
                                                      completion(YES);
                                                  } else
                                                      completion(NO);
                                              }];
            } else
                completion(NO);
        }];
    } else
        completion(NO);
}


- (void)requestForUserAccountInformation:(void (^)(NSDictionary *accountInfo))completion {
    [[SQOAuth sharedInstance] token:^(SQToken *token, NSString *accessToken) {
        NSLog(@">>>>> [ProgressViewController]: requestForUserAccountInformation, token: %@", token.accessToken);
        if (token && [token.accessToken length] != 0) {
            
            [self.userAccountHelper requestForUserAccountInformationWithAccessToken:token.accessToken withResult:^(NSDictionary *accountInfo) {
                // NSLog(@"%@", accountInfo);
                NSArray *accountInfoAllKeys = [accountInfo allKeys];
                
                if (accountInfo && [accountInfoAllKeys containsObject:@"username"] && [accountInfoAllKeys containsObject:@"email"]) {
                    completion(accountInfo);
                    
                } else // accountInfo request result server is not valid
                    completion(nil);
            }];
        } else // access token is empty
            completion(nil);
    }];
}



- (NSString *)proccessPushSettings {
    NSString *pushSetting = @"true";
    [self.userHelper saveSettingIPhoneDailyForecast:[NSNumber numberWithBool:YES]];
    return pushSetting;
}



#pragma mark - Location / File / Forecast manager

- (void)callWhatIsNeededByGuestUserFlow {
    NSDictionary *currentLocation = [self.userHelper loadUserCurrentLocation];
    NSDictionary *geneticFile = [self.userHelper loadUserGeneticFile];
    
    if (![self.userHelper locationIsEmpty:currentLocation] && geneticFile) {
        // we can open prepareForecastVC now (as we have both location as genetic file known)
        self.alreadyGotUserAccountInfo = YES;
        [self showPrepareForecastViewController];
        
    } else if (![self.userHelper locationIsEmpty:currentLocation]) {
        // launch file selector as we already have user location
        self.alreadyGotUserAccountInfo = YES;
        [self showFileSelector];
        
    } else // launch user location autodetection now (as we don't have needed information, at least location)
        [self autodetectLocationCheckAvailabilityAndStart];
}




#pragma mark - Auto-detect Location, CLLocationManagerDelegate, Define location details

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
            // NSString *latitudeLabel = [NSString stringWithFormat:@"%.8f", [locations lastObject].coordinate.latitude];
            // NSString *longitudeLabel = [NSString stringWithFormat:@"%.8f", [locations lastObject].coordinate.longitude];
            // NSLog(@"latitude: %@", latitudeLabel);
            // NSLog(@"longitude: %@", longitudeLabel);
            
            
            // *
            // * post notification with detected location
            // *
            NSDictionary *userInfoDict = @{dict_cllocationKey: [locations lastObject]};
            [[NSNotificationCenter defaultCenter] postNotificationName:GPS_COORDINATES_DETECTED_NOTIFICATION_KEY object:nil userInfo:userInfoDict];
            // *
            
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
    }
}


// Define location details
- (void)defineLocationDetails:(CLLocation *)cllocation {
    currentLocationFromLocationManager = cllocation;
    if (_imagePreloader == nil) {
        [self startCubePreloader];
    }
    // try to define location details by wunderground service
    if ([InternetConnection internetConnectionIsAvailable]) {
        [[[WundergroundHelper alloc] init] wundergroundGeolookupDefineLocationDetailsBasedOnLocationCoordinates:cllocation withResult:^(NSDictionary *location) {
            
            if (location != nil && [[location objectForKey:@"id"] length] != 0) { // location details are defined
                NSString *locationCity = [location objectForKey:@"city"];
                NSString *locationStateOrCountry = @"";
                NSString *locationID = [location objectForKey:@"id"];
                
                if ([[location objectForKey:@"state"] length] != 0) {
                    locationStateOrCountry = [location objectForKey:@"state"];
                } else {
                    locationStateOrCountry = [location objectForKey:@"country"];
                }
                
                
                // *
                // * post notification with defined location
                // *
                NSDictionary *userInfoDict = @{dict_placeKey:     locationCity,
                                               dict_cllocationKey:cllocation};
                [[NSNotificationCenter defaultCenter] postNotificationName:LOCATION_NAME_DEFINED_NOTIFICATION_KEY object:nil userInfo:userInfoDict];
                // *
                
                // save defined location details into userDefaults
                NSDictionary *definedLocation = [NSDictionary dictionaryWithObjectsAndKeys:
                                                 locationCity,           LOCATION_CITY_DICT_KEY,
                                                 locationStateOrCountry, LOCATION_STATE_COUNTRY_DICT_KEY,
                                                 locationID,             LOCATION_ID_DICT_KEY,
                                                 cllocation,             CLLOCATION_OBJECT_DICT_KEY, nil];
                [self.userHelper saveUserCurrentLocation:definedLocation];
                self.alreadyGotUserGPSLocation = YES;
                
                // send selected location to user account on server
                if ([InternetConnection internetConnectionIsAvailable])
                    [self sendLocationInfoToServer:definedLocation];
                
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



#pragma mark - AlertMessageDialogDelegate

- (void)tryAgainButtonPressed {
    [self launchAutodetectLocation];
}


- (void)manuallyButtonPressed {
    [self showLocationViewController];
}



#pragma mark - LocationVC, LocationViewControllerDelegate

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


- (void)locationViewController:(UIViewController *)controller didSelectLocation:(NSDictionary *)location {
    dispatch_async(kMainQueue, ^{
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
    if (!location) return;
    [[SQOAuth sharedInstance] token:^(SQToken *token, NSString *accessToken) {
        NSLog(@"sendLocationInfoToServer, token: %@", token.accessToken);
        if (token && [token.accessToken length] > 0) {
            
            NSString    *locationID = [location objectForKey:LOCATION_ID_DICT_KEY];
            
            NSDictionary *parameters = @{@"city" : locationID,
                                         @"token": token.accessToken};
            [self.userAccountHelper sendSelectedLocationInfoWithParameters:parameters];
        }
    }];
}




#pragma mark - FileSelector, SQFileSelectorProtocol

- (void)callFileSelectorIfNeededOrPrepareForecastVC {
    NSDictionary *geneticFile = [self.userHelper loadUserGeneticFile];
    
    if (!geneticFile) // launch file selector as we have no information about genetic file
        [self showFileSelector];
    
    else { // we can open prepareForecastVC now (as we have already have genetic file known)
        self.alreadyGotUserAccountInfo = YES;
        [self showPrepareForecastViewController];
    }
}


- (void)showFileSelector {
    if (_imagePreloader == nil) {
        [self startCubePreloader];
    }
    
    if (![InternetConnection internetConnectionIsAvailable]) {
        
        [self showPrepareForecastViewController];
        return;
    }
    
    [[SQOAuth sharedInstance] token:^(SQToken *token, NSString *accessToken) {
        dispatch_async(kMainQueue, ^{
            
            if (!token || !token.accessToken || [token.accessToken length] == 0) {
                [self showPrepareForecastViewController];
                return;
            }
            
            VideoHelper *videoHelper = [[VideoHelper alloc] init];
            NSString *videoName = [videoHelper getRandomVideoName];
            
            SQFilesAPI *filesAPI = [SQFilesAPI sharedInstance];
            [filesAPI showFilesWithTokenProvider:[SQOAuth sharedInstance]
                                 showCloseButton:NO
                        previouslySelectedFileID:nil
                         backgroundVideoFileName:videoName
                                        delegate:self];
        });
    }];
}


// SQFileSelectorProtocol
- (void)selectedGeneticFile:(NSDictionary *)file {
    [self dismissViewControllerAnimated:YES completion:nil];
    [[SQFilesAPI sharedInstance] setDelegate:nil];
    
    
    // save selected file into user defaults
    [self.userHelper saveUserGeneticFile:file];
    self.alreadyGotUserAccountInfo = YES;
    
    if ([InternetConnection internetConnectionIsAvailable]) {
        [[SQOAuth sharedInstance] token:^(SQToken *token, NSString *accessToken) {
            
            if (file && ([[file objectForKey:@"Id"] length] > 0) &&
                token && ([token.accessToken length] > 0)) {
                
                NSString *fileName;
                if ([[file objectForKey:@"FileCategory"] isEqualToString:@"Community"] )
                    fileName = [NSString stringWithFormat:@"%@ - %@", [file objectForKey:@"FriendlyDesc1"], [file objectForKey:@"FriendlyDesc2"]];
                else
                    fileName = [file objectForKey:@"Name"];
                
                NSDictionary *parameters = @{@"selectedId"  : [file objectForKey:@"Id"],
                                             @"selectedName": [fileName stringByReplacingOccurrencesOfString: @" " withString: @"%20"],
                                             @"token"       : token.accessToken};
                
                [self.userAccountHelper sendSelectedGeneticFileInfoWithParameters:parameters];
            }
            
            [self showPrepareForecastViewController];
            
        }];
    } else // open prepareForecastVC
        [self showPrepareForecastViewController];
}


- (void)errorWhileReceivingGeneticFiles:(NSError *)error {
    [self showPrepareForecastViewController];
}


#pragma mark - Show PrepareForecastViewController

- (void)showPrepareForecastViewController {
    dispatch_async(kMainQueue, ^{
        [self stopCubePreloader];
        PrepareForecastViewController *prepareForecastVC = [[PrepareForecastViewController alloc] initWithNibName:@"PrepareForecastViewController" bundle:nil];
        if (self.alreadyGotUserAccountInfo)
            prepareForecastVC.alreadyGotUserAccountInfo = YES;
        if (self.alreadyGotUserGPSLocation)
            prepareForecastVC.alreadyGotUserGPSLocation = YES;
        prepareForecastVC.isUserFromLoginScreen = YES;
        
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate.window setRootViewController:prepareForecastVC];
        [appDelegate.window makeKeyAndVisible];
    });
}



#pragma mark - Preloader

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



#pragma mark - Memory handler

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



@end
