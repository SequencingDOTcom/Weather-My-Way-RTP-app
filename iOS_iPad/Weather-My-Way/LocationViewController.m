//
//  LocationViewController.m
//  Copyright © 2016 Sequencing. All rights reserved.
//


#import <AVFoundation/AVFoundation.h>
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>
#import "LocationViewController.h"
#import "AlertMessage.h"
#import "UserHelper.h"
#import "WundergroundHelper.h"
#import "MBProgressHUD.h"
#import "VideoHelper.h"
#import "ForecastData.h"
#import "InternetConnection.h"


#define kMainQueue dispatch_get_main_queue()

@interface LocationViewController () <CLLocationManagerDelegate, AlertMessageDialogDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UITextField    *locationTextField;
@property (weak, nonatomic) IBOutlet UIImageView    *locationIcon;
@property (weak, nonatomic) IBOutlet UIView         *locationButtonView;
@property (weak, nonatomic) IBOutlet UIView         *continueButtonView;
@property (weak, nonatomic) IBOutlet UIButton       *continueButton;

@property (strong, nonatomic) NSDictionary      *nowSelectedLocation;

@property (nonatomic) MBProgressHUD     *activityProgress;

// properties for picker data
@property (nonatomic) NSArray   *namesOfLocationsForPickerData; // <NSString *>
@property (nonatomic) NSArray   *locationsObjectsFromServerToSelect; // <NSDictionary *>
@property (nonatomic) BOOL      cityIsValidated;
@property (nonatomic) NSString  *locationNameBeforeManualEdit;

// properties for videoPlayer
@property (nonatomic) AVPlayer      *avPlayer;
@property (nonatomic) UIView        *videoPlayerView;
@property (nonatomic) AVPlayerLayer *videoLayer;

@property (assign, nonatomic) BOOL alreadyGotLocationPoint;

@end



@implementation LocationViewController {
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
}

#pragma mark -
#pragma mark View Lyfecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"LocationVC: loaded");
    
    // set navigation bar fully transpanent
    [self.navigationController.navigationBar setTranslucent:YES];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    
    // set up title
    self.title = @"Select Location";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:19.0],
                                                                      NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
    // set up "back" button
    if (_backButton) {
        UIBarButtonItem *myButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                                  target:self
                                                                                  action:@selector(backButtonPressed)];
        self.navigationItem.leftBarButtonItem = myButton;
    }
    
    
    // init location manager
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
    self.alreadyGotLocationPoint = NO;
    
    // text field
    _cityIsValidated = NO;
    _locationTextField.delegate = self;
    // [_continueButton setHidden:YES];
    // [_continueButtonView setHidden:YES];
    
    // setup video and add observes
    [self initializeAndAddVideoToView];
    
    // adjust buttons views
    self.locationButtonView.layer.cornerRadius = 5;
    self.locationButtonView.layer.masksToBounds = YES;
    
    self.continueButtonView.layer.cornerRadius = 5;
    self.continueButtonView.layer.masksToBounds = YES;
    
    // add gesture to location icon
    _locationIcon.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGestureSequencing = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(autodetectLocationIconPressed)];
    tapGestureSequencing.numberOfTapsRequired = 1;
    [tapGestureSequencing setDelegate:self];
    [_locationIcon addGestureRecognizer:tapGestureSequencing];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // launch video
    [self playVideo];
    [self addNotificationObserves];
    
    // set transpanent grey background for navigation bar in case when video with white part is used now
    if ([VideoHelper isVideoWhite]) {
        [self.navigationController.navigationBar setBackgroundImage:[VideoHelper greyTranspanentImage] forBarMetrics:UIBarMetricsDefault];
    } else {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_locationTextField becomeFirstResponder];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self deallocateAndRemoveVideoFromView];
}



#pragma mark -
#pragma mark Videoplayer Methods

- (void)initializeAndAddVideoToView {
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pauseVideo)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playVideo)
                                                 name:UIApplicationDidBecomeActiveNotification // UIApplicationWillEnterForegroundNotification
                                               object:nil];
}


- (UIStatusBarStyle)preferredStatusBarStyle {
    // UIStatusBarStyleLightContent
    // UIStatusBarStyleDefault
    return UIStatusBarStyleLightContent;
}



#pragma mark -
#pragma mark Autodetect Location

- (void)autodetectLocationIconPressed {
    [self autodetectLocation];
}

