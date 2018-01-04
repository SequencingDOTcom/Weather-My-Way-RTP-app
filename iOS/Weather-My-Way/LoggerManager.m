//
//  LoggerManager.m
//  Copyright © 2017 Sequencing. All rights reserved.
//


#import "LoggerManager.h"
#import "DBManager.h"
#import "ConstantsList.h"
#import "ObserverManager.h"



@implementation LoggerManager

+ (DBManager *)dbManager {
    return [[DBManager alloc] initWithDatabaseFilename:database];
}



#pragma mark -
#pragma mark - Interactions save/update

+ (long long)saveInteraction:(NSDictionary *)interaction {
    DBManager *dbManager = [self dbManager];
    if (!dbManager) return -1;
    if (!interaction || [[interaction allKeys] count] == 0) return -1;
    if (![interaction objectForKey:dict_interactionIDKey] || [[interaction objectForKey:dict_interactionTimeKey] isEqual:[NSNull null]]) return -1;
    
    NSString *query = [NSString stringWithFormat:@"%@ %@ VALUES (null, %@, %@, '%@', %@, %@, %@)",
                       insertQuery, interactionsTable,
                       [self pullLatitudeFromInteraction:       interaction],
                       [self pullLongitudeFromInteraction:      interaction],
                       [self pullPlaceFromInteraction:          interaction],
                       [self pullTimestampFromInteraction:      interaction],
                       [self pullDurationFromInteraction:       interaction],
                       [self pullConnectionTypeFromInteraction: interaction]];
    
    NSLog(@"=== INSERT QUERY:\n%@\n", query);
    [dbManager executeQuery:query];
    
    if (dbManager.affectedRows > 0)
        NSLog(@"=== Query was executed successfully. Affected rows = %d", dbManager.affectedRows);
    else
        NSLog(@"=== Could not execute the query.");
    
    return dbManager.lastInsertedRowID;
}



+ (void)updateInteraction:(NSDictionary *)interaction {
    DBManager *dbManager = [self dbManager];
    if (!dbManager) return;
    if (!interaction || [[interaction allKeys] count] == 0) return;
    if (![interaction objectForKey:dict_interactionIDKey] || [[interaction objectForKey:dict_interactionIDKey] isEqual:[NSNull null]]) return;
    
    NSMutableString *query = [[NSMutableString alloc] init];
    [query appendString:updateQuery];
    [query appendString:[NSString stringWithFormat:@" %@ SET ", interactionsTable]];
    
    void (^addPrameterWithValueIntoUpdateQuery)(NSString *, NSDictionary *) = ^(NSString *column, NSDictionary *interaction) {
        NSString *columnValue = [self pullUpdateQueryForColumn:column fromInteraction:interaction];
        if (columnValue)
            [query appendString:[NSString stringWithFormat:@"%@ = '%@', ", column, columnValue]];
    };
    addPrameterWithValueIntoUpdateQuery(column_interaction_latitude,    interaction);
    addPrameterWithValueIntoUpdateQuery(column_interaction_longitude,   interaction);
    addPrameterWithValueIntoUpdateQuery(column_interaction_place,       interaction);
    addPrameterWithValueIntoUpdateQuery(column_interaction_duration,    interaction);
    addPrameterWithValueIntoUpdateQuery(column_interaction_media,       interaction);
    
    [self removeExtraCommaAndSpaceFromQuery:query];
    
    [query appendString:[NSString stringWithFormat:@"WHERE id = %d", [[interaction objectForKey:dict_interactionIDKey] unsignedIntValue]]];
    
    NSLog(@"=== UPDATE QUERY:\n%@\n", query);
    [dbManager executeQuery:query];
    
    if (dbManager.affectedRows > 0)
        NSLog(@"=== Query was executed successfully. Affected rows = %d", dbManager.affectedRows);
    else
        NSLog(@"=== Could not execute the query.");
}



#pragma mark - Pull data for Interaction

