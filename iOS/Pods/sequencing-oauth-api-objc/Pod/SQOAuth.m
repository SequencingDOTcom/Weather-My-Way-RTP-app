//
//  SQOAuth.h
//  Copyright © 2017 Sequencing.com. All rights reserved
//

#import "SQOAuth.h"
#import "SQServerManager.h"
#import "SQToken.h"
#import "SQTokenStorageAppSettings.h"
#import "SQTokenStorageProtocol.h"
#import "SQEmailHelper.h"
#import "SQConnectToHelper.h"


#define kMainQueue dispatch_get_main_queue()

typedef NS_ENUM(NSInteger, ViewOrientation) {
    ViewOrientationPortrait,
    ViewOrientationLandscape
};




@interface SQOAuth ()

@property (strong, nonatomic) id<SQTokenStorageProtocol> tokenStorageDelegate;

@property (strong, nonatomic) NSString  *client_secret;

// activity indicator with label properties
@property (retain, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (retain, nonatomic) UIView    *messageFrame;
@property (retain, nonatomic) UILabel   *strLabel;
@property (assign, nonatomic) CGSize    viewSizePortrait;
@property (assign, nonatomic) CGSize    viewSizeLandscape;

@end




@implementation SQOAuth

#pragma mark - Initializer

+ (instancetype)sharedInstance {
    static SQOAuth *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SQOAuth alloc] init];
        
        SQTokenStorageAppSettings *tokenStorage = [[SQTokenStorageAppSettings alloc] init];
        [instance setTokenStorageDelegate:tokenStorage];
    });
    return instance;
}




#pragma mark - register app id's

- (void)registerApplicationParametersCliendID:(NSString *)client_id
                                 clientSecret:(NSString *)client_secret
                                  redirectUri:(NSString *)redirect_uri
                                        scope:(NSString *)scope
                                     delegate:(id<SQAuthorizationProtocol>)delegate
                       viewControllerDelegate:(UIViewController *)viewControllerDelegate {
    
    if (client_id && client_secret && redirect_uri && scope) {
        [[SQServerManager sharedInstance] registrateParametersCliendID:client_id clientSecret:client_secret redirectUri:redirect_uri scope:scope];
        self.client_secret = client_secret;
    }
    
    self.delegate = delegate;
    self.viewControllerDelegate = viewControllerDelegate;
}




#pragma mark - authorize user

- (void)authorizeUser {
    if (!self.delegate)  return;
    
    [self viewController:self.viewControllerDelegate showActivityIndicatorWithText:@"Authorizing user"];
    [self.viewControllerDelegate.view setUserInteractionEnabled:NO];
    
    [[SQServerManager sharedInstance] authorizeUserForVC:self.viewControllerDelegate
                                              withResult:^(SQToken *token, BOOL didCancel, BOOL error) {
                                                  dispatch_async(kMainQueue, ^{
                                                      
                                                      [self stopActivityIndicator];
                                                      [self.viewControllerDelegate.view setUserInteractionEnabled:YES];
                                                      
                                                      if (token.accessToken) {
                                                          [self.tokenStorageDelegate saveToken:token];
                                                          [self.delegate userIsSuccessfullyAuthorized:token];
                                                          
                                                      } else if (didCancel)
                                                          [self.delegate userDidCancelAuthorization];
                                                      
                                                      else if (error)
                                                          [self.delegate userIsNotAuthorized];
                                                  });
                                              }];
}




#pragma mark - Token methods for Authorized user

- (void)token:(void(^)(SQToken *token, NSString *accessToken))tokenResult {
    SQToken *currentToken = [self.tokenStorageDelegate loadToken];
    
    if ([self isTokenUpToDay]) // token is valid > let's return current token
        tokenResult(currentToken, currentToken.accessToken);
    
    else { // token is expired > let's update it
        [self withRefreshToken:currentToken updateAccessToken:^(SQToken *updatedToken) {
            
            if (updatedToken) {
                [self.tokenStorageDelegate saveToken:updatedToken];
                tokenResult(updatedToken, updatedToken.accessToken);
                
            } else // smth is wrong, we can't update token
                tokenResult(nil, nil);
        }];
    }
}


