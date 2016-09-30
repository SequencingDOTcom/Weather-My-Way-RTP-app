//
//  SQLoginViewController.h
//  Copyright © 2015-2016 Sequencing.com. All rights reserved
//

#import "SQLoginViewController.h"
#import "SQServerManager.h"
#import "SQRequestHelper.h"

@interface SQLoginViewController () <UIWebViewDelegate>

@property (copy, nonatomic) LoginCompletionBlock completionBlock;
@property (weak, nonatomic) UIWebView *webView;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) NSURL *url;
// @property (nonatomic, retain) NSURLRequest *requestTest;

@end

@implementation SQLoginViewController

- (id)initWithURL:(NSURL *)url andCompletionBlock:(LoginCompletionBlock)completionBlock {
    self = [super init];
    if (self) {
        self.completionBlock = completionBlock;
        self.url = url;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // add webView container
    CGRect rect = self.view.bounds;
    rect.origin = CGPointZero;
    UIWebView *webView = [[UIWebView alloc] initWithFrame:rect];
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
    // open login page from url with params
    NSURLRequest *request = [NSURLRequest requestWithURL:self.url];
    webView.delegate = self;
    [webView loadRequest:request];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    self.webView.delegate = nil;
}


#pragma mark -
#pragma mark Actions

- (void)actionCancel:(UIBarButtonItem *)sender {
    if (self.completionBlock) {
        self.webView.delegate = nil;
        NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
        [result setObject:[NSNumber numberWithBool:YES] forKey:@"didCancelAuthorization"];
        self.completionBlock(result);
    }
    // put here some variations to close current webView depending on the way it was shown
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark -
#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    [self.activityIndicator startAnimating];
    
    /*
    if ((self.requestTest == nil) || ![[self.requestTest URL] isEqual:request.URL]) {
        self.requestTest = request;
    } else {
        if (self.completionBlock) {
            self.webView.delegate = nil;
            NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
            [result setObject:[NSNumber numberWithBool:YES] forKey:@"error"];
            self.completionBlock(result);
        }
        [self dismissViewControllerAnimated:YES completion:nil];
        return YES;
    }*/
    
    
    if ([[SQRequestHelper sharedInstance] verifyRequestForRedirectBack:request]) {
        self.webView.delegate = nil;
        if (self.completionBlock) {
            self.completionBlock([[SQRequestHelper sharedInstance] parseRequest:request]);
        }
        [self dismissViewControllerAnimated:YES completion:nil];
        return NO;
    }
    
    /*
    BOOL status = [self sendSynchRequest:request];
    if (!status) {
        self.webView.delegate = nil;
        if (self.completionBlock) {
            NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
            [result setObject:[NSNumber numberWithBool:YES] forKey:@"error"];
            self.completionBlock(result);
        }
        [self dismissViewControllerAnimated:YES completion:nil];
        return NO;
    }*/
    
    return YES;
}

/*
- (BOOL)sendSynchRequest:(NSURLRequest *)request {
    NSHTTPURLResponse *response;
    NSError *error;
    
    [self.activityIndicator startAnimating];
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request
                                                 returningResponse:&response
                                                             error:&error];
    if (responseData) {
        [self.activityIndicator stopAnimating];
    }
    NSString *string = [error domain];

    if (([response statusCode] != 200 && [response statusCode] != 301 && [response statusCode] != 302) || error) {
        return NO;
        
    } else {
        // [self.webView loadData:responseData MIMEType:[response MIMEType] textEncodingName:[response textEncodingName] baseURL:[response URL]];
        // [self setView:self.webView];
    }
    
    return YES;
} */

/*
- (void)sendAsynchRequest:(NSURLRequest *)request withCompletion:(void (^)(BOOL success))completion {
    [self.activityIndicator startAnimating];
    
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                      {
                                          NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
                                          NSInteger statusCode = [HTTPResponse statusCode];
                                          
                                          // NSLog(@"\nresponse \n\t-> %@", response);
                                          // NSLog(@"\nresponse. statusCode \n\t-> %ld", [response statusCode]);
                                          // NSLog(@"\nrerror -> \n\t%@", error);
                                          
                                          if ((statusCode != 200 && statusCode != 301 && statusCode != 302) || error) {
                                              // one of the error responses, e.g. 4xx or 5xx, or error
                                              [self.activityIndicator stopAnimating];
                                              completion(NO);
                                              
                                              
                                          } else {
                                              // successfull response, e.g. 2xx
                                              [self.activityIndicator stopAnimating];
                                              completion(YES);
                                              
                                              // [self.webView loadData:responseData MIMEType:[response MIMEType] textEncodingName:[response textEncodingName] baseURL:[response URL]];
                                              // [self setView:self.webView];
                                          }
                                      }];
    [dataTask resume];
}*/


- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self.activityIndicator startAnimating];
}


- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.activityIndicator stopAnimating];
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self.activityIndicator stopAnimating];
}


@end
