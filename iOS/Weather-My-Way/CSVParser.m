//
//  CSVParser.m
//  Copyright © 2017 Sequencing. All rights reserved.
//


#import "CSVParser.h"

@implementation CSVParser


+ (NSMutableArray *)loadAndParseCSVFileBasedOnStringData:(NSString*)stringData
                                         hasHeaderFields:(BOOL)hasHeaderFields {
    
    NSArray *gcRawData = [stringData componentsSeparatedByString:@"\n"];
    
    NSArray *singleGC = [NSArray array];
    NSMutableArray *allGC = [NSMutableArray array];
    
    for (int i = 0; i < gcRawData.count; i++) {
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
    
    if (hasHeaderFields) {
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



+ (NSMutableArray *)removeQuotationMarksFromParsedCSVFile:(NSMutableArray *)parsedCSV {
    NSMutableArray *correctedArray;
    
    if (parsedCSV) {
        
        for (NSMutableArray *rowArray in parsedCSV) {
            
            for (int columnIndex = 0; columnIndex < [rowArray count]; columnIndex++) {
                
                id rawValue = [rowArray objectAtIndex:columnIndex];
                NSString *forecastValue = [NSString stringWithFormat:@"%@", rawValue];
                
                if ([forecastValue length] != 0) {
                    
                    NSString *correctedValue;
                    NSString *firstCharacter = [forecastValue substringToIndex:1];
                    NSString *lastCharacter = [forecastValue substringFromIndex:[forecastValue length] - 1];
                    
                    if ([firstCharacter isEqualToString:@"\""] && [lastCharacter isEqualToString:@"\""]) {
                        correctedValue = [forecastValue substringFromIndex:1];
                        correctedValue = [correctedValue substringToIndex:[correctedValue length] - 1];
                        forecastValue = correctedValue;
                    }
                }
                [rowArray replaceObjectAtIndex:columnIndex withObject:forecastValue];
            }
        }
        correctedArray = [NSMutableArray arrayWithArray:[parsedCSV copy]];
    }
    return parsedCSV;
}


@end
