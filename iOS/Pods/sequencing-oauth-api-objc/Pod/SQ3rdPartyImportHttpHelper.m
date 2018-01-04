//
//  SQ3rdPartyImportHttpHelper.m
//  Copyright © 2017 Sequencing.com. All rights reserved
//


#import "SQ3rdPartyImportHttpHelper.h"


@implementation SQ3rdPartyImportHttpHelper

+ (void)execHttpRequestWithUrl:(NSString *)url
                        method:(NSString *)method
                         token:(NSString *)token
                     authScope:(NSString *)authScope
                jsonParameters:(NSDictionary *)parameters
                       handler:(HttpCallback)callback {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:method];
    [request setTimeoutInterval:120];
    [request setHTTPShouldHandleCookies:NO];
    [request setValue:@"en-us" forHTTPHeaderField:@"Accept-Language"];
    [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
    
    if ([authScope isEqualToString:@"Bearer"])
        [request setValue:[NSString stringWithFormat:@"%@ %@", authScope, token] forHTTPHeaderField:@"Authorization"];
    
    if (parameters) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:&error];
        if (jsonData) [request setHTTPBody:jsonData];
    }
    
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        callback([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding], response, error);
    }];
    [dataTask resume];
}







@end
