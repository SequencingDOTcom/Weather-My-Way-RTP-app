//
//  SQServerManager.h
//  Copyright © 2015-2016 Sequencing.com. All rights reserved
//

#import "SQServerManager.h"
#import "SQLoginWebViewController.h"
#import "SQToken.h"
#import "SQHttpHelper.h"
#import "SQAuthResult.h"
#import "SQRequestHelper.h"
#import "SQTokenUpdater.h"

#define kMainQueue dispatch_get_main_queue()


@interface SQServerManager ()

// activity indicator with label properties
@property (retain, nonatomic) UIView *messageFrame;
@property (retain, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (retain, nonatomic) UILabel *strLabel;
@property (retain, nonatomic) UIViewController *mainVC;

// application parameters
@property (readwrite, strong, nonatomic) NSString *client_id;
@property (readwrite, strong, nonatomic) NSString *client_secret;
@property (readwrite, strong, nonatomic) NSString *redirect_uri;
@property (readwrite, strong, nonatomic) NSString *scope;

@end


@implementation SQServerManager

// parameters for authorization request
static NSString *authURL        = @"https://sequencing.com/oauth2/authorize";
static NSString *response_type  = @"code";
static NSString *mobileParam    = @"mobile=1";

// parameters for token request
static NSString *tokenURL       = @"https://sequencing.com/oauth2/token";
static NSString *grant_type     = @"authorization_code";

// parameters for refresh token request
static NSString *refreshTokenURL    = @"https://sequencing.com/oauth2/token?q=oauth2/token";
static NSString *refreshGrant_type  = @"refresh_token";

// parameters for files request
static NSString *apiURL         = @"https://api.sequencing.com";
static NSString *demoPath       = @"/DataSourceList?sample=true";
static NSString *filesPath      = @"/DataSourceList?all=true";
// static NSString *filesPath      = @"/DataSourceList?uploaded=true&shared=true&fromApps=true&allWithAltruist=true&sample=true";


#pragma mark -
#pragma mark Initializer

+ (instancetype) sharedInstance {
    static SQServerManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[SQServerManager alloc] init];
    });
    return manager;
}


- (void)registrateParametersCliendID:(NSString *)client_id
                        ClientSecret:(NSString *)client_secret
                         RedirectUri:(NSString *)redirect_uri
                               Scope:(NSString *)scope {
    self.client_id = client_id;
    self.client_secret = client_secret;
    self.redirect_uri = redirect_uri;
    self.scope = scope;
    [[SQRequestHelper sharedInstance] rememberRedirectUri:redirect_uri];
}



#pragma mark -
#pragma mark for Guest user. Authorization

- (void)authorizeUser:(void (^)(SQToken *token, BOOL didCancel, BOOL error))result {
    NSString *randomState = [self randomStringWithLength:[self randomInt]];
    
    NSString *client_id_upd = [self.client_id stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
    NSString *urlString = [NSString stringWithFormat:
                           @"%@?"
                           "redirect_uri=%@&"
                           "response_type=%@&"
                           "state=%@&"
                           "client_id=%@&"
                           "scope=%@&"
                           "%@",
                           authURL, self.redirect_uri, response_type, randomState, client_id_upd, self.scope, mobileParam];
    NSURL *url = [NSURL URLWithString:urlString];
    
    // ===== authorizing user request =====
    
    SQLoginWebViewController *loginWebViewController = \
    [[SQLoginWebViewController alloc] initWithURL:url andCompletionBlock:^(NSMutableDictionary *response) {
        NSLog(@"%@", response);
        
        if ([response objectForKey:@"state"]) {
            // first, must check if "state" from response matches "state" in request
            if (![[response objectForKey:@"state"] isEqualToString:randomState]) {
                NSLog(@"state mismatch, response is being spoofed");
                if (result) {
                    [self stopActivityIndicator];
                    result(nil, NO, YES);
                }
            } else {
                
                // state matches - we can proceed with token request
                // ===== getting token request ======
                [self startActivityIndicatorWithTitle:@"Authorizing user"];
                [self postForTokenWithCode:[response objectForKey:@"code"] onSuccess:^(SQToken *token) {
                    if (token) {
                        [self stopActivityIndicator];
                        [[SQAuthResult sharedInstance] setToken:token];
                        [[SQTokenUpdater sharedInstance] cancelTimer];
                        // THIS WILL START TIMER TO AUTOMATICALLY REFRESH ACCESS_TOKEN WHEN IT'S EXPIRED
                        [[SQTokenUpdater sharedInstance] startTimer];
                        result(token, NO, NO);
                    } else {
                        if (result) {
                            [self stopActivityIndicator];
                            result(nil, NO, YES);
                        }
                    }
                } onFailure:^(NSError *error) {
                    NSLog(@"error = %@", [error localizedDescription]);
                    if (result) {
                        [self stopActivityIndicator];
                        result(nil, NO, YES);
                    }
                }];
            }
            
        } else if ([response objectForKey:@"didCancelAuthorization"]) {
            if (result) {
                [self stopActivityIndicator];
                result(nil, YES, NO);
            }
            
        } else if ([response objectForKey:@"error"]) {
            if (result) {
                [self stopActivityIndicator];
                result(nil, NO, YES);
            }
        }
    }];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginWebViewController];
    UIViewController *mainVC = [[[[UIApplication sharedApplication] windows] firstObject] rootViewController];
    [mainVC presentViewController:nav animated:YES completion:nil];
}


