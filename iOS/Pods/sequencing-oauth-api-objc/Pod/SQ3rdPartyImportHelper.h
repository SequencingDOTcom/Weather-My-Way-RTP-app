//
//  SQ3rdPartyImportHelper.h
//  Copyright © 2017 Sequencing.com. All rights reserved
//


#import <Foundation/Foundation.h>



@protocol SQ3rdPartyImport23andMeDelegate <NSObject>

- (void)import23andMe_ImportStarted;
- (void)import23andMe_InvalidLoginPassword;
- (void)import23andMe_SecurityOriginQuestion:(NSString *)originQuestion adjustedQuestion:(NSString *)adjustedQuestion sessionId:(NSString *)sessionId;
- (void)import23andMe_InternalServerError;
- (void)import23andMe_InvalidAnswer;

@end


@protocol SQ3rdPartyImportAncestryDelegate <NSObject>

- (void)importAncestry_EmailSentWithText:(NSString *)text sessionId:(NSString *)sessionId;
- (void)importAncestry_InvalidLoginPassword;
- (void)importAncestry_InternalServerError;
- (void)importAncestry_ImportStarted;
- (void)importAncestry_InvalidURL;

@end




@interface SQ3rdPartyImportHelper : NSObject

@property (nonatomic) id<SQ3rdPartyImport23andMeDelegate>  me23Delegate;
@property (nonatomic) id<SQ3rdPartyImportAncestryDelegate> ancestryDelegate;


+ (instancetype)sharedInstance;

- (void)importRequest23andMeWithLogin:(NSString *)login
                             password:(NSString *)password
                                token:(NSString *)token;

- (void)importRequest23andMeWithAnswer:(NSString *)answer
                      securityQuestion:(NSString *)question
                             sessionId:(NSString *)sessionId
                                 token:(NSString *)token;


- (void)importRequestAncestryWithLogin:(NSString *)login
                              password:(NSString *)password
                                 token:(NSString *)token;

- (void)importRequestAncestryWithURL:(NSString *)url
                           sessionId:(NSString *)sessionId
                               token:(NSString *)token;

@end
