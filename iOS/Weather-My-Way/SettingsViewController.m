//
//  SettingsViewController.m
//  Copyright © 2016 Sequencing. All rights reserved.
//


#import "SettingsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "LocationViewController.h"
#import "SQFileSelectorProtocol.h"
#import "SQFilesAPI.h"
#import "SQOAuth.h"
#import "AlertMessage.h"
#import "UserHelper.h"
#import "SQToken.h"
#import "MBProgressHUD.h"
#import "ForecastData.h"
#import "PhonePrefixesHelper.h"
#import "UserAccountHelper.h"
#import "InternetConnection.h"
#import "SettingsUpdater.h"
#import "EmailHelper.h"
#import "DateHelper.h"


#define kMainQueue dispatch_get_main_queue()

// set up navigation controller outlook in order to have an impact to the current view controller outlook
@interface UINavigationController (StatusBarStyle)
@end

@implementation UINavigationController (StatusBarStyle)
-(UIViewController *)childViewControllerForStatusBarStyle {
    return self.topViewController;
}

-(UIViewController *)childViewControllerForStatusBarHidden {
    return self.topViewController;
}
@end





@interface SettingsViewController () <LocationViewControllerDelegate, SQFileSelectorProtocol, AlertMessageDialogDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, SettingsUpdaterDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

// settings properties
@property (weak, nonatomic) IBOutlet UILabel     *userLocation;
@property (weak, nonatomic) IBOutlet UIView      *changeLocationButtonView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *temperatureUnitsSegmentedControl;
@property (weak, nonatomic) IBOutlet UIView      *temperatureButtonView;

@property (weak, nonatomic) IBOutlet UILabel     *userAccountName;
@property (weak, nonatomic) IBOutlet UIView      *signOutButtonView;
@property (weak, nonatomic) IBOutlet UILabel     *userGeneticFile;
@property (weak, nonatomic) IBOutlet UIView      *changeFileButtonView;

@property (weak, nonatomic) IBOutlet UISwitch    *iPhoneNotificationSwitch;

@property (weak, nonatomic) IBOutlet UISwitch    *emailSwitch;
@property (weak, nonatomic) IBOutlet UITextField *emailAddressField;

@property (weak, nonatomic) IBOutlet UISwitch    *smsSwitch;
@property (weak, nonatomic) IBOutlet UITextField *phonePrefixField;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberField;

@property (weak, nonatomic) IBOutlet UITextField *weekendNotification;
@property (weak, nonatomic) IBOutlet UITextField *wakeUpTimeWeekdays;
@property (weak, nonatomic) IBOutlet UITextField *wakeUpTimeWeekends;
@property (weak, nonatomic) IBOutlet UITextField *timezone;

@property (retain, nonatomic) NSArray           *timezonePickerData;
@property (retain, nonatomic) NSDictionary      *timeZoneDictionary;

@property (retain, nonatomic) NSArray           *weekendNotificationPickerData;

@property (strong, nonatomic) NSDictionary      *phonePrefixesDict;
@property (retain, nonatomic) NSArray           *phonePrefixPickerData;

@property (assign, nonatomic) BOOL settingsChanged;

@property (nonatomic) MBProgressHUD             *activityProgress;
@property (strong, nonatomic) UserHelper        *userHelper;
@property (strong, nonatomic) UserAccountHelper *userAccountHelper;

// properties to handle any changes in settings
@property (assign, nonatomic) NSNumber          *nowSelectedTemperatureUnit;
@property (strong, nonatomic) NSDictionary      *nowSelectedFile;
@property (strong, nonatomic) NSDictionary      *nowSelectedLocation;

@property (weak, nonatomic) IBOutlet UIButton   *changeLocationButton;

@property (assign, nonatomic) BOOL              alreadyExecutedSettingsSyncRequest;
@property (assign, nonatomic) BOOL              alreadyPopulatedSettingsValues;

// stack for Cancel button
@property (strong, nonatomic) NSMutableArray    *undoStack;

@end



@implementation SettingsViewController {
    NSNumber *oldTemperatureUnit;
    NSNumber *oldIPhoneSetting;
    NSNumber *oldEmailSetting;
    NSNumber *oldSMSSetting;
    NSString *oldEmail;
    NSString *oldPhone;
    NSString *oldWakeUpTimeWeekdays;
    NSString *oldWakeUpTimeWeekends;
    NSString *oldTimeZone;
    NSString *oldWeekendNotification;
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
    NSLog(@"SettingsVC: viewDidLoad");
    
    // set navigation bar fully transpanent
    [self.navigationController.navigationBar setTranslucent:YES];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    
    // set up title
    self.title = @"Settings";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:19.0],
                                                                      NSForegroundColorAttributeName: [UIColor whiteColor]
                                                                      }];
    
    // adjust buttons views
    self.changeLocationButtonView.layer.cornerRadius  = 5;
    self.changeLocationButtonView.layer.masksToBounds = YES;
    self.temperatureButtonView.layer.cornerRadius  = 5;
    self.temperatureButtonView.layer.masksToBounds = YES;
    self.signOutButtonView.layer.cornerRadius  = 5;
    self.signOutButtonView.layer.masksToBounds = YES;
    self.changeFileButtonView.layer.cornerRadius  = 5;
    self.changeFileButtonView.layer.masksToBounds = YES;
    
    _alreadyExecutedSettingsSyncRequest = NO;
    _alreadyPopulatedSettingsValues = NO;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    if ([InternetConnection internetConnectionIsAvailable] && !_alreadyExecutedSettingsSyncRequest && !_alreadyExecutingSettingsSyncRequest) {
        dispatch_async(kMainQueue, ^{
            _alreadyExecutedSettingsSyncRequest = YES;
            _alreadyExecutingSettingsSyncRequest = YES;
            self.activityProgress = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            
            SettingsUpdater *settingsUpdater = [SettingsUpdater sharedInstance];
            settingsUpdater.delegate = self;
            [settingsUpdater retrieveUserSettings];
        });
    } else {
        dispatch_async(kMainQueue, ^{
            if (!_alreadyPopulatedSettingsValues) {
                // pre-populate user settings
                [self prepopulateUserSettings];
                _alreadyPopulatedSettingsValues = YES;
                NSLog(@"SettingsVC: prepopulateUserSettings");
            }
        });
    }
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)dealloc {
    NSLog(@"SettingsVC: dealloc");
    [super cleanup];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent; // your own style
}




#pragma mark - SettingsUpdaterDelegate
- (void)settingsSyncRequestStarted {
    dispatch_async(kMainQueue, ^{
        _alreadyExecutingSettingsSyncRequest = YES;
    });
}

- (void)settingsSyncRequestFinished {
    dispatch_async(kMainQueue, ^{
        _alreadyExecutingSettingsSyncRequest = NO;
        _alreadyPopulatedSettingsValues = YES;
        
        // pre-populate user settings
        [self prepopulateUserSettings];
        [self.activityProgress hide:YES];
    });
}



#pragma mark - Prepopulate user settings

- (void)prepopulateUserSettings {
    [self prepopulateLocation];
    [self prepopulateTemperatureUnits];
    
    [self prepopulateUserAccountName];
    [self prepopulateGeneticFile];
    
    [self prepopulateIPhoneNotificationSetting];
    
    [self prepopulateEmailSetting];
    [self prepopulateEmailAddress];
    
    [self prepopulateSMSSetting];
    [self prepopulatePhonePrefix];
    [self prepopulatePhoneNumber];
    
    [self prepopulateWakeUpTimeWeekdays];
    [self prepopulateWakeUpTimeWeekends];
    
    [self prepopulateTimezone];
    [self prepopulateWeekendNotification];
}



#pragma mark - Location / LocationViewControllerDelegate

