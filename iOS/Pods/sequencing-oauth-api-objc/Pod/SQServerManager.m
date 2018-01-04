//
//  SQServerManager.h
//  Copyright © 2017 Sequencing.com. All rights reserved
//


#import "SQServerManager.h"
#import "SQLoginWebViewController.h"
#import "SQToken.h"
#import "SQHttpHelper.h"
#import "SQRequestHelper.h"
#import "SQConnectToWebViewController.h"
#import "SQEncryptionHelper.h"


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


// registrate new account endpoint
#define kConnectToEndpoint          @"http://sequencing.com/connect"

// registrate new account endpoint
#define kRegisterNewAccountEndpoint @"https://sequencing.com/indexApi.php?q=sequencing/public/webservice/user/seq_register.json"

// peset password endpoint
#define kResetPasswordEndpoint      @"https://sequencing.com/indexApi.php?q=sequencing/public/webservice/user/seq_new_pass.json"


#define kMainQueue dispatch_get_main_queue()
#define VALID_STATUS_CODES @[@(200), @(301), @(302)]

#define INVALID_SERVER_RESPONSE @"We are sorry as this app is experiencing a temporary issue.\nPlease try again in a few minutes."


#define kInitEncryptionVector   @"3n3CrwwnzMqxOssv"





@interface SQServerManager ()

@property (readwrite, strong, nonatomic) NSString *client_id;
@property (readwrite, strong, nonatomic) NSString *client_secret;
@property (readwrite, strong, nonatomic) NSString *redirect_uri;
@property (readwrite, strong, nonatomic) NSString *scope;

@end




@implementation SQServerManager

#pragma mark -  Initializer

+ (instancetype) sharedInstance {
    static SQServerManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[SQServerManager alloc] init];
    });
    return manager;
}


- (void)registrateParametersCliendID:(NSString *)client_id
                        clientSecret:(NSString *)client_secret
                         redirectUri:(NSString *)redirect_uri
                               scope:(NSString *)scope {
    (client_id && [client_id length] > 0)         ? self.client_id = client_id         : NSLog(@"client_id is empty");
    (client_secret && [client_secret length] > 0) ? self.client_secret = client_secret : NSLog(@"client_secret is empty");
    (redirect_uri && [redirect_uri length] > 0)   ? self.redirect_uri = redirect_uri   : NSLog(@"redirect_uri is empty");
    (scope && [scope length] > 0)                 ? self.scope = scope                 : NSLog(@"scope is empty");
    
    [[SQRequestHelper sharedInstance] rememberRedirectUri:redirect_uri];
}




#pragma mark - Authorization

- (void)authorizeUserForVC:(UIViewController *)controller withResult:(void (^)(SQToken *token, BOOL didCancel, BOOL error))result {
    
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
    SQLoginWebViewController *loginWebViewController =
    [[SQLoginWebViewController alloc] initWithURL:url andCompletionBlock:^(NSMutableDictionary *response) {
        
        if ([response objectForKey:@"state"]) {
            // first, must check if "state" from response matches "state" in request
            if (![[response objectForKey:@"state"] isEqualToString:randomState]) {
                NSLog(@"state mismatch, response is being spoofed");
                if (result) result(nil, NO, YES);
                
            } else { // state matches - we can proceed with token request
                [self postForTokenWithCode:[response objectForKey:@"code"] onSuccess:^(SQToken *token) {
                    if (token) result(token, NO, NO);
                    
                    else if (result) result(nil, NO, YES);
                    
                } onFailure:^(NSError *error) {
                    NSLog(@"error = %@", [error localizedDescription]);
                    if (result) result(nil, NO, YES);
                }];
            }
            
        } else if ([response objectForKey:@"didCancelAuthorization"]) {
            if (result) result(nil, YES, NO);
            
        } else if ([response objectForKey:@"error"]) {
            if (result) result(nil, NO, YES);
        }
    }];
    
    UINavigationController *navWebView = [[UINavigationController alloc] initWithRootViewController:loginWebViewController];
    [controller presentViewController:navWebView animated:YES completion:nil];
}