+ (NSString *)pullUpdateQueryForColumn:(NSString *)column fromInteraction:(NSDictionary *)interaction {
    NSString *value;
    NSArray *columns = @[column_interaction_latitude,
                         column_interaction_longitude,
                         column_interaction_place,
                         column_interaction_timestamp,
                         column_interaction_duration,
                         column_interaction_media];
    int index = (int)[columns indexOfObject:column];
    
    switch (index) {
        case 0: value = [self pullLatitudeFromInteraction:       interaction]; break;
        case 1: value = [self pullLongitudeFromInteraction:      interaction]; break;
        case 2: value = [self pullPlaceFromInteraction:          interaction]; break;
        case 3: value = [self pullTimestampFromInteraction:      interaction]; break;
        case 4: value = [self pullDurationFromInteraction:       interaction]; break;
        case 5: value = [self pullConnectionTypeFromInteraction: interaction]; break;
        default:value = @"null";
    }
    
    if ([value containsString:@"null"] || [value isEqualToString:@""]) return nil;
    else return value;
}


+ (NSString *)pullLatitudeFromInteraction:(NSDictionary *)interaction {
    NSString *value;
    
    NSNumber *numberValue = [interaction objectForKey:dict_latitudeKey];
    if (numberValue && ![numberValue isEqual:[NSNull null]])
        value = [NSString stringWithFormat:@"%f", [numberValue floatValue]];
    else
        value = @"null";
    
    return value;
}


+ (NSString *)pullLongitudeFromInteraction:(NSDictionary *)interaction {
    NSString *value;
    
    NSNumber *numberValue = [interaction objectForKey:dict_longitudeKey];
    if (numberValue && ![numberValue isEqual:[NSNull null]])
        value = [NSString stringWithFormat:@"%f", [numberValue floatValue]];
    else
        value = @"null";
    
    return value;
}


+ (NSString *)pullPlaceFromInteraction:(NSDictionary *)interaction {
    NSString *value;
    
    NSString *stringValue = [interaction objectForKey:dict_placeKey];
    if (stringValue && ![stringValue isEqual:[NSNull null]] && [stringValue length] > 0)
        value = stringValue;
    else
        value = @"";
    
    return value;
}


+ (NSString *)pullTimestampFromInteraction:(NSDictionary *)interaction {
    NSString *value;
    
    NSNumber *numberValue = [interaction objectForKey:dict_interactionTimeKey];
    if (numberValue && ![numberValue isEqual:[NSNull null]]) {
        int intNumberValue = (int)([numberValue longLongValue] / 1000);
        value = [NSString stringWithFormat:@"%d", intNumberValue];
    } else
        value = @"null";
    
    return value;
}


+ (NSString *)pullDurationFromInteraction:(NSDictionary *)interaction {
    NSString *value;
    
    NSNumber *numberValue = [interaction objectForKey:dict_interactionDurationKey];
    if (numberValue && ![numberValue isEqual:[NSNull null]])
        value = [NSString stringWithFormat:@"%lld", [numberValue longLongValue]];
    else
        value = @"null";
    
    return value;
}


+ (NSString *)pullConnectionTypeFromInteraction:(NSDictionary *)interaction {
    NSString *value;
    
    NSNumber *numberValue = [interaction objectForKey:dict_connectionTypeKey];
    if (numberValue && ![numberValue isEqual:[NSNull null]])
        value = [NSString stringWithFormat:@"%d", [numberValue unsignedIntValue]];
    else
        value = @"null";
    
    return value;
}





#pragma mark -
#pragma mark - Services save/update

+ (long long)saveService:(NSDictionary *)service {
    DBManager *dbManager = [self dbManager];
    if (!dbManager) return -1;
    if (!service || [[service allKeys] count] == 0) return -1;
    if (![service objectForKey:dict_interactionIDKey] || [[service objectForKey:dict_interactionIDKey] isEqual:[NSNull null]]) return -1;
    if (![service objectForKey:dict_serviceTimeKey]   || [[service objectForKey:dict_serviceTimeKey]   isEqual:[NSNull null]]) return -1;
    
    NSString *query = [NSString stringWithFormat:@"%@ %@ VALUES (null, %@, '%@', '%@', %@, %@, %@, '%@')",
                       insertQuery, servicesTable,
                       [self pullInteractionIDFromService:           service],
                       [self pullInteractionTypeFromService:         service],
                       [self pullServiceTypeFromService:             service],
                       [self pullServiceTimestampFromService:        service],
                       [self pullServiceDurationFromService:         service],
                       [self pullServiceFailureTimestampFromService: service],
                       [self pullServiceFailureReasonFromService:    service]];
    
    NSLog(@"=== INSERT QUERY:\n%@\n", query);
    [dbManager executeQuery:query];
    
    if (dbManager.affectedRows > 0)
        NSLog(@"=== Query was executed successfully. Affected rows = %d", dbManager.affectedRows);
    else
        NSLog(@"=== Could not execute the query.");
    
    return dbManager.lastInsertedRowID;
}