- (void)prepopulateLocation {
    ForecastData *forecastContainer = [ForecastData sharedInstance];
    NSDictionary *currentLocation   = [self.userHelper loadUserCurrentLocation];
    NSDictionary *selectedLocation  = [self.userHelper loadUserSelectedLocation];
    NSDictionary *defaultLocation   = [self.userHelper loadUserDefaultLocation];
    NSString *currentLocationID     = [currentLocation objectForKey:LOCATION_ID_DICT_KEY];
    NSString *selectedLocationID    = [selectedLocation objectForKey:LOCATION_ID_DICT_KEY];
    NSString *defaultLocationID     = [defaultLocation objectForKey:LOCATION_ID_DICT_KEY];
    NSString *locationCity;
    NSString *locationStateCountry;
    
    if (forecastContainer.locationForForecast != nil) {
        locationCity            = [forecastContainer.locationForForecast objectForKey:LOCATION_CITY_DICT_KEY];
        locationStateCountry    = [forecastContainer.locationForForecast objectForKey:LOCATION_STATE_COUNTRY_DICT_KEY];
        
    } else {
        if (forecastContainer.forecast != nil) {
            NSString *nowDisplayedLocationID = [[[forecastContainer.forecast objectForKey:@"current_observation"] objectForKey:@"display_location"] objectForKey:@"wmo"];
            
            if ([selectedLocationID containsString:nowDisplayedLocationID]) {
                locationCity            = [selectedLocation objectForKey:LOCATION_CITY_DICT_KEY];
                locationStateCountry    = [selectedLocation objectForKey:LOCATION_STATE_COUNTRY_DICT_KEY];
                
            } else if ([currentLocationID containsString:nowDisplayedLocationID]) {
                locationCity            = [currentLocation objectForKey:LOCATION_CITY_DICT_KEY];
                locationStateCountry    = [currentLocation objectForKey:LOCATION_STATE_COUNTRY_DICT_KEY];
                
            } else if ([defaultLocationID containsString:nowDisplayedLocationID]) {
                locationCity            = [defaultLocation objectForKey:LOCATION_CITY_DICT_KEY];
                locationStateCountry    = [defaultLocation objectForKey:LOCATION_STATE_COUNTRY_DICT_KEY];
                
            } else {
                locationCity            = [[[forecastContainer.forecast objectForKey:@"current_observation"] objectForKey:@"display_location"] objectForKey:@"city"];
                
                if ([[[[forecastContainer.forecast objectForKey:@"current_observation"] objectForKey:@"display_location"] objectForKey:@"state"] length] != 0) {
                    locationStateCountry = [[[forecastContainer.forecast objectForKey:@"current_observation"] objectForKey:@"display_location"] objectForKey:@"state"];
                } else {
                    locationStateCountry = [[[forecastContainer.forecast objectForKey:@"current_observation"] objectForKey:@"display_location"] objectForKey:@"state_name"];
                }
            }
        }
    }
    
    if ([locationCity length] != 0) {
        _userLocation.text = [NSString stringWithFormat:@"%@, %@", locationCity, locationStateCountry];
        NSLog(@"location on settings screen while prepopulation: %@", _userLocation.text);
    }
}

- (IBAction)setLocationButtonPressed:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Location" bundle:nil];
    UINavigationController *navigationVC = (UINavigationController *)[storyboard instantiateInitialViewController];
    navigationVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    LocationViewController *locationVC = [navigationVC viewControllers][0];
    locationVC.backButton = YES;
    locationVC.delegate = self;
    [self presentViewController:navigationVC animated:YES completion:nil];
}


// LocationViewControllerDelegate
- (void)locationViewController:(UIViewController *)controller didSelectLocation:(NSDictionary *)location {
    [controller dismissViewControllerAnimated:YES completion:nil];
    NSString *locationCity;
    NSString *locationStateCountry;
    
    if ([[location objectForKey:LOCATION_CITY_DICT_KEY] length] != 0) {
        locationCity         = [location objectForKey:LOCATION_CITY_DICT_KEY];
        locationStateCountry = [location objectForKey:LOCATION_STATE_COUNTRY_DICT_KEY];
        _nowSelectedLocation = location;
        [self.userHelper saveUserSelectedLocation:location];
        
    } else {
        NSDictionary *currentLocation  = [self.userHelper loadUserCurrentLocation];
        NSDictionary *selectedLocation = [self.userHelper loadUserSelectedLocation];
        NSDictionary *defaultLocation  = [self.userHelper loadUserDefaultLocation];
        
        if (![self.userHelper locationIsEmpty:currentLocation]) {
            [self.userHelper saveUserSelectedLocation:currentLocation];
            locationCity         = [currentLocation objectForKey:LOCATION_CITY_DICT_KEY];
            locationStateCountry = [currentLocation objectForKey:LOCATION_STATE_COUNTRY_DICT_KEY];
            _nowSelectedLocation = currentLocation;
            
        } else if (![self.userHelper locationIsEmpty:selectedLocation]) {
            locationCity         = [selectedLocation objectForKey:LOCATION_CITY_DICT_KEY];
            locationStateCountry = [selectedLocation objectForKey:LOCATION_STATE_COUNTRY_DICT_KEY];
            _nowSelectedLocation = selectedLocation;
            
        } else {
            [self.userHelper saveUserSelectedLocation:defaultLocation];
            locationCity         = [defaultLocation objectForKey:LOCATION_CITY_DICT_KEY];
            locationStateCountry = [defaultLocation objectForKey:LOCATION_STATE_COUNTRY_DICT_KEY];
            _nowSelectedLocation = defaultLocation;
        }
    }
    
    if ([locationCity length] != 0) {
        dispatch_async(kMainQueue, ^{
            _userLocation.text = [NSString stringWithFormat:@"%@, %@", locationCity, locationStateCountry];
            
            if (![InternetConnection internetConnectionIsAvailable])
                return;
            [[SQOAuth sharedInstance] token:^(SQToken *token, NSString *accessToken) {
                if (token && [token.accessToken length] > 0) { // send selected location to user account on server
                    
                    NSString *locationID = [_nowSelectedLocation objectForKey:LOCATION_ID_DICT_KEY];
                    NSDictionary *parameters = @{@"city" : locationID,
                                                 @"token": token.accessToken};
                    [self.userAccountHelper sendSelectedLocationInfoWithParameters:parameters];
                }
            }];
        });
    }
}


- (void)locationViewController:(UIViewController *)controller backButtonPressed:(id)sender {
    [controller dismissViewControllerAnimated:YES completion:nil];
};



#pragma mark - Temperature Units

- (void)prepopulateTemperatureUnits {
    NSNumber *userTemperatureUnit = [self.userHelper loadSettingTemperatureUnit];
    
    switch ([userTemperatureUnit integerValue]) {
        case 0: {
            _temperatureUnitsSegmentedControl.selectedSegmentIndex = [userTemperatureUnit unsignedShortValue];
            oldTemperatureUnit = [NSNumber numberWithInt:(int)_temperatureUnitsSegmentedControl.selectedSegmentIndex];
        } break;
            
        case 1: {
            _temperatureUnitsSegmentedControl.selectedSegmentIndex = [userTemperatureUnit unsignedShortValue];
            oldTemperatureUnit = [NSNumber numberWithInt:(int)_temperatureUnitsSegmentedControl.selectedSegmentIndex];
        } break;
            
        case 2: { // default value
            TemperatureUnit defaultTemperatureUnit = Fahrenheit;
            _temperatureUnitsSegmentedControl.selectedSegmentIndex = defaultTemperatureUnit;
            
            // right away save default value into user defaults
            [self.userHelper saveSettingTemperatureUnit:[NSNumber numberWithUnsignedShort:defaultTemperatureUnit]];
        } break;
        default: break;
    }
}

- (IBAction)temperatureUnitsSegmentedControlChanged:(UISegmentedControl *)sender {
    [self.userHelper saveSettingTemperatureUnit:[NSNumber numberWithInteger:sender.selectedSegmentIndex]];
    _nowSelectedTemperatureUnit = [NSNumber numberWithInteger:sender.selectedSegmentIndex];
}



#pragma mark - Account / Revoke Access / AlertMessageDialogDelegate