- (void)postForTokenWithCode:(NSString *)code
                   onSuccess:(void(^)(SQToken *token))success
                   onFailure:(void(^)(NSError *error))failure {
    NSDictionary *postParameters = [NSDictionary dictionaryWithObjectsAndKeys:
                            grant_type, @"grant_type",
                            code, @"code",
                            self.redirect_uri, @"redirect_uri", nil];
    [SQHttpHelper execHttpRequestWithUrl:tokenURL
                             andMethod:@"POST"
                            andHeaders:nil
                           andUsername:self.client_id
                           andPassword:self.client_secret
                              andToken:nil
                          andAuthScope:@"Basic"
                         andParameters:postParameters
                            andHandler:^(NSString* responseText, NSURLResponse* response, NSError* error) {
        if (response) {
            NSError *jsonError;
            NSData *jsonData = [responseText dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                         options:0
                                                                           error:&jsonError];
            if (jsonError != nil) {
                if (success) {
                    success(nil);
                }
            } else {
                SQToken *token = [SQToken new];
                token.accessToken = [parsedObject objectForKey:@"access_token"];
                NSTimeInterval interval = [[parsedObject objectForKey:@"expires_in"] doubleValue] - 600;
                token.expirationDate = [NSDate dateWithTimeIntervalSinceNow:interval];
                token.tokenType = [parsedObject objectForKey:@"token_type"];
                token.scope = [parsedObject objectForKey:@"scope"];
                token.refreshToken = [parsedObject objectForKey:@"refresh_token"];
                if (success) {
                    success(token);
                }
            }
        } else if (failure) {
            failure(error);
        }
    }];
}



#pragma mark -
#pragma mark for Authorized user. Token methods

- (void)withRefreshToken:(SQToken *)refreshToken
       updateAccessToken:(void(^)(SQToken *token))refreshedToken {
    
    [self postForNewTokenWithRefreshToken:refreshToken onSuccess:^(SQToken *updatedToken) {
        if (updatedToken.refreshToken == nil) {
            updatedToken.refreshToken = refreshToken.refreshToken;
        }
        // save new token into SQAuthResult container
        [[SQAuthResult sharedInstance] setToken:updatedToken];
        [[SQTokenUpdater sharedInstance] cancelTimer];
        // THIS WILL START TIMER TO AUTOMATICALLY REFRESH ACCESS_TOKEN WHEN IT'S EXPIRED
        [[SQTokenUpdater sharedInstance] startTimer];
        refreshedToken(updatedToken);
        
    } onFailure:^(NSError *error) {
        NSLog(@"error = %@", [error localizedDescription]);
        if (refreshedToken) {
            refreshedToken(nil);
        }
    }];
}