+ (void)updateService:(NSDictionary*)service {
    DBManager *dbManager = [self dbManager];
    if (!dbManager) return;
    if (!service || [[service allKeys] count] == 0) return;
    if (![service objectForKey:dict_serviceIDKey] || [[service objectForKey:dict_serviceIDKey] isEqual:[NSNull null]]) return;
    
    NSMutableString *query = [[NSMutableString alloc] init];
    [query appendString:updateQuery];
    [query appendString:[NSString stringWithFormat:@" %@ SET ", servicesTable]];
    
    void (^addPrameterWithValueIntoUpdateQuery)(NSString *, NSDictionary *) = ^(NSString *column, NSDictionary *service) {
        NSString *columnValue = [self pullUpdateQueryForColumn:column fromService:service];
        if (columnValue)
            [query appendString:[NSString stringWithFormat:@"%@ = '%@', ", column, columnValue]];
    };
    addPrameterWithValueIntoUpdateQuery(column_service_interactionType, service);
    addPrameterWithValueIntoUpdateQuery(column_service_type,            service);
    addPrameterWithValueIntoUpdateQuery(column_service_duration,        service);
    addPrameterWithValueIntoUpdateQuery(column_service_failureTime,     service);
    addPrameterWithValueIntoUpdateQuery(column_service_failureReason,   service);
    
    [self removeExtraCommaAndSpaceFromQuery:query];
    
    [query appendString:[NSString stringWithFormat:@"WHERE id = %d", [[service objectForKey:dict_serviceIDKey] unsignedIntValue]]];
    
    NSLog(@"=== UPDATE QUERY:\n%@\n", query);
    [dbManager executeQuery:query];
    
    if (dbManager.affectedRows > 0)
        NSLog(@"=== Query was executed successfully. Affected rows = %d", dbManager.affectedRows);
    else
        NSLog(@"=== Could not execute the query.");
    
}



#pragma mark - Pull data for Service

+ (NSString *)pullUpdateQueryForColumn:(NSString *)column fromService:(NSDictionary *)service {
    NSString *value;
    NSArray *columns = @[column_service_interactionID,
                         column_service_interactionType,
                         column_service_type,
                         column_service_timestamp,
                         column_service_duration,
                         column_service_failureTime,
                         column_service_failureReason];
    int index = (int)[columns indexOfObject:column];
    
    switch (index) {
        case 0: value = [self pullInteractionIDFromService:         service]; break;
        case 1: value = [self pullInteractionTypeFromService:       service]; break;
        case 2: value = [self pullServiceTypeFromService:           service]; break;
        case 3: value = [self pullServiceTimestampFromService:      service]; break;
        case 4: value = [self pullServiceDurationFromService:       service]; break;
        case 5: value = [self pullServiceFailureReasonFromService:  service]; break;
        case 6: value = [self pullServiceFailureReasonFromService:  service]; break;
        default:value = @"null";
    }
    
    if ([value containsString:@"null"] || [value isEqualToString:@""]) return nil;
    else return value;
}


+ (NSString *)pullInteractionIDFromService:(NSDictionary *)service {
    NSString *value;
    
    NSNumber *numberValue = [service objectForKey:dict_interactionIDKey];
    if (numberValue && ![numberValue isEqual:[NSNull null]])
        value = [NSString stringWithFormat:@"%d", [numberValue unsignedIntValue]];
    else
        value = @"null";
    
    return value;
}


+ (NSString *)pullInteractionTypeFromService:(NSDictionary *)service {
    NSString *value;
    
    NSString *stringValue = [service objectForKey:dict_interactionTypeKey];
    if (stringValue && ![stringValue isEqual:[NSNull null]] && [stringValue length] > 0)
        value = stringValue;
    else
        value = @"";
    
    return value;
}


+ (NSString *)pullServiceTypeFromService:(NSDictionary *)service {
    NSString *value;
    
    NSString *stringValue = [service objectForKey:dict_serviceTypeKey];
    if (stringValue && ![stringValue isEqual:[NSNull null]] && [stringValue length] > 0)
        value = stringValue;
    else
        value = @"";
    
    return value;
}


