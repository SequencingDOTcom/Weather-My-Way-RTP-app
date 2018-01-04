//
//  VideoHelper.m
//  Copyright © 2016 Sequencing. All rights reserved.
//


#import "VideoHelper.h"
#import "ForecastData.h"
#import "UserHelper.h"


// default video file name
static NSString *DEFAULT_VIDEO_NAME = @"shutterstock_v4584485.mp4";

// keys for hash mapping - weather type vs video file name
#define shutterstock_v120847    @"shutterstock_v120847.mp4"
#define shutterstock_v163903    @"shutterstock_v163903.mp4"
#define shutterstock_v225991    @"shutterstock_v225991.mp4"
#define shutterstock_v728440    @"shutterstock_v728440.mp4"
#define shutterstock_v800269    @"shutterstock_v800269.mp4"
#define shutterstock_v861337    @"shutterstock_v861337.mp4"
#define shutterstock_v885172    @"shutterstock_v885172.mp4"
#define shutterstock_v1126162   @"shutterstock_v1126162.mp4"
#define shutterstock_v1389124   @"shutterstock_v1389124.mp4"
#define shutterstock_v1538677   @"shutterstock_v1538677.mp4"
#define shutterstock_v1775912   @"shutterstock_v1775912.mp4"
#define shutterstock_v1936054   @"shutterstock_v1936054.mp4"
#define shutterstock_v2051507   @"shutterstock_v2051507.mp4"
#define shutterstock_v2302283   @"shutterstock_v2302283.mp4"
#define shutterstock_v2580011   @"shutterstock_v2580011.mp4"
#define shutterstock_v2629166   @"shutterstock_v2629166.mp4"
#define shutterstock_v2718020   @"shutterstock_v2718020.mp4"
#define shutterstock_v2831005   @"shutterstock_v2831005.mp4"
#define shutterstock_v2864458   @"shutterstock_v2864458.mp4"
#define shutterstock_v3036661   @"shutterstock_v3036661.mp4"
#define shutterstock_v3112114   @"shutterstock_v3112114.mp4"
#define shutterstock_v3149698   @"shutterstock_v3149698.mp4"
#define shutterstock_v3168328   @"shutterstock_v3168328.mp4"
#define shutterstock_v3579536   @"shutterstock_v3579536.mp4"
#define shutterstock_v3652088   @"shutterstock_v3652088.mp4"
#define shutterstock_v3671960   @"shutterstock_v3671960.mp4"
#define shutterstock_v3753200   @"shutterstock_v3753200.mp4"
#define shutterstock_v4189258   @"shutterstock_v4189258.mp4"
#define shutterstock_v4314167   @"shutterstock_v4314167.mp4"
#define shutterstock_v4443185   @"shutterstock_v4443185.mp4"
#define shutterstock_v4491596   @"shutterstock_v4491596.mp4"
#define shutterstock_v4584485   @"shutterstock_v4584485.mp4"
#define shutterstock_v4627466   @"shutterstock_v4627466.mp4"
#define shutterstock_v5236070   @"shutterstock_v5236070.mp4"
#define shutterstock_v5468858   @"shutterstock_v5468858.mp4"
#define shutterstock_v5649644   @"shutterstock_v5649644.mp4"
#define shutterstock_v5793242   @"shutterstock_v5793242.mp4"
#define shutterstock_v6698111   @"shutterstock_v6698111.mp4"
#define shutterstock_v6820675   @"shutterstock_v6820675.mp4"
#define shutterstock_v7188568   @"shutterstock_v7188568.mp4"
#define shutterstock_v7419178   @"shutterstock_v7419178.mp4"
#define shutterstock_v8037967   @"shutterstock_v8037967.mp4"
#define shutterstock_v8257699   @"shutterstock_v8257699.mp4"
#define shutterstock_v10572149  @"shutterstock_v10572149.mp4"
#define shutterstock_v11588486  @"shutterstock_v11588486.mp4"
#define shutterstock_v11612783  @"shutterstock_v11612783.mp4"



