//
//  AGNPhotoPopAnimator.m
//  Aegean
//
//  Created by 李凌峰 on 1/17/16.
//  Copyright © 2016 SoulBeats. All rights reserved.
//

#import "AGNPhotoPopAnimator.h"
#import "AGNPhotosViewController.h"
#import "Constants.h"

@interface AGNPhotoPopAnimator ()
@property (nonatomic, assign) CGFloat duration;
@end

@implementation AGNPhotoPopAnimator 
- (instancetype)init {
    if (self = [super init]) {
        self.duration = kPhotoTransitioningDuration;
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return self.duration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    
    if (![toVC conformsToProtocol:@protocol(AGNPhotoTransitioning)] || ![toVC respondsToSelector:@selector(targetRectWhenPoppingAtIndex:)] || ![toVC respondsToSelector:@selector(targetImageViewWhenPoppingAtIndex:)]) {
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        return;
    }
    
    [containerView insertSubview:toVC.view belowSubview:fromVC.view];
    UIImageView *sneakyImageView = [[UIImageView alloc] initWithImage:self.fromImageView.image];
    sneakyImageView.clipsToBounds = YES;
    sneakyImageView.contentMode = UIViewContentModeScaleAspectFill;
    sneakyImageView.frame = [containerView convertRect:self.fromImageView.frame fromView:self.fromImageView.superview];
    [containerView addSubview:sneakyImageView];
    self.fromImageView.hidden = YES;
    
    CGRect targetRect = [(id<AGNPhotoTransitioning>)toVC targetRectWhenPoppingAtIndex:self.index];
    UIImageView *targetImageView = [(id<AGNPhotoTransitioning>)toVC targetImageViewWhenPoppingAtIndex:self.index];
    targetImageView.hidden = YES;
    
    [UIView animateWithDuration:self.duration delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        fromVC.view.alpha = 0.0;
        sneakyImageView.frame = targetRect;
    } completion:^(BOOL finished) {
        targetImageView.hidden = NO;
        [sneakyImageView removeFromSuperview];
        fromVC.view.alpha = 1.0;
        self.fromImageView.hidden = NO;
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
    
}
@end
