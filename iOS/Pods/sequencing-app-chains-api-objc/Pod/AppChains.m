//
//  AppChains.m
//  Copyright © 2015-2016 Sequencing.com. All rights reserved
//

#import "AppChains.h"



// Schema to access remote API (http or https)
#define kDefaultAppChainsSchema @"https"

// Port to access remote API
#define kDefaultAppChainsPort   443

// Timeout to wait between tries to update Job status in seconds
static const NSUInteger kDefaultReportRetryTimeout = 3;

// Default hostname for Beacon requests
#define kBeaconHostName         @"beacon.sequencing.com"

// Default hostname for sequesing requests
#define kDefaultHostName        @"api.sequencing.com"

#define kDefaultTimeout         30

// Default AppChains protocol version
#define kDefaultApiVersion      @"v2"
#define kOldApiVersion          @"v1"




@interface AppChains () {
    // Variable contain number of status checking attempts
    NSUInteger checkCompletionCount;
}

// Security token supplied by the client
@property (nonatomic, strong) NSString *token;

// Remote hostname to send requests to
@property (nonatomic, strong) NSString *chainsHostname;


// properties for Batch requests
@property (copy, nonatomic) ReportsArray reportsArray;
@property (assign, nonatomic) NSInteger reportIndex;

// @rawResultsArray (from StartApp) - array of dictionaries {"appChainID": appChainID string, "rawReport": *RawReportJobResult}
@property (strong, nonatomic) NSArray *rawReportResultsArray;

// @reportResultsArray (results to return) - array of dictionaries {"appChainID": appChainID string, "report": *Report object}
@property (strong, nonatomic) NSMutableArray *reportResultsArray;

@end




@implementation AppChains

// Simple init
- (instancetype)init {
    self = [super init];
    if (self) { }
    return self;
}

// Init with token, uses in getReport request
- (instancetype)initWithToken:(NSString *)token {
    self = [super init];
    if (self) {
        _token = token;
    }
    return self;
}

// Init with token and with host name
- (instancetype)initWithToken:(NSString *)token withHostName:(NSString *)hostName {
    self = [super init];
    if (self) {
        _token = token;
        _chainsHostname = hostName;
    }
    return self;
}




#pragma mark -
#pragma mark AppChains v2 protocol

// =========================================================================================
/**
 * Request for report
 * v2 protocol implementation
 */
- (void)getReportWithApplicationMethodName:(NSString *)applicationMethodName
                          withDatasourceId:(NSString *)datasourceId
                          withSuccessBlock:(void (^)(Report *result))success
                          withFailureBlock:(void (^)(NSError *error))failure {
    if ([self.chainsHostname length] == 0) self.chainsHostname = kDefaultHostName;
    
    [self submitStartAppRequestWithApplicationMethodName:applicationMethodName
                                        withDatasourceId:datasourceId
                                        withSuccessBlock:^(RawReportJobResult *rawResult) {
                                            
                                            if (rawResult.isCompleted) { // StartApp is 'Completed' (we already have a result)
                                                NSLog(@">>> StartApp request status: Completed");
                                                success([self processCompletedJobWithRawReportJobResult:rawResult]);
                                                
                                            } else { // StartApp is 'Pending' (we need to use 'GetAppResults' endpoint now)
                                                NSLog(@">>> StartApp request status: Pending");
                                                Job *pendingJob = [[Job alloc] init];
                                                [pendingJob jobWithId:rawResult.getJobId];
                                                
                                                [self getAppResultsReportImplWithJob:pendingJob
                                                                    withSuccessBlock:^(Report *result) {
                                                                        success(result);
                                                                    }
                                                                    withFailureBlock:^(NSError *error) {
                                                                        failure(error);
                                                                    }];
                                            }
                                        }
                                        withFailureBlock:^(NSError *error) {
                                            failure(error);
                                        }];
}


/**
 * Request for batch report
 * v2 protocol implementation
 * @param appChainsParams - array of params. each param is a array (2 items: first object applicationMethodName, last object datasourceId)
 *
 * @reportResultsArray - result of reports for batch request, it's an array of dictionaries
 * each dictionary has following keys: "appChainID": appChainID string, "report": *Report object
 */
- (void)getBatchReportWithApplicationMethodName:(NSArray *)appChainsParams
                               withSuccessBlock:(ReportsArray)success
                               withFailureBlock:(void (^)(NSError *error))failure {
    NSLog(@">>>>> AppChains: getBatchReportWithApplicationMethodName");
    self.reportsArray = success;
    if ([self.chainsHostname length] == 0) self.chainsHostname = kDefaultHostName;
    
    [self submitStartAppBatchRequestWithParameters:appChainsParams
                                  withSuccessBlock:^(NSArray *rawReportResultsArray) {
                                      
                                      // @rawResultsArray - array of dictionaries {"appChainID": appChainID string, "rawReport": *RawReportJobResult}
                                      self.rawReportResultsArray = rawReportResultsArray;
                                      
                                      // @reportResultsArray - result of Reports for batch request, array of dictionaries
                                      // each dictionary has following keys: "appChainID": appChainID string, "report": *Report object
                                      self.reportResultsArray = [[NSMutableArray alloc] init];
                                      
                                      [self handleRawReportsFromStartAppBatchRequestAsFirstCall:YES];
                                      
                                  }
                                  withFailureBlock:^(NSError *error) {
                                      failure(error);
                                  }];
}


- (void)handleRawReportsFromStartAppBatchRequestAsFirstCall:(BOOL)firstCall {
    if (firstCall)
        self.reportIndex = 0;
    else
        self.reportIndex++;
        
    int numberOfRawReportItems = (int)[self.rawReportResultsArray count];
    
    if (self.reportIndex < numberOfRawReportItems) {
        NSDictionary *rawResultDict = self.rawReportResultsArray[self.reportIndex];
        RawReportJobResult *rawResult = [rawResultDict objectForKey:@"rawReport"];
        NSString *appChainID = [rawResultDict objectForKey:@"appChainID"];
        
        if (rawResult.isCompleted) {
            NSLog(@">>>>> AppChains: StartApp request is Completed for: %@", appChainID);
            [self addReportObjectToTheArrayOfBatchResults:[self processCompletedJobWithRawReportJobResult:rawResult]
                                            forAppChainID:appChainID];
            
        } else {
            NSLog(@">>>>> AppChains: StartApp request is Pending for: %@", appChainID);
            Job *pendingJob = [[Job alloc] init];
            [pendingJob jobWithId:rawResult.getJobId];
            
            [self getAppResultsReportImplWithJob:pendingJob
                                withSuccessBlock:^(Report *result) {
                                    
                                    [self addReportObjectToTheArrayOfBatchResults:result
                                                                    forAppChainID:appChainID];
                                }
                                withFailureBlock:^(NSError *error) {
                                    [self handleRawReportsFromStartAppBatchRequestAsFirstCall:NO];
                                }];
        }
        
    } else {
        // the rawReports are finished > let's return the result of Reports
        self.reportsArray([NSArray arrayWithArray:self.reportResultsArray]);
    }
}


