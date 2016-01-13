//
//  AGNPageViewController.m
//  Aegean
//
//  Created by LingFeng-Li on 1/13/16.
//  Copyright © 2016 SoulBeats. All rights reserved.
//

#import "AGNPageViewController.h"
#import "AGNPhotoViewController.h"

@interface AGNPageViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>
@property (nonatomic, assign) NSUInteger pendingCurrentIndex;
@end

@implementation AGNPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:nil style:UIBarButtonItemStylePlain target:self action:@selector(selectPhoto:)];
    [self setCurrentIndex:self.startingIndex];
    
    self.dataSource = self;
    self.delegate = self;
    AGNPhotoViewController *photoVC = [[AGNPhotoViewController alloc] init];
    photoVC.pageIndex = self.startingIndex;
    photoVC.image = [UIImage imageWithCGImage:[[(ALAsset *)[self.album.assets objectAtIndex:self.startingIndex] defaultRepresentation] fullResolutionImage] scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
    [self setViewControllers:@[photoVC] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
}

- (void)setCurrentIndex:(NSUInteger)currentIndex {
    self.title = [NSString stringWithFormat:@"%ld of %ld", (long)currentIndex + 1, (long)self.album.assets.count];
    
    UIBarButtonItem *rightBarButtonItem = self.navigationItem.rightBarButtonItem;
    if ([self.selectedPhotosIndexes containsObject:@(currentIndex)]) {
        rightBarButtonItem.image = [[UIImage imageNamed:@"SelectionInBar"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    } else {
        rightBarButtonItem.image = [UIImage imageNamed:@"ToSelectionInBar"];
    }
}

- (void)selectPhoto:(id)sender {
    AGNPhotoViewController *photoVC = [self.viewControllers lastObject];
    NSUInteger currentIndex = photoVC.pageIndex;
    UIBarButtonItem *rightBarButtonItem = self.navigationItem.rightBarButtonItem;
    if ([self.selectedPhotosIndexes containsObject:@(currentIndex)]) { // Deselect
        [self.selectedPhotosIndexes removeObject:@(currentIndex)];
        rightBarButtonItem.image = [UIImage imageNamed:@"ToSelectionInBar"];
    } else { // Select
        [self.selectedPhotosIndexes addObject:@(currentIndex)];
        rightBarButtonItem.image = [[UIImage imageNamed:@"SelectionInBar"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
}

#pragma mark <UIPageViewControllerDataSource>
- (UIViewController *)pageViewController:(UIPageViewController *)pvc viewControllerBeforeViewController:(AGNPhotoViewController *)vc
{
    NSInteger currentIndex = vc.pageIndex - 1;
    if (currentIndex >= 0) {
        AGNPhotoViewController *photoVC = [[AGNPhotoViewController alloc] init];
        photoVC.pageIndex = currentIndex;
        photoVC.image = [UIImage imageWithCGImage:[[(ALAsset *)[self.album.assets objectAtIndex:currentIndex] defaultRepresentation] fullResolutionImage] scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
        return photoVC;
    }
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pvc viewControllerAfterViewController:(AGNPhotoViewController *)vc
{
    NSUInteger currentIndex = vc.pageIndex + 1;
    if (currentIndex < self.album.assets.count) {
        AGNPhotoViewController *photoVC = [[AGNPhotoViewController alloc] init];
        photoVC.pageIndex = currentIndex;
        UIImage *image = [UIImage imageWithCGImage:[[(ALAsset *)[self.album.assets objectAtIndex:currentIndex] defaultRepresentation] fullResolutionImage] scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
        photoVC.image = image;
        return photoVC;
    }
    return nil;
}

#pragma mark <UIPageViewControllerDelegate>

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    if (completed) {
        [self setCurrentIndex:self.pendingCurrentIndex];
    }
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers {
    AGNPhotoViewController *photoVC = (AGNPhotoViewController *)[pendingViewControllers firstObject];
    self.pendingCurrentIndex = photoVC.pageIndex;
}
@end