@implementation VideoHelper

- (NSString *)getRandomVideoName {
    NSArray *randomVideoNames = @[@"shutterstock_v885172.mp4",
                                  @"shutterstock_v2864458.mp4",
                                  @"shutterstock_v3579536.mp4",
                                  @"shutterstock_v3671960.mp4",
                                  @"shutterstock_v4491596.mp4",
                                  @"shutterstock_v4584485.mp4",
                                  @"shutterstock_v8257699.mp4"];
    NSString *randomVideoName;
    
    int randomVideoIndex = [self getRandomValueLimitedByNumber:(int)[randomVideoNames count]];
    
    // validate random index
    if (randomVideoIndex > [randomVideoNames count]) {
        randomVideoIndex = (int)[randomVideoNames count] - 1;
    } else if (randomVideoIndex == [randomVideoNames count]) {
        randomVideoIndex--;
    } else if (randomVideoIndex < 0) {
        randomVideoIndex = 0;
    }
    
    // get random video name
    if (randomVideoIndex >= 0 && randomVideoIndex < [randomVideoNames count]) {
        // random index if valid
        randomVideoName = [randomVideoNames objectAtIndex:randomVideoIndex];
    } else {
        // random index if invalid
        randomVideoName = DEFAULT_VIDEO_NAME;
    }
    
    // return random video name
    if ([randomVideoName length] != 0) {
        return randomVideoName;
    } else {
        return DEFAULT_VIDEO_NAME;
    }
}



