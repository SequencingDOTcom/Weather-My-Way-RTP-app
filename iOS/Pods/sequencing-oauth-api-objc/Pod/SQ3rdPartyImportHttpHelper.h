//
//  SQ3rdPartyImportHttpHelper.h
//  Copyright © 2017 Sequencing.com. All rights reserved
//


#import <Foundation/Foundation.h>

typedef void (^HttpCallback)(NSString *responseText, NSURLResponse *response, NSError *error);



@interface SQ3rdPartyImportHttpHelper : NSObject

+ (void)execHttpRequestWithUrl:(NSString *)url
                        method:(NSString *)method
                         token:(NSString *)token
                     authScope:(NSString *)authScope
                jsonParameters:(NSDictionary *)parameters
                       handler:(HttpCallback)callback;



@end
