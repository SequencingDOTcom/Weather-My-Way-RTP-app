//
//  SQEncryptionHelper.h
//  Copyright © 2017 Sequencing.com. All rights reserved
//


#import <Foundation/Foundation.h>


@interface SQEncryptionHelper : NSObject

+ (NSString *)encryptAES256ForParameters:(NSDictionary *)parameters key:(NSString *)key iv:(NSString *)iv;

+ (NSString *)md5forString:(NSString *)string;

+ (NSString *)urlEncodeForString:(NSString *)string;

@end
