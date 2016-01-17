//
//  AGNPhotoViewController.m
//  Aegean
//
//  Created by LingFeng-Li on 1/13/16.
//  Copyright © 2016 SoulBeats. All rights reserved.
//

#import "AGNPhotoViewController.h"

@interface AGNPhotoViewController ()
@property (nonatomic, weak) AGNImageScrollView *imageSV;
@end

@implementation AGNPhotoViewController

- (void)loadView {
    AGNImageScrollView *imageScrollView = [[AGNImageScrollView alloc] init];
    imageScrollView.image = self.image;
    if ([self.parentViewController conformsToProtocol:@protocol(AGNImageScrollViewDelegate)]) {
        imageScrollView.imageDelegate = (id<AGNImageScrollViewDelegate>)self.parentViewController;
    }
    
    self.view = imageScrollView;
    self.imageSV = imageScrollView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidDisappear:(BOOL)animated {
    self.imageSV.zoomScale = 1.0;
    [super viewDidDisappear:animated];
}

- (void)setImage:(UIImage *)image {
    _image = image;
    if (self.isViewLoaded) {
        self.imageSV.image = image;
    }
}

@end
