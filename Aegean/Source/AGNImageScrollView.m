//
//  AGNImageScrollView.m
//  Aegean
//
//  Created by LingFeng-Li on 1/14/16.
//  Copyright © 2016 SoulBeats. All rights reserved.
//

#import "AGNImageScrollView.h"

@interface AGNImageScrollView () <UIScrollViewDelegate>
@property (nonatomic, weak) UIImageView *imageView;
@end

@implementation AGNImageScrollView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.delegate = self;
        
        self.zoomScale = 1.0;
        self.maximumZoomScale = 3.0;
        self.minimumZoomScale = 1.0;
        
        UIImageView *imageView = [[UIImageView alloc] init];
        self.imageView = imageView;
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:imageView];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        singleTap.numberOfTapsRequired = 1;
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        [singleTap requireGestureRecognizerToFail:doubleTap];
        
        [self addGestureRecognizer:singleTap];
        [self addGestureRecognizer:doubleTap];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    CGSize originalSize = self.frame.size;
    [super setFrame:frame];
    if (!CGSizeEqualToSize(originalSize, frame.size)) {
        self.imageView.frame = self.bounds;
        self.contentSize = self.imageView.bounds.size;
    }
}

- (void)setImage:(UIImage *)image {
    self.imageView.image = image;
}

#pragma mark <UIScrollViewDelegate>
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    self.imageView.center = CGPointMake(MAX(scrollView.bounds.size.width, scrollView.contentSize.width) * 0.5,
                                        MAX(scrollView.bounds.size.height, scrollView.contentSize.height) * 0.5);
}

#pragma mark - Action
- (void)singleTap:(UITapGestureRecognizer *)tap {
    if ([self.agnDelegate respondsToSelector:@selector(imageScrollView:didTap:)]) {
        [self.agnDelegate imageScrollView:self didTap:tap];
    }
}

- (void)doubleTap:(UITapGestureRecognizer *)tap {
    CGFloat scale = (self.zoomScale == 1.0) ? MIN(2.55, self.maximumZoomScale) : 1.0;
    
    CGPoint center = [tap locationInView:self];
    CGRect zoomRect;
    zoomRect.size.height = [self frame].size.height / scale;
    zoomRect.size.width  = [self frame].size.width  / scale;
    zoomRect.origin.x    = center.x - ((zoomRect.size.width / 2.0));
    zoomRect.origin.y    = center.y - ((zoomRect.size.height / 2.0));
    
    [self zoomToRect:zoomRect animated:YES];
}
@end