- (BOOL)isTokenUpToDay {
    BOOL tokenIsValid = NO;
    SQToken *currentToken = [self.tokenStorageDelegate loadToken];
    
    if (currentToken) {
        NSDate *nowDate = [NSDate date];
        NSDate *expDate = currentToken.expirationDate;
        
        if ([nowDate compare:expDate] == NSOrderedDescending) { // token is expired NSOrderedDescending
            NSLog(@">>>>> [SQOAuth]: token is expired");
            
        } else { // token is valid
            NSLog(@">>>>> [SQOAuth]: token is valid");
            tokenIsValid = YES;
        }
    }
    return tokenIsValid;
}


- (void)withRefreshToken:(SQToken *)refreshToken updateAccessToken:(void (^)(SQToken *))tokenResult {
    if (!refreshToken || !refreshToken.refreshToken) { // we can't updated token without "refresh token" value
        tokenResult(nil);
        return;
    }
    
    [[SQServerManager sharedInstance] withRefreshToken:refreshToken
                                     updateAccessToken:^(SQToken *updatedToken) {
                                         
                                         if (!updatedToken) { // invalid token
                                             tokenResult(nil);
                                             return;
                                         }
                                         
                                         if (!updatedToken.accessToken || [updatedToken.accessToken length] == 0) { // invalid token
                                             tokenResult(nil);
                                             return;
                                         }
                                         
                                         if (!updatedToken.refreshToken || [updatedToken.refreshToken length] == 0) { // invalid token
                                             tokenResult(nil);
                                             return;
                                         }
                                         
                                         // let's return valid token
                                         tokenResult(updatedToken);
                                     }];
}


- (void)userDidSignOut {
    [self.tokenStorageDelegate eraseToken];
    self.delegate = nil;
    self.viewControllerDelegate = nil;
}




#pragma mark - Client Secret

- (NSString *)clientSecret {
    return self.client_secret;
}





#pragma mark - Registrate/Reset account flow

- (void)callRegisterResetAccountFlow {
    [self.viewControllerDelegate.view setUserInteractionEnabled:NO];
    
    UIAlertController *registrationPopup = [UIAlertController alertControllerWithTitle:@"Registration / Reset"
                                                                               message:@"Please enter your email address"
                                                                        preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelButton = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction *action){
                                                             dispatch_async(kMainQueue, ^{
                                                                 
                                                                 UITextField *emailTextField = registrationPopup.textFields.firstObject;
                                                                 [emailTextField resignFirstResponder];
                                                                 [self.viewControllerDelegate.view endEditing:YES];
                                                                 [self.viewControllerDelegate.view setUserInteractionEnabled:YES];
                                                                 [self.viewControllerDelegate dismissViewControllerAnimated:YES completion:nil];
                                                             });
                                                         }];
    
    UIAlertAction *registerButton = [UIAlertAction actionWithTitle:@"Register new account"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction *action){
                                                               
                                                               UITextField *emailTextField = registrationPopup.textFields.firstObject;
                                                               [self viewController:self.viewControllerDelegate startRegistationFlow:emailTextField.text];
                                                           }];
    
    UIAlertAction *resetPasswordButton = [UIAlertAction actionWithTitle:@"Reset password"
                                                                  style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction *action){
                                                                    
                                                                    UITextField *emailTextField = registrationPopup.textFields.firstObject;
                                                                    [self viewController:self.viewControllerDelegate startResetPasswordFlow:emailTextField.text];
                                                                }];
    
    [registrationPopup addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        [textField setKeyboardType:UIKeyboardTypeEmailAddress];
        [textField setPlaceholder:@"enter email address"];
        [textField setClearButtonMode:UITextFieldViewModeWhileEditing];
    }];
    [registrationPopup addAction:cancelButton];
    [registrationPopup addAction:registerButton];
    [registrationPopup addAction:resetPasswordButton];
    
    [self.viewControllerDelegate presentViewController:registrationPopup animated:YES completion:nil];
}



