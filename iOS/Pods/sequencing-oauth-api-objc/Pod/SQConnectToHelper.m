//
//  SQConnectToHelper.m
//  Copyright © 2017 Sequencing.com. All rights reserved
//


#import "SQConnectToHelper.h"


@implementation SQConnectToHelper

+ (NSString *)checkIfFilesAreValid:(NSArray *)filesArray {
    
    for (id object in filesArray) {
        
        if (![object isKindOfClass:[NSDictionary class]])
            return @"Files are passed in incorrect format. Please provide files as NSDictionary objects in NSArray";
        
        NSDictionary *fileDict = object;
        
        if (![self areAllKeysPresent:fileDict])
            return @"Files are passed in incorrect format. Please provide files as NSDictionary objects with all parameters as string (name, url, type, hashType, hashValue, size)";
        
        if (![self isFileNamePresent:fileDict])
            return @"Files are passed in incorrect format. File name parameter is missing";
        
        if (![self isFileUrlPresent:fileDict])
            return @"Files are passed in incorrect format. File url parameter is missing";
    }
    
    return nil;
}


+ (BOOL)areAllKeysPresent:(NSDictionary *)fileDict {
    NSArray *allKeys = [fileDict allKeys];
    if ([allKeys containsObject:@"name"] &&
        [allKeys containsObject:@"type"] &&
        [allKeys containsObject:@"url"] &&
        [allKeys containsObject:@"hashType"] &&
        [allKeys containsObject:@"hashValue"] &&
        [allKeys containsObject:@"size"]) {
        return YES;
    } else return NO;
}


+ (BOOL)isFileNamePresent:(NSDictionary *)fileDict {
    id temp = [fileDict objectForKey:@"name"];
    NSString *name = [NSString stringWithFormat:@"%@", temp];
    return ([name length] > 0);
}


+ (BOOL)isFileUrlPresent:(NSDictionary *)fileDict {
    id temp = [fileDict objectForKey:@"url"];
    NSString *url = [NSString stringWithFormat:@"%@", temp];
    return ([url length] > 0);
}




@end
