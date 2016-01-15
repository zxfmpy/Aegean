//
//  AGNPageViewController.m
//  Aegean
//
//  Created by LingFeng-Li on 1/13/16.
//  Copyright © 2016 SoulBeats. All rights reserved.
//

#import "AGNPageViewController.h"
#import "AGNPhotoViewController.h"
#import "Marcos.h"
#import "UIView+SLAdditions.h"

@interface AGNPageViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate, AGNImageScrollViewDelegate>
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UILabel *dateLabel;
@property (nonatomic, assign) NSUInteger pendingCurrentIndex;
@property (nonatomic, assign) BOOL isFullScreen;
@end

@implementation AGNPageViewController

static const NSInteger kViewBackgroundColorDecimal = 0xFFFFFF;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = HEXCOLOR(kViewBackgroundColorDecimal);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:nil style:UIBarButtonItemStylePlain target:self action:@selector(selectPhoto:)];
    [self.navigationItem.rightBarButtonItem setImageInsets:UIEdgeInsetsMake(0, -8, 0, 8)];
    [self configureTitleView];
    [self setCurrentIndex:self.startingIndex];
    
    self.dataSource = self;
    self.delegate = self;
    AGNPhotoViewController *photoVC = [[AGNPhotoViewController alloc] init];
    photoVC.pageIndex = self.startingIndex;
    photoVC.image = [UIImage imageWithCGImage:[[(ALAsset *)[self.album.assets objectAtIndex:self.startingIndex] defaultRepresentation] fullResolutionImage] scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
    [self setViewControllers:@[photoVC] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.isMovingToParentViewController) {
        self.navigationController.toolbarHidden = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    if (!self.isMovingFromParentViewController) {
        self.navigationController.toolbarHidden = YES;
    }
    [super viewWillDisappear:animated];
}

- (void)configureTitleView {
    UIView *titleView = [[UIView alloc] init];
    UILabel *titleLabel = [[UILabel alloc] init];
    self.titleLabel = titleLabel;
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = BoldFont(16);
    [titleView addSubview:self.titleLabel];
    
    UILabel *dateLabel = [[UILabel alloc] init];
    self.dateLabel = dateLabel;
    self.dateLabel.textColor = [UIColor whiteColor];
    self.dateLabel.font = Font(12);
    [titleView addSubview:self.dateLabel];
    self.navigationItem.titleView = titleView;
}

- (void)setCurrentIndex:(NSUInteger)currentIndex {
    NSString *title = [NSString stringWithFormat:@"%ld of %ld", (long)currentIndex + 1, (long)self.album.assets.count];
    ALAsset *asset = [self.album.assets objectAtIndex:currentIndex];
    NSDate *date = [asset valueForProperty:ALAssetPropertyDate];
    [self setTitle:title date:date];
    
    UIBarButtonItem *rightBarButtonItem = self.navigationItem.rightBarButtonItem;
    if ([self.selectedPhotosIndexes containsObject:@(currentIndex)]) {
        rightBarButtonItem.image = [[UIImage imageNamed:@"SelectionInBar"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    } else {
        rightBarButtonItem.image = [UIImage imageNamed:@"ToSelectionInBar"];
    }
}

- (void)setTitle:(NSString *)title date:(NSDate *)date {
    static NSDateFormatter *dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"HH:mm, MMMM d, YYYY";
    }
    NSString *stringFromDate = [dateFormatter stringFromDate:date];
    self.titleLabel.text = title;
    self.dateLabel.text = stringFromDate;
    [self.titleLabel sizeToFit];
    [self.dateLabel sizeToFit];
    
    CGSize size = CGSizeMake(MAX(self.titleLabel.width, self.dateLabel.width), self.titleLabel.height + self.dateLabel.height);
    UIView *titleView = self.navigationItem.titleView;
    self.navigationItem.titleView = nil;
    titleView.frame = CGRectMake(0, (self.navigationController.navigationBar.height - size.height) / 2.0, size.width, size.height);
    self.titleLabel.center = CGPointMake(titleView.width / 2.0, self.titleLabel.height / 2.0);
    self.dateLabel.center = CGPointMake(titleView.width / 2.0, self.titleLabel.height + self.dateLabel.height / 2.0);
    self.navigationItem.titleView = titleView;
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

#pragma mark <AGNImageScrollViewDelegate>
- (BOOL)prefersStatusBarHidden {
    return self.isFullScreen;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationFade;
}

- (void)imageScrollView:(AGNImageScrollView *)imageScrollView didTap:(UITapGestureRecognizer *)tap {
    self.isFullScreen = !self.isFullScreen;
    CGFloat alpha = (self.isFullScreen) ? 0.0 : 1.0;
    
    UIView *maskView = [[UIView alloc] initWithFrame:self.view.bounds];
    maskView.backgroundColor = self.isFullScreen ? [UIColor blackColor] : HEXCOLOR(kViewBackgroundColorDecimal);
    maskView.alpha = 0.0;
    [self.view insertSubview:maskView atIndex:0];
    
    CGRect barFrame = self.navigationController.navigationBar.frame;
    [UIView animateWithDuration:0.33 delay:0 options:(self.isFullScreen ? UIViewAnimationOptionCurveEaseIn : UIViewAnimationOptionCurveEaseOut) animations:^{
        [self setNeedsStatusBarAppearanceUpdate];
        self.navigationController.navigationBar.alpha = alpha;
        self.navigationController.navigationBar.frame = barFrame;
        maskView.alpha = 1.0;
    } completion:^(BOOL finished) {
        [maskView removeFromSuperview];
        self.view.backgroundColor = self.isFullScreen ? [UIColor blackColor] : HEXCOLOR(kViewBackgroundColorDecimal);
    }];
    
    self.navigationController.navigationBar.frame = CGRectZero;
    self.navigationController.navigationBar.frame = barFrame;
    
    // Unkown Reason, Must Do Like This
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.33 animations:^{
            self.navigationController.toolbar.alpha = alpha;
        }];
    });
}
@end