- (void)addReportObjectToTheArrayOfBatchResults:(Report *)reportObject forAppChainID:(NSString *)appChainID {
    NSDictionary *reportItem = @{@"appChainID": appChainID,
                                 @"report"    : reportObject};
    [self.reportResultsArray addObject:reportItem];
    [self handleRawReportsFromStartAppBatchRequestAsFirstCall:NO];
}


/**
 * Submit StartApp request
 * v2 protocol
 * @param applicationMethodName report/application specific identifier (i.e. MelanomaDsAppv)
 * @param datasourceId resource with data to use for report generation
 */
- (void)submitStartAppRequestWithApplicationMethodName:(NSString *)applicationMethodName
                                      withDatasourceId:(NSString *)datasourceId
                                      withSuccessBlock:(void (^)(RawReportJobResult *rawResult))success
                                      withFailureBlock:(void (^)(NSError *error))failure {
    NSLog(@">>> sending '/v2/StartApp' request");
    
    [self submitStartAppRawRequestWithHTTPMethod:@"POST"
                            withRemoteMethodName:@"StartApp"
                                 withRequestBody:[self buildReportRequestBodyWithApplicationMethodName:applicationMethodName withDataSourceID:datasourceId]
                                withSuccessBlock:^(RawReportJobResult *rawResult) {
                                    success(rawResult);
                                }
                                withFailureBlock:^(NSError *error) {
                                    failure(error);
                                }];
}


/**
 * Submit StartApp request
 * v2 protocol
 * @appchainsParametersArray - array of params
 * each param is an array too (2 items: first object applicationMethodName, last object datasourceId)
 *
 * @success - array of dictionaries
 * each dictionary has following keys: "appChainID": appChainID string, "rawReport": *RawReportJobResult
 */
- (void)submitStartAppBatchRequestWithParameters:(NSArray *)appchainsParametersArray
                                withSuccessBlock:(void (^)(NSArray *rawReportResultsArray))success
                                withFailureBlock:(void (^)(NSError *error))failure {
    NSLog(@">>>>> AppChains: submitStartAppBatchRequestWithParameters");
    [self submitStartAppBatchRawRequestWithHTTPMethod:@"POST"
                                 withRemoteMethodName:@"StartAppBatch"
                                      withRequestBody:[self buildBatchReportRequestBodyWithParametersArray:appchainsParametersArray]
                                     withSuccessBlock:^(NSArray *rawResultsArray) {
                                         
                                         // @rawResultsArray - array of dictionaries
                                         // each dictionary has following keys: "appChainID": appChainID string, "rawReport": *RawReportJobResult
                                         success(rawResultsArray);
                                     }
                                     withFailureBlock:^(NSError *error) {
                                         failure(error);
                                     }];
}


/**
 * Submit StartApp low level request
 */
- (void)submitStartAppRawRequestWithHTTPMethod:(NSString *)httpMethod
                          withRemoteMethodName:(NSString *)remoteMethodName
                               withRequestBody:(NSString *)requestBody
                              withSuccessBlock:(void (^)(RawReportJobResult *rawResult))success
                              withFailureBlock:(void (^)(NSError *error))failure {
    
    [self httpRequestWithHTTPMethod:httpMethod
                            withURL:[self getJobSubmissionUrlWithApplicationMethodName:remoteMethodName]
                    withRequestBody:requestBody
                   withSuccessBlock:^(HttpResponse *httpResponse) {
                       
                       NSString *rawResponseData = [httpResponse getResponseData];
                       if ([[rawResponseData lowercaseString] rangeOfString:@"exception"].location != NSNotFound ||
                           [[rawResponseData lowercaseString] rangeOfString:@"invalid"].location != NSNotFound ||
                           [[rawResponseData lowercaseString] rangeOfString:@"error"].location != NSNotFound) {
                           
                           NSLog(@"appchains error: %@", rawResponseData);
                           failure([NSError errorWithDomain:@""
                                                       code:0
                                                   userInfo:@{@"Server error. Operation couldn't be completed" : @"localizationDescription"}]);
                           
                       } else {
                           NSData *responseData = [[httpResponse getResponseData] dataUsingEncoding:NSUTF8StringEncoding];
                           NSDictionary *decodedResponse = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:nil];
                           // NSLog(@"decodedResponse: %@", decodedResponse);
                           
                           NSArray *resultProps;
                           if (decodedResponse[@"ResultProps"] != nil) {
                               resultProps = decodedResponse[@"ResultProps"];
                           }
                           NSDictionary *status = decodedResponse[@"Status"];
                           NSString *completedSuccesfully = status[@"CompletedSuccesfully"];
                           
                           BOOL succeeded;
                           if ([status[@"CompletedSuccesfully"] isKindOfClass:[NSNull class]]) {
                               succeeded = NO;
                           } else {
                               succeeded = ([completedSuccesfully integerValue] == 1) ? YES : NO;
                           }
                           
                           NSString *jobStatus = status[@"Status"];
                           NSString *statusString = [jobStatus lowercaseString];
                           
                           Job *reportJob = [[Job alloc] init];
                           [reportJob jobWithId:[status[@"IdJob"] integerValue]];
                           
                           RawReportJobResult *result = [[RawReportJobResult alloc] init];
                           [result setSource:decodedResponse];
                           [result setJobId:[reportJob getJobId]];
                           [result setSucceded:succeeded];
                           [result setCompleted:([statusString isEqualToString:@"completed"]) ? YES : NO];
                           if (resultProps) [result setResultProps:resultProps];
                           [result setStatus:jobStatus];
                           
                           success(result);
                       }
                   }
                   withFailureBlock:^(NSError *error) {
                       failure(error);
                   }];
}


/**
 * Submit StartAppBatch low level request
 *
 * @rawResultsArray - array of dictionaries
 * each dictionary has following keys: "appChainID": appChainID string, "rawReport": *RawReportJobResult
 */
