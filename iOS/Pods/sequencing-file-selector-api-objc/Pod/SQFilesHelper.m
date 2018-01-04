//
//  SQFilesHelper.m
//  Copyright © 2015-2016 Sequencing.com. All rights reserved
//

#import "SQFilesHelper.h"
#import "SQSectionInfo.h"
#import "SQFilesContainer.h"


// fileCategory name for UI
static NSString *const SAMPLE_ALL_FILES_CATEGORY_NAME       = @"All";
static NSString *const SAMPLE_MEN_FILES_CATEGORY_NAME       = @"Men";
static NSString *const SAMPLE_WOMEN_FILES_CATEGORY_NAME     = @"Women";

static NSString *const UPLOADED_FILES_CATEGORY_NAME     = @"Uploaded";
static NSString *const SHARED_FILES_CATEGORY_NAME       = @"Shared";
static NSString *const APPLICATION_FILES_CATEGORY_NAME  = @"From Apps";
static NSString *const ALTRUIST_FILES_CATEGORY_NAME     = @"Altruist";

// fileCategory name in response
static NSString *const SAMPLE_FILES_CATEGORY_TAG        = @"Community";
static NSString *const UPLOADED_FILES_CATEGORY_TAG      = @"Uploaded";
static NSString *const SHARED_FILES_CATEGORY_TAG        = @"SharedToMe";
static NSString *const APPLICATION_FILES_CATEGORY_TAG   = @"FromApps";
static NSString *const ALTRUIST_FILES_CATEGORY_TAG      = @"AllWithAltruist";


@implementation SQFilesHelper


#pragma mark -
#pragma mark Parse Files

+ (void)parseFilesMainArray:(NSArray *)filesMainArray
                withHandler:(FilesCallback)callback {
    
    // For each category/section, set up a corresponding SectionInfo object to contain the category name, list of files and height for each row.
    NSMutableArray *sampleInfoArray = [[NSMutableArray alloc] init];    // array for section info for sample files
    NSMutableArray *myInfoArray     = [[NSMutableArray alloc] init];    // array for section info for my files
    
    SQSectionInfo *sectionSampleAll     = [[SQSectionInfo alloc] initWithName:SAMPLE_ALL_FILES_CATEGORY_NAME];
    SQSectionInfo *sectionSampleMen     = [[SQSectionInfo alloc] initWithName:SAMPLE_MEN_FILES_CATEGORY_NAME];
    SQSectionInfo *sectionSampleWomen   = [[SQSectionInfo alloc] initWithName:SAMPLE_WOMEN_FILES_CATEGORY_NAME];
    
    SQSectionInfo *sectionUploaded      = [[SQSectionInfo alloc] initWithName:UPLOADED_FILES_CATEGORY_NAME];
    SQSectionInfo *sectionShared        = [[SQSectionInfo alloc] initWithName:SHARED_FILES_CATEGORY_NAME];
    SQSectionInfo *sectionFromApps      = [[SQSectionInfo alloc] initWithName:APPLICATION_FILES_CATEGORY_NAME];
    SQSectionInfo *sectionAltruist      = [[SQSectionInfo alloc] initWithName:ALTRUIST_FILES_CATEGORY_NAME];
    
    NSArray *categories = @[SAMPLE_FILES_CATEGORY_TAG,
                            UPLOADED_FILES_CATEGORY_TAG,
                            SHARED_FILES_CATEGORY_TAG,
                            APPLICATION_FILES_CATEGORY_TAG,
                            ALTRUIST_FILES_CATEGORY_TAG];
    
    for (int i = 0; i < [filesMainArray count]; i++) {
        
        NSDictionary *tempFile = [filesMainArray objectAtIndex:i];
        id tempFileID = tempFile;
        NSString *tempCategoryName = [tempFile objectForKey:@"FileCategory"];
        int category = (int)[categories indexOfObject:tempCategoryName];
        
        switch (category) {
            case 0: {   // Sample Files Category
                NSArray *tempFileAllKeys = [tempFile allKeys];
                if (tempFileAllKeys != nil) {
                    if ([tempFileAllKeys containsObject:@"Sex"]) {
                        
                        NSString *tempFileSex = [tempFile objectForKey:@"Sex"];
                        id tempFileSexID = tempFileSex;
                        
                        if (tempFileSex != nil && tempFileSexID != [NSNull null] &&
                            tempFile != nil && tempFileID != [NSNull null]) {
                            
                            [self addFile:tempFile intoSection:sectionSampleAll];
                            if ([tempFileSex containsString:@"Male"]) {
                                [self addFile:tempFile intoSection:sectionSampleMen];
                                
                            } else {
                                [self addFile:tempFile intoSection:sectionSampleWomen];
                            }
                        }
                    }
                }
            } break;
                
            case 1: {   // Uploaded Files Category
                [self addFile:tempFile intoSection:sectionUploaded];
            } break;
                
            case 2: {   // Shared Files Category
                [self addFile:tempFile intoSection:sectionShared];
            } break;
                
            case 3: {   // From Apps Files Category
                [self addFile:tempFile intoSection:sectionFromApps];
            } break;
                
            case 4: {   // Altruist Files Category
                [self addFile:tempFile intoSection:sectionAltruist];
            } break;
                
            default:
                break;
        }   // end of switch
    }   // end of for cycle
    
    // saving sections/categories to main Sample Array
    if ([sectionSampleAll.filesArray count] > 0) {
        [sampleInfoArray addObject:sectionSampleAll];
    }
    if ([sectionSampleMen.filesArray count] > 0) {
        [sampleInfoArray addObject:sectionSampleMen];
    }
    if ([sectionSampleWomen.filesArray count] > 0) {
        [sampleInfoArray addObject:sectionSampleWomen];
    }
    
    // saving sections/categories to main My Array
    if ([sectionUploaded.filesArray count] > 0) {
        [myInfoArray addObject:sectionUploaded];
    }
    if ([sectionShared.filesArray count] > 0) {
        [myInfoArray addObject:sectionShared];
    }
    if ([sectionFromApps.filesArray count] > 0) {
        [myInfoArray addObject:sectionFromApps];
    }
    if ([sectionAltruist.filesArray count] > 0) {
        [myInfoArray addObject:sectionAltruist];
    }
    
    // return back the result
    callback(myInfoArray, sampleInfoArray);
}


