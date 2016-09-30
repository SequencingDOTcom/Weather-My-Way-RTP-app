//
//  SQFileSelectorProtocol.h
//  Copyright © 2015-2016 Sequencing.com. All rights reserved
//

#import <Foundation/Foundation.h>

@protocol SQFileSelectorProtocol <NSObject>

@required
- (void)handleFileSelected:(NSDictionary *)file;

@optional
- (void)closeButtonPressed;

@end
