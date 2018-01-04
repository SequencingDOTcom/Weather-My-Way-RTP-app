//
//  SQFilesAPI.h
//  Copyright © 2017 Sequencing.com. All rights reserved
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SQFileSelectorProtocol.h"
#import "SQTokenAccessProtocol.h"
@class SQToken;


@interface SQFilesAPI : NSObject

@property (weak, nonatomic) UIViewController<SQFileSelectorProtocol> *delegate;

+ (instancetype)sharedInstance; // designated initializer

- (void)showFilesWithTokenProvider:(id<SQTokenAccessProtocol>)tokenProvider
                   showCloseButton:(BOOL)showCloseButton
          previouslySelectedFileID:(NSString *)selectedFileID
                          delegate:(UIViewController<SQFileSelectorProtocol> *)delegate;


- (void)showFilesWithTokenProvider:(id<SQTokenAccessProtocol>)tokenProvider
                   showCloseButton:(BOOL)showCloseButton
          previouslySelectedFileID:(NSString *)selectedFileID
           backgroundVideoFileName:(NSString *)videoFileName
                          delegate:(UIViewController<SQFileSelectorProtocol> *)delegate;


@end