- (void)prepopulateUserAccountName {
    NSString *userAccountEmail = [self.userHelper loadUserAccountEmail];
    if ([userAccountEmail length] != 0) {
        _userAccountName.text = [NSString stringWithFormat:@"%@", userAccountEmail];
    }
}

- (IBAction)revokeAccessButtonPressed:(id)sender {
    AlertMessage *alertMessage = [[AlertMessage alloc] init];
    alertMessage.delegate = self;
    [alertMessage viewController:self
            showAlertWithMessage:@"Are you sure you want to sign out?"
                   withYesAction:@"Confirm" withNoAction:@"Cancel"];
}

// AlertMessageDialogDelegate
- (void)yesButtonPressed {
    [_delegate settingsViewControllerUserDidSignOut:self];
}



#pragma mark - Genetic File

- (void)prepopulateGeneticFile {
    NSDictionary *fileDict = [self.userHelper loadUserGeneticFile];
    if (!fileDict) {
        _userGeneticFile.text = @"Sorry, no selected genetic file found. Try to select one";
        
    } else {
        if ([fileDict isKindOfClass:[NSString class]]) {
            if ([(NSString *)fileDict length] != 0) {
                _userGeneticFile.text = (NSString *)fileDict;
                
            } else {
                _userGeneticFile.text = @"Sorry, no selected genetic file found. Try to select one";
            }
            
        } else if ([fileDict isKindOfClass:[NSDictionary class]]) {
            if ([fileDict objectForKey:GENETIC_FILE_NAME_DICT_KEY] != nil &&
                [[fileDict objectForKey:GENETIC_FILE_NAME_DICT_KEY] length] != 0) {
                _userGeneticFile.text = [fileDict objectForKey:GENETIC_FILE_NAME_DICT_KEY];
        
            } else {
                _userGeneticFile.text = @"Sorry, no selected genetic file found. Try to select one";
            }
        }
    }
}


- (IBAction)selectFileButtonPressed:(id)sender {
    if (![InternetConnection internetConnectionIsAvailable]) {
        [[[AlertMessage alloc] init] viewController:self showAlertWithTitle:@"Can't load genetic files" withMessage:NO_INTERNET_CONNECTION_TEXT];
        return;
    }
    
    self.activityProgress = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    // prepare selected file id
    NSString *selectedFileID;
    if ([[_userGeneticFile.text lowercaseString] rangeOfString:@"sorry, "].location == NSNotFound && [_userGeneticFile.text length] != 0) {
        
        NSDictionary *fileDict = [self.userHelper loadUserGeneticFile];
        if ([fileDict objectForKey:GENETIC_FILE_ID_DICT_KEY] != nil && [[fileDict objectForKey:GENETIC_FILE_ID_DICT_KEY] length] != 0)
            selectedFileID = [fileDict objectForKey:GENETIC_FILE_ID_DICT_KEY];
    }
    
    // prepare video file
    //TODO: change methods to be static
    //TODO: move video selection logic to VideoHelper
    // analyze other places and reduce code duplication
    // videoName shoud be returned
    ForecastData *forecastData = [ForecastData sharedInstance];
    VideoHelper *videoHelper = [[VideoHelper alloc] init];
    NSString *videoFileName = [self.userHelper loadKnownVideoFileName];
    if (!videoFileName || [videoFileName length] == 0) {
        if ([forecastData.weatherType length] != 0 && [forecastData.dayNight length] != 0)
            videoFileName = [videoHelper getVideoNameBasedOnWeatherType:forecastData.weatherType AndDayNight:forecastData.dayNight];
        else
            videoFileName = [videoHelper getRandomVideoName];
    }
    
    [[SQFilesAPI sharedInstance] showFilesWithTokenProvider:[SQOAuth sharedInstance]
                                            showCloseButton:YES
                                   previouslySelectedFileID:selectedFileID
                                    backgroundVideoFileName:videoFileName
                                                   delegate:self];
}


#pragma mark SQFileSelectorProtocol
- (void)selectedGeneticFile:(NSDictionary *)file {
    dispatch_async(kMainQueue, ^{
        [self.activityProgress hide:YES];
        [[SQFilesAPI sharedInstance] setDelegate:nil];
        
        if (file == nil) return;
        if ([[file objectForKey:@"Id"] length] == 0) return;
        
        // save selected file into user defaults first && set genetic file in UI
        [self.userHelper saveUserGeneticFile:file];
        NSDictionary *fileDict = [self.userHelper loadUserGeneticFile];
        _userGeneticFile.text = [fileDict objectForKey:GENETIC_FILE_NAME_DICT_KEY];
        _nowSelectedFile = fileDict;
        
        // send selected file into user account on server
        if (![InternetConnection internetConnectionIsAvailable]) return;
        
        [[SQOAuth sharedInstance] token:^(SQToken *token, NSString *accessToken) {
            if (token && [token.accessToken length] > 0) {
                
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
        }];
    });
}


- (void)errorWhileReceivingGeneticFiles:(NSError *)error {
    dispatch_async(kMainQueue, ^{
        [self.activityProgress hide:YES];
        [[SQFilesAPI sharedInstance] setDelegate:nil];
        if (error)
            [[[AlertMessage alloc] init] viewController:self showAlertWithMessage:error.localizedDescription];
        else
            [[[AlertMessage alloc] init] viewController:self showAlertWithMessage:@"Sorry, can't load genetic files"];
    });
}


- (void)closeButtonPressed {
    dispatch_async(kMainQueue, ^{
        [self.activityProgress hide:YES];
        [[SQFilesAPI sharedInstance] setDelegate:nil];
    });
}




#pragma mark - iPhone notification

- (void)prepopulateIPhoneNotificationSetting {
    NSNumber *iPhoneNotificationUserValue = [self.userHelper loadSettingIPhoneDailyForecast];
    switch ([iPhoneNotificationUserValue integerValue]) {
        case 0: {
            [_iPhoneNotificationSwitch setOn:NO];
            // save current value in order to compare if it was changed, when close the Settings
            oldIPhoneSetting = [NSNumber numberWithBool:[_iPhoneNotificationSwitch isOn]];
        } break;
            
        case 1: {
            [_iPhoneNotificationSwitch setOn:YES];
            // save current value in order to compare if it was changed, when close the Settings
            oldIPhoneSetting = [NSNumber numberWithBool:[_iPhoneNotificationSwitch isOn]];
        } break;
            
        default: {
            [_iPhoneNotificationSwitch setOn:YES];
            // right away save default value into user defaults
            [self.userHelper saveSettingIPhoneDailyForecast:[NSNumber numberWithBool:YES]];
        }   break;
    }
}


- (IBAction)iPhoneSwitchChanged:(UISwitch *)sender {
    [self.userHelper saveSettingIPhoneDailyForecast:[NSNumber numberWithBool:[sender isOn]]];
}



#pragma mark - Email setting / Email address

- (void)prepopulateEmailSetting {
    NSNumber *emailDailyForecastUserValue = [self.userHelper loadSettingEmailDailyForecast];
    switch ([emailDailyForecastUserValue integerValue]) {
        case 0: {
            [_emailSwitch setOn:NO];
            [_emailAddressField setEnabled:NO];
            [_emailAddressField setBackgroundColor:[UIColor lightGrayColor]];
            // save current value in order to compare if it was changed, when close the Settings
            oldEmailSetting = [NSNumber numberWithBool:[_emailSwitch isOn]];
        } break;
            
        case 1: {
            [_emailSwitch setOn:YES];
            [_emailAddressField setEnabled:YES];
            [_emailAddressField setBackgroundColor:[UIColor whiteColor]];
            // save current value in order to compare if it was changed, when close the Settings
            oldEmailSetting = [NSNumber numberWithBool:[_emailSwitch isOn]];
        } break;
            
        default: {  // default value
            [_emailSwitch setOn:NO];
            [_emailAddressField setEnabled:NO];
            [_emailAddressField setBackgroundColor:[UIColor lightGrayColor]];
            // right away save default value into user defaults
            [self.userHelper saveSettingEmailDailyForecast:[NSNumber numberWithBool:NO]];
        }   break;
    }
}


- (IBAction)emailSwitchChanged:(UISwitch *)sender {
    [self.userHelper saveSettingEmailDailyForecast:[NSNumber numberWithBool:[sender isOn]]];
    if ([sender isOn]) {
        [_emailAddressField setEnabled:YES];
        [_emailAddressField setBackgroundColor:[UIColor whiteColor]];
    } else {
        [_emailAddressField setEnabled:NO];
        [_emailAddressField setBackgroundColor:[UIColor lightGrayColor]];
    }
}


- (void)prepopulateEmailAddress {
    NSString *emailAddress = [self.userHelper loadSettingEmailAddressForForecast];
    if ([emailAddress length] != 0) {
        _emailAddressField.text = emailAddress;
        // save current value in order to compare if it was changed, when close the Settings
        oldEmail = emailAddress;
    }
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 44)];
    UIBarButtonItem *undoItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                              target:self
                                                                              action:@selector(undoActionPressed)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                   target:nil
                                                                                   action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self
                                                                                action:@selector(emailDoneAction)];
    [toolbar setItems:@[undoItem, flexibleSpace, doneButton]];
    toolbar.translucent = YES;
    [_emailAddressField setInputAccessoryView:toolbar];
    _emailAddressField.delegate = self;
}