- (void)viewController:(UIViewController *)controller startRegistationFlow:(NSString *)emailAddress {
    if (!emailAddress || [emailAddress length] == 0) {
        [self viewController:controller
          showAlertWithTitle:@"Registration error"
                 withMessage:@"Email address is empty. Please provide valid email address."];
        [controller.view setUserInteractionEnabled:YES];
        return;
    }
    
    if (![SQEmailHelper isEmailValid:emailAddress]) {
        [self viewController:controller
          showAlertWithTitle:@"Registration error"
                 withMessage:@"Invalid email address was entered. Please provide valid email address."];
        [controller.view setUserInteractionEnabled:YES];
        return;
    }
    
    
    [self viewController:controller showActivityIndicatorWithText:@"Registering email"];
    
    [[SQServerManager sharedInstance] registrateAccountForEmailAddress:emailAddress withResult:^(NSString *error) {
        dispatch_async(kMainQueue, ^{
            [self stopActivityIndicator];
            [controller.view setUserInteractionEnabled:YES];
            
            if (!error)
                [self viewController:controller
                  showAlertWithTitle:@"Registration success"
                         withMessage:@"Please check your mail box and follow instruction to activate your account."];
            
            else
                [self viewController:controller
                  showAlertWithTitle:@"Registration error"
                         withMessage:error];
        });
    }];
}



- (void)viewController:(UIViewController *)controller startResetPasswordFlow:(NSString *)emailAddress {
    if (!emailAddress || [emailAddress length] == 0) {
        [self viewController:controller
          showAlertWithTitle:@"Reset password error"
                 withMessage:@"Email address is empty. Please provide valid email address."];
        [controller.view setUserInteractionEnabled:YES];
        return;
    }
    
    if (![SQEmailHelper isEmailValid:emailAddress]) {
        [self viewController:controller
          showAlertWithTitle:@"Reset password error"
                 withMessage:@"Invalid email address was entered. Please provide valid email address."];
        [controller.view setUserInteractionEnabled:YES];
        return;
    }
    
    
    [self viewController:controller showActivityIndicatorWithText:@"Reset password"];
    
    [[SQServerManager sharedInstance] resetPasswordForEmailAddress:emailAddress withResult:^(NSString *error) {
        dispatch_async(kMainQueue, ^{
            [self stopActivityIndicator];
            [controller.view setUserInteractionEnabled:YES];
            
            if (!error)
                [self viewController:controller
                  showAlertWithTitle:@"Reset password success"
                         withMessage:@"Please check your mail box and follow instruction to reset your password."];
            
            else
                [self viewController:controller
                  showAlertWithTitle:@"Reset password error"
                         withMessage:error];
        });
    }];
}












#pragma mark -
#pragma mark - Activity indicator

