//
//  VideoHelper.h
//  Copyright © 2016 Sequencing. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface VideoHelper : NSObject

- (NSString *)getRandomVideoName;
- (NSString *)getVideoNameBasedOnWeatherType:(NSString *)weatherType AndDayNight:(NSString *)dayNight;

+ (BOOL)isVideoWhite;
+ (UIImage *)greyTranspanentImage;

@end
