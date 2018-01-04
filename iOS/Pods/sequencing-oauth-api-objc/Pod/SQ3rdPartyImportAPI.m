//
//  SQ3rdPartyImport.m
//  Copyright © 2017 Sequencing.com. All rights reserved
//


#import "SQ3rdPartyImportAPI.h"
#import "SQ3rdPartyImportHelper.h"


#define kMainQueue dispatch_get_main_queue()

typedef NS_ENUM(NSInteger, ViewOrientation) {
    ViewOrientationPortrait,
    ViewOrientationLandscape
};




@interface SQ3rdPartyImportAPI () <SQ3rdPartyImport23andMeDelegate, SQ3rdPartyImportAncestryDelegate>

@property (weak, nonatomic) UIViewController            *viewController;
@property (retain, nonatomic) UIActivityIndicatorView   *activityIndicator;
@property (retain, nonatomic) UIView    *messageFrame;
@property (retain, nonatomic) UILabel   *strLabel;

@property (assign, nonatomic) CGSize    viewSizePortrait;
@property (assign, nonatomic) CGSize    viewSizeLandscape;

@property (strong, nonatomic) NSString  *token;

@end




@implementation SQ3rdPartyImportAPI


#pragma mark - 23andMe import

- (void)importFrom23AndMeWithToken:(id<SQTokenAccessProtocol>)tokenProvider viewControllerDelegate:(UIViewController *)controller {
    if (!controller) {
        UIViewController *mainVC = [[[[UIApplication sharedApplication] windows] firstObject] rootViewController];
        [self viewController:mainVC showAlertWithTitle:@"23andMe files import" withMessage:@"UI delegate is missing. Please provide UI delegate"];
        return;
    }
    self.viewController = controller;
    
    [tokenProvider token:^(SQToken *token, NSString *accessToken) {
        dispatch_async(kMainQueue, ^{
            if (!accessToken || [accessToken length] == 0) {
                [self viewController:controller showAlertWithTitle:@"23andMe files import" withMessage:@"User token is empty. Please reauthorize."];
                [controller.view setUserInteractionEnabled:YES];
                return;
            }
            
            self.token = accessToken;
            [controller.view setUserInteractionEnabled:NO];
            
            UIAlertController *authorizationPopup = [UIAlertController alertControllerWithTitle:@"23andMe files import"
                                                                                        message:@"Please provide your credentials to authorize"
                                                                                 preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *cancelButton = [UIAlertAction actionWithTitle:@"Cancel"
                                                                   style:UIAlertActionStyleCancel
                                                                 handler:^(UIAlertAction *action){
                                                                     dispatch_async(kMainQueue, ^{
                                                                         UITextField *loginTextField = authorizationPopup.textFields.firstObject;
                                                                         [loginTextField resignFirstResponder];
                                                                         UITextField *passwordTextField = authorizationPopup.textFields.lastObject;
                                                                         [passwordTextField resignFirstResponder];
                                                                         
                                                                         [controller.view endEditing:YES];
                                                                         [controller.view setUserInteractionEnabled:YES];
                                                                         [controller dismissViewControllerAnimated:YES completion:nil];
                                                                     });
                                                                 }];
            
            UIAlertAction *authorizeButton = [UIAlertAction actionWithTitle:@"Authorize"
                                                                      style:UIAlertActionStyleDefault
                                                                    handler:^(UIAlertAction *action){
                                                                        UITextField *loginTextField    = authorizationPopup.textFields.firstObject;
                                                                        UITextField *passwordTextField = authorizationPopup.textFields.lastObject;
                                                                        
                                                                        [self viewController:controller authorize23andMeWithLogin:loginTextField.text password:passwordTextField.text token:accessToken];
                                                                    }];
            
            [authorizationPopup addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                [textField setKeyboardType:UIKeyboardTypeEmailAddress];
                textField.placeholder = @"enter login";
                textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            }];
            
            [authorizationPopup addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                [textField setKeyboardType:UIKeyboardTypeDefault];
                textField.placeholder = @"enter password";
                textField.secureTextEntry = YES;
                textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            }];
            
            [authorizationPopup addAction:cancelButton];
            [authorizationPopup addAction:authorizeButton];
            [controller presentViewController:authorizationPopup animated:YES completion:nil];
        });
    }];
}


