//
//  SQFileSelectorProtocol.h
//  Copyright © 2017 Sequencing.com. All rights reserved
//

#import <Foundation/Foundation.h>


@protocol SQFileSelectorProtocol <NSObject>

@required
- (void)selectedGeneticFile:(NSDictionary *)file;
- (void)errorWhileReceivingGeneticFiles:(NSError *)error;

@optional
- (void)closeButtonPressed;

@end