- (void)submitStartAppBatchRawRequestWithHTTPMethod:(NSString *)httpMethod
                               withRemoteMethodName:(NSString *)remoteMethodName
                                    withRequestBody:(NSString *)requestBody
                                   withSuccessBlock:(void (^)(NSArray *rawResultsArray))success
                                   withFailureBlock:(void (^)(NSError *error))failure {
    NSLog(@">>>>> AppChains: submitStartAppBatchRawRequestWithHTTPMethod");
    [self httpRequestWithHTTPMethod:httpMethod
                            withURL:[self getJobSubmissionUrlWithApplicationMethodName:remoteMethodName]
                    withRequestBody:requestBody
                   withSuccessBlock:^(HttpResponse *httpResponse) {
                       
                       NSString *rawResponseData = [httpResponse getResponseData];
                       if ([[rawResponseData lowercaseString] rangeOfString:@"exception"].location != NSNotFound ||
                           [[rawResponseData lowercaseString] rangeOfString:@"invalid"].location != NSNotFound ||
                           [[rawResponseData lowercaseString] rangeOfString:@"error"].location != NSNotFound) {
                           
                           NSLog(@"appchains error: %@", rawResponseData);
                           failure([NSError errorWithDomain:@""
                                                       code:0
                                                   userInfo:@{@"Server error. Operation couldn't be completed" : @"localizationDescription"}]);
                           
                       } else {
                           NSMutableArray *resultsArray = [[NSMutableArray alloc] init];
                           NSData *responseData = [[httpResponse getResponseData] dataUsingEncoding:NSUTF8StringEncoding];
                           id decodedResponse = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:nil];
                           // NSLog(@"decodedResponse: %@", decodedResponse);
                           
                           if ([decodedResponse isKindOfClass:[NSArray class]]) {
                               NSArray *decodedResponseArray = decodedResponse;
                               
                               for (id rawResponseItem in decodedResponseArray) {
                                   
                                   if ([rawResponseItem isKindOfClass:[NSDictionary class]]) {
                                       NSDictionary *rawResponseItemDict = rawResponseItem;
                                       
                                       if ([[rawResponseItemDict allKeys] containsObject:@"Key"] && [[rawResponseItemDict allKeys] containsObject:@"Value"]) {
                                           NSString *appChainID = [rawResponseItemDict objectForKey:@"Key"];
                                           NSDictionary *responseValue = [rawResponseItemDict objectForKey:@"Value"];
                                           
                                           NSArray *resultProps;
                                           if (responseValue[@"ResultProps"] != nil) {
                                               resultProps = responseValue[@"ResultProps"];
                                           }
                                           NSDictionary *status = responseValue[@"Status"];
                                           NSString *completedSuccesfully = status[@"CompletedSuccesfully"];
                                           
                                           BOOL succeeded;
                                           if ([status[@"CompletedSuccesfully"] isKindOfClass:[NSNull class]]) {
                                               succeeded = NO;
                                           } else {
                                               succeeded = ([completedSuccesfully integerValue] == 1) ? YES : NO;
                                           }
                                           
                                           NSString *jobStatus = status[@"Status"];
                                           NSString *statusString = [jobStatus lowercaseString];
                                           
                                           Job *reportJob = [[Job alloc] init];
                                           [reportJob jobWithId:[status[@"IdJob"] integerValue]];
                                           
                                           RawReportJobResult *result = [[RawReportJobResult alloc] init];
                                           [result setSource:responseValue];
                                           [result setJobId:[reportJob getJobId]];
                                           [result setSucceded:succeeded];
                                           [result setCompleted:([statusString isEqualToString:@"completed"]) ? YES : NO];
                                           if (resultProps) [result setResultProps:resultProps];
                                           [result setStatus:jobStatus];
                                           
                                           NSDictionary *rawResultItem = @{@"appChainID": appChainID,
                                                                           @"rawReport":     result};
                                           [resultsArray addObject:rawResultItem];
                                           
                                       } else {
                                           NSLog(@"batch appChains error: %@", rawResponseData);
                                           failure([NSError errorWithDomain:@""
                                                                       code:0
                                                                   userInfo:@{@"Invalid batch appchains server response. Operation couldn't be completed" : @"localizationDescription"}]);
                                       }
                                   }
                               }
                               
                               if ([resultsArray count] > 0) {
                                   success([NSArray arrayWithArray:resultsArray]);
                                   
                               } else {
                                   NSLog(@"batch appChains error: %@", rawResponseData);
                                   failure([NSError errorWithDomain:@""
                                                               code:0
                                                           userInfo:@{@"Invalid batch appchains server response. Operation couldn't be completed" : @"localizationDescription"}]);
                               }
                           } else {
                               NSLog(@"batch appChains error: %@", rawResponseData);
                               failure([NSError errorWithDomain:@""
                                                           code:0
                                                       userInfo:@{@"Invalid batch appchains server response. Operation couldn't be completed" : @"localizationDescription"}]);
                           }
                       }
                   }
                   withFailureBlock:^(NSError *error) {
                       failure(error);
                   }];
}


/**
 * Retrieves report data from the GetAppResults endpoint
 * @param job identifier to retrieve report
 */
- (void)getAppResultsReportImplWithJob:(Job *)job
                      withSuccessBlock:(void (^)(Report *result))success
                      withFailureBlock:(void (^)(NSError *error))failure {
    NSLog(@">>>>> AppChains: getAppResultsReportImplWithJob");
    [self getAppResultsRawReportImplWithJob:job
                           withSuccessBlock:^(RawReportJobResult *rawResult) {
                               
                               if (rawResult.isCompleted) {
                                   success([self processCompletedJobWithRawReportJobResult:rawResult]);
                               }
                           }
                           withFailureBlock:^(NSError *error) {
                               failure(error);
                           }];
}


/**
 * Retrieves report data from the GetAppResults endpoint low level request
 */
- (void)getAppResultsRawReportImplWithJob:(Job *)job
                         withSuccessBlock:(void (^)(RawReportJobResult *rawResult))success
                         withFailureBlock:(void (^)(NSError *error))failure {
    NSLog(@">>>>> AppChains: getAppResultsRawReportImplWithJob");
    
    [self getRawJobResultWithJob:job
                withSuccessBlock:^(RawReportJobResult *rawResult) {
                    success(rawResult);
                }
                withFailureBlock:^(NSError *error) {
                    failure(error);
                }];
}




