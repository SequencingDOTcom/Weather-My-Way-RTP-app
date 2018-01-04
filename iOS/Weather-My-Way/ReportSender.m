//
//  ReportSender.m
//  Copyright © 2017 Sequencing. All rights reserved.
//


#import "ReportSender.h"
#import "UserAccountHelper.h"

#define reportEndpointURL @"https://logbase.sequencing.com/logging/event/wmw"


@implementation ReportSender

+ (void)sendLogReport:(NSDictionary *)report {
    [[[UserAccountHelper alloc] init] execHttpRequestWithUrl:reportEndpointURL
                                                      method:@"POST"
                                              JSONparameters:report
                                              withCompletion:^(NSString *responseText, NSURLResponse *response, NSError *error) {
                                                  
                                                  NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                                  NSInteger statusCode = [httpResponse statusCode];
                                                  
                                                  if (!error && statusCode == 200)
                                                      //*
                                                      //* post notification for successfully log report sent
                                                      [[NSNotificationCenter defaultCenter] postNotificationName:LOG_REPORT_WAS_SENT_SUCCESSFULLY_NOTIFICATION_KEY
                                                                                                          object:nil
                                                                                                        userInfo:nil];
                                              }];
}

@end