- (void)emailDoneAction {
    [_emailAddressField resignFirstResponder];
}




#pragma mark - SMS setting

- (void)prepopulateSMSSetting {
    NSNumber *smsDailyForecastUserValue = [self.userHelper loadSettingSMSDailyForecast];
    switch ([smsDailyForecastUserValue integerValue]) {
        case 0: {
            [_smsSwitch setOn:NO];
            [_phonePrefixField setEnabled:NO];
            [_phonePrefixField setBackgroundColor:[UIColor lightGrayColor]];
            [_phoneNumberField setEnabled:NO];
            [_phoneNumberField setBackgroundColor:[UIColor lightGrayColor]];
            // save current value in order to compare if it was changed, when close the Settings
            oldSMSSetting = [NSNumber numberWithBool:[_smsSwitch isOn]];
        } break;
            
        case 1: {
            [_smsSwitch setOn:YES];
            [_phonePrefixField setEnabled:YES];
            [_phonePrefixField setBackgroundColor:[UIColor whiteColor]];
            [_phoneNumberField setEnabled:YES];
            [_phoneNumberField setBackgroundColor:[UIColor whiteColor]];
            // save current value in order to compare if it was changed, when close the Settings
            oldSMSSetting = [NSNumber numberWithBool:[_smsSwitch isOn]];
        } break;
            
        default: {  // default value
            [_smsSwitch setOn:NO];
            [_phonePrefixField setEnabled:NO];
            [_phonePrefixField setBackgroundColor:[UIColor lightGrayColor]];
            [_phoneNumberField setEnabled:NO];
            [_phoneNumberField setBackgroundColor:[UIColor lightGrayColor]];
            // right away save default value into user defaults
            [self.userHelper saveSettingSMSDailyForecast:[NSNumber numberWithBool:NO]];
        }   break;
    }
}


- (IBAction)smsSwitchChanged:(UISwitch *)sender {
    [self.userHelper saveSettingSMSDailyForecast:[NSNumber numberWithBool:[sender isOn]]];
    if ([sender isOn]) {
        [_phonePrefixField setEnabled:YES];
        [_phonePrefixField setBackgroundColor:[UIColor whiteColor]];
        [_phoneNumberField setEnabled:YES];
        [_phoneNumberField setBackgroundColor:[UIColor whiteColor]];
    } else {
        [_phonePrefixField setEnabled:NO];
        [_phonePrefixField setBackgroundColor:[UIColor lightGrayColor]];
        [_phoneNumberField setEnabled:NO];
        [_phoneNumberField setBackgroundColor:[UIColor lightGrayColor]];
    }
}



#pragma mark - Phone prefix

- (void)prepopulatePhonePrefixPickerWithData {
    PhonePrefixesHelper *phonePrefixesHelper = [[PhonePrefixesHelper alloc] sharedInstance];
    NSDictionary *phonePrefixesDict = [phonePrefixesHelper phonePrefixesDictionaryWithCodesInKeys];
    NSArray *phonePrefixesArray = [phonePrefixesHelper arrayOfCountriesWithCodesInNames];
    
    if (phonePrefixesDict && [[phonePrefixesDict allKeys] count] > 0) {
        _phonePrefixesDict = phonePrefixesDict;
    }
    
    if ([phonePrefixesArray count] > 0) {
        _phonePrefixPickerData = [phonePrefixesArray sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    }
}


- (void)prepopulatePhonePrefix {
    [self prepopulatePhonePrefixPickerWithData];
    
    NSString *phonePrefix = [self.userHelper loadSettingPhonePrefixForForecast];
    if ([phonePrefix length] != 0) {
        _phonePrefixField.text = phonePrefix;
        
    } else {
        // getting country code from json info
        // NSString *countryISO3166 = [self countryISO3166FromForecastJSON];
        // though it's better to get country code from device local settings
        NSString *countryISO3166 = [[NSLocale currentLocale] objectForKey: NSLocaleCountryCode];
        
        PhonePrefixesHelper *phonePrefixesHelper = [[PhonePrefixesHelper alloc] sharedInstance];
        NSString *countryFullName = [phonePrefixesHelper countryFullNameByCountryISO3166:countryISO3166];
        
        // TO_REMOVE
        NSString *phoneNumber = [self.userHelper loadSettingPhoneNumberForForecast];
        
        if ([self doesPickerDataArrayContainsCountry:countryFullName] && [self doesPhonePrefixesDictionaryContainsCountry:countryFullName]) {
            _phonePrefixField.text = [self countryWithCodeByCountryFullName:countryFullName];
            [self.userHelper saveSettingPhonePrefixForForecast:_phonePrefixField.text];
            
            // TO_REMOVE
            if ([phoneNumber length] == 0) {
                _phoneNumberField.text = [_phonePrefixesDict objectForKey:_phonePrefixField.text];
                [self.userHelper saveSettingPhoneNumberForForecast:_phoneNumberField.text];
            }

            
        } else if ([self doesPickerDataArrayContainsCountry:kDefaultCountry] && [[_phonePrefixesDict allKeys] containsObject:kDefaultCountry]) {
            _phonePrefixField.text = [self countryWithCodeByCountryFullName:kDefaultCountry];
            [self.userHelper saveSettingPhonePrefixForForecast:_phonePrefixField.text];
            
            // TO_REMOVE
            if ([phoneNumber length] == 0) {
                _phoneNumberField.text = [_phonePrefixesDict objectForKey:_phonePrefixField.text];
                [self.userHelper saveSettingPhoneNumberForForecast:_phoneNumberField.text];
            }
        }
    }
    _phonePrefixField.rightViewMode = UITextFieldViewModeAlways;
    _phonePrefixField.rightView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"down-arrow-icon"]];
}


- (IBAction)phonePrefixFieldPressed:(id)sender {
    UIPickerView *pickerView = [[UIPickerView alloc] init];
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 44)];
    UIBarButtonItem *undoItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                              target:self
                                                                              action:@selector(undoActionPressed)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                   target:nil
                                                                                   action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self
                                                                                action:@selector(phonePrefixPickerDoneAction:)];
    [toolbar setItems:@[undoItem, flexibleSpace, doneButton]];
    toolbar.translucent = YES;
    pickerView.delegate = self;
    pickerView.dataSource = self;
    pickerView.accessibilityIdentifier = @"phonePrefixField";
    
    [_phonePrefixField setInputView:pickerView];
    [_phonePrefixField setInputAccessoryView:toolbar];
    
    // preselect value if any
    if (([_phonePrefixField.text length] != 0) && [self doesPickerDataArrayContainsCountry:_phonePrefixField.text]) {
        NSInteger index = [self indexInArrayForCountry:_phonePrefixField.text];
        [pickerView selectRow:index inComponent:0 animated:NO];
    }
}


