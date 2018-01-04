//
//  SQConnectToWebViewController.m
//  Copyright © 2017 Sequencing.com. All rights reserved
//


#import "SQConnectToWebViewController.h"
#import "SQRequestHelper.h"



@interface SQConnectToWebViewController () <WKNavigationDelegate, WKUIDelegate>

@property (copy, nonatomic)   ConnectToCompletionBlock completionBlock;
@property (strong, nonatomic) WKWebView *webView;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) NSURL *url;

@end



@implementation SQConnectToWebViewController

- (id)initWithURL:(NSURL *)url andCompletionBlock:(ConnectToCompletionBlock)completionBlock {
    self = [super init];
    if (self) {
        self.completionBlock = completionBlock;
        self.url = url;
    }
    return self;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect rect = self.view.bounds;
    rect.origin = CGPointZero;
    
    WKPreferences *preferences = [[WKPreferences alloc] init];
    preferences.javaScriptEnabled = YES;
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.preferences = preferences;
    WKWebView *webView = [[WKWebView alloc] initWithFrame:rect configuration:configuration];
    
    webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:webView];
    self.webView = webView;
    
    // add cancel button for viewController
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                  target:self
                                                                                  action:@selector(actionCancel:)];
    [self.navigationItem setRightBarButtonItem:cancelButton animated:YES];
    
    // add activity indicator
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.navigationItem.titleView = self.activityIndicator;
    [self.activityIndicator startAnimating];
    
    // open url page
    NSURLRequest *request = [NSURLRequest requestWithURL:self.url];
    [self.webView loadRequest:request];
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
}




#pragma mark - Actions

- (void)actionCancel:(UIBarButtonItem *)sender {
    if (self.completionBlock) {
        self.webView.navigationDelegate = nil;
        self.completionBlock(NO, YES, nil);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}




#pragma mark - WKUIDelegate

- (void)webViewDidClose:(WKWebView *)webView {
    if (self.completionBlock) {
        self.webView.navigationDelegate = nil;
        self.completionBlock(YES, NO, nil);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}




#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    // NSLog(@"\nrequest: %@\n", navigationAction.request);
    decisionHandler(WKNavigationActionPolicyAllow);
}


- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    // NSLog(@"\nresponse: %@\n", [[(NSHTTPURLResponse *)navigationResponse.response URL] absoluteString]);
    decisionHandler(WKNavigationResponsePolicyAllow);
}


- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    [self.activityIndicator startAnimating];
}


- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    // NSLog(@"didFailProvisionalNavigation: %@", [error localizedDescription]);
    [self.activityIndicator stopAnimating];
}


- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    [self.activityIndicator stopAnimating];
}


- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    // NSLog(@"didFailNavigation: %@", [error localizedDescription]);
    [self.activityIndicator stopAnimating];
}



@end
