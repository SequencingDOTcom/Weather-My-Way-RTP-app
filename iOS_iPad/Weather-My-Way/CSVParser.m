//
//  CSVParser.m
//  Copyright © 2016 Sequencing. All rights reserved.
//


#import "CSVParser.h"

@implementation CSVParser


- (NSMutableArray *)loadAndParseCSVFileBasedOnStringData:(NSString*)stringData hasHeaderFields:(BOOL)hasHeaderFields{
    NSArray *gcRawData = [stringData componentsSeparatedByString:@"\n"];
    
    NSArray *singleGC = [NSArray array];
    NSMutableArray *allGC = [NSMutableArray array];
    for (int i = 0; i < gcRawData.count; i++)
    {
        NSString *nextGCString = [NSString stringWithFormat:@"%@", gcRawData[i]];
        singleGC = [nextGCString componentsSeparatedByString:@","];
        NSMutableArray *arrayOfComponents = [NSMutableArray array];
        for (int j=0; j<singleGC.count; j++) {
            NSString *str = [singleGC objectAtIndex:j];
            if([str hasPrefix:@"\""]) {
                for (int k=j+1; k<singleGC.count; k++) {
                    str = [str stringByAppendingFormat:@",%@",[singleGC objectAtIndex:k]];
                    j++;
                    if([str hasSuffix:@"\""] || [str hasSuffix:@"\"\r"]) {
                        break;
                    }
                }
            } else if([str hasPrefix:@"\'"]) {
                for (int k=j+1; k<singleGC.count; k++) {
                    str = [str stringByAppendingFormat:@",%@",[singleGC objectAtIndex:k]];
                    j++;
                    if([str hasSuffix:@"\'"] || [str hasSuffix:@"\'\r"]) {
                        break;
                    }
                }
            }
            [arrayOfComponents addObject:str];
        }
        [allGC addObject:arrayOfComponents];
    }
    if(hasHeaderFields) {
        NSArray *arrayOfHeader = [allGC objectAtIndex:0];
        NSMutableArray *newDataArray = [NSMutableArray array];
        for (NSArray *ar in allGC) {
            if([ar isEqual:arrayOfHeader]) continue;
            if(ar.count!=arrayOfHeader.count) continue;
            NSMutableDictionary *dOfRow = [NSMutableDictionary dictionary];
            for (NSString *strHeaderName in arrayOfHeader) {
                [dOfRow setObject:[ar objectAtIndex:[arrayOfHeader indexOfObject:strHeaderName]] forKey:strHeaderName];
            }
            [newDataArray addObject:dOfRow];
        }
        return newDataArray;
    }
    return allGC;
}


@end