#pragma mark -
#pragma mark High level public API

/**
 * Requests public beacon
 * @param parameters dictionary with request parameters
 * @return success success block with result data
 * @return failure failure block with error
 */
- (void)getPublicBeaconWithChrom:(int)chrom
                         withPos:(int)pos
                      withAllele:(NSString *)allele
                withSuccessBlock:(void (^)(NSString *result))success
                withFailureBlock:(void (^)(NSError *error))failure {
    
    [self getBeaconWithMethodName:@"PublicBeacons"
                   withParameters:[self getBeaconParametersWithChrom:chrom withPos:pos withAllele:allele]
                 withSuccessBlock:^(NSString *result) {
                     success(result);
                     
                 } withFailureBlock:^(NSError *error) {
                     failure(error);
                 }];
}


/**
 * Requests sequencing beacon
 * @param parameters dictionary with request parameters
 * @return success success block with result data
 * @return failure failure block with error
 */
- (void)getSequencingBeaconWithChrom:(int)chrom
                             withPos:(int)pos
                          withAllele:(NSString *)allele
                    withSuccessBlock:(void (^)(NSString *result))success
                    withFailureBlock:(void (^) (NSError *error))failure {
    
    [self getBeaconWithMethodName:@"SequencingBeacon"
                   withParameters:[self getBeaconParametersWithChrom:chrom withPos:pos withAllele:allele]
                 withSuccessBlock:^(NSString *result) {
                     success(result);
                     
                 } withFailureBlock:^(NSError *error) {
                     failure(error);
                 }];
}


/**
 * Requests patient report
 * @param applicationMethodName report/application specific identifier (i.e. MelanomaDsAppv)
 * @param datasourceId resource with data to use for report generation
 * @return success success block with report
 * @return failure failure block with error
 */
- (void)getReportWithRemoteMethodName:(NSString *)remoteMethodName
            withApplicationMethodName:(NSString *)applicationMethodName
                     withDatasourceId:(NSString *)datasourceId
                     withSuccessBlock:(void (^)(Report *result))success
                     withFailureBlock:(void (^)(NSError *error))failure {
    
    if ([self.chainsHostname length] == 0)
        self.chainsHostname = kDefaultHostName;
    
    // Submitting job request
    [self submitReportJobWithHTTPMethod:@"POST"
                   withRemoteMethodName:remoteMethodName
              withApplicationMethodName:applicationMethodName
                       withDatasourceId:datasourceId
                       withSuccessBlock:^(Job *job) {
                           
                           if (job.getJobId > 0) {
                               [self getReportImplWithJob:job
                                         withSuccessBlock:^(Report *result) {
                                             success(result);
                                         } withFailureBlock:^(NSError *error) {
                                             failure(error);
                                         }];
                           } else {
                               NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"jobID is zero.", nil),
                                                          NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"jobID is zero.", nil),
                                                          NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"jobID is zero.", nil)};
                               NSError *error = [NSError errorWithDomain:@"jobID error"
                                                                    code:0
                                                                userInfo:userInfo];
                               failure(error);
                           }
                       }
                       withFailureBlock:^(NSError *error) {
                           failure(error);
                       }];
}

/**
 * Requests report
 * @param remoteMethodName REST endpoint name (i.e. StartApp)
 * @param requestBody jsonified request body to send to server
 * @return success success block with report
 * @return failure failure block with error
 */
- (void)getReportWithRemoteMethodName:(NSString *)remoteMethodName
                      withRequestBody:(NSString *)requestBody
                     withSuccessBlock:(void (^)(Report *result))success
                     withFailureBlock:(void (^)(NSError *error))failure {
    
    self.chainsHostname = kDefaultHostName;
    
    [self submitReportJobWithHTTPMethod:@"POST"
                   withRemoteMethodName:remoteMethodName
                        withRequestBody:requestBody
                       withSuccessBlock:^(Job *job) {
                           
                           if (job.getJobId > 0) {
                               [self getReportImplWithJob:job
                                         withSuccessBlock:^(Report *result) {
                                             success(result);
                                         } withFailureBlock:^(NSError *error) {
                                             failure(error);
                                         }];
                           } else {
                               NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"jobID is zero.", nil),
                                                          NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"jobID is zero.", nil),
                                                          NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"jobID is zero.", nil)};
                               NSError *error = [NSError errorWithDomain:@"jobID error"
                                                                    code:0
                                                                userInfo:userInfo];
                               failure(error);
                           }
                       }
                       withFailureBlock:^(NSError *error) {
                           failure(error);
                       }];
}


#pragma mark -
#pragma mark Low level public API

/**
 * Returns beacon
 * @param methodName REST endpoint name (i.e. PublicBeacons)
 * @param parameters map of request (GET) parameters (key->value) to append to the URL
 * @return success success block with result string
 * @return failure failure block with error
 */
- (void)getBeaconWithMethodName:(NSString *)methodName
                 withParameters:(NSDictionary *)parameters
               withSuccessBlock:(void (^)(NSString *result))success
               withFailureBlock:(void (^) (NSError *error))failure {
    
    [self getBeaconWithMethodName:methodName
                  withQueryString:[self getRequestStringWithParameters:parameters]
                 withSuccessBlock:^(NSString *result) {
                     success(result);
                 } withFailureBlock:^(NSError *error) {
                     failure(error);
                 }];
}


/**
 * Returns beacon
 * @param methodName REST endpoint name (i.e. PublicBeacons)
 * @param parameters query string
 * @return success success block with result string
 * @return failure failure block with error
 */
- (void)getBeaconWithMethodName:(NSString *)methodName
                withQueryString:(NSString *)queryString
               withSuccessBlock:(void (^)(NSString *result))success
               withFailureBlock:(void (^)(NSError *error))failure {
    
    self.chainsHostname = kBeaconHostName;
    
    [self httpRequestWithHTTPMethod:@"GET"
                            withURL:[self getBeaconUrlWithMethodName:methodName withQueryString:queryString]
                    withRequestBody:@""
                   withSuccessBlock:^(HttpResponse *httpResponse) {
                       success([httpResponse getResponseData]);
                   } withFailureBlock:^(NSError *error) {
                       failure(error);
                   }];
}


/**
 * Requests report in raw form it is sent from the server
 * without parsing and transforming it
 * @param remoteMethodName REST endpoint name (i.e. StartApp)
 * @param applicationMethodName report/application specific identifier (i.e. MelanomaDsAppv)
 * @param datasourceId resource with data to use for report generation
 * @return success success block with result dictionary
 * @return failure failure block with error
 */
