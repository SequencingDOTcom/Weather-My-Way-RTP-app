//
//  SQ3rdPartyImportHelper.h
//  Copyright © 2017 Sequencing.com. All rights reserved
//


#import "SQ3rdPartyImportHelper.h"
#import "SQ3rdPartyImportHttpHelper.h"


#define k3rdPartyFilesImportEndpointPROD    @"https://api.sequencing.com"
NSString *k3rdPartyFilesImportEndpoint      = k3rdPartyFilesImportEndpointPROD;

#define k23andMeImportURL                   @"/23andMe/Download"
#define k23andMeImportSecurityURL           @"/23andMe/DownloadWithSecurity"

#define kAncestryImportURL                  @"/Ancestry/Authorize"
#define kAncestryImportSecurityURL          @"/Ancestry/Download"





@implementation SQ3rdPartyImportHelper

#pragma mark - Init

+ (instancetype)sharedInstance {
    static SQ3rdPartyImportHelper *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SQ3rdPartyImportHelper alloc] init];
    });
    return instance;
}




#pragma mark - 23andMe import

- (void)importRequest23andMeWithLogin:(NSString *)login password:(NSString *)password token:(NSString *)token {
    NSDictionary *postParams = @{@"Login"   : login,
                                 @"Password": password};
    
    [SQ3rdPartyImportHttpHelper execHttpRequestWithUrl:[NSString stringWithFormat:@"%@%@", k3rdPartyFilesImportEndpoint, k23andMeImportURL]
                                                method:@"POST"
                                                 token:token
                                             authScope:@"Bearer"
                                        jsonParameters:postParams
                                               handler:^(NSString *responseText, NSURLResponse *response, NSError *error) {
                                                   
                                                   if (error || !responseText || [responseText length] == 0) {
                                                       [_me23Delegate import23andMe_InternalServerError];
                                                       return;
                                                   }
                                                   
                                                   NSError      *jsonError;
                                                   NSData       *jsonData = [responseText dataUsingEncoding:NSUTF8StringEncoding];
                                                   NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&jsonError];
                                                   
                                                   if (jsonError) {
                                                       [_me23Delegate import23andMe_InternalServerError];
                                                       return;
                                                   }
                                                   
                                                   if (![self is23andMeAuthResponseValid:parsedObject]) {
                                                       [_me23Delegate import23andMe_InternalServerError];
                                                       return;
                                                   }
                                                   
                                                   NSInteger statusCode = [self statusCodeFromServerResponse:parsedObject];
                                                   
                                                   switch (statusCode) {
                                                       case 0:  [_me23Delegate import23andMe_ImportStarted]; break;
                                                           
                                                       case 1:  [_me23Delegate import23andMe_InvalidLoginPassword]; break;
                                                           
                                                       case 2: {
                                                           NSString *question = [self securityQuestionFromServerResponse:parsedObject];
                                                           NSString *sessionId = [self sessionIdFromServerResponse:parsedObject];
                                                           [_me23Delegate import23andMe_SecurityOriginQuestion:question
                                                                                            adjustedQuestion:nil
                                                                                                   sessionId:sessionId];
                                                       } break;
                                                           
                                                       case 3:  [_me23Delegate import23andMe_InternalServerError]; break;
                                                           
                                                       default: [_me23Delegate import23andMe_InternalServerError]; break;
                                                   }
                                               }];
}