#pragma mark - Token methods

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
                if (success) success(nil);
                
            } else {
                SQToken *token = [SQToken new];
                token.accessToken = [parsedObject objectForKey:@"access_token"];
                NSTimeInterval interval = [[parsedObject objectForKey:@"expires_in"] doubleValue] - 600;
                token.expirationDate = [NSDate dateWithTimeIntervalSinceNow:interval];
                token.tokenType = [parsedObject objectForKey:@"token_type"];
                token.scope = [parsedObject objectForKey:@"scope"];
                token.refreshToken = [parsedObject objectForKey:@"refresh_token"];
                if (success) success(token);
                
            }
        } else if (failure) failure(error);
    }];
}



- (void)withRefreshToken:(SQToken *)refreshToken
       updateAccessToken:(void(^)(SQToken *token))refreshedToken {
    
    [self postForNewTokenWithRefreshToken:refreshToken onSuccess:^(SQToken *updatedToken) {
        if (updatedToken.refreshToken == nil)
            updatedToken.refreshToken = refreshToken.refreshToken;
        
        refreshedToken(updatedToken);
        
    } onFailure:^(NSError *error) {
        NSLog(@"error = %@", [error localizedDescription]);
        if (refreshedToken) refreshedToken(nil);
    }];
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
                                        if (success) success(nil);
                                    } else {
                                        SQToken *token = [SQToken new];
                                        token.accessToken = [parsedObject objectForKey:@"access_token"];
                                        NSTimeInterval interval = [[parsedObject objectForKey:@"expires_in"] doubleValue] - 600;
                                        token.expirationDate = [NSDate dateWithTimeIntervalSinceNow:interval];
                                        token.tokenType = [parsedObject objectForKey:@"token_type"];
                                        token.scope = [parsedObject objectForKey:@"scope"];
                                        if (success) success(token);
                                    }
                                } else if (failure) failure(error);
                            }];
}




#pragma mark - Registrate new account

- (void)registrateAccountForEmailAddress:(NSString *)emailAddress withResult:(void(^)(NSString *error))result {
    NSString *urlString = kRegisterNewAccountEndpoint;
    NSString *urlEncoded = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: self.client_secret, @"client_id", emailAddress, @"email", nil];
    
    [SQHttpHelper execPostHttpRequestWithUrl:urlEncoded
                                  parameters:parameters
                                  andHandler:^(NSString *responseText, NSURLResponse *response, NSError *error) {
                                      
                                      NSLog(@"\n[registrateAccountForEmailAddress] responseText: %@", responseText);
                                      NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                      NSInteger statusCode = [httpResponse statusCode];
                                      
                                      if (error) {  // server connection error
                                          NSLog(@"\nerror: %@", error.localizedDescription);
                                          result(INVALID_SERVER_RESPONSE);
                                          return;
                                      }
                                      
                                      if (![VALID_STATUS_CODES containsObject:@(statusCode)]) {
                                          NSLog(@"\n[registrateAccountForEmailAddress] statusCode: %zd", statusCode);
                                          result(INVALID_SERVER_RESPONSE);
                                          return;
                                      };
                                      
                                      NSData *data = [responseText dataUsingEncoding:NSUTF8StringEncoding];
                                      if (!data || [responseText length] == 0) {
                                          result(INVALID_SERVER_RESPONSE);
                                          return;
                                      }
                                      
                                      NSError *jsonError;
                                      NSData  *jsonData = data;
                                      NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&jsonError];
                                      
                                      if (jsonError) { // error with invalid json
                                          result(INVALID_SERVER_RESPONSE);
                                          return;
                                      }
                                      
                                      result([self validateRegistrationResetPasswordResponse:parsedObject]);
                                  }];
}




#pragma mark - Reset password

