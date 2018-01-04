//
//  SQRequestHelper.h
//  Copyright © 2015-2016 Sequencing.com. All rights reserved
//

#import <Foundation/Foundation.h>

@interface SQRequestHelper : NSObject

+ (instancetype)sharedInstance;
    
- (void)rememberRedirectUri:(NSString *)redirect_uri;

- (BOOL)verifyRequestForRedirectBack:(NSURLRequest *)request;

- (NSMutableDictionary *)parseRequest:(NSURLRequest *)request;

@end
