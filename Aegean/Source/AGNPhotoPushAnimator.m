//
//  AGNPhotoPushAnimator.m
//  Aegean
//
//  Created by 李凌峰 on 1/17/16.
//  Copyright © 2016 SoulBeats. All rights reserved.
//

#import "AGNPhotoPushAnimator.h"

@interface AGNPhotoPushAnimator ()
@property (nonatomic, assign) CGFloat transitionDuration;
@end

@implementation AGNPhotoPushAnimator

- (instancetype)init {
    if (self = [super init]) {
        self.transitionDuration = 0.35;
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return self.transitionDuration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    
    [containerView addSubview:toVC.view];
    toVC.view.alpha = 0.0;
    for (UIView *subview in toVC.view.subviews) {
        subview.hidden = YES;
    }
    
    self.imageView.frame = self.startRect;
    [containerView addSubview:self.imageView];
    
    CGFloat ratio = 1.05;
    CGRect scaledRect = CGRectMake(self.targetRect.origin.x - (ratio - 1) * self.targetRect.size.width * 0.5, self.targetRect.origin.y - (ratio - 1) * self.targetRect.size.height * 0.5, self.targetRect.size.width * ratio, self.targetRect.size.height * ratio);
    [UIView animateWithDuration:self.transitionDuration * 2.0 / 3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.imageView.frame = scaledRect;
        toVC.view.alpha = 1.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:self.transitionDuration * 1.0 / 3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.imageView.frame = self.targetRect;
        } completion:^(BOOL finished) {
            for (UIView *subview in toVC.view.subviews) {
                subview.hidden = NO;
            }
            [self.imageView removeFromSuperview];
            [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        }];
    }];
}
@end
