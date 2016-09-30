//
//  AppChains.h
//  Copyright © 2015-2016 Sequencing.com. All rights reserved
//

#import <Foundation/Foundation.h>

@class Job;
@class ResultValue;
@class TextResultValue;
@class FileResultValue;
@class Result;
@class Report;
@class RawReportJobResult;

@class HttpResponse;

@interface AppChains : NSObject

// Simple init
- (instancetype)init;

// Init with token, uses in getReport request
- (instancetype)initWithToken:(NSString *)token;

// Init with token and with host name
- (instancetype)initWithToken:(NSString *)token withHostName:(NSString *)hostName;

#pragma mark High level public API

- (void)getPublicBeaconWithChrom:(int)chrom
                         withPos:(int)pos
                      withAllele:(NSString *)allele
                withSuccessBlock:(void (^)(NSString *result))success
                withFailureBlock:(void (^)(NSError *error))failure;

- (void)getSequencingBeaconWithChrom:(int)chrom
                             withPos:(int)pos
                          withAllele:(NSString *)allele
                    withSuccessBlock:(void (^)(NSString *result))success
                    withFailureBlock:(void (^) (NSError *error))failure;

- (void)getReportWithRemoteMethodName:(NSString *)remoteMethodName
            withApplicationMethodName:(NSString *)applicationMethodName
                     withDatasourceId:(NSString *)datasourceId
                     withSuccessBlock:(void (^)(Report *result))success
                     withFailureBlock:(void (^)(NSError *error))failure;

- (void)getReportWithRemoteMethodName:(NSString *)remoteMethodName
                      withRequestBody:(NSString *)requestBody
                     withSuccessBlock:(void (^)(Report *result))success
                     withFailureBlock:(void (^)(NSError *error))failure;


#pragma mark Low level public API

- (void)getRawReportWithRemoteMethodName:(NSString *)remoteMethodName
               withApplicationMethodName:(NSString *)applicationMethodName
                        withDatasourceId:(NSString *)datasourceId
                        withSuccessBlock:(void (^)(NSDictionary *result))success
                        withFailureBlock:(void (^)(NSError *error))failure;


- (void)getRawReportWithRemoteMethodName:(NSString *)remoteMethodName
                         withRequestBody:(NSString *)requestBody
                        withSuccessBlock:(void (^)(NSDictionary *result))success
                        withFailureBlock:(void (^)(NSError *error))failure;


- (void)getBeaconWithMethodName:(NSString *)methodName
                 withParameters:(NSDictionary *)parameters
               withSuccessBlock:(void (^)(NSString *result))success
               withFailureBlock:(void (^)(NSError *error))failure;


- (void)getBeaconWithMethodName:(NSString *)methodName
                withQueryString:(NSString *)queryString
               withSuccessBlock:(void (^)(NSString *result))success
               withFailureBlock:(void (^)(NSError *error))failure;

@end


#pragma mark - Job

/**
 * Class that represents generic job identifier
 */
@interface Job : NSObject

- (void)jobWithId:(NSInteger)jobId;
- (NSInteger)getJobId;

@end

#pragma mark - ResultValue

/**
 * Enumerates possible result entity types
 */
typedef NS_ENUM (NSUInteger, ResultType) {
    kResultTypeFile,
    kResultTypeText
};

@interface ResultValue : NSObject

- (void)resultValueWithResultType:(ResultType)type;
- (ResultType)getType;

@end


#pragma mark - TextResultValue

/**
 * Class that represents result entity if plain text string
 */
@interface TextResultValue : ResultValue

- (void)textResultValueWithData:(NSString *)data;
- (NSString *)getData;

@end


#pragma mark - FileResultValue

/**
 * Class that represents result entity if it's file
 */
@interface FileResultValue : ResultValue

- (void)fileResultValueWithChains:(AppChains *)chains withName:(NSString *)name withExtension:(NSString *)extension withURL:(NSURL *)url;
- (NSString *)getName;
- (NSURL *)getURL;
- (NSString *)getExtension;
- (void)getStreamWithSuccessBlock:(void (^)(NSData *data))success
                 withFailureBlock:(void (^)(NSError *error))failure;
- (void)saveAsWithFullPathWithName:(NSString *)fullPathWithName;
- (void)saveToLocation:(NSString *)location;

@end


#pragma mark - Result

/**
 * Class that represents single report result entity
 */
@interface Result : NSObject

- (void)resultWithName:(NSString *)name withResultType:(ResultType)resultType withResultValue:(ResultValue *)resultValue;
- (ResultValue *)getValue;
- (NSString *)getName;

@end


#pragma mark - Report

/**
 * Class that represents report available to
 * the end client
 */
@interface Report : NSObject

- (BOOL)isSucceeded;
- (void)setSucceded:(BOOL)succeded;
- (NSArray *)getResults;
- (void)setResults:(NSArray *)results;

@end


#pragma mark - RawReportJobResult

/**
 * Class that represents unstructured job response
 */
@interface RawReportJobResult : NSObject

- (NSArray *)getResultProps;
- (void)setResultProps:(NSArray *)resultProps;
- (NSString *)getStatus;
- (void)setStatus:(NSString *)status;
- (BOOL)isCompleted;
- (void)setCompleted:(BOOL)completed;
- (BOOL)isSucceeded;
- (void)setSucceded:(BOOL)succeded;
- (NSInteger)getJobId;
- (void)setJobId:(NSInteger)jobId;
- (NSDictionary *)getSource;
- (void)setSource:(NSDictionary *)source;

@end


#pragma mark - HttpResponse

/**
 * Class that represents generic HTTP response
 */

@interface HttpResponse : NSObject

- (void)httpResponseWithResponseCode:(NSInteger)responseCode withResponseData:(NSString *)responseData;
- (NSInteger)getResponseCode;
- (void)setResponseCode:(NSInteger)responseCode;
- (NSString *)getResponseData;
- (void)setResponseData:(NSString *)responseData;

@end
