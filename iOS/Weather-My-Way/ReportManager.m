//
//  ReportManager.m
//  Copyright © 2017 Sequencing. All rights reserved.
//


#import "ReportManager.h"
#import "DeviceDetector.h"
#import "ConstantsList.h"
#import "UserHelper.h"
#import "LoggerManager.h"
#import "ReportSender.h"


@implementation ReportManager


+ (void)prepareAndSendLoggingReport {
    // pull and prepare report
    NSMutableDictionary *report = [[NSMutableDictionary alloc] init];
    [report setObject:[self prepareUserValue]    forKey:jsonKey_user];
    [report setObject:[self prepareOsSection]    forKey:jsonKey_os];
    [report setObject:[self prepareAppSection]   forKey:jsonKey_app];
    [report setObject:[self prepareUsageSection] forKey:jsonKey_usage];
    
    // send report
    [ReportSender sendLogReport:report];
}



#pragma mark -
#pragma mark - Pull report
+ (id)prepareUserValue {
    NSString *email = [[[UserHelper alloc] init] loadUserAccountEmail];
    if (!email || [email length] == 0) return [NSNull null];
    else return email;
}


+ (NSDictionary *)prepareOsSection {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[DeviceDetector osName]          forKey:jsonKey_name];
    [dict setObject:[DeviceDetector osVersion]       forKey:jsonKey_ver];
    [dict setObject:[DeviceDetector cpuArchitecture] forKey:jsonKey_arch];
    //NSString *device        = [DeviceDetector deviceModel];
    //NSString *deviceUUID    = [DeviceDetector deviceUUID];
    return [NSDictionary dictionaryWithDictionary:dict];
}


+ (NSDictionary *)prepareAppSection {
    NSString *version = [[DeviceDetector appVersion] stringByReplacingOccurrencesOfString:@"v" withString:@""];
    return [NSDictionary dictionaryWithObject:version forKey:jsonKey_ver];
}



#pragma mark -
#pragma mark - Usage section
+ (NSDictionary *)prepareUsageSection {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[NSNumber numberWithInteger:[[NSDate date] timeIntervalSince1970]] forKey:jsonKey_start];
    [dict setObject:[NSNull null]                            forKey:jsonKey_end];
    [dict setObject:[self prepareEventsSubsection]           forKey:jsonKey_events];
    [dict setObject:[self prepareBackgroundSubsection]       forKey:jsonKey_background];
    [dict setObject:[self prepareForegroundSubsection]       forKey:jsonKey_interactions];
    
    return [NSDictionary dictionaryWithDictionary:dict];
}



#pragma mark - Events subsection
+ (NSArray *)prepareEventsSubsection {
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNull null], jsonKey_ts,
                          [NSNull null], jsonKey_type, nil];
    return @[dict];
}



#pragma mark - Background subsection
+ (NSDictionary *)prepareBackgroundSubsection {
    NSDictionary *wundergoundRequests = [LoggerManager loadBackgroundWundergroundServices];
    NSDictionary *appchainsRequests   = [LoggerManager loadBackgroundAppchainsServices];
    
    NSMutableDictionary *backgroundServiceRequests = [[NSMutableDictionary alloc] init];
    [backgroundServiceRequests setObject:[self prepareServicesSubsection:wundergoundRequests] forKey:jsonKey_wu];
    [backgroundServiceRequests setObject:[self prepareServicesSubsection:appchainsRequests]   forKey:jsonKey_appchains];
    return backgroundServiceRequests;
}




#pragma mark - Foreground subsection
+ (NSArray *)prepareForegroundSubsection {
    NSDictionary *interactions = [LoggerManager loadForegroundInteractions];
    if (!interactions) return [NSArray arrayWithObject:[self prepareEmptyInteraction]];
        
    NSArray *records = [interactions objectForKey:dict_sql_records];
    NSArray *columns = [interactions objectForKey:dict_sql_column_names];
    if (!records || [records count] == 0 || !columns || [columns count] == 0) return [NSArray arrayWithObject:[self prepareEmptyInteraction]];
    
    NSMutableArray *interactionResults = [[NSMutableArray alloc] init];
    for (NSArray *record in records) {
        [interactionResults addObject:[self prepareOneInteractionResult:record withColumnNames:columns]];
    }
    
    return interactionResults;
}