- (void)viewController:(UIViewController *)controller authorize23andMeWithLogin:(NSString *)login password:(NSString *)password token:(NSString *)token {
    if (!login || [login length] == 0) {
        [self viewController:controller
          showAlertWithTitle:@"23andMe files import"
                 withMessage:@"Login is empty. Please provide valid login."];
        [controller.view setUserInteractionEnabled:YES];
        return;
    }
    
    if (!password || [password length] == 0) {
        [self viewController:controller
          showAlertWithTitle:@"23andMe files import"
                 withMessage:@"Password is empty. Please provide valid Password."];
        [controller.view setUserInteractionEnabled:YES];
        return;
    }
    
    if (!token || [token length] == 0) {
        [self viewController:controller
          showAlertWithTitle:@"23andMe files import"
                 withMessage:@"User token is empty. Please reauthorize."];
        [controller.view setUserInteractionEnabled:YES];
        return;
    }
    
    [self viewController:controller showActivityIndicatorWithText:@"Authorizing user..."];
    
    SQ3rdPartyImportHelper *importHelper = [SQ3rdPartyImportHelper sharedInstance];
    [importHelper setMe23Delegate:self];
    [importHelper importRequest23andMeWithLogin:login password:password token:token];
}



- (void)viewController:(UIViewController *)controller sendSecurityAnswer:(NSString *)answer securityQuestion:(NSString *)question sessionId:(NSString *)sessionId token:(NSString *)token {
    if (!answer || [answer length] == 0) {
        NSString *adjustedQuestion = [NSString stringWithFormat:@"Security answer is empty.\nPlease provide valid answer for the following security question:\n\"%@\"", question];
        [self import23andMe_SecurityOriginQuestion:question adjustedQuestion:adjustedQuestion sessionId:sessionId];
        return;
    }
    
    if (!sessionId || [sessionId length] == 0 || !token || [token length] == 0) {
        [self viewController:controller
          showAlertWithTitle:@"23andMe security question error"
                 withMessage:@"Your sessionId/token are empty. Please reauthorize."];
        [controller.view setUserInteractionEnabled:YES];
        return;
    }
    
    [self viewController:controller showActivityIndicatorWithText:@"Sending security answer..."];
    
    SQ3rdPartyImportHelper *importHelper = [SQ3rdPartyImportHelper sharedInstance];
    [importHelper setMe23Delegate:self];
    [importHelper importRequest23andMeWithAnswer:answer securityQuestion:question sessionId:sessionId token:token];
}



#pragma mark SQ3rdPartyImport23andMeDelegate

- (void)import23andMe_ImportStarted {
    dispatch_async(kMainQueue, ^{
        [self stopActivityIndicator];
        [self.viewController.view setUserInteractionEnabled:YES];
        [[SQ3rdPartyImportHelper sharedInstance] setMe23Delegate:nil];
        [self viewController:self.viewController showAlertWithTitle:@"23andMe files import" withMessage:@"Genetic file(s) import sucessfully started."];
    });
}


- (void)import23andMe_InvalidLoginPassword {
    dispatch_async(kMainQueue, ^{
        [self stopActivityIndicator];
        [self.viewController.view setUserInteractionEnabled:YES];
        [[SQ3rdPartyImportHelper sharedInstance] setMe23Delegate:nil];
        [self viewController:self.viewController showAlertWithTitle:@"23andMe files import" withMessage:@"Sorry, invalid credentials were entered. Please provide valid credentials."];
    });
}