+ (NSString *)pullServiceTimestampFromService:(NSDictionary *)service {
    NSString *value;
    
    NSNumber *numberValue = [service objectForKey:dict_serviceTimeKey];
    if (numberValue && ![numberValue isEqual:[NSNull null]]) {
        int intNumberValue = (int)([numberValue longLongValue] / 1000);
        value = [NSString stringWithFormat:@"%d", intNumberValue];
    } else
        value = @"null";
    
    return value;
}


+ (NSString *)pullServiceDurationFromService:(NSDictionary *)service {
    NSString *value;
    
    NSNumber *numberValue = [service objectForKey:dict_serviceDurationKey];
    if (numberValue && ![numberValue isEqual:[NSNull null]])
        value = [NSString stringWithFormat:@"%lld", [numberValue longLongValue]];
    else
        value = @"null";
    
    return value;
}


+ (NSString *)pullServiceFailureTimestampFromService:(NSDictionary *)service {
    NSString *value;
    
    NSNumber *numberValue = [service objectForKey:dict_serviceFailureTimeKey];
    if (numberValue && ![numberValue isEqual:[NSNull null]]) {
        int intNumberValue = (int)([numberValue longLongValue] / 1000);
        value = [NSString stringWithFormat:@"%d", intNumberValue];
    } else
        value = @"null";
    
    return value;
}


+ (NSString *)pullServiceFailureReasonFromService:(NSDictionary *)service {
    NSString *value;
    
    NSString *stringValue = [service objectForKey:dict_serviceFailureReasonKey];
    if (stringValue && ![stringValue isEqual:[NSNull null]] && [stringValue length] > 0)
        value = stringValue;
    else
        value = @"";
    
    return value;
}





#pragma mark -
#pragma mark - Report save/update

+ (NSNumber *)loadLastReportTime {
    DBManager *dbManager = [self dbManager];
    if (!dbManager) return nil;
    
    NSString *query = [NSString stringWithFormat:@"%@ %@", selectQuery, reportTable];
    NSArray *resultsArray = [[NSArray alloc] initWithArray:[dbManager loadDataFromDB:query]];
    if (!resultsArray || [resultsArray count] == 0) return nil;
    
    NSArray  *timestampRecord = [resultsArray firstObject];
    NSString *timestampString = [timestampRecord lastObject];
    if (!timestampString || [timestampString length] == 0 || [timestampString isEqual:[NSNull null]]) return nil;
    
    return [NSNumber numberWithLongLong:[timestampString longLongValue]];
}



+ (void)saveNewReportTime:(NSNumber *)reportTime {
    DBManager *dbManager = [self dbManager];
    if (!dbManager) return;
    if (!reportTime) return;
    if ([reportTime longLongValue] <= 0) return;
    
    [self removeAllStoredReportTimeRecords:dbManager];
    
    NSString *query = [NSString stringWithFormat:@"%@ %@ VALUES (null, %@)", insertQuery, reportTable, [NSString stringWithFormat:@"%lld", [reportTime longLongValue]]];
    NSLog(@"=== INSERT QUERY:\n%@\n", query);
    [dbManager executeQuery:query];
    
    if (dbManager.affectedRows > 0)
        NSLog(@"=== Query was executed successfully. Affected rows = %d", dbManager.affectedRows);
    else
        NSLog(@"=== Could not execute the query.");
}


+ (void)removeAllStoredReportTimeRecords:(DBManager *)dbManager {
    NSString *query = [NSString stringWithFormat:@"%@ %@", deleteQuery, reportTable];
    NSLog(@"=== DELETE QUERY:\n%@\n", query);
    [dbManager executeQuery:query];
}




#pragma mark -
#pragma mark - Clean Interactions & Services

+ (void)cleanInteractionsAndServices {
    DBManager *dbManager = [self dbManager];
    if (!dbManager) return;
    
    [dbManager executeQuery:[NSString stringWithFormat:@"%@ %@", deleteQuery, interactionsTable]];
    [dbManager executeQuery:[NSString stringWithFormat:@"%@ %@", deleteQuery, servicesTable]];
}




#pragma mark -
#pragma mark - Query helper
+ (void)removeExtraCommaAndSpaceFromQuery:(NSMutableString *)query {
    NSString *last2Character = [query substringFromIndex:MAX((int)[query length] - 2, 0)];
    if ([last2Character isEqualToString:@", "])
        [query replaceCharactersInRange:NSMakeRange([query length] - 2, 2) withString:@" "];
}





#pragma mark -
#pragma mark - Load Background services

+ (NSDictionary *)loadBackgroundWundergroundServices {
    return [self loadBackgroundServices:ServiceTypeWunderground];
}


