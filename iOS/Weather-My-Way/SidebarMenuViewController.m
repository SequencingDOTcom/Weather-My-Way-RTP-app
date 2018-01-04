//
//  SidebarMenuViewController.m
//  Copyright © 2016 Sequencing. All rights reserved.
//


#import "SidebarMenuViewController.h"
#import "SWRevealViewController.h"
#import "AboutViewController.h"
#import "UserHelper.h"

#define kMainQueue dispatch_get_main_queue()
NSString *MENU_ITEM_SELECTED_NOTIFICATION_KEY = @"MENU_ITEM_SELECTED_NOTIFICATION_KEY";


@interface SidebarMenuViewController () <UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *sequencing_logo;
@property (weak, nonatomic) IBOutlet UILabel *appVersion;

@end



@implementation SidebarMenuViewController

#pragma mark -
#pragma mark View Lyfecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"SidebarMenuVC: viewDidLoad");
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // add gesture to logos
    _sequencing_logo.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGestureSequencing = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sequencing_logoPressed)];
    tapGestureSequencing.numberOfTapsRequired = 1;
    [tapGestureSequencing setDelegate:self];
    [_sequencing_logo addGestureRecognizer:tapGestureSequencing];
    
    // set background image
    UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
    if (background.bounds.size.width > self.tableView.contentSize.width &&
        background.bounds.size.height > self.tableView.contentSize.height) {
        background.contentMode = UIViewContentModeScaleAspectFill;
    }
    [self.tableView setBackgroundView:background];
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    self.appVersion.text = [NSString stringWithFormat:@"v%@(%@)", version, build];
}

- (void)dealloc {
    NSLog(@"SidebarMenuVC: dealloc");
}



#pragma mark -
#pragma mark Cells

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    cell.indentationLevel = 10;
    cell.indentationWidth = 10;
    
    switch (cell.tag) {
        case 1: // about
            cell.imageView.image = [UIImage imageNamed:@"info_white"];
            break;
            
        case 2: // settings
            cell.imageView.image = [UIImage imageNamed:@"settings_white"];
            break;
            
        case 3: // location
            cell.imageView.image = [UIImage imageNamed:@"location_white"];
            break;
            
        case 4: // share
            cell.imageView.image = [UIImage imageNamed:@"share_white"];
            break;
            
        case 5: // feedback
            cell.imageView.image = [UIImage imageNamed:@"message_white"];
            break;
            
        case 6: // sign out
            cell.imageView.image = [UIImage imageNamed:@"white_exit"];
            break;
            
        default:
            break;
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    dispatch_async(kMainQueue, ^{
        // close menu
        [self.revealViewController revealToggleAnimated:YES];
        
        CGRect cellRect = [self rectForRowAtIndexPath:indexPath];
        NSDictionary *userInfoDict = @{@"cellRect": [NSValue valueWithCGRect:cellRect]};
        
        UITableViewCell *selectedCell=[tableView cellForRowAtIndexPath:indexPath];
        NSNumber *menuItemTag = [NSNumber numberWithInteger:selectedCell.tag];
        [[NSNotificationCenter defaultCenter] postNotificationName:MENU_ITEM_SELECTED_NOTIFICATION_KEY
                                                            object:menuItemTag
                                                          userInfo:userInfoDict];
    });
}



#pragma mark -
#pragma mark Actions

- (void)sequencing_logoPressed {
    NSURL *url = [NSURL URLWithString:@"https://sequencing.com/"];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}



#pragma mark -
#pragma mark Helper methods

- (CGRect)rectForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGRect cellRect = [self.tableView rectForRowAtIndexPath:indexPath];
    return cellRect;
}



#pragma mark -
#pragma mark Memory handler

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



@end