- (void)import23andMe_SecurityOriginQuestion:(NSString *)originQuestion adjustedQuestion:(NSString *)adjustedQuestion sessionId:(NSString *)sessionId {
    dispatch_async(kMainQueue, ^{
        [self stopActivityIndicator];
        [[SQ3rdPartyImportHelper sharedInstance] setMe23Delegate:nil];
        NSString *question = adjustedQuestion ? adjustedQuestion : [NSString stringWithFormat:@"\"%@\"", originQuestion];
        
        UIAlertController *securityQuestionPopup = [UIAlertController alertControllerWithTitle:@"23andMe security question"
                                                                                       message:question
                                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelButton = [UIAlertAction actionWithTitle:@"Cancel"
                                                               style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction *action){
                                                                 dispatch_async(kMainQueue, ^{
                                                                     UITextField *answerTextField = securityQuestionPopup.textFields.firstObject;
                                                                     [answerTextField resignFirstResponder];
                                                                     
                                                                     [self.viewController.view endEditing:YES];
                                                                     [self.viewController.view setUserInteractionEnabled:YES];
                                                                     [self.viewController dismissViewControllerAnimated:YES completion:nil];
                                                                 });
                                                             }];
        
        UIAlertAction *sendButton = [UIAlertAction actionWithTitle:@"Send"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction *action){
                                                               UITextField *answerTextField = securityQuestionPopup.textFields.firstObject;
                                                               
                                                               [self viewController:self.viewController
                                                                 sendSecurityAnswer:answerTextField.text
                                                                   securityQuestion:originQuestion
                                                                          sessionId:sessionId
                                                                              token:self.token];
                                                           }];
        
        [securityQuestionPopup addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            [textField setKeyboardType:UIKeyboardTypeDefault];
            textField.placeholder = @"enter answer";
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        }];
        
        [securityQuestionPopup addAction:cancelButton];
        [securityQuestionPopup addAction:sendButton];
        [self.viewController presentViewController:securityQuestionPopup animated:YES completion:nil];
    });
}


- (void)import23andMe_InternalServerError {
    dispatch_async(kMainQueue, ^{
        [self stopActivityIndicator];
        [self.viewController.view setUserInteractionEnabled:YES];
        [[SQ3rdPartyImportHelper sharedInstance] setMe23Delegate:nil];
        [self viewController:self.viewController showAlertWithTitle:@"23andMe files import" withMessage:@"Sorry, there is a temporary server error. Please try later."];
    });
}


- (void)import23andMe_InvalidAnswer {
    dispatch_async(kMainQueue, ^{
        [self stopActivityIndicator];
        [self.viewController.view setUserInteractionEnabled:YES];
        [[SQ3rdPartyImportHelper sharedInstance] setMe23Delegate:nil];
        [self viewController:self.viewController showAlertWithTitle:@"23andMe files import" withMessage:@"Invalid security answer provided."];
    });
}







#pragma mark - ancestry.com import

