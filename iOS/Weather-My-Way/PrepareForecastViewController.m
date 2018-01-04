//
//  PrepareForecastViewController.m
//  Copyright © 2016 Sequencing. All rights reserved.
//


#import "PrepareForecastViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "SQToken.h"
#import "SQOAuth.h"
#import "UserHelper.h"
#import "UserAccountHelper.h"
#import "InternetConnection.h"
#import "WundergroundHelper.h"
#import "MBProgressHUD.h"
#import "SWRevealViewController.h"
#import "ForecastData.h"
#import "GeneticForecastHelper.h"
#import "ConstantsList.h"


#define kMainQueue dispatch_get_main_queue()



@interface PrepareForecastViewController () <CLLocationManagerDelegate>

@property (assign, nonatomic) BOOL                  alreadyGotLocationPoint;
@property (weak, nonatomic) IBOutlet UIImageView    *imagePreloader;
@property (nonatomic) MBProgressHUD                 *activityProgress;
@property (strong, nonatomic) UserHelper            *userHelper;
@property (strong, nonatomic) UserAccountHelper     *userAccountHelper;

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
    
    // init location manager
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
    self.alreadyGotLocationPoint = NO;
    
    // processUserAccountInfo
    [self startProcessingUserAccountInfo];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self startCubePreloader];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)dealloc {
    NSLog(@"PrepareForecastVC: dealloc");
    [super cleanup];
    
    [self stopCubePreloader];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}





#pragma mark - Process user account info

- (void)startProcessingUserAccountInfo {
    if (!self.alreadyGotUserAccountInfo) { // check for up-to-date user account settings
        [self checkForUserAccountWithCompletion:^{
            
            // get current user gps location
            if (!self.alreadyGotUserGPSLocation)
                [self autodetectLocationCheckAvailabilityAndStart];
            else
                [self manageWeatherForecast];
            
        }];
        
    } else // get current user gps location
        if (!self.alreadyGotUserGPSLocation)
            [self autodetectLocationCheckAvailabilityAndStart];
        else
            [self manageWeatherForecast];
    
    // in case we need to sign user out
    /*
     dispatch_async(kMainQueue, ^{
     UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
     UINavigationController *loginNavigationVC = (UINavigationController *)[storyboard instantiateInitialViewController];
     LoginViewController *loginViewController = [loginNavigationVC viewControllers][0];
     [loginViewController setMessageTextForErrorCase:@"Sorry, there was an error while getting authorized user data.\nPlease reauthorize"];
     AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
     [appDelegate.window setRootViewController:loginNavigationVC];
     [appDelegate.window makeKeyAndVisible];
     });
     */
}



#pragma mark - User account information

- (void)checkForUserAccountWithCompletion:(void (^)(void))completion {
    if (![InternetConnection internetConnectionIsAvailable]) {
        completion();
        return;
    }
    
    [[SQOAuth sharedInstance] token:^(SQToken *token, NSString *accessToken) {
        NSLog(@">>>>> [PrepareForecastVC]: getting user settings, token: %@", token.accessToken);
        if (!token || ([token.accessToken length] == 0)) {
            completion();
            return;
        }
        
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
                                          if (userAccountSettings)
                                              [self.userAccountHelper processUserAccountSettings:userAccountSettings];
                                          completion();
                                      }];
    }];
}


- (NSString *)proccessPushSettings {
    NSString *pushSetting = @"true";
    [self.userHelper saveSettingIPhoneDailyForecast:[NSNumber numberWithBool:YES]];
    return pushSetting;
}




#pragma mark - Auto-detect Location, CLLocationManagerDelegate, Define location details

- (void)autodetectLocationCheckAvailabilityAndStart {
    NSLog(@"[PrepareForecastVC] autodetectLocationCheckAvailabilityAndStart");
    if ([CLLocationManager locationServicesEnabled]) {
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        switch (status) {
                
            case kCLAuthorizationStatusDenied: { // skip getting current gps location > start getting weather and genetic forecast
                [self manageWeatherForecast];
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
                
            default: { // skip getting current gps location > start getting weather and genetic forecast
                [self manageWeatherForecast];
            } break;
        }
    } else { // skip getting current gps location > start getting weather and genetic forecast
        [self manageWeatherForecast];
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
        [self manageWeatherForecast];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    if (!self.alreadyGotLocationPoint) {
        self.alreadyGotLocationPoint = YES;
        
        if (locations && [locations count] > 0) {
            
            // *
            // * post notification with detected location
            // *
            NSDictionary *userInfoDict = @{dict_cllocationKey: [locations lastObject]};
            [[NSNotificationCenter defaultCenter] postNotificationName:GPS_COORDINATES_DETECTED_NOTIFICATION_KEY object:nil userInfo:userInfoDict];
            // *
            
            // let's try to define current location details
            [self defineLocationDetails:[locations lastObject]];
            
        } else { // currentLocation is nil, we can't define any information > start getting weather and genetic forecast
            [self manageWeatherForecast];
        }
    }
}


// Define location details
- (void)defineLocationDetails:(CLLocation *)cllocation {
    if ([InternetConnection internetConnectionIsAvailable]) {
        
        // try to define location details by wunderground service
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
                
                // send selected location to user account on server
                [self sendLocationInfoToServer:definedLocation];
                
                // start getting weather and genetic forecasts
                [self manageWeatherForecast];
                
            } else // wunderground service returned an error > time to show alert message
                [self manageWeatherForecast];
        }];
    } else // skip defining current location > start getting weather and genetic forecast
        [self manageWeatherForecast];
}



