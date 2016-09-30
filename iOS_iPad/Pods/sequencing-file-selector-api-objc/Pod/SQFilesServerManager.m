//
//  SQFilesServerManager.m
//  Copyright © 2015-2016 Sequencing.com. All rights reserved
//

#import "SQFilesServerManager.h"
#import "SQFilesHttpHelper.h"

@implementation SQFilesServerManager

// parameters for files request
static NSString *apiURL         = @"https://api.sequencing.com";
static NSString *filesPath      = @"/DataSourceList?all=true";


+ (instancetype) sharedInstance {
    static SQFilesServerManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[SQFilesServerManager alloc] init];
    });
    return manager;
}


#pragma mark -
#pragma mark Request fuctions

- (void)getForFilesWithToken:(NSString *)accessToken
                   onSuccess:(void (^)(NSArray *))success
                   onFailure:(void (^)(NSError *))failure {
    NSString *apiUrlForFiles = [[NSString alloc] initWithFormat:@"%@%@", apiURL, filesPath];
    [SQFilesHttpHelper execHttpRequestWithUrl:apiUrlForFiles
                                    andMethod:@"GET"
                                   andHeaders:nil
                                  andUsername:nil
                                  andPassword:nil
                                     andToken:accessToken
                                 andAuthScope:@"Bearer"
                                andParameters:nil
                                   andHandler:^(NSString* responseText, NSURLResponse* response, NSError* error) {
                                       
                                       if (response) {
                                           
                                           if ([[responseText lowercaseString] rangeOfString:@"exception"].location != NSNotFound ||
                                               [[responseText lowercaseString] rangeOfString:@"invalid"].location != NSNotFound ||
                                               [[responseText lowercaseString] rangeOfString:@"error"].location != NSNotFound) {
                                               
                                               NSLog(@"Error: %@", responseText);
                                               if (success) {
                                                   success(nil);
                                               }
                                               
                                           } else {
                                               
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
                                           }
                                           
                                       } else if (failure) {
                                           failure(error);
                                       }
                                   }];
}



@end