- (void)importFromAncestryWithToken:(id<SQTokenAccessProtocol>)tokenProvider viewControllerDelegate:(UIViewController *)controller {
    if (!controller) {
        UIViewController *mainVC = [[[[UIApplication sharedApplication] windows] firstObject] rootViewController];
        [self viewController:mainVC showAlertWithTitle:@"Ancestry files import" withMessage:@"UI delegate is missing. Please provide UI delegate"];
        return;
    }
    self.viewController = controller;
    
    [tokenProvider token:^(SQToken *token, NSString *accessToken) {
        dispatch_async(kMainQueue, ^{
            if (!accessToken || [accessToken length] == 0) {
                [self viewController:controller showAlertWithTitle:@"Ancestry files import" withMessage:@"User token is empty. Please reauthorize."];
                [controller.view setUserInteractionEnabled:YES];
                return;
            }
            
            self.token = accessToken;
            [controller.view setUserInteractionEnabled:NO];
            
            UIAlertController *authorizationPopup = [UIAlertController alertControllerWithTitle:@"Ancestry files import"
                                                                                        message:@"Please provide your credentials to authorize"
                                                                                 preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *cancelButton = [UIAlertAction actionWithTitle:@"Cancel"
                                                                   style:UIAlertActionStyleCancel
                                                                 handler:^(UIAlertAction *action){
                                                                     dispatch_async(kMainQueue, ^{
                                                                         UITextField *loginTextField = authorizationPopup.textFields.firstObject;
                                                                         [loginTextField resignFirstResponder];
                                                                         UITextField *passwordTextField = authorizationPopup.textFields.lastObject;
                                                                         [passwordTextField resignFirstResponder];
                                                                         
                                                                         [controller.view endEditing:YES];
                                                                         [controller.view setUserInteractionEnabled:YES];
                                                                         [controller dismissViewControllerAnimated:YES completion:nil];
                                                                     });
                                                                 }];
            
            UIAlertAction *authorizeButton = [UIAlertAction actionWithTitle:@"Authorize"
                                                                      style:UIAlertActionStyleDefault
                                                                    handler:^(UIAlertAction *action){
                                                                        UITextField *loginTextField    = authorizationPopup.textFields.firstObject;
                                                                        UITextField *passwordTextField = authorizationPopup.textFields.lastObject;
                                                                        
                                                                        [self viewController:controller authorizeAncestryWithLogin:loginTextField.text password:passwordTextField.text token:accessToken];
                                                                    }];
            
            [authorizationPopup addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                [textField setKeyboardType:UIKeyboardTypeEmailAddress];
                textField.placeholder = @"enter login";
                textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            }];
            
            [authorizationPopup addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                [textField setKeyboardType:UIKeyboardTypeDefault];
                textField.placeholder = @"enter password";
                textField.secureTextEntry = YES;
                textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            }];
            
            [authorizationPopup addAction:cancelButton];
            [authorizationPopup addAction:authorizeButton];
            [controller presentViewController:authorizationPopup animated:YES completion:nil];
        });
    }];
}



- (void)viewController:(UIViewController *)controller authorizeAncestryWithLogin:(NSString *)login password:(NSString *)password token:(NSString *)token {
    if (!login || [login length] == 0) {
        [self viewController:controller
          showAlertWithTitle:@"Ancestry files import"
                 withMessage:@"Login is empty. Please provide valid login."];
        [controller.view setUserInteractionEnabled:YES];
        return;
    }
    
    if (!password || [password length] == 0) {
        [self viewController:controller
          showAlertWithTitle:@"Ancestry files import"
                 withMessage:@"Password is empty. Please provide valid Password."];
        [controller.view setUserInteractionEnabled:YES];
        return;
    }
    
    if (!token || [token length] == 0) {
        [self viewController:controller
          showAlertWithTitle:@"Ancestry files import"
                 withMessage:@"User token is empty. Please reauthorize."];
        [controller.view setUserInteractionEnabled:YES];
        return;
    }
    
    [self viewController:controller showActivityIndicatorWithText:@"Authorizing user..."];
    
    SQ3rdPartyImportHelper *importHelper = [SQ3rdPartyImportHelper sharedInstance];
    [importHelper setAncestryDelegate:self];
    [importHelper importRequestAncestryWithLogin:login password:password token:token];
}



- (void)viewController:(UIViewController *)controller sendURL:(NSString *)url sessionId:(NSString *)sessionId token:(NSString *)token {
    if (!url || [url length] == 0) {
        [self importAncestry_EmailSentWithText:@"URL is empty.\nPlease provide valid URL from email." sessionId:sessionId];
        return;
    }
    
    if (!sessionId || [sessionId length] == 0 || !token || [token length] == 0) {
        [self viewController:controller
          showAlertWithTitle:@"Ancestry files import"
                 withMessage:@"Your sessionId/token are empty. Please reauthorize."];
        [controller.view setUserInteractionEnabled:YES];
        return;
    }
    
    [self viewController:controller showActivityIndicatorWithText:@"Sending file URL..."];
    
    SQ3rdPartyImportHelper *importHelper = [SQ3rdPartyImportHelper sharedInstance];
    [importHelper setAncestryDelegate:self];
    [importHelper importRequestAncestryWithURL:url sessionId:sessionId token:token];
}



#pragma mark SQ3rdPartyImportAncestryDelegate