- (void)getRawReportWithRemoteMethodName:(NSString *)remoteMethodName
               withApplicationMethodName:(NSString *)applicationMethodName
                        withDatasourceId:(NSString *)datasourceId
                        withSuccessBlock:(void (^)(NSDictionary *result))success
                        withFailureBlock:(void (^)(NSError *error))failure {
    
    self.chainsHostname = kDefaultHostName;
    
    [self submitReportJobWithHTTPMethod:@"POST"
                   withRemoteMethodName:remoteMethodName
              withApplicationMethodName:applicationMethodName
                       withDatasourceId:datasourceId
                       withSuccessBlock:^(Job *job) {
                           
                           if (job.getJobId > 0) {
                               [self getRawJobResultWithJob:job
                                           withSuccessBlock:^(RawReportJobResult *rawResult) {
                                               success([rawResult getSource]);
                                           } withFailureBlock:^(NSError *error) {
                                               failure(error);
                                           }];
                           } else {
                               NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"jobID is zero.", nil),
                                                          NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"jobID is zero.", nil),
                                                          NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"jobID is zero.", nil)};
                               NSError *error = [NSError errorWithDomain:@"jobID error"
                                                                    code:0
                                                                userInfo:userInfo];
                               failure(error);
                           }
                       } withFailureBlock:^(NSError *error) {
                           failure(error);
                       }];
}


/**
 * Requests report in raw form it is sent from the server
 * without parsing and transforming it
 * @param remoteMethodName REST endpoint name (i.e. StartApp)
 * @param requestBody jsonified request body to send to server
 * @return success success block with result dictionary
 * @return failure failure block with error
 */
- (void)getRawReportWithRemoteMethodName:(NSString *)remoteMethodName
                         withRequestBody:(NSString *)requestBody
                        withSuccessBlock:(void (^)(NSDictionary *result))success
                        withFailureBlock:(void (^)(NSError *error))failure {
    
    self.chainsHostname = kDefaultHostName;
    
    [self submitReportJobWithHTTPMethod:@"POST"
                   withRemoteMethodName:remoteMethodName
                        withRequestBody:requestBody
                       withSuccessBlock:^(Job *job) {
                           
                           if (job.getJobId > 0) {
                               [self getRawJobResultWithJob:job
                                           withSuccessBlock:^(RawReportJobResult *rawResult) {
                                               success([rawResult getSource]);
                                           } withFailureBlock:^(NSError *error) {
                                               failure(error);
                                           }];
                           } else {
                               NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"jobID is zero.", nil),
                                                          NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"jobID is zero.", nil),
                                                          NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"jobID is zero.", nil)};
                               NSError *error = [NSError errorWithDomain:@"jobID error"
                                                                    code:0
                                                                userInfo:userInfo];
                               failure(error);
                           }
                       } withFailureBlock:^(NSError *error) {
                           failure(error);
                       }];
}


#pragma mark - 
#pragma mark Internal methods
- (NSDictionary *)getBeaconParametersWithChrom:(int)chrom
                                       withPos:(int)pos
                                    withAllele:(NSString *)allele {
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:@(chrom), @"chrom",
                                @(pos), @"pos",
                                allele, @"allele", nil];
    return parameters;
}


- (NSString *)getRequestStringWithParameters:(NSDictionary *)parameters {
    NSString *queryString = @"";
    
    if (parameters) {
        queryString = @"?";
        
        for (NSString *key in parameters.allKeys) {
            NSString *param = [NSString stringWithFormat:@"%@=%@&", key, parameters[key]];
            queryString = [queryString stringByAppendingString:param];
        }
        queryString =  [queryString substringToIndex:[queryString length] - 1];
    }
    
    return queryString;
}


- (NSURL *)getBeaconUrlWithMethodName:(NSString *)methodName withQueryString:(NSString *)queryString {
    NSString *urlString = [NSString stringWithFormat:@"%@://%@:%d/%@/", kDefaultAppChainsSchema, self.chainsHostname, kDefaultAppChainsPort, methodName];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", urlString, queryString]];
    
    return url;
}


/**
 * Submits job to the API server
 * @param httpMethod HTTP method to access API server
 * @param remoteMethodName REST endpoint name (i.e. StartApp)
 * @param applicationMethodName report/application specific identifier (i.e. MelanomaDsAppv)
 * @param datasourceId resource with data to use for report generation
 * @return success success block with job
 * @return failure failure block with error
 */
- (void)submitReportJobWithHTTPMethod:(NSString *)httpMethod
                 withRemoteMethodName:(NSString *)remoteMethodName
            withApplicationMethodName:(NSString *)applicationMethodName
                     withDatasourceId:(NSString *)datasourceId
                     withSuccessBlock:(void (^)(Job *job))success
                     withFailureBlock:(void (^)(NSError *error))failure {
    
    [self submitReportJobWithHTTPMethod:httpMethod
                   withRemoteMethodName:remoteMethodName
                        withRequestBody:[self buildReportRequestBodyWithApplicationMethodName:applicationMethodName withDataSourceID:datasourceId]
                       withSuccessBlock:^(Job *job) {
                           success(job);
                       }
                       withFailureBlock:^(NSError *error) {
                           failure(error);
                       }];
}

/**
 * Submits job to the API server
 * @param httpMethod httpMethod HTTP method to access API server
 * @param remoteMethodName REST endpoint name (i.e. StartApp)
 * @param requestBody jsonified request body to send to server
 * @return success success block with job
 * @return failure failure block with error
 */
- (void)submitReportJobWithHTTPMethod:(NSString *)httpMethod
                 withRemoteMethodName:(NSString *)remoteMethodName
                      withRequestBody:(NSString *)requestBody
                     withSuccessBlock:(void (^)(Job *job))success
                     withFailureBlock:(void (^)(NSError *error))failure {
    
    [self httpRequestWithHTTPMethod:httpMethod
                            withURL:[self getJobSubmissionUrlWithApplicationMethodName:remoteMethodName]
                    withRequestBody:requestBody
                   withSuccessBlock:^(HttpResponse *httpResponse) {
                       
                       NSData *data = [httpResponse.getResponseData dataUsingEncoding:NSUTF8StringEncoding];
                       NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                       
                       Job *reportJob = [[Job alloc] init];
                       [reportJob jobWithId:[dict[@"jobId"] integerValue]];
                       
                       success(reportJob);
                   }
                   withFailureBlock:^(NSError *error) {
                       failure(error);
                   }];
}

