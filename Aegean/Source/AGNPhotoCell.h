//
//  AGNPhotoCell.h
//  Aegean
//
//  Created by 李凌峰 on 1/10/16.
//  Copyright © 2016 SoulBeats. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AGNPhotoCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIButton *selectionButton;
@property (weak, nonatomic) IBOutlet UIImageView *selectionImageView;
- (void)setImage:(UIImage *)image;
@end
