//
//  SQTokenRefreshProtocol.h
//  Copyright © 2015-2016 Sequencing.com. All rights reserved
//

#import <Foundation/Foundation.h>
#import "SQToken.h"

@protocol SQTokenRefreshProtocol <NSObject>

@required

- (void)tokenIsRefreshed:(SQToken *)updatedToken;

@end