- (void)importAncestry_EmailSentWithText:(NSString *)text sessionId:(NSString *)sessionId {
    dispatch_async(kMainQueue, ^{
        [self stopActivityIndicator];
        [self.viewController.view setUserInteractionEnabled:YES];
        [[SQ3rdPartyImportHelper sharedInstance] setAncestryDelegate:nil];
        
        UIAlertController *urlPopup = [UIAlertController alertControllerWithTitle:@"Ancestry files import"
                                                                          message:(text ? text : @"Please provide URL from email")
                                                                   preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelButton = [UIAlertAction actionWithTitle:@"Cancel"
                                                               style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction *action){
                                                                 dispatch_async(kMainQueue, ^{
                                                                     UITextField *urlTextField = urlPopup.textFields.firstObject;
                                                                     [urlTextField resignFirstResponder];
                                                                     
                                                                     [self.viewController.view endEditing:YES];
                                                                     [self.viewController.view setUserInteractionEnabled:YES];
                                                                     [self.viewController dismissViewControllerAnimated:YES completion:nil];
                                                                 });
                                                             }];
        
        UIAlertAction *sendButton = [UIAlertAction actionWithTitle:@"Send"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction *action){
                                                               UITextField *urlTextField = urlPopup.textFields.firstObject;
                                                               
                                                               [self viewController:self.viewController
                                                                            sendURL:urlTextField.text
                                                                          sessionId:sessionId
                                                                              token:self.token];
                                                           }];
        
        [urlPopup addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            [textField setKeyboardType:UIKeyboardTypeURL];
            textField.placeholder = @"enter url";
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        }];
        
        [urlPopup addAction:cancelButton];
        [urlPopup addAction:sendButton];
        [self.viewController presentViewController:urlPopup animated:YES completion:nil];
    });
}

- (void)importAncestry_InvalidLoginPassword {
    dispatch_async(kMainQueue, ^{
        [self stopActivityIndicator];
        [self.viewController.view setUserInteractionEnabled:YES];
        [[SQ3rdPartyImportHelper sharedInstance] setAncestryDelegate:nil];
        [self viewController:self.viewController showAlertWithTitle:@"Ancestry files import" withMessage:@"Sorry, invalid credentials were entered. Please provide valid credentials."];
    });
}


- (void)importAncestry_InternalServerError {
    dispatch_async(kMainQueue, ^{
        [self stopActivityIndicator];
        [self.viewController.view setUserInteractionEnabled:YES];
        [[SQ3rdPartyImportHelper sharedInstance] setAncestryDelegate:nil];
        [self viewController:self.viewController showAlertWithTitle:@"Ancestry files import" withMessage:@"Sorry, there is a temporary server error. Please try later."];
    });
}


- (void)importAncestry_ImportStarted {
    dispatch_async(kMainQueue, ^{
        [self stopActivityIndicator];
        [self.viewController.view setUserInteractionEnabled:YES];
        [[SQ3rdPartyImportHelper sharedInstance] setAncestryDelegate:nil];
        [self viewController:self.viewController showAlertWithTitle:@"Ancestry files import" withMessage:@"Genetic file(s) import sucessfully started."];
    });
}


- (void)importAncestry_InvalidURL {
    dispatch_async(kMainQueue, ^{
        [self stopActivityIndicator];
        [self.viewController.view setUserInteractionEnabled:YES];
        [[SQ3rdPartyImportHelper sharedInstance] setAncestryDelegate:nil];
        [self viewController:self.viewController showAlertWithTitle:@"Ancestry files import" withMessage:@"Invalid URL was provided."];
    });
}







#pragma mark -
#pragma mark - Alert popup with text

- (void)viewController:(UIViewController *)controller showAlertWithTitle:(NSString *)title withMessage:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *close = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:close];
    [controller presentViewController:alert animated:YES completion:nil];
}




#pragma mark - Activity indicator methods
/*
 * Activity indicator
 */
- (void)viewController:(UIViewController *)controller showActivityIndicatorWithText:(NSString *)text {
    dispatch_async(kMainQueue, ^{
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




@end