- (IBAction)autodetectLocationButtonPressed:(id)sender {
    [self autodetectLocation];
}

- (void)autodetectLocation {
    // let's hide keyboard or pickerview if they are present
    if ([_locationTextField isFirstResponder]) {
        [_locationTextField resignFirstResponder];
        if (_locationTextField.inputView != nil) {
            [_locationTextField setInputView:nil];
            [_locationTextField setInputAccessoryView:nil];
        }
    }
    
    if ([CLLocationManager locationServicesEnabled]) {
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        switch (status) {
                
            case kCLAuthorizationStatusDenied: { // If the status is denied or only granted for when in use, display an alert
                _cityIsValidated = NO;
                dispatch_async(kMainQueue, ^{
                    NSString *title = @"Location Services Forbidden for \"Weather My Way\" application";
                    NSString *message = @"Please turn on location services in your device settings and select \"Always\" option";
                    AlertMessage *alertMessage = [[AlertMessage alloc] init];
                    alertMessage.delegate = self;
                    [alertMessage viewController:self showAlertWithTitle:title withMessage:message withSettingsAction:@"Settings"];
                });
            } break;
                
            case kCLAuthorizationStatusNotDetermined: {
                [locationManager requestAlwaysAuthorization];
                [self launchAutodetectLocation];
            } break;
                
            case kCLAuthorizationStatusAuthorizedAlways: {
                [self launchAutodetectLocation];
            } break;
                
            case kCLAuthorizationStatusAuthorizedWhenInUse: {
                [locationManager requestAlwaysAuthorization];
                [self launchAutodetectLocation];
            } break;
                
            default: {
                [locationManager requestAlwaysAuthorization];
                [self launchAutodetectLocation];
            } break;
        }
        
    } else { // Location Services are disabled
        _cityIsValidated = NO;
        dispatch_async(kMainQueue, ^{
            NSString *title = @"Location Services Disabled";
            NSString *message = @"Please turn on location services in your device settings";
            AlertMessage *alertMessage = [[AlertMessage alloc] init];
            alertMessage.delegate = self;
            [alertMessage viewController:self showAlertWithTitle:title withMessage:message withSettingsAction:@"Settings"];
        });
    }
}


- (void)launchAutodetectLocation {
    // setting activity indicator
    self.activityProgress = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.alreadyGotLocationPoint = NO;
    
    [locationManager requestLocation];
}



#pragma mark -
#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if (!self.alreadyGotLocationPoint) {
        self.alreadyGotLocationPoint = YES;
        _cityIsValidated = NO;
        dispatch_async(kMainQueue, ^{
            [self.activityProgress hide:YES];
            AlertMessage *alert = [[AlertMessage alloc] init];
            [alert viewController:self showAlertWithMessage:@"Failed to Get Your Location"];
        });
    } else {
        NSLog(@"LocationVC: already got location point!!!");
    }
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    [locationManager stopUpdatingLocation];

    if (!self.alreadyGotLocationPoint) {
        self.alreadyGotLocationPoint = YES;
        if (locations && [locations count] > 0) { // CLLocation is defined
            NSString *latitudeLabel = [NSString stringWithFormat:@"%.8f", [locations lastObject].coordinate.latitude];
            NSString *longitudeLabel = [NSString stringWithFormat:@"%.8f", [locations lastObject].coordinate.longitude];
            NSLog(@"latitude: %@", latitudeLabel);
            NSLog(@"longitude: %@", longitudeLabel);
            
            // save currentLocation
            UserHelper *userHelper = [[UserHelper alloc] init];
            [userHelper saveUserCurrentGPSLocation:[locations lastObject]];
            
            // let's try to define current location details
            if ([InternetConnection internetConnectionIsAvailable]) {
                [self defineLocationDetails:[locations lastObject]];
                
            } else {
                dispatch_async(kMainQueue, ^{
                    [self.activityProgress hide:YES];
                    _cityIsValidated = NO;
                    AlertMessage *alert = [[AlertMessage alloc] init];
                    [alert viewController:self
                       showAlertWithTitle:@"Can't validate location"
                              withMessage:NO_INTERNET_CONNECTION_TEXT];
                });
            }
            
        } else { // CLLocation is nil, we can't define any information
            dispatch_async(kMainQueue, ^{
                [self.activityProgress hide:YES];
                _cityIsValidated = NO;
                AlertMessage *alert = [[AlertMessage alloc] init];
                [alert viewController:self showAlertWithMessage:@"Failed to Get Your Location\nTry it again or enter city manually"];
            });
        }
    } else {
        NSLog(@"LocationVC: already got location point!!!");
    }
}