#pragma mark Interaction
+ (NSDictionary *)prepareOneInteractionResult:(NSArray *)interaction withColumnNames:(NSArray *)columns {
    if (!interaction || [interaction count] == 0 || !columns || [columns count] == 0 || [interaction count] != [columns count]) return [self prepareEmptyInteraction];
    
    NSNumber *interactionID = [self pullInteractionIDFromInteractionRecord:interaction withColumnNames:columns];
    
    NSMutableDictionary *interactionResult = [[NSMutableDictionary alloc] init];
    [interactionResult setObject:[self pullLocationFromInteractionRecord:   interaction withColumnNames:columns] forKey:jsonKey_location];
    [interactionResult setObject:[self pullPlaceFromInteractionRecord:      interaction withColumnNames:columns] forKey:jsonKey_place];
    [interactionResult setObject:[self pullTimestampFromInteractionRecord:  interaction withColumnNames:columns] forKey:jsonKey_ts];
    [interactionResult setObject:[self pullDurationFromInteractionRecord:   interaction withColumnNames:columns] forKey:jsonKey_duration];
    [interactionResult setObject:[self pullMediaFromInteractionRecord:      interaction withColumnNames:columns] forKey:jsonKey_media];
    
    NSDictionary *services = [NSDictionary dictionaryWithObjectsAndKeys:
                              [self prepareForegroundWundergroundServicesByInteractionID:interactionID], jsonKey_wu,
                              [self prepareForegroundAppchainsServicesByInteractionID:   interactionID], jsonKey_appchains, nil];
    [interactionResult setObject:services forKey:jsonKey_services];
    return interactionResult;
}


+ (NSNumber *)pullInteractionIDFromInteractionRecord:(NSArray *)interaction withColumnNames:(NSArray *)columns {
    id tempValue = [interaction objectAtIndex:[columns indexOfObject:column_interaction_id]];
    if (!tempValue || [tempValue isEqual:[NSNull null]])
        return nil;
    else
        return [NSNumber numberWithLongLong:[[NSString stringWithFormat:@"%@", tempValue] longLongValue]];
}


+ (id)pullLocationFromInteractionRecord:(NSArray *)interaction withColumnNames:(NSArray *)columns {
    id latitude  = [self pullLatitudeFromInteractionRecord: interaction withColumnNames:columns];
    id longitude = [self pullLongitudeFromInteractionRecord:interaction withColumnNames:columns];
    
    if (!latitude || [latitude isEqual:[NSNull null]] || !longitude || [longitude isEqual:[NSNull null]])
        return [NSNull null];
    
    return [NSString stringWithFormat:@"%f,%f", [latitude floatValue], [longitude floatValue]];
}


+ (id)pullLatitudeFromInteractionRecord:(NSArray *)interaction withColumnNames:(NSArray *)columns {
    id tempValue = [interaction objectAtIndex:[columns indexOfObject:column_interaction_latitude]];
    if (!tempValue || [tempValue isEqual:[NSNull null]])
        return [NSNull null];
    else
        return [NSNumber numberWithFloat:[tempValue floatValue]];
}


+ (id)pullLongitudeFromInteractionRecord:(NSArray *)interaction withColumnNames:(NSArray *)columns {
    id tempValue = [interaction objectAtIndex:[columns indexOfObject:column_interaction_longitude]];
    if (!tempValue || [tempValue isEqual:[NSNull null]])
        return [NSNull null];
    else
        return [NSNumber numberWithFloat:[tempValue floatValue]];
}


+ (id)pullPlaceFromInteractionRecord:(NSArray *)interaction withColumnNames:(NSArray *)columns {
    id tempValue = [interaction objectAtIndex:[columns indexOfObject:column_interaction_place]];
    if (!tempValue || [tempValue isEqualToString:@""] || [tempValue isEqual:[NSNull null]])
        return [NSNull null];
    else
        return [NSString stringWithFormat:@"%@", tempValue];
}