/**
 * Executes HTTP request of the specified type
 * @param method HTTP method (GET/POST)
 * @param url URL to send request to
 * @param body request body (applicable for POST)
 * @return success success block with response
 * @return failure failure block with error
 */
- (void)httpRequestWithHTTPMethod:(NSString *)httpMethod
                          withURL:(NSURL *)url
                  withRequestBody:(NSString *)requestBody
                 withSuccessBlock:(void (^)(HttpResponse *httpResponse))success
                 withFailureBlock:(void (^)(NSError *error))failure {
    NSLog(@">>>>> AppChains: httpRequestWithHTTPMethod");
    if ([[httpMethod uppercaseString] isEqualToString:@"GET"]) {
        
        [self openHTTPGETSessionWithURL:url withSuccessBlock:^(NSData *data, NSURLResponse *response) {
            
            HttpResponse *resultResponse = [[HttpResponse alloc] init];
            
            NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)response;
            NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            [resultResponse httpResponseWithResponseCode:urlResponse.statusCode withResponseData:dataString];
            
            success(resultResponse);
            
        } withFailureBlock:^(NSError *error) {
            failure(error);
        }];
        
    } else if ([[httpMethod uppercaseString] isEqualToString:@"POST"]) {
        
        [self openHTTPPOSTSessionWithURL:url withBody:requestBody withSuccessBlock:^(NSData *data, NSURLResponse *response) {
            
            HttpResponse *resultResponse = [[HttpResponse alloc] init];
            
            NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)response;
            NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            [resultResponse httpResponseWithResponseCode:urlResponse.statusCode withResponseData:dataString];
            
            success(resultResponse);
            
        } withFailureBlock:^(NSError *error) {
            failure(error);
        }];
        
    } else {
        NSLog(@"HTTP method %@ is not supported", httpMethod);
        failure(nil);
    }
    
}


- (void)openHTTPGETSessionWithURL:(NSURL *)url
                 withSuccessBlock:(void (^)(NSData *data, NSURLResponse *response))success
                 withFailureBlock:(void (^) (NSError *error))failure {
    NSLog(@">>>>> AppChains: openHTTPGETSessionWithURL");
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:defaultConfigObject delegate:nil delegateQueue: [NSOperationQueue mainQueue]];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest addValue:[NSString stringWithFormat:@"Bearer %@", self.token] forHTTPHeaderField:@"Authorization"];
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest setTimeoutInterval:20];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    
                                                    if (!error) {
                                                        success (data, response);
                                                        
                                                    } else {
                                                        failure(error);
                                                    }
                                                }];
    [dataTask resume];
    
}

- (void)openHTTPPOSTSessionWithURL:(NSURL *)url
                          withBody:(NSString *)body
                  withSuccessBlock:(void (^)(NSData *data, NSURLResponse *response))success
                  withFailureBlock:(void (^)(NSError *error))failure {
    NSLog(@">>>>> AppChains: openHTTPPOSTSessionWithURL");
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    NSData *requestBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    [urlRequest setHTTPBody:requestBody];
    [urlRequest addValue:[NSString stringWithFormat:@"Bearer %@", self.token] forHTTPHeaderField:@"Authorization"];
    [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest addValue:[NSString stringWithFormat:@"%lu", (unsigned long)[body length]] forHTTPHeaderField:@"Content-Length"];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setTimeoutInterval:20];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    
                                                    if (!error) {
                                                        success(data, response);
                                                        
                                                    } else {
                                                        failure(error);
                                                    }
                                                }];
    [dataTask resume];
}


//==========================================================================================================
/**
 * Builds request body used for report generation
 * @param applicationMethodName
 * @param datasourceId
 * @return NSString report request body
 */
- (NSString *)buildReportRequestBodyWithApplicationMethodName:(NSString *)appMethodName withDataSourceID:(NSString *)dataSourceID {
    
    NSDictionary *parameters = @{@"Name": @"dataSourceId",
                                 @"Value": dataSourceID};
    
    NSDictionary *result = @{@"AppCode": appMethodName,
                             @"Pars": @[parameters]};
    
    NSError *jsonError = nil;
    NSData  *dataJSON = [NSJSONSerialization dataWithJSONObject:result options:NSJSONWritingPrettyPrinted error:&jsonError];
    if (jsonError) {
        NSLog(@"ERROR: %@", jsonError.localizedDescription);
    }
    
    NSString *resultString = [[NSString alloc] initWithData:dataJSON encoding:NSUTF8StringEncoding];
    return resultString;
}


/**
 * Builds request body used for batch report generation
 * array of params. each param is a array (2 items: first object applicationMethodName, last object datasourceId)
 */
- (NSString *)buildBatchReportRequestBodyWithParametersArray:(NSArray *)appchainsParamsArray {
    NSMutableArray *paramsArray = [[NSMutableArray alloc] init];
    
    for (NSArray *appchainParams in appchainsParamsArray) {
        
        NSDictionary *parameters = @{@"Name": @"dataSourceId",
                                     @"Value": [appchainParams lastObject]};
        
        NSDictionary *result = @{@"AppCode": [appchainParams firstObject], //appMethodName
                                 @"Pars": @[parameters]};
        
        [paramsArray addObject:result];
    }
    
    NSDictionary *batchResult = @{@"Pars": paramsArray};
    
    NSError *jsonError = nil;
    NSData  *dataJSON = [NSJSONSerialization dataWithJSONObject:batchResult options:NSJSONWritingPrettyPrinted error:&jsonError];
    if (jsonError) {
        NSLog(@"ERROR: %@", jsonError.localizedDescription);
    }
    
    NSString *resultString = [[NSString alloc] initWithData:dataJSON encoding:NSUTF8StringEncoding];
    return resultString;
}


/**
 * Constructs URL for job submission
 * @param applicationMethodName report/application specific identifier (i.e. MelanomaDsAppv)
 * @return NSURL url
 */
- (NSURL *)getJobSubmissionUrlWithApplicationMethodName:(NSString *)applicationMethodName {
    return [self getBaseAppChainsUrlWithContext:applicationMethodName];
}


/**
 * Constructs URL for getting job results
 * @param jobId job identifier
 * @return NSURL
 */
- (NSURL *)getJobResultsUrlWithJobId:(NSInteger)jobId {
    
    NSString *appMethodNameString = [NSString stringWithFormat:@"GetAppResults?idJob=%ld", (long)jobId];
    return [self getBaseAppChainsUrlWithContext:appMethodNameString];
}