#pragma mark -
#pragma mark Add file into section

+ (void)addFile:(NSDictionary *)file intoSection:(SQSectionInfo *)section {
    CGFloat tempHeight = 35.f;
    
    if ([section.sectionName containsString:@"Sample"] || [section.sectionName containsString:@"All"] || [section.sectionName containsString:@"Men"] || [section.sectionName containsString:@"Women"]) {
        
        //calculate height for sample file
        NSAttributedString *tempText = [self prepareTextFromSampleFile:file];
        tempHeight = [self heightForRowSampleFile:tempText];
        
    } else {
        // otherwise calculate height for my file
        NSString *tempText = [self prepareTextFromMyFile:file];
        tempHeight = [self heightForRow:tempText];
    }
    
    [section addFile:file withHeight:tempHeight];
}


#pragma mark -
#pragma mark Height for row

+ (CGFloat)heightForRow:(NSString *)text {
    return 35.f;
}


+ (CGFloat)heightForRowSampleFile:(NSAttributedString *)text {
    return 35.f;
}


#pragma mark -
#pragma mark Prepare text

+ (NSString *)prepareTextFromMyFile:(NSDictionary *)file {
    NSMutableString *preparedText = [[NSMutableString alloc] init];
    NSString *filename = [file objectForKey:@"Name"];
    NSString *tempString = [NSString stringWithFormat:@"%@", filename];
    [preparedText appendString:tempString];
    return [preparedText copy];
}


+ (NSAttributedString *)prepareTextFromSampleFile:(NSDictionary *)file {
    NSString *friendlyDesk1;
    NSString *friendlyDesk2;
    NSString *tempString;
    NSMutableAttributedString *attString;
    
    NSString *friendlyDesk1Temp = [self prepareDesc1String:file];
    NSString *friendlyDesk2Temp = [self prepareDesc2String:file];
    
    if ([friendlyDesk1Temp length] == 0)
        friendlyDesk1 = @"noname";
    else
        friendlyDesk1 = friendlyDesk1Temp;
    
    if ([friendlyDesk2Temp length] > 0) {
        friendlyDesk2 = friendlyDesk2Temp;
        tempString = [NSString stringWithFormat:@"%@\n%@", friendlyDesk1, friendlyDesk2];
        attString = [[NSMutableAttributedString alloc] initWithString:tempString];
        
        NSRange fileTitle    = NSMakeRange(0, [friendlyDesk1 length] - 1);
        NSRange fileSubTitle = NSMakeRange([friendlyDesk1 length] + 1, [friendlyDesk2 length]);
        
        if (fileTitle.location != NSNotFound)
            [attString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13.f] range:fileTitle];
        if (fileSubTitle.location != NSNotFound)
            [attString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:10.f] range:fileSubTitle];
        
    } else {
        tempString = [NSString stringWithFormat:@"%@", friendlyDesk1];
        attString = [[NSMutableAttributedString alloc] initWithString:tempString];
        
        NSRange fileTitle    = NSMakeRange(0, [friendlyDesk1 length] - 1);
        
        if (fileTitle.location != NSNotFound)
            [attString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13.f] range:fileTitle];
    }
    return [attString copy];
}


+ (NSString *)prepareDesc1String:(NSDictionary *)file {
    NSString *tempString;
    
    if ([[file allKeys] containsObject:@"FriendlyDesc1"]) {
        id desc1 = [file objectForKey:@"FriendlyDesc1"];
        
        if (desc1 != [NSNull null] && desc1 != nil) {
            NSString *desc1String = [NSString stringWithFormat:@"%@", desc1];
            
            if ([desc1String length] > 0) {
                tempString = desc1String;
            }
        }
    }
    return tempString;
}


