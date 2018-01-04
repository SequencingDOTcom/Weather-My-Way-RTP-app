//
//  CubePreloader.m
//  Copyright © 2017 Sequencing.com. All rights reserved
//

#import "CubePreloader.h"


@implementation CubePreloader

+ (NSArray *)cubePreloaderImagesNames {
    NSArray *imageNames = @[@"PR_3_00000", @"PR_3_00001", @"PR_3_00002", @"PR_3_00003", @"PR_3_00004",
                            @"PR_3_00005", @"PR_3_00006", @"PR_3_00007", @"PR_3_00008", @"PR_3_00009",
                            @"PR_3_00010", @"PR_3_00011", @"PR_3_00012", @"PR_3_00013", @"PR_3_00014",
                            @"PR_3_00015", @"PR_3_00016", @"PR_3_00017", @"PR_3_00018", @"PR_3_00019",
                            @"PR_3_00020", @"PR_3_00021", @"PR_3_00022", @"PR_3_00023", @"PR_3_00024",
                            @"PR_3_00025", @"PR_3_00026", @"PR_3_00027", @"PR_3_00028", @"PR_3_00029",
                            @"PR_3_00030", @"PR_3_00031", @"PR_3_00032", @"PR_3_00033", @"PR_3_00034",
                            @"PR_3_00035", @"PR_3_00036", @"PR_3_00037", @"PR_3_00038", @"PR_3_00039",
                            @"PR_3_00040", @"PR_3_00041", @"PR_3_00042", @"PR_3_00043", @"PR_3_00044",
                            @"PR_3_00045", @"PR_3_00046", @"PR_3_00047", @"PR_3_00048", @"PR_3_00049",
                            @"PR_3_00050", @"PR_3_00051"];
    return imageNames;
}


+ (NSMutableArray *)arrayWithUIImages {
    NSArray *imageNames = [self cubePreloaderImagesNames];
    
    NSMutableArray *images = [[NSMutableArray alloc] init];
    for (int i = 0; i < imageNames.count; i++)
        [images addObject:[UIImage imageNamed:[imageNames objectAtIndex:i]]];
    
    return images;
}


@end
