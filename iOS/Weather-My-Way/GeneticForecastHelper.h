//
//  GeneticForecastHelper.h
//  Copyright © 2016 Sequencing. All rights reserved.
//


#import <Foundation/Foundation.h>


#define kAbsentGeneticForecastMessage @"An error occurred while processing your genetically tailored forecast. Please reload this screen or check back later."


@interface GeneticForecastHelper : NSObject

// genetics parameters related to selected file
@property (strong, nonatomic) NSString *vitaminDValue;
@property (strong, nonatomic) NSString *melanomaRiskValue;


// designated initializer
+ (instancetype)sharedInstance;

- (void)requestForGeneticDataForFileID:(NSString *)fileID
                           accessToken:(NSString *)accessToken
                        withCompletion:(void (^)(BOOL success))completion;

- (void)requestForGeneticForecastsWithToken:(NSString *)accessToken
                             withCompletion:(void (^)(NSArray *geneticForecastsArray))completion;

    
@end
