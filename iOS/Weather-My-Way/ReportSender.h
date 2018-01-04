//
//  ReportSender.h
//  Copyright © 2017 Sequencing. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "ConstantsList.h"


@interface ReportSender : NSObject

+ (void)sendLogReport:(NSDictionary *)report;

@end