#pragma mark - Forecast manager

- (void)manageWeatherForecast {
    NSLog(@"[PrepareForecastVC] manageWeatherForecast");
    [self requestForForecast:^(NSDictionary *forecast) { // get weather forecast
        if (forecast) {
            ForecastData *forecastContainer = [ForecastData sharedInstance];
            [forecastContainer setForecast:forecast];
            
            [self showForecastScreen];
            
        } else // we have an error from weatherforecast (wunderground), show forecast (will be empty)
            [self showForecastScreenWithEmptyWeatherData];
    }];
}


#pragma mark - Request for weather forecast

- (void)requestForForecast:(void (^)(NSDictionary *forecast))completion {
    if ([InternetConnection internetConnectionIsAvailable]) {
        
        ForecastData *forecastContainer = [ForecastData  sharedInstance];
        NSDictionary *currentLocation   = [self.userHelper loadUserCurrentLocation];
        NSDictionary *selectedLocation  = [self.userHelper loadUserSelectedLocation];
        NSDictionary *defaultLocation   = [self.userHelper loadUserDefaultLocation];
        NSString *locationID;
        NSDictionary *locationForServer;
        
        if (![self.userHelper locationIsEmpty:currentLocation]) { // try to get forecast for current location
            [self.userHelper saveUserSelectedLocation:currentLocation];
            locationID = [currentLocation objectForKey:LOCATION_ID_DICT_KEY];
            forecastContainer.locationForForecast = currentLocation;
            locationForServer = [currentLocation copy];
            
        } else if (![self.userHelper locationIsEmpty:selectedLocation]) { // try to get forecast for selected location
            locationID = [selectedLocation objectForKey:LOCATION_ID_DICT_KEY];
            forecastContainer.locationForForecast = selectedLocation;
            locationForServer = [selectedLocation copy];
            
        } else { // try to get forecast for default location
            [self.userHelper saveUserSelectedLocation:defaultLocation];
            locationID = [defaultLocation objectForKey:LOCATION_ID_DICT_KEY];
            forecastContainer.locationForForecast = defaultLocation;
            locationForServer = [defaultLocation copy];
        }
        
        // update location on Server (user account)
        [self sendLocationInfoToServer:locationForServer];
        
        // get forecast with Wunderground service
        [[[WundergroundHelper alloc] init] wundergroundForecast10dayConditionsDefineByLocationID:locationID withResult:^(NSDictionary *forecast) {
            completion(forecast);
        }];
        
    } else
        completion(nil);
}


- (void)sendLocationInfoToServer:(NSDictionary *)location {
    if ([InternetConnection internetConnectionIsAvailable]) {
        [[SQOAuth sharedInstance] token:^(SQToken *token, NSString *accessToken) {
            NSLog(@">>>>> [PrepareForecastVC] sendLocationInfoToServer, token: %@", token.accessToken);
            if (token && [token.accessToken length] > 0) {
                
                NSString     *locationID = [location objectForKey:LOCATION_ID_DICT_KEY];
                NSDictionary *parameters = @{@"city" : locationID,
                                             @"token": token.accessToken};
                [self.userAccountHelper sendSelectedLocationInfoWithParameters:parameters];
            }
        }];
    }
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
    
    _imagePreloader.animationImages = images;
    _imagePreloader.animationDuration = 2;
    [_imagePreloader startAnimating];
}

- (void)stopCubePreloader {
    [_imagePreloader stopAnimating];
    _imagePreloader.animationImages = nil;
}



#pragma mark - Show Weather Forecast screen

- (void)showForecastScreenWithEmptyWeatherData {
    // TODO USE HERE THE WAY TO GET LAST AVAILABLE WEATHER FORECAST FROM CACHE SERIALIZATION
    
    dispatch_async(kMainQueue, ^{ // save empty weather forecast into data container
        ForecastData *forecastContainer = [ForecastData sharedInstance];
        [forecastContainer setForecast:nil];
        
        // showForecastScreen now
        [self showForecastScreen];
    });
}

- (void)showForecastScreen {
    dispatch_async(kMainQueue, ^{ // show main screen with sidebarmenu via storyboard
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Forecast" bundle:nil];
        SWRevealViewController *revealViewController = (SWRevealViewController *)[storyboard instantiateInitialViewController];
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate.window setRootViewController:revealViewController];
        [appDelegate.window makeKeyAndVisible];
    });
}



#pragma mark - Memory handler
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



@end
