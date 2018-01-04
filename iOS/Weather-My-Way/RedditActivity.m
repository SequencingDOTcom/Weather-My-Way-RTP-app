//
//  RedditActivity.m
//  Copyright © 2016 Sequencing. All rights reserved.
//


#import "RedditActivity.h"
#import "ShareViaWebViewController.h"


static NSString *redditURL = @"https://www.reddit.com/submit";


@interface RedditActivity () <ShareViaWebViewControllerDelegate>

@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSURL *url;

@end


@implementation RedditActivity

+ (UIActivityCategory)activityCategory {
    return UIActivityCategoryShare;
}


- (NSString *)activityTitle {
    return @"Reddit";
}


- (UIImage *)activityImage {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return [UIImage imageNamed:@"reddit-icon-ipad"];
    } else {
        return [UIImage imageNamed:@"reddit-icon-iphone"];
    }
}


- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    BOOL canPerform = NO;
    for (id object in activityItems) {
        if ([object isKindOfClass:[NSString class]]) {
            canPerform = YES;
        }
    }
    return canPerform;
}


- (void)prepareWithActivityItems:(NSArray *)activityItems {
    for (id object in activityItems) {
        if ([object isKindOfClass:[NSString class]]) {
            _text = object;
            
        } else if ([object isKindOfClass:[NSURL class]]) {
            _url = object;
        }
    }
}


- (UIViewController *)activityViewController {
    NSString *urlEncoded = [_url absoluteString];
    NSString *titleEncoded = [_text stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
    
    NSString *urlString = [NSString stringWithFormat:
                           @"%@?"
                           "url=%@&"
                           "title=%@",
                           redditURL, urlEncoded, titleEncoded];
    NSURL *url = [NSURL URLWithString:urlString];
    
    ShareViaWebViewController *shareViaWebViewController = [[ShareViaWebViewController alloc] initWithURL:url];
    shareViaWebViewController.delegate = self;
    UINavigationController *navigationViewController = [[UINavigationController alloc] initWithRootViewController:shareViaWebViewController];
    
    return navigationViewController;
}



#pragma mark -
#pragma mark ShareViaWebViewControllerDelegate

- (void)ShareViaWebViewController:(ShareViaWebViewController *)controller closeButtonPressed:(id)sender {
    [controller dismissViewControllerAnimated:YES completion:nil];
    [self activityDidFinish:YES];
}


@end
