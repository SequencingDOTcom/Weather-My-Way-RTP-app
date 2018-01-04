//
//  SQToken.h
//  Copyright © 2015-2016 Sequencing.com. All rights reserved
//

#import <Foundation/Foundation.h>

@interface SQToken : NSObject <NSCoding>

@property (readwrite, strong, nonatomic) NSString  *accessToken;
@property (readwrite, strong, nonatomic) NSDate    *expirationDate;
@property (readwrite, strong, nonatomic) NSString  *tokenType;
@property (readwrite, strong, nonatomic) NSString  *scope;
@property (readwrite, strong, nonatomic) NSString  *refreshToken;

@end