#pragma mark -
#pragma mark Define location details

- (void)defineLocationDetails:(CLLocation *)currentLocation {
    // try to define location details by wunderground service
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
            
            // save user current location details
            [self saveUserCurrentLocationWithLocationCity:locationCity locationStateOrCountry:locationStateOrCountry locationID:locationID];
            
            // show location details in UI
            dispatch_async(kMainQueue, ^{
                _locationTextField.text = [NSString stringWithFormat:@"%@, %@", locationCity, locationStateOrCountry];
                _cityIsValidated = YES;
                _locationNameBeforeManualEdit = _locationTextField.text;
                [self.activityProgress hide:YES];
            });
            
        } else { // wunderground service returned an error > time to show alert message
            dispatch_async(kMainQueue, ^{
                [self.activityProgress hide:YES];
                _cityIsValidated = NO;
                AlertMessage *alert = [[AlertMessage alloc] init];
                [alert viewController:self showAlertWithMessage:@"Failed to Get Your Location\nTry it again or enter city manually"];
            });
        }
    }];
}



#pragma mark -
#pragma mark AlertMessageDialogDelegate

- (void)settingsButtonPressed {
    dispatch_async(kMainQueue, ^{
        NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:settingsURL];
    });
}



#pragma mark -
#pragma mark UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    _locationNameBeforeManualEdit = _locationTextField.text;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self continueButtonPressed:nil];
    [textField resignFirstResponder];
    return YES;
}



#pragma mark -
#pragma mark Validating provided Location

- (IBAction)continueButtonPressed:(id)sender {
    // let's hide keyboard or pickerview if they are present
    if ([_locationTextField isFirstResponder]) {
        [_locationTextField resignFirstResponder];
        if (_locationTextField.inputView != nil) {
            [_locationTextField setInputView:nil];
            [_locationTextField setInputAccessoryView:nil];
        }
    }
    
    if ([_locationTextField.text length] != 0) {
        // let's check if user changed location name or left it the same
        if ([_locationNameBeforeManualEdit isEqualToString:_locationTextField.text]) {
            _cityIsValidated = YES;
        } else {
            _cityIsValidated = NO;
        }
        
        // if city is validated let's continue
        if (_cityIsValidated && [_locationTextField.text length] != 0 && _nowSelectedLocation) {
            // set message to delegate in order to close location window
            [self.delegate locationViewController:self didSelectLocation:_nowSelectedLocation];
            
        } else { // we need to validate porovided location
            if ([InternetConnection internetConnectionIsAvailable]) {
                [self validateProvidedLocation];
                
            } else {
                AlertMessage *alert = [[AlertMessage alloc] init];
                [alert viewController:self
                   showAlertWithTitle:@"Can't validate location"
                          withMessage:NO_INTERNET_CONNECTION_TEXT];
            }
        }
    } else { // we have not entered city into textField, location text field is empty
        dispatch_async(kMainQueue, ^{
            [self.activityProgress hide:YES];
            _cityIsValidated = NO;
            AlertMessage *alert = [[AlertMessage alloc] init];
            [alert viewController:self showAlertWithMessage:@"Please enter your city or tap auto-detect"];
        });
    }
}


