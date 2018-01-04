//
//  SQ3rdPartyImportAPI.h
//  Copyright © 2017 Sequencing.com. All rights reserved
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SQTokenAccessProtocol.h"


@interface SQ3rdPartyImportAPI : NSObject

- (void)importFrom23AndMeWithToken: (id<SQTokenAccessProtocol>)tokenProvider viewControllerDelegate:(UIViewController *)controller;

- (void)importFromAncestryWithToken:(id<SQTokenAccessProtocol>)tokenProvider viewControllerDelegate:(UIViewController *)controller;

@end