- (void)viewController:(UIViewController *)controller showActivityIndicatorWithText:(NSString *)text {
    dispatch_async(kMainQueue, ^{
        /*
         // getting the rootViewController directly from cocoapod
         UIViewController *topmostVC;
         UIViewController *rootVC1 = [[[[UIApplication sharedApplication] windows] firstObject] rootViewController];
         
         if ([rootVC1 isKindOfClass:[UINavigationController class]]) {
         UINavigationController *navVC = (UINavigationController *)rootVC1;
         topmostVC = [navVC viewControllers][0];
         self.mainVC = topmostVC;
         } else {
         self.mainVC = [[[[UIApplication sharedApplication] windows] firstObject] rootViewController];
         }*/
        
        ViewOrientation viewOrientation = [self detectViewOrientation];
        [self saveViewControllerSize:controller forViewOrientation:viewOrientation];
        
        // message frame
        self.messageFrame = [[UIView alloc] initWithFrame:[self messageFrameDependingViewOrientation:viewOrientation]];
        self.messageFrame.layer.cornerRadius = 10;
        self.messageFrame.backgroundColor = [UIColor lightGrayColor];
        self.messageFrame.alpha = 0.95;
        
        // differX value
        CGFloat differX = [self differValueBetweenControllerWidth:([self viewCenterPointForViewOrientation:viewOrientation].x * 2)
                                                    andFrameWidth:self.messageFrame.frame.size.width];
        
        // activityIndicator frame
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        CGRect activityIndicatorFrame = [self activityIndicatorFrameDependingOnMessageFrame:self.messageFrame.frame
                                                                               differXValue:differX];
        [self.activityIndicator setFrame:activityIndicatorFrame];
        [self.activityIndicator startAnimating];
        //[self.activityIndicator setBackgroundColor:[UIColor greenColor]];
        
        // label frame
        self.strLabel = [[UILabel alloc] initWithFrame:[self labelFrameDependingOnMessageFrame:self.messageFrame.frame
                                                                        activityIndicatorFrame:activityIndicatorFrame
                                                                                  differXValue:differX]];
        self.strLabel.text = text;
        self.strLabel.textColor = [UIColor whiteColor];
        self.strLabel.textAlignment = NSTextAlignmentCenter;
        
        // show resulted activity indicator on UI
        [self.messageFrame addSubview:self.activityIndicator];
        [self.messageFrame addSubview:self.strLabel];
        [controller.view addSubview:self.messageFrame];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateActivityFrameLayout)
                                                     name:UIApplicationDidChangeStatusBarOrientationNotification
                                                   object:nil];
    });
}


- (void)stopActivityIndicator {
    dispatch_async(kMainQueue, ^{
        [self.activityIndicator stopAnimating];
        [self.messageFrame removeFromSuperview];
        
        self.messageFrame = nil;
        self.activityIndicator = nil;
        self.strLabel = nil;
        
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    });
}


- (void)updateActivityFrameLayout {
    if (self.messageFrame && self.activityIndicator && self.strLabel) {
        
        ViewOrientation viewOrientation = [self detectViewOrientation];
        
        // message frame
        [self.messageFrame setFrame:[self messageFrameDependingViewOrientation:viewOrientation]];
        
        // differX value
        CGFloat differX = [self differValueBetweenControllerWidth:([self viewCenterPointForViewOrientation:viewOrientation].x * 2)
                                                    andFrameWidth:self.messageFrame.frame.size.width];
        
        // activityIndicator frame
        CGRect activityIndicatorFrame = [self activityIndicatorFrameDependingOnMessageFrame:self.messageFrame.frame
                                                                               differXValue:differX];
        [self.activityIndicator setFrame:activityIndicatorFrame];
        
        // label frame
        [self.strLabel setFrame:[self labelFrameDependingOnMessageFrame:self.messageFrame.frame
                                                 activityIndicatorFrame:activityIndicatorFrame
                                                           differXValue:differX]];
    }
}



- (ViewOrientation)detectViewOrientation {
    switch ([[UIApplication sharedApplication] statusBarOrientation]) {
        
        case UIInterfaceOrientationUnknown:
            return ViewOrientationPortrait; break;
            
        case UIInterfaceOrientationPortrait:
            return ViewOrientationPortrait; break;
            
        case UIInterfaceOrientationPortraitUpsideDown:
            return ViewOrientationPortrait; break;
            
        case UIInterfaceOrientationLandscapeLeft:
            return ViewOrientationLandscape; break;
            
        case UIInterfaceOrientationLandscapeRight:
            return ViewOrientationLandscape; break;
            
        default:
            return ViewOrientationPortrait; break;
    }
}


