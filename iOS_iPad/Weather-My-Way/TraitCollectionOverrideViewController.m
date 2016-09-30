//
//  TraitCollectionOverrideViewController.m
//  Copyright © 2016 Sequencing. All rights reserved.
//


#import "TraitCollectionOverrideViewController.h"


@interface TraitCollectionOverrideViewController ()

@end


@implementation TraitCollectionOverrideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (UITraitCollection *)traitCollection {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return super.traitCollection;
    } else {
        UITraitCollection *traitCollection_hCompact = [UITraitCollection traitCollectionWithHorizontalSizeClass:UIUserInterfaceSizeClassCompact];
        UITraitCollection *traitCollection_vRegular = [UITraitCollection traitCollectionWithVerticalSizeClass:UIUserInterfaceSizeClassRegular];
        UITraitCollection *traitCollection_CompactRegular = [UITraitCollection traitCollectionWithTraitsFromCollections:@[traitCollection_hCompact, traitCollection_vRegular]];
        
        UITraitCollection *traitCollection_hRegular = [UITraitCollection traitCollectionWithHorizontalSizeClass:UIUserInterfaceSizeClassRegular];
        UITraitCollection *traitCollection_RegularRegular = [UITraitCollection traitCollectionWithTraitsFromCollections:@[traitCollection_hRegular, traitCollection_vRegular]];
        
        BOOL willTransitionToPortrait = self.view.frame.size.height > self.view.frame.size.width;
        
        UITraitCollection *traitCollectionForOverride = willTransitionToPortrait ? traitCollection_CompactRegular : traitCollection_RegularRegular;
        return traitCollectionForOverride;
    }
}

@end
