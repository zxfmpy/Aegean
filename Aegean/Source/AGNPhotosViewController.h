//
//  AGNPhotosViewController.h
//  Aegean
//
//  Created by 李凌峰 on 1/10/16.
//  Copyright © 2016 SoulBeats. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AGNAlbum.h"

static const CGFloat kBarButtomItemFontSize = 16;

@interface AGNPhotosViewController : UICollectionViewController
@property (nonatomic, strong) AGNAlbum *album;
@end
