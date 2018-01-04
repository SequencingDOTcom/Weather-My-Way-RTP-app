//
//  SQSampleFilesViewController.m
//  Copyright © 2017 Sequencing.com. All rights reserved
//

#import "SQSampleFilesViewController.h"
#import "SQFilesContainer.h"
#import "SQFilesHelper.h"
#import "SQSectionInfo.h"
#import "SQExtendedNavBarView.h"
#import "SQSegmentedControlHelper.h"
#import "SQTableCell.h"
#import "SQPopoverInfoViewController.h"
#import "SQPopoverMyFilesViewController.h"
#import "SQFilesAPI.h"

#define kMainQueue dispatch_get_main_queue()




@interface SQSampleFilesViewController () <UITableViewDataSource, UITableViewDelegate, UIPopoverPresentationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet SQExtendedNavBarView *extendedNavBarView;

// files source
@property (strong, nonatomic) NSArray *filesArray;
@property (strong, nonatomic) NSArray *filesHeightsArray;

// buttons
@property (strong, nonatomic) UIBarButtonItem    *continueButton;

// file details / selection index
@property (strong, nonatomic) NSIndexPath        *nowSelectedFileIndexPath;
@property (strong, nonatomic) NSDictionary       *categoryIndexes;

@property (strong, nonatomic) UISegmentedControl *fileTypeSelect;

@end




@implementation SQSampleFilesViewController

#pragma mark - View Lyfecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    SQFilesContainer *filesContainer = [SQFilesContainer sharedInstance];
    
    // prepare navigation bar
    self.title = @"Sample Files";
    [self.navigationItem setTitle:@"Select a file"];
    
    
    // setup extended navbar images
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController.navigationBar setShadowImage:[UIImage imageNamed:@"nav_clear_pixel"]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_pixel"] forBarMetrics:UIBarMetricsDefault];
    
    
    // set up images for TabBar
    UITabBarItem *tabBarItem_MyFiles = (UITabBarItem *)[self.tabBarController.tabBar.items objectAtIndex:0];
    tabBarItem_MyFiles.image = [UIImage imageNamed:@"icon_myfiles"];
    
    UIImage *myFiles_SelectedImage = [UIImage imageNamed:@"icon_myfiles_color"];
    myFiles_SelectedImage = [myFiles_SelectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [tabBarItem_MyFiles setSelectedImage:myFiles_SelectedImage];
    
    UITabBarItem *tabBarItem_SampleFiles = (UITabBarItem *)[self.tabBarController.tabBar.items objectAtIndex:1];
    tabBarItem_SampleFiles.image = [UIImage imageNamed:@"icon_samplefiles"];
    
    
    // continueButton
    self.continueButton = [[UIBarButtonItem alloc] initWithTitle:@"Continue"
                                                           style:UIBarButtonItemStyleDone
                                                          target:self
                                                          action:@selector(fileIsSelected)];
    self.continueButton.enabled = NO;
    
    
    // rightBarButtonItems
    NSArray *rightButtonsArray = [[NSArray alloc] initWithObjects:self.continueButton, nil]; // self.infoButton,
    self.navigationItem.rightBarButtonItems = rightButtonsArray;
    
    // closeButton
    if (filesContainer.showCloseButton) {
        UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                                     target:self
                                                                                     action:@selector(closeButtonPressed)];
        [self.navigationItem setLeftBarButtonItem:closeButton animated:NO];
    }
    
    
    // prepare tableView
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    // allows using "native" radio button for selecting row
    [self.tableView setEditing:YES animated:YES];
    
    [self.tableView setEstimatedRowHeight:20.f];
    [self.tableView setRowHeight:UITableViewAutomaticDimension];
    
    // prepare array with segmented control items and indexes in source
    NSDictionary *itemsAndIndexes = [SQSegmentedControlHelper prepareSegmentedControlItemsAndCategoryIndexes:filesContainer.sampleSectionsArray];
    NSArray *segmentedControlItems = [itemsAndIndexes objectForKey:@"items"];
    self.categoryIndexes = [itemsAndIndexes objectForKey:@"indexes"];
    
    
    // segmented control init
    self.fileTypeSelect = [[UISegmentedControl alloc] initWithItems:segmentedControlItems];
    [self.fileTypeSelect addTarget:self action:@selector(segmentControlAction:) forControlEvents:UIControlEventValueChanged];
    [self.fileTypeSelect sizeToFit];
    [self.fileTypeSelect setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.extendedNavBarView addSubview:self.fileTypeSelect];
    
    // adding constraints for segmented control
    NSLayoutConstraint *xCenter = [NSLayoutConstraint constraintWithItem:self.fileTypeSelect
                                                               attribute:NSLayoutAttributeCenterX
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.extendedNavBarView
                                                               attribute:NSLayoutAttributeCenterX
                                                              multiplier:1
                                                                constant:0];
    NSLayoutConstraint *yCenter = [NSLayoutConstraint constraintWithItem:self.fileTypeSelect
                                                               attribute:NSLayoutAttributeCenterY
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.extendedNavBarView
                                                               attribute:NSLayoutAttributeCenterY
                                                              multiplier:1
                                                                constant:0];
    [self.extendedNavBarView addConstraint:xCenter];
    [self.extendedNavBarView addConstraint:yCenter];
    
    
    // select first item in segmentedControl and assign related source
    self.fileTypeSelect.selectedSegmentIndex = 0;
    SQSectionInfo *section = (filesContainer.sampleSectionsArray)[0];
    self.filesArray = section.filesArray;
    self.filesHeightsArray = section.rowHeights;
    
    
    // show notification message if there are no my files at all
    if (![[[[self.tabBarController tabBar] items] objectAtIndex:0] isEnabled])
        [self showMyFilesPopover];
    
    if (!([filesContainer.mySectionsArray count] > 0))
        [[[[self.tabBarController tabBar] items] objectAtIndex:0] setEnabled:FALSE];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
    SQFilesContainer *filesContainer = [SQFilesContainer sharedInstance];
    NSNumber *fileIndexInArray = nil;
    
    NSString *selectedSegmentItem = [self.fileTypeSelect titleForSegmentAtIndex:self.fileTypeSelect.selectedSegmentIndex];
    int indexOfSectionInArray = [[self.categoryIndexes objectForKey:selectedSegmentItem] intValue];
    
    if ([filesContainer.selectedFileID length] != 0)
        fileIndexInArray = [SQFilesHelper checkIfSelectedFileID:filesContainer.selectedFileID
                                             isPresentInSection:indexOfSectionInArray
                                                    forCategory:@"sample"];
    
    if (fileIndexInArray)
        _nowSelectedFileIndexPath = [NSIndexPath indexPathForRow:[fileIndexInArray integerValue] inSection:0];
    else
        _nowSelectedFileIndexPath = nil;
    
    if (_nowSelectedFileIndexPath)
        [self preselectFileInCurrentSection];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    if (indexPath) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        self.continueButton.enabled = NO;
    }
}



