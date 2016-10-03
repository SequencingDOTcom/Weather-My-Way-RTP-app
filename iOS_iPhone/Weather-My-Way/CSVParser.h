//
//  CSVParser.h
//  Copyright © 2016 Sequencing. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface CSVParser : NSObject

- (NSMutableArray *)loadAndParseCSVFileBasedOnStringData:(NSString*)stringData hasHeaderFields:(BOOL)hasHeaderFields;
    
@end