- (NSString *)getVideoNameBasedOnWeatherType:(NSString *)weatherType AndDayNight:(NSString *)dayNight {
    NSDictionary *dayWeatherTypeDict = @{@"heavy low drifting sand":    shutterstock_v2580011,
                                         @"sand":                       shutterstock_v2580011,
                                         @"lowdriftingsand":            shutterstock_v2580011,
                                         @"low drifting sand":          shutterstock_v2580011,
                                         @"blowingsand":                shutterstock_v2580011,
                                         @"blowing sand":               shutterstock_v2580011,
                                         @"light sand":                 shutterstock_v2580011,
                                         @"light low drifting sand":    shutterstock_v2580011,
                                         @"light blowing sand":         shutterstock_v2580011,
                                         @"heavy blowing sand":         shutterstock_v2580011,
                                         
                                         @"light drizzle":      shutterstock_v4627466,
                                         @"light rain showers": shutterstock_v4627466,
                                         
                                         @"partly cloudy":      shutterstock_v10572149,
                                         @"scattered clouds":   shutterstock_v10572149,
                                         
                                         @"heavy widespread dust":          shutterstock_v1126162,
                                         @"heavy blowing widespread dust":  shutterstock_v1126162,
                                         @"widespreaddust":                 shutterstock_v1126162,
                                         @"widespread dust":                shutterstock_v1126162,
                                         
                                         @"heavy haze":     shutterstock_v11588486,
                                         @"haze":           shutterstock_v11588486,
                                         @"rainmist":       shutterstock_v11588486,
                                         @"rain mist":      shutterstock_v11588486,
                                         @"light haze":     shutterstock_v11588486,
                                         @"hazy":           shutterstock_v11588486,
                                         
                                         @"heavy thunderstorms and snow":   shutterstock_v11612783,
                                         @"thunderstormsandsnow":           shutterstock_v11612783,
                                         @"thunderstorms and snow":         shutterstock_v11612783,
                                         @"light thunderstorms and snow":   shutterstock_v11612783,
                                         
                                         @"heavy freezing drizzle":     shutterstock_v120847,
                                         @"freezingrain":               shutterstock_v120847,
                                         @"freezing rain":              shutterstock_v120847,
                                         @"light freezing rain":        shutterstock_v120847,
                                         
                                         @"light mist":     shutterstock_v1389124,
                                         
                                         @"heavy thunderstorm":     shutterstock_v1538677,
                                         @"thunderstormsandrain":   shutterstock_v1538677,
                                         @"thunderstorms and rain": shutterstock_v1538677,
                                         
                                         @"squalls":    shutterstock_v163903,
                                         
                                         @"light thunderstorm":             shutterstock_v2051507,
                                         @"light thunderstorms and rain":   shutterstock_v2051507,
                                         @"heavy thunderstorms and rain":   shutterstock_v2051507,
                                         @"thunderstorm":                   shutterstock_v2051507,
                                         
                                         @"heavy drizzle":          shutterstock_v225991,
                                         @"heavy rain":             shutterstock_v225991,
                                         @"heavy rain mist":        shutterstock_v225991,
                                         @"rain":                   shutterstock_v225991,
                                         @"rainshowers":            shutterstock_v225991,
                                         @"rain showers":           shutterstock_v225991,
                                         @"unknown precipitation":  shutterstock_v225991,
                                         @"chance of showers":      shutterstock_v225991,
                                         @"showers":                shutterstock_v225991,
                                         
                                         @"heavy rain showers": shutterstock_v2302283,
                                         @"chance of rain":     shutterstock_v2302283,
                                         
                                         @"heavy ice crystals":                     shutterstock_v2629166,
                                         @"heavy ice pellets":                      shutterstock_v2629166,
                                         @"heavy hail":                             shutterstock_v2629166,
                                         @"heavy ice pellet showers":               shutterstock_v2629166,
                                         @"heavy hail showers":                     shutterstock_v2629166,
                                         @"heavy small hail showers":               shutterstock_v2629166,
                                         @"heavy thunderstorms and ice pellets":    shutterstock_v2629166,
                                         @"heavy thunderstorms with hail":          shutterstock_v2629166,
                                         @"heavy thunderstorms with small hail":    shutterstock_v2629166,
                                         @"hail":                                   shutterstock_v2629166,
                                         @"icepelletshowers":                       shutterstock_v2629166,
                                         @"ice pellet showers":                     shutterstock_v2629166,
                                         @"hailshowers":                            shutterstock_v2629166,
                                         @"hail showers":                           shutterstock_v2629166,
                                         @"smallhailshowers":                       shutterstock_v2629166,
                                         @"small hail showers":                     shutterstock_v2629166,
                                         @"thunderstormsandicepellets":             shutterstock_v2629166,
                                         @"thunderstorm sand ice pellets":          shutterstock_v2629166,
                                         @"thunderstormswithhail":                  shutterstock_v2629166,
                                         @"thunderstorms with hail":                shutterstock_v2629166,
                                         @"thunderstormswithsmallhail":             shutterstock_v2629166,
                                         @"thunderstorms with small hail":          shutterstock_v2629166,
                                         @"light hail showers":                     shutterstock_v2629166,
                                         @"light small hail showers":               shutterstock_v2629166,
                                         @"chance of ice pellets":                  shutterstock_v2629166,
                                         @"ice pellets":                            shutterstock_v2629166,
                                         @"icepellets":                             shutterstock_v2629166,
                                         
                                         @"heavy smoke":        shutterstock_v2718020,
                                         @"heavy freezing fog": shutterstock_v2718020,
                                         @"smoke":              shutterstock_v2718020,
                                         @"freezingfog":        shutterstock_v2718020,
                                         @"freezing fog":       shutterstock_v2718020,
                                         @"light smoke":        shutterstock_v2718020,
                                         
                                         @"very cold":                              shutterstock_v3036661,
                                         @"icecrystals":                            shutterstock_v3036661,
                                         @"ice crystals":                           shutterstock_v3036661,
                                         @"light ice crystals":                     shutterstock_v3036661,
                                         @"light ice pellet showers":               shutterstock_v3036661,
                                         @"light thunderstorms and ice pellets":    shutterstock_v3036661,
                                         @"light thunderstorms with hail":          shutterstock_v3036661,
                                         @"light thunderstorms with small hail":    shutterstock_v3036661,
                                         
                                         @"patches of fog": shutterstock_v3112114,
                                         @"shallow fog":    shutterstock_v3112114,
                                         @"partial fog":    shutterstock_v3112114,
                                         
                                         @"drizzle":            shutterstock_v3168328,
                                         @"light rain":         shutterstock_v3168328,
                                         @"light rain mist":    shutterstock_v3168328,
                                         
                                         @"heavy spray":    shutterstock_v3652088,
                                         @"spray":          shutterstock_v3652088,
                                         @"light spray":    shutterstock_v3652088,
                                         
                                         @"mostly cloudy":      shutterstock_v3671960,
                                         
                                         @"heavy freezing rain":    shutterstock_v3753200,
                                         @"snow showers":           shutterstock_v3753200,
                                         
                                         @"heavy dust whirls":                  shutterstock_v4189258,
                                         @"heavy low drifting widespread dust": shutterstock_v4189258,
                                         @"dustwhirls":                         shutterstock_v4189258,
                                         @"dust whirls":                        shutterstock_v4189258,
                                         @"lowdriftingwidespreaddust":          shutterstock_v4189258,
                                         @"low drifting widespread dust":       shutterstock_v4189258,
                                         @"blowingwidespreaddust":              shutterstock_v4189258,
                                         @"blowing widespread dust":            shutterstock_v4189258,
                                         @"light widespread dust":              shutterstock_v4189258,
                                         @"light dust whirls":                  shutterstock_v4189258,
                                         @"light low drifting widespread dust": shutterstock_v4189258,
                                         @"light blowing widespread dust":      shutterstock_v4189258,
                                         
                                         @"freezingdrizzle":                shutterstock_v4314167,
                                         @"freezing drizzle":               shutterstock_v4314167,
                                         @"light snow":                     shutterstock_v4314167,
                                         @"light snow grains":              shutterstock_v4314167,
                                         @"light blowing snow":             shutterstock_v4314167,
                                         @"light snow showers":             shutterstock_v4314167,
                                         @"light snow blowing snow mist":   shutterstock_v4314167,
                                         @"light freezing drizzle":         shutterstock_v4314167,
                                         @"light freezing fog":             shutterstock_v4314167,
                                         
                                         @"mist":                   shutterstock_v4443185,
                                         @"fog":                    shutterstock_v4443185,
                                         @"fogpatches":             shutterstock_v4443185,
                                         @"fog patches":            shutterstock_v4443185,
                                         @"light fog":              shutterstock_v4443185,
                                         @"light fog patches":      shutterstock_v4443185,
                                         
                                         @"very hot":   shutterstock_v4491596,
                                         
                                         @"heavy snow":                     shutterstock_v5236070,
                                         @"heavy snow grains":              shutterstock_v5236070,
                                         @"heavy snow showers":             shutterstock_v5236070,
                                         @"heavy snow blowing snow mist":   shutterstock_v5236070,
                                         @"snow":                           shutterstock_v5236070,
                                         @"snowgrains":                     shutterstock_v5236070,
                                         @"snow grains":                    shutterstock_v5236070,
                                         @"chance of snow showers":         shutterstock_v5236070,
                                         @"chance of snow":                 shutterstock_v5236070,
                                         
                                         @"heavy low drifting snow":    shutterstock_v5468858,
                                         @"heavy blowing snow":         shutterstock_v5468858,
                                         @"lowdriftingsnow":            shutterstock_v5468858,
                                         @"low drifting snow":          shutterstock_v5468858,
                                         @"blowingsnow":                shutterstock_v5468858,
                                         @"blowing snow":               shutterstock_v5468858,
                                         @"blizzard":                   shutterstock_v5468858,
                                         
                                         @"heavy mist":         shutterstock_v5793242,
                                         @"heavy fog":          shutterstock_v5793242,
                                         @"heavy fog patches":  shutterstock_v5793242,
                                         
                                         @"snowblowingsnowmist":        shutterstock_v6698111,
                                         @"snow blowing snow mist":     shutterstock_v6698111,
                                         @"light low drifting snow":    shutterstock_v6698111,
                                         @"flurries":                   shutterstock_v6698111,
                                         
                                         @"funnel cloud":   shutterstock_v7188568,
                                         
                                         @"light ice pellets":  shutterstock_v728440,
                                         @"light hail":         shutterstock_v728440,
                                         @"small hail":         shutterstock_v728440,
                                         
                                         @"heavy volcanic ash":     shutterstock_v8037967,
                                         @"volcanicash":            shutterstock_v8037967,
                                         @"volcanic ash":           shutterstock_v8037967,
                                         @"light volcanic ash":     shutterstock_v8037967,
                                         
                                         @"clear":  shutterstock_v8257699,
                                         
                                         @"heavy sand":         shutterstock_v861337,
                                         @"heavy sandstorm":    shutterstock_v861337,
                                         @"sandstorm":          shutterstock_v861337,
                                         @"light sandstorm":    shutterstock_v861337,
                                         
                                         @"overcast":   shutterstock_v885172,
                                         @"cloudy":     shutterstock_v885172,
                                         
                                         @"chance of a thunderstorm":   shutterstock_v800269,
                                         
                                         @"unknown":    shutterstock_v4584485,
                                         @"omitted":    shutterstock_v4584485
                                         };
    
    
    NSDictionary *nightWeatherTypeDict = @{@"heavy low drifting sand":    shutterstock_v2580011,
                                           @"sand":                       shutterstock_v2580011,
                                           @"lowdriftingsand":            shutterstock_v2580011,
                                           @"low drifting sand":          shutterstock_v2580011,
                                           @"blowingsand":                shutterstock_v2580011,
                                           @"blowing sand":               shutterstock_v2580011,
                                           @"light sand":                 shutterstock_v2580011,
                                           @"light low drifting sand":    shutterstock_v2580011,
                                           @"light blowing sand":         shutterstock_v2580011,
                                           @"heavy blowing sand":         shutterstock_v2580011,
                                           
                                           @"heavy widespread dust":          shutterstock_v1126162,
                                           @"heavy blowing widespread dust":  shutterstock_v1126162,
                                           @"widespreaddust":                 shutterstock_v1126162,
                                           @"widespread dust":                shutterstock_v1126162,
                                           
                                           @"heavy haze":     shutterstock_v11588486,
                                           @"haze":           shutterstock_v11588486,
                                           @"light haze":     shutterstock_v11588486,
                                           @"hazy":           shutterstock_v11588486,
                                           
                                           @"light mist":           shutterstock_v1389124,
                                           @"patches of fog":       shutterstock_v1389124,
                                           @"shallow fog":          shutterstock_v1389124,
                                           @"partial fog":          shutterstock_v1389124,
                                           @"light freezing fog":   shutterstock_v1389124,
                                           @"fog":                  shutterstock_v1389124,
                                           @"fogpatches":           shutterstock_v1389124,
                                           @"fog patches":          shutterstock_v1389124,
                                           @"light fog":            shutterstock_v1389124,
                                           @"light fog patches":    shutterstock_v1389124,
                                           @"heavy fog patches":    shutterstock_v1389124,
                                           
                                           @"thunderstormsandrain":         shutterstock_v163903,
                                           @"thunderstorms and rain":       shutterstock_v163903,
                                           @"squalls":                      shutterstock_v163903,
                                           @"light thunderstorms and rain": shutterstock_v163903,
                                           @"heavy thunderstorms and rain": shutterstock_v163903,
                                           
                                           @"overcast":     shutterstock_v1936054,
                                           
                                           @"chance of ice pellets":                  shutterstock_v2629166,
                                           @"ice pellets":                            shutterstock_v2629166,
                                           @"icepellets":                             shutterstock_v2629166,
                                           @"heavy ice pellet showers":               shutterstock_v2629166,
                                           @"heavy hail showers":                     shutterstock_v2629166,
                                           @"heavy small hail showers":               shutterstock_v2629166,
                                           @"heavy thunderstorms and ice pellets":    shutterstock_v2629166,
                                           @"heavy thunderstorms with hail":          shutterstock_v2629166,
                                           @"heavy thunderstorms with small hail":    shutterstock_v2629166,
                                           @"hail":                                   shutterstock_v2629166,
                                           @"icepelletshowers":                       shutterstock_v2629166,
                                           @"ice pellet showers":                     shutterstock_v2629166,
                                           @"thunderstormsandicepellets":             shutterstock_v2629166,
                                           @"thunderstorm sand ice pellets":          shutterstock_v2629166,
                                           @"thunderstormswithhail":                  shutterstock_v2629166,
                                           @"thunderstorms with hail":                shutterstock_v2629166,
                                           @"thunderstormswithsmallhail":             shutterstock_v2629166,
                                           @"thunderstorms with small hail":          shutterstock_v2629166,
                                           
                                           @"heavy smoke":  shutterstock_v2718020,
                                           @"smoke":        shutterstock_v2718020,
                                           @"light smoke":  shutterstock_v2718020,
                                           
                                           @"partly cloudy":    shutterstock_v2831005,
                                           
                                           @"very hot":     shutterstock_v2864458,
                                           
                                           @"heavy freezing drizzle":               shutterstock_v3036661,
                                           @"freezingrain":                         shutterstock_v3036661,
                                           @"freezing rain":                        shutterstock_v3036661,
                                           @"light freezing rain":                  shutterstock_v3036661,
                                           @"icecrystals":                          shutterstock_v3036661,
                                           @"ice crystals":                         shutterstock_v3036661,
                                           @"light ice crystals":                   shutterstock_v3036661,
                                           @"light ice pellet showers":             shutterstock_v3036661,
                                           @"light thunderstorms and ice pellets":  shutterstock_v3036661,
                                           @"light thunderstorms with hail":        shutterstock_v3036661,
                                           @"light thunderstorms with small hail":  shutterstock_v3036661,
                                           @"heavy freezing rain":                  shutterstock_v3036661,
                                           @"freezingdrizzle":                      shutterstock_v3036661,
                                           @"freezing drizzle":                     shutterstock_v3036661,
                                           @"light freezing drizzle":               shutterstock_v3036661,
                                           
                                           @"very cold":                shutterstock_v3149698,
                                           @"hail showers":             shutterstock_v3149698,
                                           @"hailshowers":              shutterstock_v3149698,
                                           @"small hail showers":       shutterstock_v3149698,
                                           @"light hail showers":       shutterstock_v3149698,
                                           @"light small hail showers": shutterstock_v3149698,
                                           @"heavy freezing fog":       shutterstock_v3149698,
                                           @"freezingfog":              shutterstock_v3149698,
                                           @"freezing fog":             shutterstock_v3149698,
                                           
                                           @"rainmist":         shutterstock_v3168328,
                                           @"rain mist":        shutterstock_v3168328,
                                           @"light rain mist":  shutterstock_v3168328,
                                           
                                           @"chance of showers":    shutterstock_v3579536,
                                           @"heavy rain":           shutterstock_v3579536,
                                           @"heavy rain mist":      shutterstock_v3579536,
                                           @"heavy rain showers":   shutterstock_v3579536,
                                           @"rainshowers":          shutterstock_v3579536,
                                           @"rain showers":         shutterstock_v3579536,
                                           
                                           @"heavy spray":    shutterstock_v3652088,
                                           @"spray":          shutterstock_v3652088,
                                           @"light spray":    shutterstock_v3652088,
                                           
                                           @"heavy dust whirls":                    shutterstock_v4189258,
                                           @"heavy low drifting widespread dust":   shutterstock_v4189258,
                                           @"dustwhirls":                           shutterstock_v4189258,
                                           @"dust whirls":                          shutterstock_v4189258,
                                           @"lowdriftingwidespreaddust":            shutterstock_v4189258,
                                           @"low drifting widespread dust":         shutterstock_v4189258,
                                           @"blowingwidespreaddust":                shutterstock_v4189258,
                                           @"blowing widespread dust":              shutterstock_v4189258,
                                           @"light widespread dust":                shutterstock_v4189258,
                                           @"light dust whirls":                    shutterstock_v4189258,
                                           @"light low drifting widespread dust":   shutterstock_v4189258,
                                           @"light blowing widespread dust":        shutterstock_v4189258,
                                           @"light low drifting snow":              shutterstock_v4189258,
                                           
                                           @"mist":     shutterstock_v4443185,
                                           @"foggy":    shutterstock_v4443185,
                                           
                                           @"blizzard":                     shutterstock_v5468858,
                                           @"light snow":                   shutterstock_v5468858,
                                           @"light snow grains":            shutterstock_v5468858,
                                           @"light snow showers":           shutterstock_v5468858,
                                           @"light snow blowing snow mist": shutterstock_v5468858,
                                           @"blowingsnow":                  shutterstock_v5468858,
                                           @"blowing snow":                 shutterstock_v5468858,
                                           
                                           @"showers":                  shutterstock_v5649644,
                                           @"chance of rain":           shutterstock_v5649644,
                                           @"rain":                     shutterstock_v5649644,
                                           @"light rain":               shutterstock_v5649644,
                                           @"light drizzle":            shutterstock_v5649644,
                                           @"light rain showers":       shutterstock_v5649644,
                                           @"unknown precipitation":    shutterstock_v5649644,
                                           @"drizzle":                  shutterstock_v5649644,
                                           @"heavy drizzle":            shutterstock_v5649644,
                                           
                                           @"heavy mist":   shutterstock_v5793242,
                                           @"heavy fog":    shutterstock_v5793242,
                                           
                                           @"light blowing snow":   shutterstock_v6698111,
                                           @"snow":                 shutterstock_v6698111,
                                           @"snowgrains":           shutterstock_v6698111,
                                           @"snow grains":          shutterstock_v6698111,
                                           
                                           @"scattered clouds": shutterstock_v6820675,
                                           @"mostly cloudy":    shutterstock_v6820675,
                                           @"cloudy":           shutterstock_v6820675,
                                           
                                           @"funnel cloud":   shutterstock_v7188568,
                                           
                                           @"heavy ice crystals":   shutterstock_v728440,
                                           @"heavy ice pellets":    shutterstock_v728440,
                                           @"heavy hail":           shutterstock_v728440,
                                           @"light ice pellets":    shutterstock_v728440,
                                           @"light hail":           shutterstock_v728440,
                                           @"small hail":           shutterstock_v728440,
                                           
                                           @"blowingsnow":                  shutterstock_v7419178,
                                           @"blowing snow":                 shutterstock_v7419178,
                                           @"heavy thunderstorms and snow": shutterstock_v7419178,
                                           @"thunderstormsandsnow":         shutterstock_v7419178,
                                           @"thunderstorms and snow":       shutterstock_v7419178,
                                           @"light thunderstorms and snow": shutterstock_v7419178,
                                           @"heavy snow":                   shutterstock_v7419178,
                                           @"heavy snow grains":            shutterstock_v7419178,
                                           @"heavy snow showers":           shutterstock_v7419178,
                                           @"heavy snow blowing snow mist": shutterstock_v7419178,
                                           @"heavy low drifting snow":      shutterstock_v7419178,
                                           @"heavy blowing snow":           shutterstock_v7419178,
                                           @"lowdriftingsnow":              shutterstock_v7419178,
                                           @"snowshowers":                  shutterstock_v7419178,
                                           @"snow showers":                 shutterstock_v7419178,
                                           @"snowblowingsnowmist":          shutterstock_v7419178,
                                           @"snow blowing snow mist":       shutterstock_v7419178,
                                           @"chance of snow showers":       shutterstock_v7419178,
                                           @"chance of snow":               shutterstock_v7419178,
                                           @"snow":                         shutterstock_v7419178,
                                           @"flurries":                     shutterstock_v7419178,
                                           
                                           @"chance of a thunderstorm": shutterstock_v800269,
                                           @"heavy thunderstorm":       shutterstock_v800269,
                                           @"thunderstorm":             shutterstock_v800269,
                                           @"light thunderstorm":       shutterstock_v800269,
                                           
                                           @"heavy volcanic ash":     shutterstock_v8037967,
                                           @"volcanicash":            shutterstock_v8037967,
                                           @"volcanic ash":           shutterstock_v8037967,
                                           @"light volcanic ash":     shutterstock_v8037967,
                                           
                                           @"heavy sand":         shutterstock_v861337,
                                           @"heavy sandstorm":    shutterstock_v861337,
                                           @"sandstorm":          shutterstock_v861337,
                                           @"light sandstorm":    shutterstock_v861337,
                                           
                                           @"thunderstorm": shutterstock_v2051507,
                                           
                                           @"clear":    shutterstock_v1775912,
                                           @"unknown":  shutterstock_v1775912,
                                           @"omitted":  shutterstock_v1775912
                                           };
    
    NSString *videoName;
    
    if ([dayNight isEqualToString:@"day"]) { // day time
        if ([[dayWeatherTypeDict allKeys] containsObject:weatherType]) {
            // video is present for such weatherType
            videoName = [dayWeatherTypeDict objectForKey:weatherType];
            
        } else {
            // no video for such weatherType
            NSLog(@"VideoHelper: we don't have video for \"%@\" weather type for day time", weatherType);
            videoName = [self getRandomVideoName];
        }
        
    } else if ([dayNight isEqualToString:@"night"]) { // night time
        if ([[nightWeatherTypeDict allKeys] containsObject:weatherType]) {
            // video is present for such weatherType
            videoName = [nightWeatherTypeDict objectForKey:weatherType];
            
        } else {
            // no video for such weatherType
            NSLog(@"VideoHelper: we don't have video for \"%@\" weather type for night time", weatherType);
            videoName = [self getRandomVideoName];
        }
        
    } else {
        // get random video - as we don't have a proper daytime
        NSLog(@"VideoHelper: error in dayNight: %@", dayNight);
        videoName = [self getRandomVideoName];
    }
    
    return videoName;
}