- (void)phonePrefixPickerDoneAction:(id)sender {
    [_phonePrefixField resignFirstResponder];
}



#pragma mark - Phone number

- (void)prepopulatePhoneNumber {
    NSString *phoneNumber = [self.userHelper loadSettingPhoneNumberForForecast];
    if ([phoneNumber length] != 0) {
        _phoneNumberField.text = phoneNumber;
        // save current value in order to compare if it was changed, when close the Settings
        oldPhone = phoneNumber;
        
    } else {
        if ([_phonePrefixField.text length] != 0) {
            for (NSString *key in _phonePrefixesDict) {
                if ([_phonePrefixField.text containsString:key]) {
                    _phoneNumberField.text = [_phonePrefixesDict objectForKey:key];
                    [self.userHelper saveSettingPhoneNumberForForecast:_phoneNumberField.text];
                }
            }
        }
    }
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 44)];
    UIBarButtonItem *undoItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                              target:self
                                                                              action:@selector(undoActionPressed)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                   target:nil
                                                                                   action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self
                                                                                action:@selector(phoneNumberDoneAction)];
    [toolbar setItems:@[undoItem, flexibleSpace, doneButton]];
    toolbar.translucent = YES;
    [_phoneNumberField setInputAccessoryView:toolbar];
    _phoneNumberField.delegate = self;
}

- (void)phoneNumberDoneAction {
    [_phoneNumberField resignFirstResponder];
}



#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
    // save email
    if ([textField.accessibilityIdentifier isEqualToString:@"email"]) {
        
        if ([textField.text length] != 0) {
            EmailHelper *emailHelper = [[EmailHelper alloc] init];
            if ([emailHelper isEmailValid:textField.text]) {
                [self.userHelper saveSettingEmailAddressForForecast:textField.text];
            } else {
                AlertMessage *alertMessage = [[AlertMessage alloc] init];
                [alertMessage viewController:self
                          showAlertWithTitle:@"Provided email is invalid"
                                 withMessage:@"Please provide valid email address"];
            }
        }
    }
    
    // save phone
    if ([textField.accessibilityIdentifier isEqualToString:@"phone"]) {
        dispatch_async(kMainQueue, ^{
            NSString *phoneNumberCorrected = [self.userAccountHelper correctPhoneNumber:textField.text];
            _phoneNumberField.text = phoneNumberCorrected;
            [self.userHelper saveSettingPhoneNumberForForecast:phoneNumberCorrected];
        });
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - UndoStack
- (void)prepareUndoStack {
    self.undoStack = [[NSMutableArray alloc] init];
    NSString *data;
    UITextField *textField;
    
    NSMethodSignature *methodSignature = [self methodSignatureForSelector:@selector(revertData:forTextField:)];
    NSInvocation *undoChangeAction = [NSInvocation invocationWithMethodSignature:methodSignature];
    [undoChangeAction setTarget:self];
    [undoChangeAction setSelector:@selector(revertData:forTextField:)];
    
    if ([_emailAddressField isFirstResponder]) {
        data = _emailAddressField.text;
        textField = _emailAddressField;
        
    } else if ([_phonePrefixField isFirstResponder]) {
        data = _phonePrefixField.text;
        textField = _phonePrefixField;
        
    } else if ([_phoneNumberField isFirstResponder]) {
        data = _phoneNumberField.text;
        textField = _phoneNumberField;
        
    } else if ([_weekendNotification isFirstResponder]) {
        data = _weekendNotification.text;
        textField = _weekendNotification;
        
    } else if ([_wakeUpTimeWeekdays isFirstResponder]) {
        data = _wakeUpTimeWeekdays.text;
        textField = _wakeUpTimeWeekdays;
        
    } else if ([_wakeUpTimeWeekends isFirstResponder]) {
        data = _wakeUpTimeWeekends.text;
        textField = _wakeUpTimeWeekends;
        
    } else if ([_timezone isFirstResponder]) {
        data = _timezone.text;
        textField = _timezone;
    }
    
    [undoChangeAction setArgument:&data atIndex:2];
    [undoChangeAction setArgument:&textField atIndex:3];
    [undoChangeAction retainArguments];
    
    [self.undoStack addObject:undoChangeAction];
}


- (void)undoActionPressed {
    if (self.undoStack.count > 0) {
        NSInvocation *undoAction = [self.undoStack lastObject];
        [self.undoStack removeLastObject];
        [undoAction invoke];
    }
}


- (void)revertData:(NSString *)data forTextField:(UITextField *)textfield {
    textfield.text = data;
    [textfield resignFirstResponder];
    
    switch (textfield.tag) {
        case 2: {   // phone prefix selector
            [self.userHelper saveSettingPhonePrefixForForecast:_phonePrefixField.text];
            _phoneNumberField.text = oldPhone;
            [self.userHelper saveSettingPhoneNumberForForecast:_phoneNumberField.text];
        }   break;
            
        case 4: {   // weekend notification selector
            [self.userHelper saveSettingWeekendNotification:_weekendNotification.text];
        }   break;
            
        case 5: {   // wake up weekdays selector
            [self.userHelper saveSettingWakeUpTimeWeekdays:_wakeUpTimeWeekdays.text];
        }   break;
            
        case 6: {   // wake up weekends selector
            [self.userHelper saveSettingWakeUpTimeWeekends:_wakeUpTimeWeekends.text];
        }   break;
            
        case 7: {   // timezone selector
            [self.userHelper saveSettingTimezone:_timezone.text];
        }   break;
            
        default: break;
    }
}


#pragma mark - Keyboard delegate

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGFloat keyboardHeight = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height + 24;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardHeight, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    CGRect visibleRect = self.view.frame;
    visibleRect.size.height -= keyboardHeight;
    
    CGPoint textFieldOrigin;
    if ([_emailAddressField isFirstResponder]) {
        textFieldOrigin = _emailAddressField.frame.origin;
        
    } else if ([_phonePrefixField isFirstResponder]) {
        textFieldOrigin = _phonePrefixField.frame.origin;
        
    } else if ([_phoneNumberField isFirstResponder]) {
        textFieldOrigin = _phoneNumberField.frame.origin;
        
    } else if ([_weekendNotification isFirstResponder]) {
        textFieldOrigin = _weekendNotification.frame.origin;
        
    } else if ([_wakeUpTimeWeekdays isFirstResponder]) {
        textFieldOrigin = _wakeUpTimeWeekdays.frame.origin;
        
    } else if ([_wakeUpTimeWeekends isFirstResponder]) {
        textFieldOrigin = _wakeUpTimeWeekends.frame.origin;
        
    } else if ([_timezone isFirstResponder]) {
        textFieldOrigin = _timezone.frame.origin;
    }
    
    if (!CGRectContainsPoint(visibleRect, textFieldOrigin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, textFieldOrigin.y - keyboardHeight);
        [self.scrollView setContentOffset:scrollPoint animated:YES];
    }
    
    [self prepareUndoStack];
}


- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGFloat keyboardHeight = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
    
    if (self.view.frame.origin.y >= 0) {
        [self setViewMovedUp:YES keyboardHeight:keyboardHeight];
        
    } else if (self.view.frame.origin.y < 0) {
        [self setViewMovedUp:NO keyboardHeight:keyboardHeight];
    }
}


//method to move the view up/down whenever the keyboard is shown/dismissed
- (void)setViewMovedUp:(BOOL)movedUp keyboardHeight:(CGFloat)keyboardHeight {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    if (movedUp) {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= keyboardHeight;
        rect.size.height += keyboardHeight;
        
    } else {
        // revert back to the normal state.
        rect.origin.y += keyboardHeight;
        rect.size.height -= keyboardHeight;
    }
    
    self.view.frame = rect;
    [UIView commitAnimations];
}



#pragma mark - TimePickerWeekdays

