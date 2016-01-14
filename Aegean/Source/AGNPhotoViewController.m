//
//  AGNPhotoViewController.m
//  Aegean
//
//  Created by LingFeng-Li on 1/13/16.
//  Copyright © 2016 SoulBeats. All rights reserved.
//

#import "AGNPhotoViewController.h"
#import "AGNImageScrollView.h"

@interface AGNPhotoViewController () <AGNImageScrollViewDelegate>
@property (nonatomic, weak) AGNImageScrollView *imageSV;
@end

@implementation AGNPhotoViewController

- (void)loadView {
    AGNImageScrollView *imageScrollView = [[AGNImageScrollView alloc] init];
    imageScrollView.image = self.image;
    imageScrollView.agnDelegate = self;
    
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

#pragma mark <AGNImageScrollViewDelegate>
- (void)imageScrollView:(AGNImageScrollView *)imageScrollView didTap:(UITapGestureRecognizer *)tap {
}
@end