- (void)saveViewControllerSize:(UIViewController *)controller forViewOrientation:(ViewOrientation)viewOrientation {
    switch (viewOrientation) {
        
        case ViewOrientationPortrait: {
            self.viewSizePortrait = controller.view.frame.size;
            CGSize sizeOpposite = CGSizeMake(0, 0);
            sizeOpposite.width  = controller.view.frame.size.height;
            sizeOpposite.height = controller.view.frame.size.width;
            self.viewSizeLandscape = sizeOpposite;
        }   break;
            
        case ViewOrientationLandscape: {
            self.viewSizeLandscape = controller.view.frame.size;
            CGSize sizeOpposite = CGSizeMake(0, 0);
            sizeOpposite.width  = controller.view.frame.size.height;
            sizeOpposite.height = controller.view.frame.size.width;
            self.viewSizePortrait = sizeOpposite;
        }   break;
            
        default: {
            self.viewSizePortrait = controller.view.frame.size;
            CGSize sizeOpposite = CGSizeMake(0, 0);
            sizeOpposite.width  = controller.view.frame.size.height;
            sizeOpposite.height = controller.view.frame.size.width;
            self.viewSizeLandscape = sizeOpposite;
        }   break;
    }
}


- (CGPoint)viewCenterPointForViewOrientation:(ViewOrientation)viewOrientation {
    switch (viewOrientation) {
        case ViewOrientationPortrait:
            return CGPointMake(self.viewSizePortrait.width / 2, self.viewSizePortrait.height / 2); break;
        
        case ViewOrientationLandscape:
            return CGPointMake(self.viewSizeLandscape.width / 2, self.viewSizeLandscape.height / 2); break;
            
        default:
            return CGPointMake(self.viewSizePortrait.width / 2, self.viewSizePortrait.height / 2); break;
    }
}


- (CGFloat)differValueBetweenControllerWidth:(CGFloat)viewWidth andFrameWidth:(CGFloat)frameWidth {
    CGFloat differX = (viewWidth - frameWidth) / 2;
    return differX;
}


- (CGRect)messageFrameDependingViewOrientation:(ViewOrientation)viewOrientation {
    CGPoint viewCenterPoint = [self viewCenterPointForViewOrientation:viewOrientation];
    CGFloat controllerMidX = viewCenterPoint.x;
    CGFloat controllerMidY = viewCenterPoint.y;
    
    CGFloat messageFrameWidth = 260;
    CGFloat messageFrameHeight = 100;
    CGFloat messageFrameX = controllerMidX - (messageFrameWidth / 2);
    CGFloat messageFrameY = controllerMidY - (messageFrameHeight / 2);
    
    return CGRectMake(messageFrameX, messageFrameY, messageFrameWidth, messageFrameHeight);
}


- (CGRect)activityIndicatorFrameDependingOnMessageFrame:(CGRect)messageFrame differXValue:(CGFloat)differX {
    CGFloat activityIndicatorWidth = 50;
    CGFloat activityIndicatorHeight = 50;
    CGFloat activityIndicatorX = CGRectGetMidX(messageFrame) - (activityIndicatorHeight / 2) - differX;
    CGFloat activityIndicatorY = 10;
    
    return CGRectMake(activityIndicatorX, activityIndicatorY, activityIndicatorWidth, activityIndicatorHeight);
}


- (CGRect)labelFrameDependingOnMessageFrame:(CGRect)messageFrame activityIndicatorFrame:(CGRect)activityIndicatorFrame differXValue:(CGFloat)differX {
    CGFloat labelWidth = messageFrame.size.width;
    CGFloat labelHeight = messageFrame.size.height - activityIndicatorFrame.size.height;
    CGFloat labelX = CGRectGetMidX(messageFrame) - (labelWidth / 2) - differX;
    CGFloat labelY = activityIndicatorFrame.size.height;
    
    return CGRectMake(labelX, labelY, labelWidth, labelHeight);
}




#pragma mark - Alert popup

- (void)viewController:(UIViewController *)controller showAlertWithTitle:(NSString *)title withMessage:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *close = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:close];
    [controller presentViewController:alert animated:YES completion:nil];
}



@end
