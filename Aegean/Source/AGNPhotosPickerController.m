//
//  AGNPhotosPickerController.m
//  Aegean
//
//  Created by 李凌峰 on 1/7/16.
//  Copyright © 2016 SoulBeats. All rights reserved.
//

#import "AGNPhotosPickerController.h"
#import "AGNAlbumsViewController.h"
#import "Marcos.h"

@interface AGNPhotosPickerController () <UINavigationControllerDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, weak) UIViewController *lastViewController;
@end

@implementation AGNPhotosPickerController

- (instancetype)init
{
    self = [super init];
    if (self) {
        AGNAlbumsViewController *albumsVC = [[AGNAlbumsViewController alloc] init];
        self.viewControllers = @[albumsVC];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    self.interactivePopGestureRecognizer.delegate = self;
    
    // Appearance
    self.navigationBar.barTintColor = HEXCOLOR(0x343339);
    self.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    self.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationBar.translucent = YES;
    
    self.toolbar.barTintColor = [UIColor whiteColor];
    self.toolbar.translucent = YES;
}

#pragma mark <UINavigationControllerDelegate>
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    SEL selector = @selector(navigationController:animationControllerForOperation:fromViewController:toViewController:);
    id<UIViewControllerAnimatedTransitioning> result = nil;
    if ([fromVC conformsToProtocol:@protocol(UINavigationControllerDelegate)] && [fromVC respondsToSelector:selector]) {
        result = [(id<UINavigationControllerDelegate>)fromVC navigationController:navigationController animationControllerForOperation:operation fromViewController:fromVC toViewController:toVC];
        if (result) {
            self.lastViewController = fromVC;
        }
    }
    return result;
}

- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController {
    if ([self.lastViewController conformsToProtocol:@protocol(UINavigationControllerDelegate)] && [self.lastViewController respondsToSelector:@selector(navigationController:interactionControllerForAnimationController:)]) {
        return [(id<UINavigationControllerDelegate>)self.lastViewController navigationController:navigationController interactionControllerForAnimationController:animationController];
    }
    return nil;
}

#pragma mark <UIGestureRecognizerDelegate>
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}
@end
