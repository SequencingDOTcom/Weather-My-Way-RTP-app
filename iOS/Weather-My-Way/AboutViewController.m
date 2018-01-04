//
//  AboutViewController.m
//  Copyright © 2016 Sequencing. All rights reserved.
//

#import "AboutViewController.h"

#define kMainQueue dispatch_get_main_queue()

#define kSequencingURL      @"https://sequencing.com/"
#define kGithubURL          @"https://github.com/SequencingDOTcom/Weather-My-Way-RTP-app"
#define kRegisterPhrase     @"register for a free account"
#define kRegisterAccountURL @"https://sequencing.com/user/register"



@interface AboutViewController () <UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UILabel    *aboutText;
@property (strong, nonatomic) NSString          *aboutTempText;

@property (weak, nonatomic) IBOutlet UILabel *poweredLogo;
@property (weak, nonatomic) IBOutlet UIImageView *sequencingLogo;
@property (weak, nonatomic) IBOutlet UIImageView *wundergroundLogo;
@property (weak, nonatomic) IBOutlet UIImageView *githubLogo;

@end



@implementation AboutViewController

#pragma mark - View Lyfecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"AboutVC: viewDidLoad");
    
    // set navigation bar fully transpanent
    [self.navigationController.navigationBar setTranslucent:YES];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    
    // set up title
    self.title = @"About Weather My Way +RTP";
    [self.navigationController.navigationBar setTitleTextAttributes:@{ NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:19.0],
                                                                       NSForegroundColorAttributeName: [UIColor whiteColor]
                                                                       }];
    
    // rename "Back" button
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    [[self navigationItem] setBackBarButtonItem:newBackButton];
    
    
    // add gesture to logos
    UITapGestureRecognizer *tapGestureSequencing = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sequencingLogoPressed)];
    tapGestureSequencing.numberOfTapsRequired = 1;
    [tapGestureSequencing setDelegate:self];
    _sequencingLogo.userInteractionEnabled = YES;
    [_sequencingLogo addGestureRecognizer:tapGestureSequencing];
    
    UITapGestureRecognizer *tapGestureSequencing2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sequencingLogoPressed)];
    tapGestureSequencing2.numberOfTapsRequired = 1;
    [tapGestureSequencing2 setDelegate:self];
    _poweredLogo.userInteractionEnabled = YES;
    [_poweredLogo addGestureRecognizer:tapGestureSequencing2];
    
    UITapGestureRecognizer *tapGestureGithub = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(githubLogoPressed)];
    tapGestureGithub.numberOfTapsRequired = 1;
    [tapGestureGithub setDelegate:self];
    _githubLogo.userInteractionEnabled = YES;
    [_githubLogo addGestureRecognizer:tapGestureGithub];
    
    // prepare text lable
    [self prepareText];
    
    // add tapGesture for text
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnText:)];
    singleTap.numberOfTapsRequired = 1;
    [singleTap setDelegate:self];
    _aboutText.userInteractionEnabled = YES;
    [_aboutText addGestureRecognizer:singleTap];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)dealloc {
    NSLog(@"AboutVC: dealloc");
    [super cleanup];
}


- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}



#pragma mark - Prepare text

- (void)prepareText {
    NSString *originalText = [_aboutText.text copy];
    _aboutTempText = [_aboutText.text copy];
    _aboutText.text = nil;
    NSString *urlPhrase = kRegisterPhrase;
    
    // set attributed string
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:originalText];
    
    NSDictionary *textPart = @{NSFontAttributeName:           [UIFont fontWithName:@"HelveticaNeue-Light" size:18.f],
                               NSForegroundColorAttributeName:[UIColor whiteColor]};
    
    NSDictionary *urlPart = @{NSFontAttributeName:           [UIFont fontWithName:@"HelveticaNeue-Medium" size:18.f],
                              NSForegroundColorAttributeName:[UIColor colorWithRed:0 green:140.0/255.0 blue:255.0/255.0 alpha:1.0]};
    
    
    NSRange firstTextPart = NSMakeRange(0, [originalText length] - 1);
    NSRange urlTextPart = [originalText rangeOfString:urlPhrase];
    
    [attributedString addAttributes:textPart range:firstTextPart];
    [attributedString addAttributes:urlPart  range:urlTextPart];
    
    _aboutText.attributedText = [attributedString copy];
}



#pragma mark - UITapGestureRecognizer

- (void)handleTapOnText:(UITapGestureRecognizer *)tapRecognizer {
    CGPoint touchPoint = [tapRecognizer locationInView:_aboutText];
    
    NSString *urlPhrase = kRegisterPhrase;
    NSRange urlTextRange = [_aboutTempText rangeOfString:urlPhrase];
    CGRect urlRect = [self boundingRectForCharacterRange:urlTextRange];
    
    if (CGRectContainsPoint(urlRect, touchPoint)) {
        NSURL *url = [NSURL URLWithString:kRegisterAccountURL];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}

- (CGRect)boundingRectForCharacterRange:(NSRange)range {
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:_aboutText.attributedText];
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    [textStorage addLayoutManager:layoutManager];
    
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:_aboutText.bounds.size]; //
    textContainer.lineFragmentPadding = 0;
    [layoutManager addTextContainer:textContainer];
    
    NSRange glyphRange;
    [layoutManager characterRangeForGlyphRange:range actualGlyphRange:&glyphRange];
    
    return [layoutManager boundingRectForGlyphRange:glyphRange inTextContainer:textContainer];
}



#pragma mark - Actions

- (IBAction)backButtonPressed:(id)sender {
    [_delegate AboutViewController:self closeButtonPressed:nil];
}

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^ __nullable)(void))completion {
    [super dismissViewControllerAnimated:flag completion:completion];
    _delegate = nil;
}



- (void)sequencingLogoPressed {
    NSURL *url = [NSURL URLWithString:kSequencingURL];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}


- (void)githubLogoPressed {
    NSURL *url = [NSURL URLWithString:kGithubURL];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}



#pragma mark - Memory handler

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
