//
//  SQFilesHelper.h
//  Copyright © 2015-2016 Sequencing.com. All rights reserved
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^FilesCallback)(NSMutableArray *mySectionsArray, NSMutableArray *sampleSectionsArray);

@interface SQFilesHelper : NSObject

+ (void)parseFilesMainArray:(NSArray *)filesMainArray
                withHandler:(FilesCallback)callback;

+ (CGFloat)heightForRow:(NSString *)text;

+ (NSString *)prepareTextFromMyFile:(NSDictionary *)file;

+ (NSAttributedString *)prepareTextFromSampleFile:(NSDictionary *)file;

+ (NSString *)prepareText:(NSDictionary *)text;

+ (NSDictionary *)searchForFileID:(NSString *)fileID inMyFilesSectionsArray:(NSArray *)sectionsArray;
+ (NSDictionary *)searchForFileID:(NSString *)fileID inSampleFilesSectionsArray:(NSArray *)sectionsArray;
    
+ (NSNumber *)checkIfSelectedFileID:(NSString *)fileID isPresentInSection:(NSInteger)sectionNumber forCategory:(NSString *)category;

@end