/**
 * Constructs base URL for accessing sequencing backend
 * @param jobId job identifier
 * @return NSURL
 */
- (NSURL *)getBaseAppChainsUrlWithContext:(NSString*)context {
    
    NSString *urlString = [NSString stringWithFormat:@"%@://%@:%d/%@/%@", kDefaultAppChainsSchema,
                           self.chainsHostname, kDefaultAppChainsPort, kDefaultApiVersion, context];
    
    return [NSURL URLWithString:urlString];
}


// ===================================================================================================
/**
 * Retrieves report data from the API server
 * @param job identifier to retrieve report
 * @return success success block with report
 * @return failure failure block with error
 */
- (void)getReportImplWithJob:(Job *)job
            withSuccessBlock:(void (^)(Report *result))success
            withFailureBlock:(void (^)(NSError *error))failure {
    
    [self getRawJobResultWithJob:job
                withSuccessBlock:^(RawReportJobResult *rawResult) {
                    
                    if (rawResult.isCompleted) {
                        
                        success([self processCompletedJobWithRawReportJobResult:rawResult]);
                    }
                    
                } withFailureBlock:^(NSError *error) {
                    failure(error);
                }];
}

/**
 * Retrieves raw job results data
 * @param job job identifier
 * @return success success block with raw report job result
 * @return failure failure block with error
 */
- (void)getRawJobResultWithJob:(Job *)job
              withSuccessBlock:(void (^)(RawReportJobResult *rawResult))success
              withFailureBlock:(void (^)(NSError *error))failure {
    NSLog(@">>>>> AppChains: getRawJobResultWithJob");
    NSURL *url = [self getJobResultsUrlWithJobId:[job getJobId]];
    
    [self httpRequestWithHTTPMethod:@"GET"
                            withURL:url
                    withRequestBody:@""
                   withSuccessBlock:^(HttpResponse *httpResponse) {
                       
                       NSString *rawResponseData = [httpResponse getResponseData];
                       if ([[rawResponseData lowercaseString] rangeOfString:@"exception"].location != NSNotFound ||
                           [[rawResponseData lowercaseString] rangeOfString:@"invalid"].location != NSNotFound ||
                           [[rawResponseData lowercaseString] rangeOfString:@"error"].location != NSNotFound) {
                           
                           NSLog(@"appchains error: %@", rawResponseData);
                           failure([NSError errorWithDomain:@""
                                                       code:0
                                                   userInfo:@{@"Server error. Operation couldn't be completed" : @"localizationDescription"}]);
                           
                       } else {
                           NSData *responseData = [[httpResponse getResponseData] dataUsingEncoding:NSUTF8StringEncoding];
                           NSDictionary *decodedResponse = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:nil];
                           // NSLog(@"decodedResponse: %@", decodedResponse);
                           
                           NSArray *resultProps;
                           if (decodedResponse[@"ResultProps"] != nil) {
                               resultProps = decodedResponse[@"ResultProps"];
                           }
                           NSDictionary *status = decodedResponse[@"Status"];
                           
                           BOOL succeeded;
                           if ([status[@"CompletedSuccesfully"] isKindOfClass:[NSNull class]]) {
                               succeeded = NO;
                           } else {
                               succeeded = YES; // status[@"CompletedSuccesfully"]
                           }
                           
                           NSString *jobStatus = status[@"Status"];
                           NSString *statusString = [jobStatus lowercaseString];
                           
                           
                           if ([statusString isEqualToString:@"completed"]) { // || [statusString isEqualToString:@"failed"]
                               RawReportJobResult *result = [[RawReportJobResult alloc] init];
                               [result setSource:decodedResponse];
                               [result setJobId:[job getJobId]];
                               [result setSucceded:succeeded];
                               [result setCompleted:YES];
                               [result setResultProps:resultProps];
                               [result setStatus:jobStatus];
                               success(result);
                               
                           } else {
                               if (checkCompletionCount <= kDefaultTimeout) {
                                   dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kDefaultReportRetryTimeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                       NSLog(@">> check job completion {%02lu}, %@", (unsigned long)checkCompletionCount, statusString);
                                       checkCompletionCount++;
                                       [self getRawJobResultWithJob:job withSuccessBlock:success withFailureBlock:failure];
                                   });
                               } else {
                                      failure([NSError errorWithDomain:@""
                                                                  code:0
                                                              userInfo:@{@"Operation couldn't be completed" : @"localizationDescription"}]);
                               }
                           }
                       }
                   } withFailureBlock:^(NSError *error) {
                       failure(error);
                   }];
}


/**
 * Handles raw report result by transforming it to user friendly state
 * @param name="rawResult"
 * @return Report
 */
- (Report *)processCompletedJobWithRawReportJobResult:(RawReportJobResult *)rawResult {
    NSMutableArray *results = [NSMutableArray new];
    
    for (NSDictionary *resultProp in rawResult.getResultProps) {
        
        id type = resultProp[@"Type"];
        id value = resultProp[@"Value"];
        id name = resultProp[@"Name"];
        
        if (type == nil || value == nil || name == nil)
            continue;
        
        NSString *resultPropType = [[NSString stringWithFormat:@"%@", type] lowercaseString];
        NSString *resultPropValue = [[NSString stringWithFormat:@"%@", value] lowercaseString];
        NSString *resultPropName = [NSString stringWithFormat:@"%@", name];
        
        if ([resultPropType isEqualToString:@"plaintext"]) {
            
            Result *textResult = [[Result alloc] init];
            
            TextResultValue *textResultValue = [[TextResultValue alloc] init];
            [textResultValue textResultValueWithData:resultPropValue];
            
            [textResult resultWithName:resultPropName withResultType:kResultTypeText withResultValue:textResultValue];
            
            [results addObject:textResult];
            
        } else if ([resultPropType isEqualToString:@"pdf"]) {
            
            Result *fileResult = [[Result alloc] init];
            
            NSString *filename = [NSString stringWithFormat:@"report_%ld.%@", (long)rawResult.getJobId, resultPropType];
            NSURL *reportFileUrl = [self getReportFileUrlWithFileId:[resultPropValue integerValue]];
            
            FileResultValue *fileResultValue = [[FileResultValue alloc] init];
            [fileResultValue fileResultValueWithChains:self withName:filename withExtension:resultPropType withURL:reportFileUrl];
            
            [fileResult resultWithName:resultPropName withResultType:kResultTypeFile withResultValue:(ResultValue *)fileResultValue];
            
            [results addObject:fileResult];
        }
    }
    
    Report *finalResult = [[Report alloc] init];
    [finalResult setSucceded:rawResult.isSucceeded];
    [finalResult setResults:[NSArray arrayWithArray:results]];
    
    return finalResult;
}


