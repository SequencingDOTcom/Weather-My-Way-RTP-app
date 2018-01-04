//
//  SQRequestHelper.h
//  Copyright © 2015-2016 Sequencing.com. All rights reserved
//

#import "SQRequestHelper.h"

@interface SQRequestHelper ()

@property (strong, nonatomic) NSString *redirect_uri;

@end

@implementation SQRequestHelper

+ (instancetype)sharedInstance {
    static SQRequestHelper *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SQRequestHelper alloc] init];
    });
    return instance;
}

- (void)rememberRedirectUri:(NSString *)redirect_uri {
    self.redirect_uri = redirect_uri;
}

- (BOOL)verifyRequestForRedirectBack:(NSURLRequest *)request {
    if ([[NSString stringWithFormat:@"%@", [request URL]] containsString:[NSString stringWithFormat:@"%@?", self.redirect_uri]]) {
        return YES;
    }
    return NO;
}

- (NSMutableDictionary *)parseRequest:(NSURLRequest *)request {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSString *query = [[request URL] description];
    
    if ([query containsString:@"access_denied"]) {
        [dict setObject:[NSNumber numberWithBool:YES] forKey:@"didCancelAuthorization"];
        
    } else if ([query containsString:@"invalid_request"]) {
        [dict setObject:[NSNumber numberWithBool:YES] forKey:@"error"];
        
    } else {
        NSArray *array = [query componentsSeparatedByString:@"?"];
        if ([array count] > 1) {
            query = [array lastObject];
        }
        NSArray *params = [query componentsSeparatedByString:@"&"];
        for (NSString *param in params) {
            NSArray *elements = [param componentsSeparatedByString:@"="];
            if ([elements count] == 2) {
                NSString *key = [[elements firstObject] stringByRemovingPercentEncoding];
                NSString *val = [[elements lastObject] stringByRemovingPercentEncoding];
                [dict setObject:val forKey:key];
            }
        }
    }
    
    return dict;
}


@end