+ (id)pullTimestampFromInteractionRecord:(NSArray *)interaction withColumnNames:(NSArray *)columns {
    id tempValue = [interaction objectAtIndex:[columns indexOfObject:column_interaction_timestamp]];
    if (!tempValue || [tempValue isEqual:[NSNull null]])
        return [NSNull null];
    else
        return [NSNumber numberWithLongLong:[tempValue longLongValue]];
}


+ (id)pullDurationFromInteractionRecord:(NSArray *)interaction withColumnNames:(NSArray *)columns {
    id tempValue = [interaction objectAtIndex:[columns indexOfObject:column_interaction_duration]];
    if (!tempValue || [tempValue isEqual:[NSNull null]])
        return [NSNull null];
    else
        return [NSNumber numberWithLongLong:[tempValue longLongValue]];
}


+ (id)pullMediaFromInteractionRecord:(NSArray *)interaction withColumnNames:(NSArray *)columns {
    id tempValue = [interaction objectAtIndex:[columns indexOfObject:column_interaction_media]];
    if (!tempValue || [tempValue isEqual:[NSNull null]])
        return [NSNull null];
    else
        return [NSNumber numberWithInt:[tempValue intValue]];
}


+ (NSDictionary *)prepareEmptyInteraction {
    NSMutableDictionary *emptyInteraction = [[NSMutableDictionary alloc] init];
    [emptyInteraction setObject:[NSNull null] forKey:jsonKey_location];
    [emptyInteraction setObject:[NSNull null] forKey:jsonKey_place];
    [emptyInteraction setObject:[NSNull null] forKey:jsonKey_ts];
    [emptyInteraction setObject:[NSNull null] forKey:jsonKey_duration];
    [emptyInteraction setObject:[NSNull null] forKey:jsonKey_media];
    
    NSDictionary *services = [NSDictionary dictionaryWithObjectsAndKeys:
                              [self prepareEmptyServiceRequests], jsonKey_wu,
                              [self prepareEmptyServiceRequests], jsonKey_appchains, nil];
    [emptyInteraction setObject:services forKey:jsonKey_services];
    return emptyInteraction;
}




#pragma mark Services for Interaction
+ (NSDictionary *)prepareForegroundWundergroundServicesByInteractionID:(NSNumber *)interactionID {
    if (!interactionID || [interactionID isEqual:[NSNull null]]) return [self prepareEmptyServiceRequests];
    NSDictionary *services = [LoggerManager loadForegroundWundergroundServicesByInteractionID:interactionID];
    return [self prepareServicesSubsection:services];
}


+ (NSDictionary *)prepareForegroundAppchainsServicesByInteractionID:(NSNumber *)interactionID {
    if (!interactionID || [interactionID isEqual:[NSNull null]]) return [self prepareEmptyServiceRequests];
    NSDictionary *services = [LoggerManager loadForegroundAppchainsServicesByInteractionID:interactionID];
    return [self prepareServicesSubsection:services];
}


+ (NSDictionary *)prepareServicesSubsection:(NSDictionary *)services {
    if (!services || [[services allKeys] count] == 0) return [self prepareEmptyServiceRequests];
    
    NSArray *records = [services objectForKey:dict_sql_records];
    NSArray *columns = [services objectForKey:dict_sql_column_names];
    if (!records || [records count] == 0 || !columns || [columns count] == 0) return [self prepareEmptyServiceRequests];
    
    NSMutableDictionary *serviceResults = [[NSMutableDictionary alloc] init];
    [serviceResults setObject:[self pullFastestRequestInfoForServices:records withColumnNames:columns] forKey:jsonKey_l];
    [serviceResults setObject:[self pullSlowestRequestInfoForServices:records withColumnNames:columns] forKey:jsonKey_h];
    [serviceResults setObject:[self pullAverageRequestInfoForServices:records withColumnNames:columns] forKey:jsonKey_avg];
    [serviceResults setObject:[self pullNumberOfRequests:records              withColumnNames:columns] forKey:jsonKey_n];
    
    id failuresSubSection = [self pullFailuresFromServiceRecords:records withColumnNames:columns];
    if ([failuresSubSection isKindOfClass:[NSArray class]])
        if ((NSArray *)failuresSubSection && [(NSArray *)failuresSubSection count] > 0)
            [serviceResults setObject:(NSArray *)failuresSubSection forKey:jsonKey_failures];
    
    return serviceResults;
}




