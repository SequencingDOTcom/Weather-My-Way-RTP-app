//
//  ConstantsList.h
//  Copyright © 2017 Sequencing. All rights reserved.
//


#import <Foundation/Foundation.h>


// keys for Database
#define database            @"log.sql"

#define reportTable         @"report"
#define interactionsTable   @"interactions"
#define servicesTable       @"services"

#define deleteQuery         @"DELETE FROM"
#define insertQuery         @"INSERT INTO"
#define updateQuery         @"UPDATE"
#define selectQuery         @"SELECT * FROM"
#define selectByIDQuery     @"SELECT `_rowid_`, * FROM"



// notification keys for Events Logging
#define LOG_REPORT_WAS_SENT_SUCCESSFULLY_NOTIFICATION_KEY       @"LOG_REPORT_WAS_SENT_SUCCESSFULLY_NOTIFICATION_KEY"
#define GPS_COORDINATES_DETECTED_NOTIFICATION_KEY               @"GPS_COORDINATES_DETECTED_NOTIFICATION_KEY"
#define LOCATION_NAME_DEFINED_NOTIFICATION_KEY                  @"LOCATION_NAME_DEFINED_NOTIFICATION_KEY"
#define WUNDERGROUND_FORECAST_REQUEST_STARTED_NOTIFICATION_KEY  @"WUNDERGROUND_FORECAST_REQUEST_STARTED_NOTIFICATION_KEY"
#define WUNDERGROUND_FORECAST_REQUEST_FINISHED_NOTIFICATION_KEY @"WUNDERGROUND_FORECAST_REQUEST_FINISHED_NOTIFICATION_KEY"
#define WUNDERGROUND_FORECAST_REQUEST_FAILED_NOTIFICATION_KEY   @"WUNDERGROUND_FORECAST_REQUEST_FAILED_NOTIFICATION_KEY"
#define APPCHAINS_REQUEST_STARTED_NOTIFICATION_KEY              @"APPCHAINS_REQUEST_STARTED_NOTIFICATION_KEY"
#define APPCHAINS_REQUEST_FINISHED_NOTIFICATION_KEY             @"APPCHAINS_REQUEST_FINISHED_NOTIFICATION_KEY"
#define APPCHAINS_REQUEST_FAILED_NOTIFICATION_KEY               @"APPCHAINS_REQUEST_FAILED_NOTIFICATION_KEY"



// string value for Interaction & Service types
#define foregroundInteractionType       @"foreground"
#define backgroundInteractionType       @"background"
#define unknownInteractionType          @"unknownInteraction"
#define wundergroundServiceType         @"wunderground"
#define appChainsServiceType            @"appchains"
#define unknownServiceType              @"unknownService"



// report table columns
#define column_report_id                @"id"
#define column_report_timestamp         @"timestamp"

// interactions table columns
#define column_interaction_id           @"ID"
#define column_interaction_latitude     @"latitude"
#define column_interaction_longitude    @"longitude"
#define column_interaction_place        @"place"
#define column_interaction_timestamp    @"timestamp"
#define column_interaction_duration     @"duration"
#define column_interaction_media        @"media"

// services table columns
#define column_service_id               @"id"
#define column_service_interactionID    @"interactionid"
#define column_service_interactionType  @"interactiontype"
#define column_service_type             @"servicetype"
#define column_service_timestamp        @"servicetimestamp"
#define column_service_duration         @"serviceduration"
#define column_service_failureTime      @"failuretime"
#define column_service_failureReason    @"failurereason"



// JSON keys for Events Logging
#define jsonKey_user            @"user"
#define jsonKey_os              @"os"
#define jsonKey_name            @"name"
#define jsonKey_ver             @"ver"
#define jsonKey_arch            @"arch"
#define jsonKey_app             @"app"

#define jsonKey_usage           @"usage"
#define jsonKey_start           @"start"
#define jsonKey_end             @"end"
#define jsonKey_events          @"events"
#define jsonKey_ts              @"ts"
#define jsonKey_type            @"type"

#define jsonKey_background      @"background"
#define jsonKey_wu              @"wu"
#define jsonKey_appchains       @"appchains"
#define jsonKey_l               @"l"
#define jsonKey_h               @"h"
#define jsonKey_avg             @"avg"
#define jsonKey_n               @"n"
#define jsonKey_failures        @"failures"
#define jsonKey_reason          @"reason"

#define jsonKey_interactions    @"interactions"
#define jsonKey_lat             @"lat"
#define jsonKey_lng             @"lng"
#define jsonKey_location           @"location"
#define jsonKey_place           @"place"
#define jsonKey_duration        @"duration"
#define jsonKey_media           @"media"
#define jsonKey_services        @"services"



// DICTIONARY keys for Events Logging
#define dict_interactionIDKey       @"dict_interactionIDKey"
#define dict_latitudeKey            @"dict_latitudeKey"
#define dict_longitudeKey           @"dict_longitudeKey"
#define dict_placeKey               @"dict_placeKey"
#define dict_interactionTimeKey     @"dict_interactionTimeKey"
#define dict_interactionDurationKey @"dict_interactionDurationKey"
#define dict_connectionTypeKey      @"dict_connectionTypeKey"

#define dict_cllocationKey          @"dict_cllocationKey"

#define dict_serviceIDKey           @"dict_serviceIDKey"
#define dict_interactionTypeKey     @"dict_interactionTypeKey"
#define dict_serviceTypeKey         @"dict_serviceTypeKey"
#define dict_serviceTimeKey         @"dict_serviceTimeKey"
#define dict_serviceDurationKey     @"dict_serviceDurationKey"
#define dict_serviceFailureTimeKey  @"dict_serviceFailureTimeKey"
#define dict_serviceFailureReasonKey    @"dict_serviceFailureReasonKey"

#define dict_failureDescriptionKey  @"dict_failureDescriptionKey"


// DICTIONARY SQL RESULTS
#define dict_sql_records            @"dict_sql_records"
#define dict_sql_column_names       @"dict_sql_column_names"







// HTTP request keys
#define VALID_STATUS_CODES  @[@(200), @(301), @(302)]




@interface ConstantsList : NSObject

@end