- (void)prepopulateWakeUpTimeWeekdays {
    NSString *wakeUpTimeWeekdays = [self.userHelper loadSettingWakeUpTimeWeekdays];
    
    if ([wakeUpTimeWeekdays length] != 0) {
        _wakeUpTimeWeekdays.text = [DateHelper convertedTimeStringToLocaleFromUSTimeString:wakeUpTimeWeekdays];
        oldWakeUpTimeWeekdays = _wakeUpTimeWeekdays.text; // save current value in order to compare if it was changed, when close the Settings
        
    } else {
        _wakeUpTimeWeekdays.text = [DateHelper convertedTimeStringToLocaleFromUSTimeString:kWakeUpTimeForWeekDays]; // use default value
        oldWakeUpTimeWeekdays = _wakeUpTimeWeekdays.text;
        [self.userHelper saveSettingWakeUpTimeWeekdays:kWakeUpTimeForWeekDays]; // right away save value into user defaults
    }
    _wakeUpTimeWeekdays.rightViewMode = UITextFieldViewModeAlways;
    _wakeUpTimeWeekdays.rightView     = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"down-arrow-icon"]];
}




- (IBAction)wakeUpWeekdaysPressed:(id)sender {
    UIDatePicker *timePicker = [[UIDatePicker alloc] init];
    timePicker.datePickerMode = UIDatePickerModeTime;
    timePicker.timeZone = [NSTimeZone localTimeZone];
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 44)];
    UIBarButtonItem *undoItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                              target:self
                                                                              action:@selector(undoActionPressed)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                   target:nil
                                                                                   action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self
                                                                                action:@selector(weekdaysTimePickerDoneAction:)];
    [timePicker addTarget:self action:@selector(weekdaysTimePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    [toolbar setItems:@[undoItem, flexibleSpace, doneButton]];
    toolbar.translucent = YES;
    
    [_wakeUpTimeWeekdays setInputView:timePicker];
    [_wakeUpTimeWeekdays setInputAccessoryView:toolbar];
    
    if ([_wakeUpTimeWeekdays.text length] != 0) {
        NSDate *wakeUpTime = [DateHelper convertedDateToLocaleFromTimeString:_wakeUpTimeWeekdays.text];
        
        @try {
            [timePicker setDate:wakeUpTime animated:YES];
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception.reason);
        }
        @finally {
            NSLog(@"Can't set date %@", wakeUpTime);
        }
    }
}


- (void)weekdaysTimePickerValueChanged:(id)sender {
    UIDatePicker *timePicker = (UIDatePicker *)[_wakeUpTimeWeekdays inputView];
    
    // show selected time in field
    _wakeUpTimeWeekdays.text = [DateHelper actualTimeStringFromDate:timePicker.date];
    
    // save selected time to user settings
    [self.userHelper saveSettingWakeUpTimeWeekdays:[DateHelper convertedTimeStringToUSFromDate:timePicker.date]];
}


- (void)weekdaysTimePickerDoneAction:(id)sender {
    [_wakeUpTimeWeekdays resignFirstResponder];
}




#pragma mark - TimePickerWeekends
- (void)prepopulateWakeUpTimeWeekends {
    NSString *wakeUpTimeWeekends = [self.userHelper loadSettingWakeUpTimeWeekends];
    
    if ([wakeUpTimeWeekends length] != 0) {
        _wakeUpTimeWeekends.text = [DateHelper convertedTimeStringToLocaleFromUSTimeString:wakeUpTimeWeekends];
        oldWakeUpTimeWeekends = _wakeUpTimeWeekends.text; // save current value in order to compare if it was changed, when close the Settings
        
    } else {
        _wakeUpTimeWeekends.text = [DateHelper convertedTimeStringToLocaleFromUSTimeString:kWakeUpTimeForWeekEnds]; // default value
        oldWakeUpTimeWeekends = _wakeUpTimeWeekends.text;
        [self.userHelper saveSettingWakeUpTimeWeekends:kWakeUpTimeForWeekEnds]; // right away save value into user defaults
    }
    _wakeUpTimeWeekends.rightViewMode = UITextFieldViewModeAlways;
    _wakeUpTimeWeekends.rightView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"down-arrow-icon"]];
}


- (IBAction)wakeUpWeekendsPressed:(id)sender {
    UIDatePicker *timePicker = [[UIDatePicker alloc] init];
    timePicker.datePickerMode = UIDatePickerModeTime;
    timePicker.timeZone = [NSTimeZone localTimeZone];
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 44)];
    UIBarButtonItem *undoItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                              target:self
                                                                              action:@selector(undoActionPressed)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                   target:nil
                                                                                   action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self
                                                                                action:@selector(weekendsTimePickerDoneAction:)];
    [timePicker addTarget:self action:@selector(weekendsTimePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    [toolbar setItems:@[undoItem, flexibleSpace, doneButton]];
    toolbar.translucent = YES;
    
    [_wakeUpTimeWeekends setInputView:timePicker];
    [_wakeUpTimeWeekends setInputAccessoryView:toolbar];
    
    if ([_wakeUpTimeWeekends.text length] != 0) {
        NSDate *wakeUpTime = [DateHelper convertedDateToLocaleFromTimeString:_wakeUpTimeWeekends.text];
        
        @try {
            [timePicker setDate:wakeUpTime animated:YES];
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception.reason);
        }
        @finally {
            NSLog(@"Can't set date %@", wakeUpTime);
        }
    }
}


- (void)weekendsTimePickerValueChanged:(id)sender {
    UIDatePicker *timePicker = (UIDatePicker *)[_wakeUpTimeWeekends inputView];
    
    // show selected time in field
    _wakeUpTimeWeekends.text = [DateHelper actualTimeStringFromDate:timePicker.date];
    
    // save selected time to user settings
    [self.userHelper saveSettingWakeUpTimeWeekends:[DateHelper convertedTimeStringToUSFromDate:timePicker.date]];
}

- (void)weekendsTimePickerDoneAction:(id)sender {
    [_wakeUpTimeWeekends resignFirstResponder];
}



#pragma mark - Timezone
- (void)prepopulateTimezonePickerWithData {
    NSDictionary *timeZonesDict = [self.userAccountHelper availableTimeZones];
    _timeZoneDictionary = timeZonesDict;
    
    //_timezonePickerData = [self sortedArrayOfTimeZones:timeZonesDict];
    _timezonePickerData = [self.userAccountHelper timeZonesArrayFiltered];
}


- (void)prepopulateTimezone {
    [self prepopulateTimezonePickerWithData];
    
    NSString *timezone = [self.userHelper loadSettingTimezone];
    if ([timezone length] != 0) {
        _timezone.text = [self.userAccountHelper convertTimeZoneNameWithoutUnderscore:timezone];
        // save current value in order to compare if it was changed, when close the Settings
        oldTimeZone = timezone;
        
    } else { // lets define local timezone
        NSString *localTimeZoneName = [self.userAccountHelper localTimeZoneName];
        NSLog(@"%@", localTimeZoneName);
        
        NSString *localTimeZone = _timezonePickerData[[self indexOfTimeZoneInPicker:localTimeZoneName]];
        _timezone.text = [self.userAccountHelper convertTimeZoneNameWithoutUnderscore:localTimeZone];
        // right away save value into user defaults
        [self.userHelper saveSettingTimezone:[self.userAccountHelper convertTimeZoneNameWithUnderscore:_timezone.text]];
    }
    _timezone.rightViewMode = UITextFieldViewModeAlways;
    _timezone.rightView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"down-arrow-icon"]];
}


- (IBAction)timezonePressed:(id)sender {
    UIPickerView *pickerView = [[UIPickerView alloc] init];
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 44)];
    UIBarButtonItem *undoItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                              target:self
                                                                              action:@selector(undoActionPressed)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                   target:nil
                                                                                   action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self
                                                                                action:@selector(timezonePickerDoneAction:)];
    [toolbar setItems:@[undoItem, flexibleSpace, doneButton]];
    toolbar.translucent = YES;
    pickerView.delegate = self;
    pickerView.dataSource = self;
    pickerView.accessibilityIdentifier = @"timezonePicker";
    
    [_timezone setInputView:pickerView];
    [_timezone setInputAccessoryView:toolbar];
    
    // preselect value if any
    if (([_timezone.text length] != 0) && [_timezonePickerData containsObject:_timezone.text]) {
        NSInteger index = [_timezonePickerData indexOfObject:_timezone.text];
        [pickerView selectRow:index inComponent:0 animated:NO];
    }
}