- (void)importRequest23andMeWithAnswer:(NSString *)securityAnswer securityQuestion:(NSString *)question sessionId:(NSString *)sessionId token:(NSString *)token {
    NSDictionary *postParams = @{@"SeqAnswer": securityAnswer,
                                 @"SessionId": sessionId};
    
    [SQ3rdPartyImportHttpHelper execHttpRequestWithUrl:[NSString stringWithFormat:@"%@%@", k3rdPartyFilesImportEndpoint, k23andMeImportSecurityURL]
                                                method:@"POST"
                                                 token:token
                                             authScope:@"Bearer"
                                        jsonParameters:postParams
                                               handler:^(NSString *responseText, NSURLResponse *response, NSError *error) {
                                                   
                                                   if (error || !responseText || [responseText length] == 0) {
                                                       [_me23Delegate import23andMe_InternalServerError];
                                                       return;
                                                   }
                                                   
                                                   NSError      *jsonError;
                                                   NSData       *jsonData = [responseText dataUsingEncoding:NSUTF8StringEncoding];
                                                   NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&jsonError];
                                                   
                                                   if (jsonError) {
                                                       [_me23Delegate import23andMe_InternalServerError];
                                                       return;
                                                   }
                                                   
                                                   if (![self isSecurityResponseValid:parsedObject]) {
                                                       [_me23Delegate import23andMe_InternalServerError];
                                                       return;
                                                   }
                                                   
                                                   NSInteger statusCode = [self statusCodeFromServerResponse:parsedObject];
                                                   
                                                   switch (statusCode) {
                                                       case 0:  [_me23Delegate import23andMe_ImportStarted]; break;
                                                           
                                                       case 1:  [_me23Delegate import23andMe_InvalidAnswer]; break;
                                                           
                                                       case 2:  [_me23Delegate import23andMe_InternalServerError]; break;
                                                           
                                                       default: [_me23Delegate import23andMe_InternalServerError]; break;
                                                   }
                                               }];
}




#pragma mark - Ancestry.com import


- (void)importRequestAncestryWithLogin:(NSString *)login password:(NSString *)password token:(NSString *)token {
    NSDictionary *postParams = @{@"Login"   : login,
                                 @"Password": password};
    
    [SQ3rdPartyImportHttpHelper execHttpRequestWithUrl:[NSString stringWithFormat:@"%@%@", k3rdPartyFilesImportEndpoint, kAncestryImportURL]
                                                method:@"POST"
                                                 token:token
                                             authScope:@"Bearer"
                                        jsonParameters:postParams
                                               handler:^(NSString *responseText, NSURLResponse *response, NSError *error) {
                                                   
                                                   if (error || !responseText || [responseText length] == 0) {
                                                       [_ancestryDelegate importAncestry_InternalServerError];
                                                       return;
                                                   }
                                                   
                                                   NSError      *jsonError;
                                                   NSData       *jsonData = [responseText dataUsingEncoding:NSUTF8StringEncoding];
                                                   NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&jsonError];
                                                   
                                                   if (jsonError) {
                                                       [_ancestryDelegate importAncestry_InternalServerError];
                                                       return;
                                                   }
                                                   
                                                   if (![self isAncestryAuthResponseValid:parsedObject]) {
                                                       [_ancestryDelegate importAncestry_InternalServerError];
                                                       return;
                                                   }
                                                   
                                                   NSInteger statusCode = [self statusCodeFromServerResponse:parsedObject];
                                                   
                                                   switch (statusCode) {
                                                       case 0:  [_ancestryDelegate importAncestry_EmailSentWithText:nil
                                                                                                          sessionId:[self sessionIdFromServerResponse:parsedObject]]; break;
                                                           
                                                       case 1:  [_ancestryDelegate importAncestry_InvalidLoginPassword]; break;
                                                           
                                                       case 2:  [_ancestryDelegate importAncestry_InternalServerError]; break;
                                                           
                                                       default: [_ancestryDelegate importAncestry_InternalServerError]; break;
                                                   }
                                               }];
}


- (void)importRequestAncestryWithURL:(NSString *)url sessionId:(NSString *)sessionId token:(NSString *)token {
    NSDictionary *postParams = @{@"Url": url,
                                 @"SessionId": sessionId};
    
    [SQ3rdPartyImportHttpHelper execHttpRequestWithUrl:[NSString stringWithFormat:@"%@%@", k3rdPartyFilesImportEndpoint, kAncestryImportSecurityURL]
                                                method:@"POST"
                                                 token:token
                                             authScope:@"Bearer"
                                        jsonParameters:postParams
                                               handler:^(NSString *responseText, NSURLResponse *response, NSError *error) {
                                                   
                                                   if (error || !responseText || [responseText length] == 0) {
                                                       [_ancestryDelegate importAncestry_InternalServerError];
                                                       return;
                                                   }
                                                   
                                                   NSError      *jsonError;
                                                   NSData       *jsonData = [responseText dataUsingEncoding:NSUTF8StringEncoding];
                                                   NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&jsonError];
                                                   
                                                   if (jsonError) {
                                                       [_ancestryDelegate importAncestry_InternalServerError];
                                                       return;
                                                   }
                                                   
                                                   if (![self isSecurityResponseValid:parsedObject]) {
                                                       [_ancestryDelegate importAncestry_InternalServerError];
                                                       return;
                                                   }
                                                   
                                                   NSInteger statusCode = [self statusCodeFromServerResponse:parsedObject];
                                                   
                                                   switch (statusCode) {
                                                       case 0:  [_ancestryDelegate importAncestry_ImportStarted]; break;
                                                           
                                                       case 1:  [_ancestryDelegate importAncestry_InvalidURL]; break;
                                                           
                                                       case 2:  [_ancestryDelegate importAncestry_InternalServerError]; break;
                                                           
                                                       default: [_ancestryDelegate importAncestry_InternalServerError]; break;
                                                   }
                                               }];
}




