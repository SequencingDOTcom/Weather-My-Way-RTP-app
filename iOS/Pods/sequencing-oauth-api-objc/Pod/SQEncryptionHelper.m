//
//  SQEncryptionHelper.m
//  Copyright © 2017 Sequencing.com. All rights reserved
//


#import "SQEncryptionHelper.h"
// #import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>
#import "FBEncryptorAES.h"
#import "NSData+Base64.h"


@implementation SQEncryptionHelper

+ (NSString *)encryptAES256ForParameters:(NSDictionary *)parameters key:(NSString *)key iv:(NSString *)iv {
    
    NSError  *jsonError;
    NSData   *jsonData = [NSJSONSerialization dataWithJSONObject:parameters options:kNilOptions error:&jsonError];
    // NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    // NSString *jsonStringCorrected = [jsonString stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
    
    NSData   *keyData  = [key dataUsingEncoding:NSUTF8StringEncoding];
    NSData   *ivData   = [iv  dataUsingEncoding:NSASCIIStringEncoding];
    
    NSData   *encryptedBytes = [FBEncryptorAES encryptData:jsonData key:keyData iv:ivData];
    NSString *encrypted = [encryptedBytes base64EncodedStringWithSeparateLines:NO];
    
    return encrypted;
}



+ (NSString *)md5forString:(NSString *)string {
    const char *cStr = [string UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (int)strlen(cStr), result ); // This is the md5 call
    
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
    
    /*
    const char *pointer = [string UTF8String];
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(pointer, (CC_LONG)strlen(pointer), md5Buffer);
    
    NSMutableString *encodedString = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [encodedString appendFormat:@"%02x",md5Buffer[i]];
    
    return encodedString;*/
}



+ (NSString *)urlEncodeForString:(NSString *)string {
    /*
     !   *   '   (   )   ;   :   @   &   =   +   $   ,   /   ?   #   [   ]
     %21 %2A %27 %28 %29 %3B %3A %40 %26 %3D %2B %24 %2C %2F %3F %23 %5B %5D    */
    
    NSMutableString *temp = [string mutableCopy];
    NSString *urlStringEncoded = @"";
    
    if ([string length] != 0) {
        NSArray *escapeChars =  [NSArray arrayWithObjects:
                                 @";",   @"/",   @"?",   @":",   @"@",   @"&",   @"=",   @"+",   @"$",   @",",   @"[",   @"]",   @"#",   @"!",   @"'",   @"(",   @")",   @"*",   @" ", nil];
        NSArray *replaceChars = [NSArray arrayWithObjects:
                                 @"%3B", @"%2F", @"%3F", @"%3A", @"%40", @"%26", @"%3D", @"%2B", @"%24", @"%2C", @"%5B", @"%5D", @"%23", @"%21", @"%27", @"%28", @"%29", @"%2A", @"",  nil];
        
        for(int i = 0; i < [escapeChars count]; i++) {
            [temp replaceOccurrencesOfString:[escapeChars objectAtIndex:i]
                                  withString:[replaceChars objectAtIndex:i]
                                     options:NSLiteralSearch
                                       range:NSMakeRange(0, [temp length])];
        }
        urlStringEncoded = [NSString stringWithString:temp];
    }
    return urlStringEncoded;
}

@end
