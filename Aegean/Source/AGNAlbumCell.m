//
//  AGNAlbumCell.m
//  Aegean
//
//  Created by 李凌峰 on 1/9/16.
//  Copyright © 2016 SoulBeats. All rights reserved.
//

#import "AGNAlbumCell.h"

@interface AGNAlbumCell ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView1;
@property (weak, nonatomic) IBOutlet UIImageView *imageView2;
@property (weak, nonatomic) IBOutlet UIImageView *imageView3;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *quantityLabel;

@end

@implementation AGNAlbumCell

- (void)awakeFromNib {
    // Initialization code
    
    UIColor *borderColor = [UIColor whiteColor];
    CGFloat borderWidth = 0.5;
    UIViewContentMode contentMode = UIViewContentModeScaleAspectFill;
    
    NSArray *imageViews = @[self.imageView1, self.imageView2, self.imageView3];
    for (UIImageView *imageView in imageViews) {
        imageView.layer.borderColor = borderColor.CGColor;
        imageView.layer.borderWidth = borderWidth;
        imageView.contentMode = contentMode;
        imageView.clipsToBounds = YES;
    }
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    if (selected) {
        self.backgroundColor = [UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1.0];
    } else {
        self.backgroundColor = [UIColor whiteColor];
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted) {
        self.backgroundColor = [UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1.0];
    } else {
        self.backgroundColor = [UIColor whiteColor];
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.nameLabel.text = nil;
    self.quantityLabel.text = nil;
    
    self.imageView1.image = nil;
    self.imageView2.image = nil;
    self.imageView3.image = nil;
}

- (void)setAlbum:(AGNAlbum *)album {
    self.nameLabel.text = album.name;
    self.quantityLabel.text = [NSString stringWithFormat:@"%ld", (long)album.photos.count];
    
    NSInteger index = album.photos.count;
    if (--index >= 0) {
        self.imageView1.image = [UIImage imageWithCGImage: [(ALAsset *)[album.photos objectAtIndex:index] aspectRatioThumbnail] scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
    }
    if (--index >= 0) {
        self.imageView2.image = [UIImage imageWithCGImage: [(ALAsset *)[album.photos objectAtIndex:index] aspectRatioThumbnail] scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
    }
    if (--index >= 0) {
        self.imageView3.image = [UIImage imageWithCGImage: [(ALAsset *)[album.photos objectAtIndex:index] aspectRatioThumbnail] scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
    }
}
@end
