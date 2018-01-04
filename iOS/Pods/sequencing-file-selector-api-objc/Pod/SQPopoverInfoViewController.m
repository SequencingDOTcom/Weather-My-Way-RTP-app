//
//  SQPopoverInfoViewController.m
//  Copyright © 2015-2016 Sequencing.com. All rights reserved
//

#import "SQPopoverInfoViewController.h"

@interface SQPopoverInfoViewController ()

@end

@implementation SQPopoverInfoViewController

+ (CGFloat)heightForPopoverWidth:(CGFloat)width {
    NSString *text = @"RTP = Real-Time Personalization®\nRTP is as easy as 1, 2, 3...\n\n1) Choose whether you want to use a sample file or your own file.\nIf you want to use your own file, you will be able to select from a list of files stored in your Sequencing.com account.\n\n2) Wait a moment for the list of files to appear and then select a file.\nThis app's Real-Time Personalization® will then be powered by the genetic data in the file you select.\n\n3) Press continue.";
    
    UIFont *font = [UIFont systemFontOfSize:14.f];
    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowOffset = CGSizeMake(0, -1);
    shadow.shadowBlurRadius = 0.5;
    
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    [paragraph setLineBreakMode:NSLineBreakByWordWrapping];
    [paragraph setAlignment:NSTextAlignmentLeft];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                font, NSFontAttributeName,
                                paragraph, NSParagraphStyleAttributeName,
                                shadow, NSShadowAttributeName, nil];
    
    CGRect rect = [text boundingRectWithSize:CGSizeMake(width - 30, CGFLOAT_MAX)
                                     options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                  attributes:attributes
                                     context:nil];
    
    return CGRectGetHeight(rect) + 180;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // [self.textView scrollRangeToVisible:NSMakeRange(0, 0)];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
