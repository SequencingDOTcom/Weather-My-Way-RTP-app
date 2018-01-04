//
//  ShareViaWebViewController.h
//  Copyright © 2016 Sequencing. All rights reserved.
//


#import <UIKit/UIKit.h>
@class ShareViaWebViewController;


@protocol ShareViaWebViewControllerDelegate <NSObject>

- (void)ShareViaWebViewController:(ShareViaWebViewController *)controller closeButtonPressed:(id)sender;

@end


@interface ShareViaWebViewController : UIViewController

- (id)initWithURL:(NSURL *)url;

@property (nonatomic) id <ShareViaWebViewControllerDelegate> delegate;

@end
