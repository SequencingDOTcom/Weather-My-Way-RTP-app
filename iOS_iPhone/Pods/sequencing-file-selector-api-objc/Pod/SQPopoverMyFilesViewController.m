//
//  SQPopoverMyFilesViewController.m
//  Copyright © 2015-2016 Sequencing.com. All rights reserved
//

#import "SQPopoverMyFilesViewController.h"

@interface SQPopoverMyFilesViewController ()

@end

@implementation SQPopoverMyFilesViewController

+ (CGFloat)heightForPopoverWidth:(CGFloat)width {
    NSString *text = @"Your Sequencing.com account doesn't appear to have any genetic data.\n\nPlease go to the Upload Center at Sequencing.com to upload your genetic data. You'll then be able to connect this app with your genetic data.\n\nUntil then, please use one of the following sample files.";
    
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
    
    return CGRectGetHeight(rect) + 40;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