+ (NSString *)prepareDesc2String:(NSDictionary *)file {
    NSString *tempString;
    
    if ([[file allKeys] containsObject:@"FriendlyDesc2"]) {
        id desc2 = [file objectForKey:@"FriendlyDesc2"];
        
        if (desc2 != [NSNull null] && desc2 != nil) {
            NSString *desc2String = [NSString stringWithFormat:@"%@", desc2];
            
            if ([desc2String length] > 0) {
                tempString = desc2String;
            }
        }
    }
    return tempString;
}



+ (NSString *)prepareText:(NSDictionary *)demoText {
    NSMutableString *preparedText = [[NSMutableString alloc] init];
    NSArray *keys = [NSArray arrayWithArray:[demoText allKeys]];
    NSArray *sortedKeys = [keys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    for (NSString *key in sortedKeys) {
        id obj = [demoText objectForKey:key];
        NSString *tempString = [NSString stringWithFormat:@"%@: %@\n", key, obj];
        [preparedText appendString:tempString];
    }
    
    return preparedText;
}



+ (NSDictionary *)searchForFileID:(NSString *)fileID inMyFilesSectionsArray:(NSArray *)sectionsArray {
    
    NSNumber *sectionIndexNumber;
    NSNumber *fileIndexNumber;
    
    SQSectionInfo *section;
    
    // search among sections
    for (int arrayIndex = 0; arrayIndex < [sectionsArray count]; arrayIndex++) {
        section = (sectionsArray)[arrayIndex];
        NSArray *arrayWithFilesFromSection = section.filesArray;
        
        // search files in section
        for (int fileIndex = 0; fileIndex < [arrayWithFilesFromSection count]; fileIndex++) {
            
            NSDictionary *file = [arrayWithFilesFromSection objectAtIndex:fileIndex];
            NSString *fileIDFromSection = [file objectForKey:@"Id"];
            
            if ([fileIDFromSection isEqualToString:fileID]) {
                fileIndexNumber = [NSNumber numberWithInteger:fileIndex];
                break;
            }
        }
        
        if (fileIndexNumber) {
            sectionIndexNumber = [NSNumber numberWithInteger:arrayIndex];
            break;
        }
    }
    
    if (sectionIndexNumber && fileIndexNumber) {
        NSDictionary *indexesDict = @{@"sectionIndex":  sectionIndexNumber,
                                      @"fileIndex":     fileIndexNumber};
        return indexesDict;
    } else {
        return nil;
    }
}



+ (NSDictionary *)searchForFileID:(NSString *)fileID inSampleFilesSectionsArray:(NSArray *)sectionsArray {
    
    NSNumber *sectionIndexNumber;
    NSNumber *fileIndexNumber;
    
    SQSectionInfo *section = (sectionsArray)[0];
    NSArray *arrayWithFilesFromSection = section.filesArray;
    
    // search files in section
    for (int fileIndex = 0; fileIndex < [arrayWithFilesFromSection count]; fileIndex++) {
        
        NSDictionary *file = [arrayWithFilesFromSection objectAtIndex:fileIndex];
        NSString *fileIDFromSection = [file objectForKey:@"Id"];
        
        if ([fileIDFromSection isEqualToString:fileID]) {
            fileIndexNumber = [NSNumber numberWithInteger:fileIndex];
            break;
        }
    }
    
    if (fileIndexNumber) {
        sectionIndexNumber = [NSNumber numberWithInteger:0];
    }
    
    if (sectionIndexNumber && fileIndexNumber) {
        NSDictionary *indexesDict = @{@"sectionIndex":  sectionIndexNumber,
                                      @"fileIndex":     fileIndexNumber};
        return indexesDict;
    } else {
        return nil;
    }
}



+ (NSNumber *)checkIfSelectedFileID:(NSString *)fileID isPresentInSection:(NSInteger)sectionNumber forCategory:(NSString *)category {
    
    NSNumber *indexOfSelectedFile;
    SQFilesContainer *filesContainer = [SQFilesContainer sharedInstance];
    SQSectionInfo *section;
    
    if ([category containsString:@"sample"]) {
        section = (filesContainer.sampleSectionsArray)[sectionNumber];
        
    } else {
        section = (filesContainer.mySectionsArray)[sectionNumber];
    }
    
    NSArray *arrayWithFilesFromSection = section.filesArray;
    
    for (int index = 0; index < [arrayWithFilesFromSection count]; index++) {
        
        NSDictionary *file = [arrayWithFilesFromSection objectAtIndex:index];
        NSString *fileIDFromSection = [file objectForKey:@"Id"];
        
        if ([fileIDFromSection isEqualToString:fileID]) {
            indexOfSelectedFile = [NSNumber numberWithInt:index];
            break;
        }
    }
    
    return indexOfSelectedFile;
}

@end
