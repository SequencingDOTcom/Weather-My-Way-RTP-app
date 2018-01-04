//
//  DBManager.h
//  Copyright © 2017 Sequencing. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface DBManager : NSObject

@property (strong, nonatomic) NSMutableArray *arrResults;
@property (strong, nonatomic) NSMutableArray *arrColumnNames;

@property (nonatomic) int       affectedRows;
@property (nonatomic) long long lastInsertedRowID;


- (instancetype)initWithDatabaseFilename:(NSString *)dbFilename;

- (NSArray *)loadDataFromDB:(NSString *)query;
- (void)executeQuery:(NSString *)query;

@end
