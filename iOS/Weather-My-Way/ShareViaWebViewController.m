//
//  ShareViaWebViewController.m
//  Copyright © 2016 Sequencing. All rights reserved.
//


#import "ShareViaWebViewController.h"


@interface ShareViaWebViewController () <UIWebViewDelegate>

@property (weak, nonatomic) UIWebView *webView;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) NSURL *url;

@end



@implementation ShareViaWebViewController

- (id)initWithURL:(NSURL *)url {
    self = [super init];
    if (self) {
        self.url = url;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect rect = self.view.bounds;
    rect.origin = CGPointZero;
    UIWebView *webView = [[UIWebView alloc] initWithFrame:rect];
    webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:webView];
    self.webView = webView;
    
    // add cancel button for viewController
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                                  target:self
                                                                                  action:@selector(actionClose:)];
    [self.navigationItem setLeftBarButtonItem:closeButton animated:YES];
    
    // add activity indicator
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.navigationItem.titleView = self.activityIndicator;
    
    [self.activityIndicator startAnimating];
    // open login page from url with params
    NSURLRequest *request = [NSURLRequest requestWithURL:self.url];
    webView.delegate = self;
    [webView loadRequest:request];
}


- (void)dealloc {
    self.webView.delegate = nil;
}



#pragma mark -
#pragma mark Actions

- (void)actionClose:(UIBarButtonItem *)sender {
    [_delegate ShareViaWebViewController:self closeButtonPressed:nil];
}



#pragma mark -
#pragma mark UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self.activityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.activityIndicator stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:( NSError *)error {
    [self.activityIndicator stopAnimating];
}



#pragma mark -
#pragma mark Memory handler

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