+ (id)pullFastestRequestInfoForServices:(NSArray *)services withColumnNames:(NSArray *)columns {
    NSArray *requestsDurations = [self pullAllDurationsFromServiceRecords:services withColumnNames:columns];
    if (!requestsDurations || [requestsDurations count] == 0) return [NSNull null];
    
    NSNumber *minTime = [requestsDurations valueForKeyPath:@"@min.self"];
    return minTime;
}


+ (id)pullSlowestRequestInfoForServices:(NSArray *)services withColumnNames:(NSArray *)columns {
    NSArray *requestsDurations = [self pullAllDurationsFromServiceRecords:services withColumnNames:columns];
    if (!requestsDurations || [requestsDurations count] == 0) return [NSNull null];
    
    NSNumber *maxTime = [requestsDurations valueForKeyPath:@"@max.self"];
    return maxTime;
}


+ (id)pullAverageRequestInfoForServices:(NSArray *)services withColumnNames:(NSArray *)columns {
    NSArray *requestsDurations = [self pullAllDurationsFromServiceRecords:services withColumnNames:columns];
    if (!requestsDurations || [requestsDurations count] == 0) return [NSNull null];
    
    NSNumber *avgTime = [requestsDurations valueForKeyPath:@"@avg.self"];
    return avgTime;
}


+ (NSArray *)pullAllDurationsFromServiceRecords:(NSArray *)services withColumnNames:(NSArray *)columns {
    NSMutableArray *requestsDurations = [[NSMutableArray alloc] init];
    for (NSArray *service in services) {
        id tempValue = [service objectAtIndex:[columns indexOfObject:column_service_duration]];
        if (tempValue && ![tempValue isEqual:[NSNull null]] && (long long)tempValue != 0)
            [requestsDurations addObject:[NSNumber numberWithLongLong:[tempValue longLongValue]]];
    }
    return [NSArray arrayWithArray:requestsDurations];
}


+ (id)pullNumberOfRequests:(NSArray *)services withColumnNames:(NSArray *)columns {
    if (!services) return [NSNull null];
    return [NSNumber numberWithUnsignedInteger:[services count]];
}


+ (id)pullFailuresFromServiceRecords:(NSArray *)services withColumnNames:(NSArray *)columns {
    if (!services || !columns) return [NSNull null];
    NSMutableArray *failureArray = [[NSMutableArray alloc] init];
    
    for (NSArray *service in services) {
        id tempTime = [service objectAtIndex:[columns indexOfObject:column_service_failureTime]];
        id tempText = [service objectAtIndex:[columns indexOfObject:column_service_failureReason]];
        
        NSMutableDictionary *failureObject = [[NSMutableDictionary alloc] init];
        if (tempTime && ![tempTime isEqual:[NSNull null]])
            [failureObject setObject:[NSNumber numberWithLongLong:[tempTime longLongValue]] forKey:jsonKey_ts];
        
        if (tempText && ![tempText isEqualToString:@""] && ![tempText isEqual:[NSNull null]])
            [failureObject setObject:[NSString stringWithFormat:@"%@", tempText] forKey:jsonKey_reason];
        
        if (failureObject && [[failureObject allKeys] count] != 0)
            [failureArray addObject:failureObject];
    }
    
    if (!failureArray || [failureArray count] == 0) return [NSNull null];
    else return [NSArray arrayWithArray:failureArray];
}



+ (NSDictionary *)prepareEmptyServiceRequests {
    NSMutableDictionary *emptyRequest = [[NSMutableDictionary alloc] init];
    [emptyRequest setObject:[NSNull null] forKey:jsonKey_l];
    [emptyRequest setObject:[NSNull null] forKey:jsonKey_h];
    [emptyRequest setObject:[NSNull null] forKey:jsonKey_avg];
    [emptyRequest setObject:[NSNull null] forKey:jsonKey_n];
    // [emptyRequest setObject:[NSNull null] forKey:jsonKey_failures];
    return emptyRequest;
}

@end