- (int)getRandomValueLimitedByNumber:(int)limit {
    int randomNumber = arc4random() %limit;
    return randomNumber;
}


- (int)randomNumberBetween:(int)min maxNumber:(int)max {
    return min + arc4random_uniform(max - min + 1);
}




#pragma mark -
#pragma mark White video issue helper

+ (BOOL)isVideoWhite {
    BOOL videoFileIsWhite = NO;
    UserHelper *userHelper = [[UserHelper alloc] init];
    NSString *currentVideoFileUsed = [userHelper loadKnownVideoFileName];
    
    NSArray *arrayOfVideoFilesWithWhiteBarInTheTop = @[@"shutterstock_v120847.mp4",
                                                       @"shutterstock_v1126162.mp4",
                                                       @"shutterstock_v3036661.mp4",
                                                       @"shutterstock_v4314167.mp4",
                                                       @"shutterstock_v3753200.mp4",
                                                       @"shutterstock_v4627466.mp4",
                                                       @"shutterstock_v5468858.mp4",
                                                       @"shutterstock_v2302283.mp4",
                                                       @"shutterstock_v5793242.mp4",
                                                       @"shutterstock_v8037967.mp4"];
    
    if ([arrayOfVideoFilesWithWhiteBarInTheTop containsObject:currentVideoFileUsed]) {
        videoFileIsWhite = YES;
    }
    return videoFileIsWhite;
}


+ (UIImage *)greyTranspanentImage {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIColor *greyTranspanentColor = [UIColor colorWithRed:85.0/255.0 green:85.0/255.0 blue:85.0/255.0 alpha:0.6];
    CGContextSetFillColorWithColor(context, [greyTranspanentColor CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}



@end
