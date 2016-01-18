//
//  AGNPhotoCell.m
//  Aegean
//
//  Created by 李凌峰 on 1/10/16.
//  Copyright © 2016 SoulBeats. All rights reserved.
//

#import "AGNPhotoCell.h"

@interface AGNPhotoCell ()
@property (nonatomic, strong) UIView *maskView;
@end

@implementation AGNPhotoCell

- (void)awakeFromNib {
    // Initialization code
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    if (highlighted) {
        if (!self.maskView) {
            self.maskView = [[UIView alloc] init];
            self.maskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        }
        self.maskView.frame = self.contentView.bounds;
        [self.contentView addSubview:self.maskView];
        [self.contentView bringSubviewToFront:self.selectionImageView];
    } else {
        [self.maskView removeFromSuperview];
    }
}

- (void)setImage:(UIImage *)image {
    self.imageView.image = image;
}

@end