- (void)validateProvidedLocation {
    if ([_locationTextField isFirstResponder]) {
        [_locationTextField resignFirstResponder];
        if (_locationTextField.inputView != nil) {
            [_locationTextField setInputView:nil];
            [_locationTextField setInputAccessoryView:nil];
        }
    }
    
    if ([_locationTextField.text length] != 0) {
        self.activityProgress = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        // we have entered city into textField, let's validate provided city/location
        WundergroundHelper *wundergroundHelper = [[WundergroundHelper alloc] init];
        [wundergroundHelper wundergroundAutoCompleteValidateProvidedCity:_locationTextField.text withResult:^(NSArray *locations) {
            
            if (locations != nil) { // no results were returned > invalid city name was enteres
                if ([locations count] == 0) {
                    NSLog(@"city validation: no results were returned");
                    dispatch_async(kMainQueue, ^{
                        [self.activityProgress hide:YES];
                        _cityIsValidated = NO;
                        AlertMessage *alert = [[AlertMessage alloc] init];
                        [alert viewController:self showAlertWithMessage:@"Failed to validate your location\nPlease enter valid city or tap auto-detect"];
                    });
                }
                
                // valid city name was provided > we can show it in UI and save into user defaults
                else if ([locations count] == 1) {
                    NSDictionary *location = locations[0];
                    NSLog(@"%@", location);
                    NSString *locationName = [location objectForKey:@"name"];
                    NSString *locationID = [location objectForKey:@"l"];
                    NSString *locationCity;
                    NSString *locationStateOrCountry;
                    
                    if ([locationID length] != 0 && [locationName length] != 0 && [[location objectForKey:@"type"] isEqualToString:@"city"]) {
                        NSArray *names = [locationName componentsSeparatedByString:@", "];
                        if ([names count] == 2) {
                            locationCity = [[names firstObject] stringByRemovingPercentEncoding];
                            locationStateOrCountry = [[names lastObject] stringByRemovingPercentEncoding];
                        } else {
                            locationCity = locationName;
                        }
                        
                        // save user selected location details
                        [self saveUserSelectedLocationWithLocationCity:locationCity locationStateOrCountry:locationStateOrCountry locationID:locationID];
                        
                        // show location details in UI
                        dispatch_async(kMainQueue, ^{
                            _cityIsValidated = YES;
                            _locationTextField.text = locationName;
                            _locationNameBeforeManualEdit = _locationTextField.text;
                            [self.activityProgress hide:YES];
                        });
                        
                    } else { // result is not valid
                        dispatch_async(kMainQueue, ^{
                            [self.activityProgress hide:YES];
                            _cityIsValidated = NO;
                            AlertMessage *alert = [[AlertMessage alloc] init];
                            [alert viewController:self showAlertWithMessage:@"Failed to validate your location\nPlease enter valid city or tap auto-detect"];
                        });
                    }
                }
                
                // valid city name was provided > several cities with such name are available > let's clarify user city via picker view
                else if ([locations count] > 1) {
                    NSMutableArray *offeredLocationsArrayOfObjects = [[NSMutableArray alloc] init]; // <NSDictionary *>
                    NSMutableArray *offeredLocationsArrayOfNames = [[NSMutableArray alloc] init]; // <NSString *>
                    for (NSDictionary *location in locations) {
                        // NSLog(@"location: %@", location);
                        if ([[location objectForKey:@"type"] isEqualToString:@"city"] && [[location objectForKey:@"name"] containsString:@","]) {
                            NSString *locationName = [location objectForKey:@"name"];
                            [offeredLocationsArrayOfNames addObject:locationName];
                            [offeredLocationsArrayOfObjects addObject:location];
                        }
                    }
                    _locationsObjectsFromServerToSelect = [NSArray arrayWithArray:offeredLocationsArrayOfObjects];
                    
                    // create pickerView
                    _namesOfLocationsForPickerData = [NSArray arrayWithArray:offeredLocationsArrayOfNames];
                    UIPickerView *pickerView = [[UIPickerView alloc] init];
                    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 44)];
                    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                                target:self
                                                                                                action:@selector(locationsPickerDoneAction:)];
                    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                                   target:nil
                                                                                                   action:nil];
                    [toolbar setItems:@[flexibleSpace, doneButton]];
                    toolbar.translucent = YES;
                    
                    pickerView.delegate = self;
                    pickerView.dataSource = self;
                    pickerView.accessibilityIdentifier = @"locationsPicker";
                    
                    [_locationTextField setInputView:pickerView];
                    [_locationTextField setInputAccessoryView:toolbar];
                    
                    dispatch_async(kMainQueue, ^{
                        // save the first location as selected right away
                        NSDictionary *location = _locationsObjectsFromServerToSelect[0];
                        NSString *locationName = [location objectForKey:@"name"];
                        NSString *locationID = [location objectForKey:@"l"];
                        NSString *locationCity;
                        NSString *locationStateOrCountry;
                        
                        NSArray *names = [locationName componentsSeparatedByString:@", "];
                        if ([names count] == 2) {
                            locationCity = [[names firstObject] stringByRemovingPercentEncoding];
                            locationStateOrCountry = [[names lastObject] stringByRemovingPercentEncoding];
                        } else {
                            locationCity = locationName;
                        }
                        
                        // save user current location details
                        [self saveUserSelectedLocationWithLocationCity:locationCity locationStateOrCountry:locationStateOrCountry locationID:locationID];
                        
                        // show preselected location in UI
                        _cityIsValidated = YES;
                        _locationNameBeforeManualEdit = locationName;
                        _locationTextField.text = locationName;
                        
                        [self.activityProgress hide:YES];
                        [_locationTextField becomeFirstResponder];
                    });
                }
                
            } else { // failed to validate city
                dispatch_async(kMainQueue, ^{
                    [self.activityProgress hide:YES];
                    _cityIsValidated = NO;
                    AlertMessage *alert = [[AlertMessage alloc] init];
                    [alert viewController:self showAlertWithMessage:@"Failed to validate your location\nPlease enter valid city or tap auto-detect"];
                });
            }
        }]; // end of validation request
        
    } else { // we have not entered city into textField, location text field is empty
        dispatch_async(kMainQueue, ^{
            [self.activityProgress hide:YES];
            _cityIsValidated = NO;
            AlertMessage *alert = [[AlertMessage alloc] init];
            [alert viewController:self showAlertWithMessage:@"Please enter your city or tap auto-detect"];
        });
    }
}