#pragma mark - Actions

- (void)segmentControlAction:(UISegmentedControl *)sender {
    self.nowSelectedFileIndexPath = nil;
    self.continueButton.enabled = NO;
    
    self.filesArray = nil;
    self.filesHeightsArray = nil;
    [self.tableView reloadData];
    
    SQFilesContainer *filesContainer = [SQFilesContainer sharedInstance];
    SQSectionInfo *section = [[SQSectionInfo alloc] init];
    
    NSString *selectedSegmentItem = [sender titleForSegmentAtIndex:sender.selectedSegmentIndex];
    
    int indexOfSectionInArray = [[self.categoryIndexes objectForKey:selectedSegmentItem] intValue];
    section = (filesContainer.sampleSectionsArray)[indexOfSectionInArray];
    
    self.filesArray = section.filesArray;
    self.filesHeightsArray = section.rowHeights;
    [self.tableView reloadData];
    
    // preselect file by index if any
    NSNumber *fileIndexInArray = nil;
    
    if ([filesContainer.selectedFileID length] != 0)
        fileIndexInArray = [SQFilesHelper checkIfSelectedFileID:filesContainer.selectedFileID
                                             isPresentInSection:indexOfSectionInArray
                                                    forCategory:@"sample"];
    
    if (fileIndexInArray)
        _nowSelectedFileIndexPath = [NSIndexPath indexPathForRow:[fileIndexInArray integerValue] inSection:0];
    else
        _nowSelectedFileIndexPath = nil;
    
    if (_nowSelectedFileIndexPath)
        [self preselectFileInCurrentSection];
}


