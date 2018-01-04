//
//  SQToken.h
//  Copyright © 2015-2016 Sequencing.com. All rights reserved
//

#import "SQToken.h"

@implementation SQToken

#pragma mark -
#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.accessToken = [decoder decodeObjectForKey:@"accessToken"];
        self.expirationDate = [decoder decodeObjectForKey:@"expirationDate"];
        self.tokenType = [decoder decodeObjectForKey:@"tokenType"];
        self.scope = [decoder decodeObjectForKey:@"scope"];
        self.refreshToken = [decoder decodeObjectForKey:@"refreshToken"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.accessToken forKey:@"accessToken"];
    [encoder encodeObject:self.expirationDate forKey:@"expirationDate"];
    [encoder encodeObject:self.tokenType forKey:@"tokenType"];
    [encoder encodeObject:self.scope forKey:@"scope"];
    [encoder encodeObject:self.refreshToken forKey:@"refreshToken"];
}

@end