- (void)timezonePickerDoneAction:(id)sender {
    [_timezone resignFirstResponder];
}



#pragma mark - WeekendNotification
- (void)prepopulateWeekendNotificationPickerWithData {
    _weekendNotificationPickerData = @[[self.userAccountHelper stringValueOfEnumWeekendNotifications:WeekendNotificationsAll],
                                       [self.userAccountHelper stringValueOfEnumWeekendNotifications:WeekendNotificationsiPhone],
                                       [self.userAccountHelper stringValueOfEnumWeekendNotifications:WeekendNotificationsEmail],
                                       [self.userAccountHelper stringValueOfEnumWeekendNotifications:WeekendNotificationsSMS],
                                       [self.userAccountHelper stringValueOfEnumWeekendNotifications:WeekendNotificationsiPhoneAndEmail],
                                       [self.userAccountHelper stringValueOfEnumWeekendNotifications:WeekendNotificationsiPhoneAndSMS],
                                       [self.userAccountHelper stringValueOfEnumWeekendNotifications:WeekendNotificationsEmailAndSMS],
                                       [self.userAccountHelper stringValueOfEnumWeekendNotifications:WeekendNotificationsNone]];
}


- (void)prepopulateWeekendNotification {
    [self prepopulateWeekendNotificationPickerWithData];
    
    NSString *weekendNotification = [self.userHelper loadSettingWeekendNotification];
    if (weekendNotification != nil) {
        _weekendNotification.text = weekendNotification;
        // save current value in order to compare if it was changed, when close the Settings
        oldWeekendNotification = weekendNotification;
        
    } else {
        _weekendNotification.text = [self.userAccountHelper stringValueOfEnumWeekendNotifications:WeekendNotificationsAll];
        
        // right away save value into user defaults
        [self.userHelper saveSettingWeekendNotification:_weekendNotification.text];
    }
    _weekendNotification.rightViewMode = UITextFieldViewModeAlways;
    _weekendNotification.rightView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"down-arrow-icon"]];
}


- (IBAction)weekendNotificationPressed:(id)sender {
    UIPickerView *pickerView = [[UIPickerView alloc] init];
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 44)];
    UIBarButtonItem *undoItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                              target:self
                                                                              action:@selector(undoActionPressed)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                   target:nil
                                                                                   action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self
                                                                                action:@selector(weekendNotificationPickerDoneAction:)];
    [toolbar setItems:@[undoItem, flexibleSpace, doneButton]];
    toolbar.translucent = YES;
    pickerView.delegate = self;
    pickerView.dataSource = self;
    pickerView.accessibilityIdentifier = @"weekendNotificationPicker";
    
    [_weekendNotification setInputView:pickerView];
    [_weekendNotification setInputAccessoryView:toolbar];
    
    // preselect value if any
    if (([_weekendNotification.text length] != 0) && [_weekendNotificationPickerData containsObject:_weekendNotification.text]) {
        NSInteger index = [_weekendNotificationPickerData indexOfObject:_weekendNotification.text];
        [pickerView selectRow:index inComponent:0 animated:NO];
    }
}


- (void)weekendNotificationPickerDoneAction:(id)sender {
    [_weekendNotification resignFirstResponder];
}



#pragma mark - UIPickerViewDataSource / UIPickerViewDelegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    // the number of columns of data
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    // the number of rows of data
    NSInteger countForPicker;
    if ([pickerView.accessibilityIdentifier isEqualToString:@"timezonePicker"]) {
        countForPicker = _timezonePickerData.count;
        
    } else if ([pickerView.accessibilityIdentifier isEqualToString:@"weekendNotificationPicker"]) {
        countForPicker = _weekendNotificationPickerData.count;
        
    } else if ([pickerView.accessibilityIdentifier isEqualToString:@"phonePrefixField"]) {
        countForPicker = _phonePrefixPickerData.count;
    }
    
    return countForPicker;
}


- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    // the data to return for the row and component (column) that's being passed in
    NSString *rowForPicker = @"";
    if ([pickerView.accessibilityIdentifier isEqualToString:@"timezonePicker"]) {
        rowForPicker = _timezonePickerData[row];
        
    } else if ([pickerView.accessibilityIdentifier isEqualToString:@"weekendNotificationPicker"]) {
        rowForPicker = _weekendNotificationPickerData[row];
        
    } else if ([pickerView.accessibilityIdentifier isEqualToString:@"phonePrefixField"]) {
        rowForPicker = _phonePrefixPickerData[row];
    }
    
    return rowForPicker;
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if ([pickerView.accessibilityIdentifier isEqualToString:@"timezonePicker"]) {
        _timezone.text = _timezonePickerData[row];
        [self.userHelper saveSettingTimezone:[self.userAccountHelper convertTimeZoneNameWithUnderscore:_timezonePickerData[row]]];
        
    } else if ([pickerView.accessibilityIdentifier isEqualToString:@"weekendNotificationPicker"]) {
        _weekendNotification.text = _weekendNotificationPickerData[row];
        [self.userHelper saveSettingWeekendNotification:_weekendNotification.text];
        
    } else if ([pickerView.accessibilityIdentifier isEqualToString:@"phonePrefixField"]) {
        _phonePrefixField.text = _phonePrefixPickerData[row];
        [self.userHelper saveSettingPhonePrefixForForecast:_phonePrefixField.text];
        
        // TO_REMOVE
        _phoneNumberField.text = [_phonePrefixesDict objectForKey:_phonePrefixField.text];
        [self.userHelper saveSettingPhoneNumberForForecast:_phoneNumberField.text];
    }
}



#pragma mark - Navigation
- (IBAction)closeButtonPressed:(id)sender {
    if ([_emailAddressField.text length] != 0) {
        EmailHelper *emailHelper = [[EmailHelper alloc] init];
        if ([emailHelper isEmailValid:_emailAddressField.text]) {
            [self sendSettingsAndCloseView];
            
        } else {
            AlertMessage *alertMessage = [[AlertMessage alloc] init];
            [alertMessage viewController:self showAlertWithTitle:@"Provided email is invalid" withMessage:@"Please provide valid email address"];
        }
    } else {
        [self sendSettingsAndCloseView];
    }
}


- (void)sendSettingsAndCloseView {
    if ([InternetConnection internetConnectionIsAvailable]) {
        if (_alreadyPopulatedSettingsValues) {
            [self sendUserAccountSettingsToServer];
            [self sendPushNotificationsSettingToServer];
        }
    }
    
    [_delegate settingsViewControllerWasClosed:self
                           withTemperatureUnit:_nowSelectedTemperatureUnit
                                  selectedFile:_nowSelectedFile
                           andSelectedLocation:_nowSelectedLocation];
}


- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^ __nullable)(void))completion {
    [super dismissViewControllerAnimated:flag completion:completion];
    _delegate = nil;
}



#pragma mark - User account settings requests

- (BOOL)emailSmsSettingsWereChanged {
    BOOL settingsWereChanged = NO;
    if (![oldTemperatureUnit isEqual:[NSNumber numberWithInt:(int)_temperatureUnitsSegmentedControl.selectedSegmentIndex]] ||
        ![oldEmailSetting isEqual:[NSNumber numberWithBool:[_emailSwitch isOn]]] ||
        ![oldSMSSetting isEqual:[NSNumber numberWithBool:[_smsSwitch isOn]]] ||
        ![oldEmail isEqual:_emailAddressField.text] ||
        ![oldPhone isEqual:_phoneNumberField.text] ||
        ![oldWakeUpTimeWeekdays isEqual:_wakeUpTimeWeekdays.text] ||
        ![oldWakeUpTimeWeekends isEqual:_wakeUpTimeWeekends.text] ||
        ![oldTimeZone isEqual:_timezone.text] ||
        ![oldWeekendNotification isEqual:_weekendNotification.text]) {
        settingsWereChanged = YES;
    }
    return settingsWereChanged;
}


