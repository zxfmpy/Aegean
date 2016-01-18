//
//  AGNPhotoPushAnimator.m
//  Aegean
//
//  Created by 李凌峰 on 1/17/16.
//  Copyright © 2016 SoulBeats. All rights reserved.
//

#import "AGNPhotoPushAnimator.h"
#import "Constants.h"

@interface AGNPhotoPushAnimator ()
@property (nonatomic, assign) CGFloat transitionDuration;
@end

@implementation AGNPhotoPushAnimator

- (instancetype)init {
    if (self = [super init]) {
        self.transitionDuration = kPhotoTransitioningDuration;
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return self.transitionDuration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    
    if (![toVC conformsToProtocol:@protocol(AGNPhotoTransitioning)] || ![toVC respondsToSelector:@selector(targetImageViewWhenPushing)]) {
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        return;
    }
    UIImageView *toImageView = [toVC performSelector:@selector(targetImageViewWhenPushing)];
    [containerView addSubview:toVC.view];
    toVC.view.alpha = 0.0;
    toImageView.hidden = YES;
    
    UIImageView *sneakyImageView = [[UIImageView alloc] initWithImage:self.photo];
    sneakyImageView.clipsToBounds = YES;
    sneakyImageView.contentMode = UIViewContentModeScaleAspectFill;
    sneakyImageView.frame = self.startRect;
    [containerView addSubview:sneakyImageView];
    self.fromImageView.hidden = YES;
    
    CGRect targetRect = toImageView.frame;
    [UIView animateWithDuration:self.transitionDuration delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        sneakyImageView.frame = targetRect;
        toVC.view.alpha = 1.0;
    } completion:^(BOOL finished) {
        toImageView.hidden = NO;
        self.fromImageView.hidden = NO;
        [sneakyImageView removeFromSuperview];
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
}
@end
