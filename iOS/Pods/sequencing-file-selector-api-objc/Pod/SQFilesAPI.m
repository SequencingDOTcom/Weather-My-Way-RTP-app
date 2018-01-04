//
//  SQFilesAPI.h
//  Copyright © 2017 Sequencing.com. All rights reserved
//

#import "SQFilesAPI.h"
#import "SQFilesServerManager.h"
#import "SQFilesHelper.h"
#import "SQFilesContainer.h"

#define kMainQueue dispatch_get_main_queue()



@interface SQFilesAPI()

@property (readwrite, nonatomic) NSString *accessToken;

@end




@implementation SQFilesAPI

+ (instancetype)sharedInstance {
    static SQFilesAPI *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SQFilesAPI alloc] init];
    });
    return instance;
}


#pragma mark - API methods

- (void)showFilesWithTokenProvider:(id<SQTokenAccessProtocol>)tokenProvider
                   showCloseButton:(BOOL)showCloseButton
          previouslySelectedFileID:(NSString *)selectedFileID
                          delegate:(UIViewController<SQFileSelectorProtocol> *)delegate {
    
    [self showFilesWithTokenProvider:tokenProvider
                     showCloseButton:showCloseButton
            previouslySelectedFileID:selectedFileID
             backgroundVideoFileName:nil
                            delegate:delegate];
}


- (void)showFilesWithTokenProvider:(id<SQTokenAccessProtocol>)tokenProvider
                   showCloseButton:(BOOL)showCloseButton
          previouslySelectedFileID:(NSString *)selectedFileID
           backgroundVideoFileName:(NSString *)videoFileName
                          delegate:(UIViewController<SQFileSelectorProtocol> *)delegate {
    if (!delegate) return;
    self.delegate = delegate;
    
    [tokenProvider token:^(SQToken *token, NSString *accessToken) {
        if (!token || !accessToken || [accessToken length] == 0) {
            [[SQFilesContainer sharedInstance] setSelectedFileID:nil];
            [_delegate errorWhileReceivingGeneticFiles:nil];
            return;
        }
        self.accessToken = accessToken;
        
        SQFilesContainer *filesContainer = [SQFilesContainer sharedInstance];
        [filesContainer setShowCloseButton: showCloseButton];
        [filesContainer setVideoFileName:   videoFileName];
        [filesContainer setSelectedFileID:  selectedFileID];
        
        // send request to server to get files assigned to account and then parse these files into categories and subcategories
        [self loadFilesWithToken:accessToken result:^(NSArray *files, NSError *error) {
            if (!files) {
                [[SQFilesContainer sharedInstance] setSelectedFileID:nil];
                [_delegate errorWhileReceivingGeneticFiles:error];
                return;
            }
            
            [SQFilesHelper parseFilesMainArray:files withHandler:^(NSMutableArray *mySectionsArray, NSMutableArray *sampleSectionsArray) {
                if (!sampleSectionsArray) {
                    [[SQFilesContainer sharedInstance] setSelectedFileID:nil];
                    [_delegate errorWhileReceivingGeneticFiles:nil];
                    return;
                }
                
                [filesContainer setMySectionsArray:    [mySectionsArray copy]];
                [filesContainer setSampleSectionsArray:[sampleSectionsArray copy]];
                [self showUIforDelegate:_delegate];
            }];
        }];
        
    }];
}


- (void)loadFilesWithToken:(NSString *)token result:(void (^)(NSArray *files, NSError *error))files {
    [[SQFilesServerManager sharedInstance] getForFilesWithToken:token onSuccess:^(NSArray *filesList) {
        files(filesList, nil);
        
    } onFailure:^(NSError *error) {
        NSLog(@"Error: %@", [error localizedDescription]);
        files(nil, error);
    }];
}


- (void)showUIforDelegate:(UIViewController *)delegate {
    dispatch_async(kMainQueue, ^{
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TabbarFileSelector" bundle:nil];
        UINavigationController *fileNavViewController = [storyboard instantiateInitialViewController];
        fileNavViewController.modalPresentationStyle  = UIModalTransitionStyleCoverVertical;
        [delegate presentViewController:fileNavViewController animated:YES completion:nil];
        
        // UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TabbarFileSelector" bundle:nil];
        // UINavigationController *fileSelectorVC = (UINavigationController *)[storyboard instantiateInitialViewController];
        // fileSelectorVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        // [self presentViewController:fileSelectorVC animated:YES completion:nil];
    });
}


- (void)deselectFile {
    SQFilesContainer *filesContainer = [SQFilesContainer sharedInstance];
    [filesContainer setSelectedFileID:nil];
}


@end