#pragma mark -
#pragma mark Back button

- (void)backButtonPressed {
    dispatch_async(kMainQueue, ^{
        [self.activityProgress hide:YES];
        
        if ([_locationTextField isFirstResponder]) {
            [_locationTextField resignFirstResponder];
        }
        
        if ([_delegate respondsToSelector:@selector(locationViewController: backButtonPressed:)]) {
            [_delegate locationViewController:self backButtonPressed:nil];
        }
    });
}



#pragma mark -
#pragma mark UIPickerViewDataSource / UIPickerViewDelegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    // the number of columns of data
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    // the number of rows of data
    return _namesOfLocationsForPickerData.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    // the data to return for the row and component (column) that's being passed in
    return _namesOfLocationsForPickerData[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    // show location details in UI
    dispatch_async(kMainQueue, ^{
        _locationTextField.text = _namesOfLocationsForPickerData[row];
    });
    
    // save selected location into userDefaults
    NSDictionary *location = _locationsObjectsFromServerToSelect[row];
    NSLog(@"selected location %@", location);
    NSString *locationName = [location objectForKey:@"name"];
    NSString *locationID = [location objectForKey:@"l"];
    NSString *locationCity;
    NSString *locationStateOrCountry;
    
    NSArray *names = [locationName componentsSeparatedByString:@", "];
    if ([names count] == 2) {
        locationCity = [[names firstObject] stringByRemovingPercentEncoding];
        locationStateOrCountry = [[names lastObject] stringByRemovingPercentEncoding];
    } else {
        locationCity = locationName;
    }
    
    // save user current location details
    [self saveUserSelectedLocationWithLocationCity:locationCity locationStateOrCountry:locationStateOrCountry locationID:locationID];
    
    _cityIsValidated = YES;
    _locationNameBeforeManualEdit = locationName;
}

- (void)locationsPickerDoneAction:(id)sender {
    [self continueButtonPressed:nil];
}



#pragma mark -
#pragma mark Save user location

- (void)saveUserCurrentLocationWithLocationCity:(NSString *)locationCity locationStateOrCountry:(NSString *)locationStateOrCountry locationID:(NSString *)locationID {
    // save defined location details into userDefaults
    NSDictionary *location = [NSDictionary dictionaryWithObjectsAndKeys:
                              locationCity,             LOCATION_CITY_DICT_KEY,
                              locationStateOrCountry,   LOCATION_STATE_COUNTRY_DICT_KEY,
                              locationID,               LOCATION_ID_DICT_KEY, nil];
    UserHelper *userHelper = [[UserHelper alloc] init];
    [userHelper saveUserCurrentLocation:location];
    _nowSelectedLocation = location;
}


- (void)saveUserSelectedLocationWithLocationCity:(NSString *)locationCity locationStateOrCountry:(NSString *)locationStateOrCountry locationID:(NSString *)locationID {
    // save defined location details into userDefaults
    NSDictionary *location = [NSDictionary dictionaryWithObjectsAndKeys:
                              locationCity,             LOCATION_CITY_DICT_KEY,
                              locationStateOrCountry,   LOCATION_STATE_COUNTRY_DICT_KEY,
                              locationID,               LOCATION_ID_DICT_KEY, nil];
    UserHelper *userHelper = [[UserHelper alloc] init];
    [userHelper saveUserSelectedLocation:location];
    _nowSelectedLocation = location;
}



#pragma mark -
#pragma mark Memory handler

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



@end