+ (NSDictionary *)loadBackgroundAppchainsServices {
    return [self loadBackgroundServices:ServiceTypeAppChains];
}


+ (NSDictionary *)loadBackgroundServices:(ServiceType)service {
    DBManager *dbManager = [self dbManager];
    if (!dbManager) return nil;
    
    NSString *serviceType;
    switch (service) {
        case ServiceTypeWunderground:   serviceType = wundergroundServiceType;  break;
        case ServiceTypeAppChains:      serviceType = appChainsServiceType;     break;
        case ServiceTypeNoData:         return nil;                             break;
    }
    
    NSString *query = [NSString stringWithFormat:@"%@ %@ WHERE `%@` LIKE '%%%@%%' ESCAPE '\\' AND `%@` LIKE '%%%@%%' ESCAPE '\\';",
                       selectQuery, servicesTable, column_service_interactionType, backgroundInteractionType, column_service_type, serviceType];
    
    NSArray *resultsArray = [[NSArray alloc] initWithArray:[dbManager loadDataFromDB:query]];
    NSArray *columnsArray = dbManager.arrColumnNames;
    
    if (!resultsArray || [resultsArray count] == 0 || !columnsArray || [columnsArray count] == 0) return nil;
    
    return [NSDictionary dictionaryWithObjectsAndKeys:resultsArray, dict_sql_records, columnsArray, dict_sql_column_names, nil];
}




#pragma mark -
#pragma mark - Load Foreground interactions

+ (NSDictionary *)loadForegroundInteractions {
    DBManager *dbManager = [self dbManager];
    if (!dbManager) return nil;
    
    NSString *query = [NSString stringWithFormat:@"%@ %@", selectQuery, interactionsTable];
    
    NSArray *resultsArray = [[NSArray alloc] initWithArray:[dbManager loadDataFromDB:query]];
    NSArray *columnsArray = dbManager.arrColumnNames;
    
    if (!resultsArray || [resultsArray count] == 0 || !columnsArray || [columnsArray count] == 0) return nil;
    
    return [NSDictionary dictionaryWithObjectsAndKeys:resultsArray, dict_sql_records, columnsArray, dict_sql_column_names, nil];
}



+ (NSDictionary *)loadForegroundWundergroundServicesByInteractionID:(NSNumber *)interactionID {
    if (!interactionID) return nil;
    return [self loadForegroundServices:ServiceTypeWunderground byInteractionID:interactionID];
}


+ (NSDictionary *)loadForegroundAppchainsServicesByInteractionID:   (NSNumber *)interactionID {
    if (!interactionID) return nil;
    return [self loadForegroundServices:ServiceTypeAppChains byInteractionID:interactionID];
}


+ (NSDictionary *)loadForegroundServices:(ServiceType)service byInteractionID:(NSNumber *)interactionID {
    DBManager *dbManager = [self dbManager];
    if (!dbManager) return nil;
    if (!interactionID) return nil;
    
    NSString *serviceType;
    switch (service) {
        case ServiceTypeWunderground:   serviceType = wundergroundServiceType;  break;
        case ServiceTypeAppChains:      serviceType = appChainsServiceType;     break;
        case ServiceTypeNoData:         return nil;                             break;
    }
    
    NSString *query = [NSString stringWithFormat:@"%@ %@ WHERE %@ = %lld AND `%@` LIKE '%%%@%%' ESCAPE '\\' AND `%@` LIKE '%%%@%%' ESCAPE '\\';",
                       selectQuery, servicesTable,
                       column_service_interactionID, [interactionID longLongValue],
                       column_service_interactionType, foregroundInteractionType,
                       column_service_type, serviceType];
    
    NSArray *resultsArray = [[NSArray alloc] initWithArray:[dbManager loadDataFromDB:query]];
    NSArray *columnsArray = dbManager.arrColumnNames;
    
    if (!resultsArray || [resultsArray count] == 0 || !columnsArray || [columnsArray count] == 0) return nil;
    
    return [NSDictionary dictionaryWithObjectsAndKeys:resultsArray, dict_sql_records, columnsArray, dict_sql_column_names, nil];
}



#pragma mark - Test load
- (void)loadTestData {
    // Form the query.
    // NSString *query = @"select * from interactions";
    
    // Get the results.
    // NSArray *tempArray = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    
    // Reload the table view.
    // NSLog(@"\n\ndata:\n%@\n\n", tempArray);
}

@end