// Continue button selected
- (void)fileIsSelected {
    NSDictionary *selectedFile = [[NSDictionary alloc] init];
    selectedFile = (self.filesArray)[self.nowSelectedFileIndexPath.row];
    [[SQFilesContainer sharedInstance] setSelectedFileID:nil];
    [[[SQFilesAPI sharedInstance] delegate] selectedGeneticFile:selectedFile];
    [self dismissViewControllerAnimated:NO completion:nil];
    [_viewCloseDelegate sampleFilesViewControllerClosed];
}


// Back button tapped
- (void)closeButtonPressed {
    SQFilesAPI *filesAPI = [SQFilesAPI sharedInstance];
    
    if ([filesAPI.delegate respondsToSelector:@selector(closeButtonPressed)]) {
        [[SQFilesContainer sharedInstance] setSelectedFileID:nil];
        [filesAPI.delegate closeButtonPressed];
    }
    [self dismissViewControllerAnimated:NO completion:nil];
    [_viewCloseDelegate sampleFilesViewControllerClosed];
}



#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.filesArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"cell";
    SQTableCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    NSDictionary *tempFile = [[NSDictionary alloc] init];
    tempFile = (self.filesArray)[indexPath.row];
    NSAttributedString *fileName = [SQFilesHelper prepareTextFromSampleFile:tempFile];
    
    cell.cellLabel.attributedText = fileName;
    cell.cellLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.tintColor = [UIColor blueColor];
    
    return cell;
}



#pragma mark - Cells selection

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return 3;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.nowSelectedFileIndexPath == nil) {
        self.nowSelectedFileIndexPath = indexPath;
    } else {
        if (self.nowSelectedFileIndexPath != indexPath) {
            [self.tableView deselectRowAtIndexPath:self.nowSelectedFileIndexPath animated:YES];
            self.nowSelectedFileIndexPath = indexPath;
        }
    }
    self.continueButton.enabled = YES;
    
    SQFilesContainer *filesContainer = [SQFilesContainer sharedInstance];
    // note selected file, in order to be preselected when get back to current section
    NSDictionary *selectedFile = (self.filesArray)[self.nowSelectedFileIndexPath.row];
    NSString *fileID = [selectedFile objectForKey:@"Id"];
    
    if ([fileID length] != 0)
        filesContainer.selectedFileID = fileID;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.nowSelectedFileIndexPath = nil;
    self.continueButton.enabled = NO;
    [[SQFilesContainer sharedInstance] setSelectedFileID:nil];
}


- (void)preselectFileInCurrentSection {
    
    if (self.nowSelectedFileIndexPath && self.nowSelectedFileIndexPath.row >= 0 && self.nowSelectedFileIndexPath.row < [self.filesArray count]) {
        dispatch_async(kMainQueue, ^{
            [self.tableView selectRowAtIndexPath:self.nowSelectedFileIndexPath
                                        animated:NO
                                  scrollPosition:UITableViewScrollPositionNone];
            
            [self.tableView scrollToRowAtIndexPath:self.nowSelectedFileIndexPath
                                  atScrollPosition:UITableViewScrollPositionMiddle
                                          animated:NO];
            
            self.continueButton.enabled = YES;
        });
    }
}



#pragma mark - Popover

- (void)showMyFilesPopover {
    UIViewController *popoverContentController = [[UIViewController alloc] initWithNibName:@"SQPopoverMyFilesViewController" bundle:nil];
    CGFloat height = [SQPopoverMyFilesViewController heightForPopoverWidth:self.view.bounds.size.width - 30];
    popoverContentController.preferredContentSize = CGSizeMake(self.view.bounds.size.width - 30, height);
    
    // Set the presentation style to modal and delegate so that the below methods get called
    popoverContentController.modalPresentationStyle = UIModalPresentationPopover;
    popoverContentController.popoverPresentationController.delegate = self;
    popoverContentController.popoverPresentationController.sourceView = [self.tabBarController tabBar];
    
    // int tabBarItemsNumber = (int)[[[self.tabBarController tabBar] items] count];
    CGFloat tabBarWidth = [self.tabBarController tabBar].frame.size.width;
    CGFloat tabBarHeight = [self.tabBarController tabBar].frame.size.height;
    CGFloat tabBarItemWidth =  tabBarWidth / 2;
    int x = tabBarItemWidth;
    CGRect frame = CGRectMake(x, 0, tabBarItemWidth, tabBarHeight);
    
    popoverContentController.popoverPresentationController.sourceRect = frame;
    
    [self presentViewController:popoverContentController animated:YES completion:nil];
}

- (void)prepareForPopoverPresentation:(UIPopoverPresentationController *)popoverPresentationController {
    popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}



@end