/**
 * Constructs URL for getting report file
 * @param fileId file identifier
 * @return URL
 */
- (NSURL *)getReportFileUrlWithFileId:(NSInteger)fileId {
    NSString *appMethodNameString = [NSString stringWithFormat:@"GetReportFile?id=%ld", (long)fileId];
    return [self getBaseAppChainsUrlWithContext:appMethodNameString];
}

@end




#pragma mark - Job
/**
 * Class that represents generic job identifier
 */
@interface Job ()

@property (nonatomic, assign) NSInteger jobID;

@end

@implementation Job

- (void)jobWithId:(NSInteger)jobId {
    _jobID = jobId;
}

- (NSInteger)getJobId {
    return self.jobID;
}

@end




#pragma mark - ResultValue

@interface ResultValue ()

@property (nonatomic, assign) ResultType type;

@end

@implementation ResultValue

- (void)resultValueWithResultType:(ResultType)type {
    _type = type;
}

- (ResultType)getType {
    return self.type;
}
@end




#pragma mark - TextResultValue
/**
 * Class that represents result entity if plain text string
 */
@interface TextResultValue ()

@property (nonatomic, strong) NSString *data;

@end

@implementation TextResultValue

- (void)textResultValueWithData:(NSString *)data {
    self.type = kResultTypeText;
    _data = data;
}

- (NSString *)getData {
    return self.data;
}

@end




#pragma mark - FileResultValue
/**
 * Class that represents result entity if it's file
 */
@interface FileResultValue () <NSStreamDelegate>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *extension;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) AppChains *chains;

@end

@implementation FileResultValue

- (void)fileResultValueWithChains:(AppChains *)chains withName:(NSString *)name withExtension:(NSString *)extension withURL:(NSURL *)url {
    _chains = chains;
    self.type = kResultTypeFile;
    _name = name;
    _extension = extension;
    _url = url;
}

- (NSString *)getName {
    return self.name;
}

- (NSURL *)getURL {
    return self.url;
}

- (NSString *)getExtension {
    return self.extension;
}

- (void)getStreamWithSuccessBlock:(void (^)(NSData *data))success
                 withFailureBlock:(void (^)(NSError *error))failure {
    
    [self.chains openHTTPGETSessionWithURL:[self getURL]
                          withSuccessBlock:^(NSData *data, NSURLResponse *response) {
                              success(data);
                          } withFailureBlock:^(NSError *error) {
                              failure(error);
                          }];
}

- (void)saveAsWithFullPathWithName:(NSString *)fullPathWithName
{
    [self getStreamWithSuccessBlock:^(NSData *data) {
        NSLog(@"Success");
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        path = [path stringByAppendingString:fullPathWithName];
        
        [data writeToFile:path atomically:YES];
        
    } withFailureBlock:^(NSError *error) {
        NSLog(@"Error: %@", error.localizedDescription);
    }];
}

- (void)saveToLocation:(NSString *)location {
    
    [self saveAsWithFullPathWithName:[NSString stringWithFormat:@"%@/%@", location, [self getName]]];
}

@end




#pragma mark - Result
/**
 * Class that represents single report result entity
 */
@interface Result ()

@property (nonatomic, strong) ResultValue *value;
@property (nonatomic, strong) NSString *name;

@end

@implementation Result

- (void)resultWithName:(NSString *)name withResultType:(ResultType)resultType withResultValue:(ResultValue *)resultValue {
    _name = name;
    _value = resultValue;
}

- (ResultValue *)getValue {
    return self.value;
}

- (NSString *)getName {
    return self.name;
}

@end




#pragma mark - Report
/**
 * Class that represents report available to
 * the end client
 */
@interface Report ()

@property (nonatomic, assign) BOOL succeeded;
@property (nonatomic, strong) NSArray *results;

@end

@implementation Report

- (BOOL)isSucceeded {
    return self.succeeded;
}

- (void)setSucceded:(BOOL)succeded {
    _succeeded = succeded;
}

- (NSArray *)getResults {
    return self.results;
}

- (void)setResults:(NSArray *)results {
    _results = results;
}

@end




#pragma mark - RawReportJobResult
/**
 * Class that represents unstructured job response
 */
@interface RawReportJobResult ()

@property (nonatomic, assign) NSInteger jobId;
@property (nonatomic, assign) BOOL succeeded;
@property (nonatomic, assign) BOOL completed;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSDictionary *source;
@property (nonatomic, strong) NSArray *resultProps;

@end

@implementation RawReportJobResult

- (NSArray *)getResultProps {
    return self.resultProps;
}

- (void)setResultProps:(NSArray *)resultProps {
    _resultProps = resultProps;
}

- (NSString *)getStatus {
    return self.status;
}

- (void)setStatus:(NSString *)status {
    _status = status;
}

- (BOOL)isCompleted {
    return self.completed;
}

- (void)setCompleted:(BOOL)completed {
    _completed = completed;
}

- (BOOL)isSucceeded {
    return self.succeeded;
}

- (void)setSucceded:(BOOL)succeded {
    _succeeded = succeded;
}

- (NSInteger)getJobId {
    return self.jobId;
}

- (void)setJobId:(NSInteger)jobId {
    _jobId = jobId;
}

- (NSDictionary *)getSource {
    return self.source;
}

- (void)setSource:(NSDictionary *)source {
    _source = source;
}

@end




#pragma mark - HttpResponse
/**
 * Class that represents generic HTTP response
 */

@interface HttpResponse ()

@property (nonatomic, assign) NSInteger responseCode;
@property (nonatomic, strong) NSString *responseData;

@end

@implementation HttpResponse

- (void)httpResponseWithResponseCode:(NSInteger)responseCode withResponseData:(NSString *)responseData {
    _responseCode = responseCode;
    _responseData = responseData;
}

- (NSInteger)getResponseCode {
    return self.responseCode;
}

- (void)setResponseCode:(NSInteger)responseCode {
    _responseCode = responseCode;
}

- (NSString *)getResponseData {
    return self.responseData;
}

- (void)setResponseData:(NSString *)responseData {
    _responseData = responseData;
}

@end