- (void)launchTokenTimerUpdateWithToken:(SQToken *)token {
    [[SQAuthResult sharedInstance] setToken:token];
    [[SQTokenUpdater sharedInstance] cancelTimer];
    // THIS WILL START TIMER TO AUTOMATICALLY REFRESH ACCESS_TOKEN WHEN IT'S EXPIRED
    [[SQTokenUpdater sharedInstance] startTimer];
}


- (void)postForNewTokenWithRefreshToken:(SQToken *)token
                              onSuccess:(void(^)(SQToken *updatedToken))success
                              onFailure:(void(^)(NSError *error))failure {
    
    NSDictionary *postParameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    refreshGrant_type,  @"grant_type",
                                    token.refreshToken, @"refresh_token", nil];
    
    [SQHttpHelper execHttpRequestWithUrl:refreshTokenURL
                             andMethod:@"POST"
                            andHeaders:nil
                           andUsername:self.client_id
                           andPassword:self.client_secret
                              andToken:nil
                          andAuthScope:@"Basic"
                         andParameters:postParameters
                            andHandler:^(NSString* responseText, NSURLResponse* response, NSError* error) {
                                
                                if (response) {
                                    NSError *jsonError;
                                    NSData *jsonData = [responseText dataUsingEncoding:NSUTF8StringEncoding];
                                    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                                                 options:0
                                                                                                   error:&jsonError];
                                    if (jsonError != nil) {
                                        if (success) {
                                            success(nil);
                                        }
                                    } else {
                                        SQToken *token = [SQToken new];
                                        token.accessToken = [parsedObject objectForKey:@"access_token"];
                                        NSTimeInterval interval = [[parsedObject objectForKey:@"expires_in"] doubleValue] - 600;
                                        token.expirationDate = [NSDate dateWithTimeIntervalSinceNow:interval];
                                        token.tokenType = [parsedObject objectForKey:@"token_type"];
                                        token.scope = [parsedObject objectForKey:@"scope"];
                                        if (success) {
                                            success(token);
                                        }
                                    }
                                } else if (failure) {
                                    failure(error);
                                }
                            }];
}



#pragma mark -
#pragma mark for Authorized user. Sign Out

- (void)userDidSignOut {
    [[SQAuthResult sharedInstance] setToken:nil];
    [[SQTokenUpdater sharedInstance] cancelTimer];
}




#pragma mark -
#pragma mark Request helpers

- (int)randomInt {
    return arc4random_uniform(100);
}


- (NSString *)randomStringWithLength:(int)len {
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    for (int i = 0; i < len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: (NSUInteger)arc4random_uniform((u_int32_t)[letters length])]];
    }
    return randomString;
}



#pragma mark -
#pragma mark Activity indicator

- (void)startActivityIndicatorWithTitle:(NSString *)title {
    dispatch_async(kMainQueue, ^{
        self.messageFrame = [UIView new];
        self.activityIndicator = [UIActivityIndicatorView new];
        self.strLabel = [UILabel new];
        
        UIViewController *topmostVC;
        UIViewController *rootVC1 = [[[[UIApplication sharedApplication] windows] firstObject] rootViewController];
        
        if ([rootVC1 isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navVC = rootVC1;
            topmostVC = [navVC viewControllers][0];
            self.mainVC = topmostVC;
        } else {
            self.mainVC = [[[[UIApplication sharedApplication] windows] firstObject] rootViewController];
        }
        
        self.strLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, 150, 50)];
        self.strLabel.text = title;
        // self.strLabel.font = [UIFont systemFontOfSize:15.f];
        self.strLabel.textColor = [UIColor whiteColor];
        
        CGFloat xPos = self.mainVC.view.frame.size.width / 2 - 100;
        CGFloat yPos = self.mainVC.view.frame.size.height / 2 + 50;
        self.messageFrame = [[UIView alloc] initWithFrame:CGRectMake(xPos, yPos, 250, 50)];
        self.messageFrame.layer.cornerRadius = 15;
        self.messageFrame.backgroundColor = [UIColor clearColor];
        
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        self.activityIndicator.frame = CGRectMake(0, 0, 50, 50);
        [self.activityIndicator startAnimating];
        
        [self.messageFrame addSubview:self.activityIndicator];
        [self.messageFrame addSubview:self.strLabel];
        [self.mainVC.view addSubview:self.messageFrame];
    });
}

