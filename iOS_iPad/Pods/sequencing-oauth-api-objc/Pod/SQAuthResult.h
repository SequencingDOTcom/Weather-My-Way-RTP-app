//
//  SQAuthResult.h
//  Copyright © 2015-2016 Sequencing.com. All rights reserved
//

#import <Foundation/Foundation.h>

@class SQToken;

@interface SQAuthResult : NSObject

+ (instancetype)sharedInstance;    // designated initializer

@property (readwrite, strong, nonatomic) SQToken *token;

@end