- (void)sendUserAccountSettingsToServer {
    [[SQOAuth sharedInstance] token:^(SQToken *token, NSString *accessToken) {
        if (token && [token.accessToken length] > 0) {
            
            // TO_REMOVE
            NSString *phoneNumber = [NSString stringWithFormat:@"%@", _phoneNumberField.text];
            phoneNumber = [self.userAccountHelper correctPhoneNumber:phoneNumber];
            
            NSInteger temperature    = (int)_temperatureUnitsSegmentedControl.selectedSegmentIndex;
            NSNumber *emailChk       = [NSNumber numberWithBool:[_emailSwitch isOn]];
            NSString *email          = ([_emailAddressField.text length] != 0) ? _emailAddressField.text : @"";
            NSNumber *smsChk         = [NSNumber numberWithBool:[_smsSwitch isOn]];
            NSString *phone          = ([phoneNumber length] != 0) ? [self.userAccountHelper encodePhoneNumber:phoneNumber] : @"";
            NSString *wakeupDay      = [_userHelper loadSettingWakeUpTimeWeekdays];
            NSString *wakeupEnd      = [_userHelper loadSettingWakeUpTimeWeekends];
            NSString *timezoneSelect = [_timeZoneDictionary objectForKey:[self.userAccountHelper convertTimeZoneNameWithUnderscore:_timezone.text]];
            if (!timezoneSelect) timezoneSelect = @"timezoneSelect";
            
            NSString *timezoneOffset = [self.userAccountHelper convertTimeZoneIntoStringGMTValueByLongTimeZoneName:_timezone.text];
            NSInteger weekendMode = [self.userAccountHelper intValueOfWeekendNotification:_weekendNotification.text];
            
            NSDictionary *parameters = @{@"temperature"   : @(temperature),
                                         @"emailChk"      : emailChk,
                                         @"email"         : email,
                                         @"smsChk"        : smsChk,
                                         @"phone"         : phone,
                                         @"wakeupDay"     : wakeupDay,
                                         @"wakeupEnd"     : wakeupEnd,
                                         @"timezoneSelect": timezoneSelect,
                                         @"timezoneOffset": timezoneOffset,
                                         @"weekendMode"   : @(weekendMode),
                                         @"token"         : token.accessToken};
            [self.userAccountHelper sendEmailSmsAndSettingsInfoWithParameters:parameters];
        }
    }];
}


- (BOOL)iPhonePushNotificationsSettingWasChanged {
    if (![oldIPhoneSetting isEqual:[NSNumber numberWithBool:[_iPhoneNotificationSwitch isOn]]])
        return YES;
    else
        return NO;
}

- (void)sendPushNotificationsSettingToServer {
    if ([[self.userHelper loadDeviceToken] length] == 0)
        return;
    
    [[SQOAuth sharedInstance] token:^(SQToken *token, NSString *accessToken) {
        if (token && [token.accessToken length] > 0) {
            NSDictionary *parameters = @{@"pushCheck"  : [NSNumber numberWithBool:[_iPhoneNotificationSwitch isOn]],
                                         @"deviceType" : @(1),
                                         @"deviceToken": ([[self.userHelper loadDeviceToken] length] != 0) ? [self.userHelper loadDeviceToken] : @"",
                                         @"accessToken": token.accessToken,
                                         @"appVersion" : [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]};
            [self.userAccountHelper sendDevicePushNotificationsSettingsWithParameters:parameters];
        }
    }];
}



#pragma mark - Phone helpers

- (BOOL)doesPickerDataArrayContainsCountry:(NSString *)country {
    BOOL flag = NO;
    for (NSString *countryWithCode in _phonePrefixPickerData) {
        if ([countryWithCode containsString:country]) {
            flag = YES;
            break;
        }
    }
    return flag;
}

- (BOOL)doesPhonePrefixesDictionaryContainsCountry:(NSString *)country {
    BOOL flag = NO;
    NSArray *keys = [_phonePrefixesDict allKeys];
    for (NSString *countryWithCode in keys) {
        if ([countryWithCode containsString:country]) {
            flag = YES;
            break;
        }
    }
    return flag;
}

- (NSString *)countryWithCodeByCountryFullName:(NSString *)country {
    NSString *countryWithPhoneCode;
    for (NSString *countryWithCode in _phonePrefixPickerData) {
        if ([countryWithCode containsString:country]) {
            countryWithPhoneCode = countryWithCode;
            break;
        }
    }
    return countryWithPhoneCode;
}

- (NSInteger)indexInArrayForCountry:(NSString *)country {
    NSInteger index = 0;
    for (int i = 0; i < [_phonePrefixPickerData count]; i++) {
    
        if ([[_phonePrefixPickerData objectAtIndex:i] containsString:country]) {
            index = i;
            break;
        }
    }
    return index;
}

- (NSString *)countryISO3166FromForecastJSON {
    NSString *countryISO3166 = @"US";
    ForecastData *forecastContainer = [ForecastData sharedInstance];
    if ([[forecastContainer.forecast allKeys] containsObject:@"current_observation"]) {
        NSDictionary *current_observation = [forecastContainer.forecast objectForKey:@"current_observation"];
        
        if ([[current_observation allKeys] containsObject:@"observation_location"]) {
            NSDictionary *observation_location = [current_observation objectForKey:@"observation_location"];

            if ([[observation_location allKeys] containsObject:@"country_iso3166"]) {
                if ([[observation_location objectForKey:@"country_iso3166"] length] != 0) {
                    countryISO3166 = [observation_location objectForKey:@"country_iso3166"];
                }
            }
        }
    }
    return countryISO3166;
}



#pragma mark - Timezone helpers

- (NSArray *)sortedArrayOfTimeZones:(NSDictionary *)timeZonesDictionary {
    NSArray *allTimeZonesUnsorted = [timeZonesDictionary allKeys];
    
    NSMutableArray *allTimeZonesSorted = [[NSMutableArray alloc] init];
    NSMutableArray *timeZonesNegative = [[NSMutableArray alloc] init];
    NSMutableArray *timeZonesPozitive = [[NSMutableArray alloc] init];
    
    for (NSString *timeZone in allTimeZonesUnsorted) {
        if ([timeZone containsString:@"+"]) {
            [timeZonesPozitive addObject:timeZone];
        } else {
            [timeZonesNegative addObject:timeZone];
        }
    }
    
    NSArray *negativeArray = [NSArray arrayWithArray:[timeZonesNegative copy]];
    NSArray *pozitiveArray = [NSArray arrayWithArray:[timeZonesPozitive copy]];
    NSSortDescriptor *sortOrder = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:NO];
    NSArray *negativeArraySorted =  [NSArray arrayWithArray:[negativeArray  sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortOrder]]];
    NSArray *pozitiveArraySorted =  [NSArray arrayWithArray:[pozitiveArray  sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
    
    for (NSString *timeZone in negativeArraySorted) {
        [allTimeZonesSorted addObject:timeZone];
    }
    for (NSString *timeZone in pozitiveArraySorted) {
        [allTimeZonesSorted addObject:timeZone];
    }
    return allTimeZonesSorted;
}


- (int)indexOfTimeZoneInPicker:(NSString *)timeZoneName {
    NSNumber *index;
    for (int i = 0; i < [_timezonePickerData count]; i++) {
        if ([_timezonePickerData[i] containsString:timeZoneName])
            index = [NSNumber numberWithInt:i];
    }
    
    if (!index) {
        for (int i = 0; i < [_timezonePickerData count]; i++) {
            if ([_timezonePickerData[i] containsString:kDefaultTimeZoneName])
                index = [NSNumber numberWithInt:i];
        }
    }
    
    if (index) {
        return [index intValue];
    } else {
        return 20;
    }
}




#pragma mark - Memory handler

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



@end
