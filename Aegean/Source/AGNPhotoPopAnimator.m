//
//  AGNPhotoPopAnimator.m
//  Aegean
//
//  Created by 李凌峰 on 1/17/16.
//  Copyright © 2016 SoulBeats. All rights reserved.
//

#import "AGNPhotoPopAnimator.h"
#import "AGNPhotosViewController.h"

@interface AGNPhotoPopAnimator ()
@property (nonatomic, assign) CGFloat transitionDuration;
@end

@implementation AGNPhotoPopAnimator 
- (instancetype)init {
    if (self = [super init]) {
        self.transitionDuration = 0.35;
    }
    return self;
}

- (CGFloat)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return self.transitionDuration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *container = [transitionContext containerView];
}
@end
