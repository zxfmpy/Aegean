//
//  AGNPhotoPopAnimator.h
//  Aegean
//
//  Created by 李凌峰 on 1/17/16.
//  Copyright © 2016 SoulBeats. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AGNPhotoTransitioning.h"

@interface AGNPhotoPopAnimator : NSObject <UIViewControllerAnimatedTransitioning>
@property (nonatomic, weak) UIImageView *fromImageView;
@property (nonatomic, assign) NSUInteger index;
@end