- (void)resetPasswordForEmailAddress:(NSString *)emailAddress withResult:(void(^)(NSString *error))result {
    NSString *urlString = kResetPasswordEndpoint;
    NSString *urlEncoded = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                self.client_secret, @"client_id",
                                emailAddress, @"email", nil];
    
    [SQHttpHelper execPostHttpRequestWithUrl:urlEncoded
                                  parameters:parameters
                                  andHandler:^(NSString *responseText, NSURLResponse *response, NSError *error) {
                                      
                                      NSLog(@"\n[resetPasswordForEmailAddress] responseText: %@", responseText);
                                      NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                      NSInteger statusCode = [httpResponse statusCode];
                                      
                                      if (error) {  // server connection error
                                          NSLog(@"\nerror: %@", error.localizedDescription);
                                          result(INVALID_SERVER_RESPONSE);
                                          return;
                                      }
                                      
                                      if (![VALID_STATUS_CODES containsObject:@(statusCode)]) {
                                          NSLog(@"\n[resetPasswordForEmailAddress] statusCode: %zd", statusCode);
                                          result(INVALID_SERVER_RESPONSE);
                                          return;
                                      };
                                      
                                      NSData *data = [responseText dataUsingEncoding:NSUTF8StringEncoding];
                                      if (!data || [responseText length] == 0) {
                                          result(INVALID_SERVER_RESPONSE);
                                          return;
                                      }
                                      
                                      NSError *jsonError;
                                      NSData  *jsonData = data;
                                      NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&jsonError];
                                      
                                      if (jsonError) { // error with invalid json
                                          result(INVALID_SERVER_RESPONSE);
                                          return;
                                      }
                                      
                                      result([self validateRegistrationResetPasswordResponse:parsedObject]);
                                  }];
}



- (NSString *)validateRegistrationResetPasswordResponse:(NSDictionary *)parsedObject {
    if (![[parsedObject allKeys] containsObject:@"status"])
        return INVALID_SERVER_RESPONSE;
    
    id statusCode = [parsedObject objectForKey:@"status"];
    NSString *statusCodeString = [NSString stringWithFormat:@"%@", statusCode];
    int statusCodeValue = (int)[statusCodeString integerValue];
    
    switch (statusCodeValue) {
        case 0: // success, no errors
            return nil;
            break;
            
        case 1: { // error
            if (![[parsedObject allKeys] containsObject:@"errorCode"])
                return INVALID_SERVER_RESPONSE;
            
            if (![[parsedObject allKeys] containsObject:@"errorMessage"])
                return INVALID_SERVER_RESPONSE;
            
            id responseErrorMessage = [parsedObject objectForKey:@"errorMessage"];
            
            if ([responseErrorMessage isKindOfClass:[NSString class]])
                return [NSString stringWithFormat:@"%@", responseErrorMessage];
            
            if ([responseErrorMessage isKindOfClass:[NSDictionary class]]) {
                NSMutableString *validationResult = [[NSMutableString alloc] init];
                for (id key in [responseErrorMessage allKeys]) {
                    id value = [responseErrorMessage objectForKey: key];
                    [validationResult appendString:[NSString stringWithFormat:@"%@", value]];
                }
                return [NSString stringWithString:validationResult];
            }
            
            return INVALID_SERVER_RESPONSE;
        }   break;
            
        default:
            return INVALID_SERVER_RESPONSE;
            break;
    }
}




#pragma mark - Connect to request

- (void)connectToSequencingWithClient_id:(NSString *)client_id
                               userEmail:(NSString *)emailAddress
                              filesArray:(NSArray *)filesArray
                  viewControllerDelegate:(UIViewController *)controller {
    
    NSMutableDictionary *urlParametersDict = [[NSMutableDictionary alloc] init];
    [urlParametersDict setObject:client_id    forKey:@"client_id"];
    [urlParametersDict setObject:emailAddress forKey:@"email"];
    [urlParametersDict setObject:filesArray   forKey:@"files"];
    
    NSString *key = client_id;
    NSString *iv  = kInitEncryptionVector;
    
    NSString *encryptedString = [SQEncryptionHelper encryptAES256ForParameters:urlParametersDict key:key iv:iv];
    NSString *encryptedJsonURLEncoded = [SQEncryptionHelper urlEncodeForString:encryptedString];
    
    NSString *md5Key = [SQEncryptionHelper md5forString:client_id];
    
    NSString *urlString  = [NSString stringWithFormat:@"%@?c=%@&json=%@", kConnectToEndpoint, md5Key, encryptedJsonURLEncoded];
    NSURL    *url = [NSURL URLWithString:urlString];
    
    SQConnectToWebViewController *connectToWebViewController =
    [[SQConnectToWebViewController alloc] initWithURL:url andCompletionBlock:^(BOOL success, BOOL didCancel, NSString *error) {
        dispatch_async(kMainQueue, ^{
            [controller.view setUserInteractionEnabled:YES];
        });
    }];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:connectToWebViewController];
    [controller presentViewController:nav animated:YES completion:nil];
}




#pragma mark - Request helpers

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




@end