- (void)stopActivityIndicator {
    dispatch_async(kMainQueue, ^{
        [self.activityIndicator stopAnimating];
        [self.messageFrame removeFromSuperview];
    });
}


/*
#pragma mark -
#pragma mark for Authorized user. Load Files

- (void)getForFilesWithToken:(SQToken *)token
                   onSuccess:(void (^)(NSArray *))success
                   onFailure:(void (^)(NSError *))failure {
    
    NSString *apiUrlForFiles = [[NSString alloc] initWithFormat:@"%@%@", apiURL, filesPath];
    
    [SQHttpHelper execHttpRequestWithUrl:apiUrlForFiles
                               andMethod:@"GET"
                              andHeaders:nil
                             andUsername:nil
                             andPassword:nil
                                andToken:token.accessToken
                            andAuthScope:@"Bearer"
                           andParameters:nil
                              andHandler:^(NSString* responseText, NSURLResponse* response, NSError* error) {
                                  
                                  if (response) {
                                      NSError *jsonError;
                                      NSData *jsonData = [responseText dataUsingEncoding:NSUTF8StringEncoding];
                                      NSArray *parsedObject = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                                              options:0
                                                                                                error:&jsonError];
                                      if (jsonError != nil) {
                                          NSLog(@"Error: %@", jsonError);
                                          if (success) {
                                              success(nil);
                                          }
                                      } else {
                                          if (success) {
                                              success(parsedObject);
                                          }
                                      }
                                  } else if (failure) {
                                      failure(error);
                                  }
                              }];
}*/

/*
- (void)getForSampleFilesWithToken:(SQToken *)token
                         onSuccess:(void(^)(NSArray *))success
                         onFailure:(void(^)(NSError *))failure {
    
    NSString *apiUrlForDemo = [[NSString alloc] initWithFormat:@"%@%@", apiURL, demoPath];
    
    [SQHttpHelper execHttpRequestWithUrl:apiUrlForDemo
                               andMethod:@"GET"
                              andHeaders:nil
                             andUsername:nil
                             andPassword:nil
                                andToken:token.accessToken
                            andAuthScope:@"Bearer"
                           andParameters:nil
                              andHandler:^(NSString* responseText, NSURLResponse* response, NSError* error) {
                                  
                                  if (response) {
                                      NSError *jsonError;
                                      NSData *jsonData = [responseText dataUsingEncoding:NSUTF8StringEncoding];
                                      NSArray *parsedObject = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                                              options:0
                                                                                                error:&jsonError];
                                      if (jsonError != nil) {
                                          NSLog(@"Error: %@", jsonError);
                                          if (success) {
                                              success(nil);
                                          }
                                      } else {
                                          if (success) {
                                              success(parsedObject);
                                          }
                                      }
                                  } else if (failure) {
                                      failure(error);
                                  }
                              }];
}*/

/*
- (void)getForOwnFilesWithToken:(SQToken *)token
                      onSuccess:(void (^)(NSArray *))success
                      onFailure:(void (^)(NSError *))failure {
    
    NSString *apiUrlForFiles = [[NSString alloc] initWithFormat:@"%@%@", apiURL, filesPath];
    
    [SQHttpHelper execHttpRequestWithUrl:apiUrlForFiles
                               andMethod:@"GET"
                              andHeaders:nil
                             andUsername:nil
                             andPassword:nil
                                andToken:token.accessToken
                            andAuthScope:@"Bearer"
                           andParameters:nil
                              andHandler:^(NSString* responseText, NSURLResponse* response, NSError* error) {
                                  
                                  if (response) {
                                      NSError *jsonError;
                                      NSData *jsonData = [responseText dataUsingEncoding:NSUTF8StringEncoding];
                                      NSArray *parsedObject = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                                              options:0
                                                                                                error:&jsonError];
                                      if (jsonError != nil) {
                                          NSLog(@"Error: %@", jsonError);
                                          if (success) {
                                              success(nil);
                                          }
                                      } else {
                                          if (success) {
                                              success(parsedObject);
                                          }
                                      }
                                  } else if (failure) {
                                      failure(error);
                                  }
                              }];
}*/



@end
