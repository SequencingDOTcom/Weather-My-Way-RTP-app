//
//  GeneticForecastCSV.m
//  Copyright © 2017 Sequencing. All rights reserved.
//


#import "GeneticForecastCSV.h"
#import "CSVParser.h"

#define csvFileName @"recs.csv"
#define kAbsentGeneticForecastMessage @"An error occurred while processing your genetically tailored forecast. Please reload this screen or check back later."




@interface GeneticForecastCSV ()

@property (strong, nonatomic) NSMutableArray *csvFileParsed;

@end



@implementation GeneticForecastCSV

+ (instancetype)sharedInstance {
    static GeneticForecastCSV *instance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [[GeneticForecastCSV alloc] init];
        instance.csvFileParsed = [self parseCSVFile];
    });
    
    return instance;
}



- (void)requestForGeneticForecastsArrayBasedOnAccessToken:(NSString *)accessToken
                                            vitaminDValue:(NSString *)vitaminDValue
                                        melanomaRiskValue:(NSString *)melanomaRiskValue
                                     forecastRequestArray:(NSArray *)forecastRequestArray
                                           withCompletion:(void (^)(NSArray *geneticForecastsArray))completion {
    
    NSLog(@"starting request for GeneticForecastsArray - CSV based");
    NSMutableArray *preparedGeneticForecastsArray = [[NSMutableArray alloc] init];
    
    for (NSDictionary *day in forecastRequestArray) {
        NSString *alertCode   = [day objectForKey:@"alertCode"];
        NSString *date        = [day objectForKey:@"date"];
        NSString *weatherType = [day objectForKey:@"weather"];
        NSString *geneticForecastFor1Day;
        
        if (![alertCode containsString:@"--"])
            geneticForecastFor1Day = [self pullGeneticForecastBasedOnWeather:alertCode
                                                               vitaminDValue:vitaminDValue
                                                                   riskValue:melanomaRiskValue];
        else
            geneticForecastFor1Day = [self pullGeneticForecastBasedOnWeather:weatherType
                                                               vitaminDValue:vitaminDValue
                                                                   riskValue:melanomaRiskValue];
        
        if (!geneticForecastFor1Day || [geneticForecastFor1Day length] == 0)
            geneticForecastFor1Day = kAbsentGeneticForecastMessage;
        
        NSDictionary *newDay = @{@"date"       : date,
                                 @"gtForecast" : geneticForecastFor1Day};
        
        [preparedGeneticForecastsArray addObject:newDay];
    }
    
    completion(preparedGeneticForecastsArray);
}




#pragma mark - Pull genetic forecast from csv file

- (NSString *)pullGeneticForecastBasedOnWeather:(NSString *)weatherType vitaminDValue:(NSString *)vitaminDValue riskValue:(NSString *)riskValue {
    
    NSString *geneticForecast;
    NSNumber *rowIndex;
    NSNumber *columnIndexInRow;
    
    if ([weatherType length] != 0 && [vitaminDValue length] != 0 && [riskValue length] != 0) {
        if (_csvFileParsed) {
            
            rowIndex = [self indexOfRowInCSV:_csvFileParsed equalToWeatherType:weatherType];
            
            columnIndexInRow = [self columnIndexInRowInCSV:_csvFileParsed
                                          equalToRiskValue:riskValue
                                          andVitaminDValue:vitaminDValue];
            
            if (rowIndex && columnIndexInRow) {
                geneticForecast = [self geneticForecastValueInCSV:_csvFileParsed
                                                       byRowIndex:rowIndex
                                                   andColumnIndex:columnIndexInRow];
            }
        }
    }
    return geneticForecast;
}



- (NSNumber *)indexOfRowInCSV:(NSMutableArray *)csvFile equalToWeatherType:(NSString *)weatherType {
    NSNumber *index = nil;
    if ([weatherType length] != 0) {
        
        // first cycle among main rows in CSV
        for (int rowIndex = 0; rowIndex < [csvFile count]; rowIndex++) {
            
            NSMutableArray *csvRowArray = [csvFile objectAtIndex:rowIndex];
            NSString *weatherIdentifier = [csvRowArray objectAtIndex:0];
            
            if ([weatherIdentifier length] != 0) {
                
                if ([[weatherType lowercaseString] isEqualToString:[weatherIdentifier lowercaseString]]) {
                    index = [NSNumber numberWithInt:rowIndex];
                    break;
                }
            }
        }
    } else {
        return index;
    }
    return index;
}


- (NSNumber *)columnIndexInRowInCSV:(NSMutableArray *)csvFile equalToRiskValue:(NSString *)riskValue andVitaminDValue:(NSString *)vitaminDValue  {
    // NSLog(@"GeneticForecastHelper: columnIndexInRowInCSV");
    NSNumber *index = nil;
    NSString *riskVitaminType = [NSString stringWithFormat:@"%@-%@", [riskValue lowercaseString], [vitaminDValue lowercaseString]];
    
    if ([vitaminDValue length] != 0 && [riskValue length] != 0) {
        
        NSMutableArray *csvTitleRowArray = [csvFile objectAtIndex:0];
        
        // second cycle among columns in title row in CSV
        for (int columnIndex = 0; columnIndex < [csvTitleRowArray count]; columnIndex++) {
            
            id riskVitaminRawValue = [csvTitleRowArray objectAtIndex:columnIndex];
            NSString *riskVitaminIdentifier = [NSString stringWithFormat:@"%@", riskVitaminRawValue];
            
            if ([riskVitaminIdentifier length] != 0) {
                
                if ([riskVitaminType isEqualToString:[riskVitaminIdentifier lowercaseString]]) {
                    index = [NSNumber numberWithInt:columnIndex];
                    break;
                }
            }
        }
        
    } else {
        return index;
    }
    return index;
}


- (NSString *)geneticForecastValueInCSV:(NSMutableArray *)csvFile byRowIndex:(NSNumber *)rowIndex andColumnIndex:(NSNumber *)columnIndex  {
    // NSLog(@"GeneticForecastHelper: geneticForecastValueInCSV");
    
    NSString *geneticForecast;
    
    NSMutableArray *row = [csvFile objectAtIndex:[rowIndex integerValue]];
    
    id column = [row objectAtIndex:[columnIndex integerValue]];
    NSString *forecast = [NSString stringWithFormat:@"%@", column];
    
    if ([forecast length] != 0) {
        geneticForecast = forecast;
    }
    return geneticForecast;
}




#pragma mark - CSV parser helper

+ (NSMutableArray *)parseCSVFile {
    
    NSString    *csvFilePath = [[NSBundle mainBundle] pathForResource:csvFileName ofType:nil];
    NSError     *error;
    NSString    *csvFileContents = [NSString stringWithContentsOfFile:csvFilePath
                                                             encoding:NSUTF8StringEncoding
                                                                error:&error];
    NSMutableArray *parsedCSV;
    
    if (csvFileContents && !error) {
        
        parsedCSV = [CSVParser loadAndParseCSVFileBasedOnStringData:csvFileContents hasHeaderFields:NO];
        
        if (parsedCSV) {
            NSMutableArray *parsedCSVNoQuotation = [CSVParser removeQuotationMarksFromParsedCSVFile:parsedCSV];
            
            if (parsedCSVNoQuotation)
                parsedCSV = parsedCSVNoQuotation;
            return parsedCSV;
        }
    }
    return parsedCSV;
}


@end