#pragma mark - server response helpers

- (BOOL)is23andMeAuthResponseValid:(NSDictionary *)response {
    if (!response || [response allKeys].count == 0) return NO;
    
    NSArray *keysArray = [response allKeys];
    if (![keysArray containsObject:@"SecurityQuestion"]) return NO;
    if (![keysArray containsObject:@"SessionId"]) return NO;
    if (![keysArray containsObject:@"StatusCode"]) return NO;
    
    id temp = [response objectForKey:@"StatusCode"];
    if (!temp) return NO;
    
    NSString *codeString = [NSString stringWithFormat:@"%@", temp];
    if (!codeString || [codeString length] == 0) return NO;
    
    NSInteger statusCode = [codeString integerValue];
    if (statusCode == 2) {
        id tempQuestion  = [response objectForKey:@"SecurityQuestion"];
        id tempSessionId = [response objectForKey:@"SessionId"];
        if (!tempQuestion || !tempSessionId) return NO;
        
        NSString *stringQuestion  = [NSString stringWithFormat:@"%@", tempQuestion];
        NSString *stringSessionId = [NSString stringWithFormat:@"%@", tempSessionId];
        if (!stringQuestion || [stringQuestion length] == 0 || !stringSessionId || [stringSessionId length] == 0) return NO;
    }
    return YES;
}


- (BOOL)isAncestryAuthResponseValid:(NSDictionary *)response {
    if (!response || [response allKeys].count == 0) return NO;
    
    NSArray *keysArray = [response allKeys];
    if (![keysArray containsObject:@"SessionId"]) return NO;
    if (![keysArray containsObject:@"StatusCode"]) return NO;
    
    id temp = [response objectForKey:@"StatusCode"];
    if (!temp) return NO;
    
    NSString *codeString = [NSString stringWithFormat:@"%@", temp];
    if (!codeString || [codeString length] == 0) return NO;
    
    NSInteger statusCode = [codeString integerValue];
    if (statusCode == 0) {
        id tempSessionId = [response objectForKey:@"SessionId"];
        if (!tempSessionId || !tempSessionId) return NO;
        NSString *stringSessionId = [NSString stringWithFormat:@"%@", tempSessionId];
        if (!stringSessionId || [stringSessionId length] == 0) return NO;
    }
    return YES;
}


- (BOOL)isSecurityResponseValid:(NSDictionary *)response {
    if (!response || [response allKeys].count == 0) return NO;
    
    NSArray *keysArray = [response allKeys];
    if (![keysArray containsObject:@"StatusCode"]) return NO;
    
    id temp = [response objectForKey:@"StatusCode"];
    if (!temp) return NO;
    
    NSString *codeString = [NSString stringWithFormat:@"%@", temp];
    if (!codeString || [codeString length] == 0) return NO;
    
    return YES;
}



- (NSInteger)statusCodeFromServerResponse:(NSDictionary *)response {
    NSInteger statusCode = 3;
    id temp = [response objectForKey:@"StatusCode"];
    if (temp) {
        NSString *codeString = [NSString stringWithFormat:@"%@", temp];
        if (codeString && [codeString length] > 0)
            statusCode = [codeString integerValue];
    }
    return statusCode;
}


- (NSString *)securityQuestionFromServerResponse:(NSDictionary *)response {
    return [response objectForKey:@"SecurityQuestion"];
}


- (NSString *)sessionIdFromServerResponse:(NSDictionary *)response {
    return [response objectForKey:@"SessionId"];
}




@end
