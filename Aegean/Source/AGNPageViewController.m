//
//  AGNPageViewController.m
//  Aegean
//
//  Created by LingFeng-Li on 1/13/16.
//  Copyright © 2016 SoulBeats. All rights reserved.
//

#import "AGNPageViewController.h"
#import "AGNPhotosPickerController.h"
#import "AGNPhotoViewController.h"
#import "AGNPhotoPopAnimator.h"

#import "Marcos.h"
#import "Constants.h"
#import "UIView+SLAdditions.h"

@interface AGNPageViewController () <UINavigationControllerDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate, AGNImageScrollViewDelegate, AGNPhotoTransitioning>
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UILabel *dateLabel;
@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, weak) UIBarButtonItem *doneBarButtonItem;
@property (nonatomic, weak) UIBarButtonItem *infoBarButtonItem;
@property (nonatomic, weak) UIBarButtonItem *resetBarButtonItem;

@property (nonatomic, assign) BOOL isFullScreen;
@property (nonatomic, assign) NSUInteger pendingCurrentIndex;
@property (nonatomic, strong) AGNPhotoViewController *photoVCBeforeStarting;
@property (nonatomic, strong) AGNPhotoViewController *photoVCAfterStarting;
@end

@implementation AGNPageViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    [self p_configureTitleView];
    [self p_configureNavigationItem];
    [self p_configureToolbar];
    [self setCurrentIndex:self.startingIndex];
    
    self.dataSource = self;
    self.delegate = self;
    AGNPhotoViewController *photoVC = [[AGNPhotoViewController alloc] init];
    photoVC.pageIndex = self.startingIndex;
    photoVC.image = [self.album fullResolutionImageAtIndex:self.startingIndex];
    [self setViewControllers:@[photoVC] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
    
    // To avoid a little delay at the first time switching
    if (self.startingIndex > 0) {
        self.photoVCBeforeStarting = [[AGNPhotoViewController alloc] init];
        self.photoVCBeforeStarting.pageIndex = self.startingIndex - 1;
        self.photoVCBeforeStarting.image = [self.album fullResolutionImageAtIndex:self.startingIndex - 1];
    }
    if (self.startingIndex < self.album.assets.count - 1) {
        self.photoVCAfterStarting = [[AGNPhotoViewController alloc] init];
        self.photoVCAfterStarting.pageIndex = self.startingIndex + 1;
        self.photoVCAfterStarting.image = [self.album fullResolutionImageAtIndex:self.startingIndex + 1];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.toolbarHidden = NO;
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    if (!self.isMovingFromParentViewController) {
        self.navigationController.toolbarHidden = YES;
    }
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    [super viewWillDisappear:animated];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self.navigationController setNavigationBarHidden:self.isFullScreen];
    [self.navigationController setToolbarHidden:self.isFullScreen];
}

- (void)setCurrentIndex:(NSUInteger)currentIndex {
    NSString *title = [NSString stringWithFormat:@"%ld of %ld", (long)currentIndex + 1, (long)self.album.assets.count];
    ALAsset *asset = [self.album.assets objectAtIndex:currentIndex];
    NSDate *date = [asset valueForProperty:ALAssetPropertyDate];
    [self p_setTitle:title date:date];
    
    if ([self.selectedPhotosIndexes containsObject:@(currentIndex)]) {
        self.imageView.image = [UIImage imageNamed:@"SelectionInBar"];
    } else {
        self.imageView.image = [UIImage imageNamed:@"ToSelectionInBar"];
    }
}

#pragma mark - Private
- (void)p_configureNavigationItem {
    UIImage *placeholderImage = [UIImage imageNamed:@"ToSelectionInBar"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:placeholderImage];
    self.imageView = imageView;
    imageView.autoresizingMask = UIViewAutoresizingNone;
    imageView.contentMode = UIViewContentModeCenter;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 44, self.navigationController.navigationBar.height);
    [button addSubview:imageView];
    [button addTarget:self action:@selector(selectPhoto:) forControlEvents:UIControlEventTouchUpInside];
    imageView.center = CGPointMake(button.width - 6 - placeholderImage.size.width / 2, button.height / 2.0);
    
    UIBarButtonItem *negativeSeparator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSeparator.width = -16;
    
    self.navigationItem.rightBarButtonItems = @[negativeSeparator, [[UIBarButtonItem alloc] initWithCustomView:button]];
}

- (void)p_configureToolbar {
    UIBarButtonItem *flexibleSpaceBarButton1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *flexibleSpaceBarButton2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *resetBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Reset" style:UIBarButtonItemStylePlain target:self action:@selector(reset:)];
    resetBarButtonItem.tintColor = HEXCOLOR(0xC24065);
    [resetBarButtonItem setTitleTextAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:kBarButtomItemFontSize]} forState:UIControlStateNormal];
    
    UIBarButtonItem *infoBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:(self.selectedPhotosIndexes.count ? [NSString stringWithFormat:@"%ld Selected", (long)self.selectedPhotosIndexes.count] : nil) style:UIBarButtonItemStylePlain target:nil action:nil];
    infoBarButtonItem.tintColor = [UIColor lightGrayColor];
    [infoBarButtonItem setTitleTextAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:kBarButtomItemFontSize]} forState:UIControlStateNormal];
    
    UIBarButtonItem *doneBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
    doneBarButtonItem.tintColor = HEXCOLOR(0x08BB08);
    [doneBarButtonItem setTitleTextAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:kBarButtomItemFontSize]} forState:UIControlStateNormal];
    
    UIBarButtonItem *fixedSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedSpacer.width = 43.5 - 40;
    self.toolbarItems = @[resetBarButtonItem, flexibleSpaceBarButton1, infoBarButtonItem, flexibleSpaceBarButton2, fixedSpacer, doneBarButtonItem];
    
    self.resetBarButtonItem = resetBarButtonItem;
    self.resetBarButtonItem.enabled = (self.selectedPhotosIndexes.count > 0);
    self.infoBarButtonItem = infoBarButtonItem;
    self.doneBarButtonItem = doneBarButtonItem;
    self.doneBarButtonItem.enabled = (self.selectedPhotosIndexes.count > 0);
}

- (void)p_configureTitleView {
    UIView *titleView = [[UIView alloc] init];
    UILabel *titleLabel = [[UILabel alloc] init];
    self.titleLabel = titleLabel;
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = BoldFont(16);
    [titleView addSubview:self.titleLabel];
    
    UILabel *dateLabel = [[UILabel alloc] init];
    self.dateLabel = dateLabel;
    self.dateLabel.textColor = [UIColor whiteColor];
    self.dateLabel.font = Font(11);
    [titleView addSubview:self.dateLabel];
    self.navigationItem.titleView = titleView;
}

- (void)p_setTitle:(NSString *)title date:(NSDate *)date {
    static NSDateFormatter *dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"MMMM d, YYYY  HH:mm";
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

#pragma mark - Protocol
#pragma mark <UINavigationControllerDelegate>
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    if (operation == UINavigationControllerOperationPop && [toVC conformsToProtocol:@protocol(AGNPhotoTransitioning)]) {
        AGNPhotoPopAnimator *animator = [[AGNPhotoPopAnimator alloc] init];
        
        AGNPhotoViewController *photoVC = [self.viewControllers lastObject];
        animator.index = photoVC.pageIndex;
        animator.fromImageView = [(AGNImageScrollView *)photoVC.view imageView];
        return animator;
    }
    return nil;
}

#pragma mark <AGNPhotoTransitioning>
- (UIImageView *)targetImageViewWhenPushing {
    AGNPhotoViewController *photoVC = [self.viewControllers lastObject];
    if ([photoVC.view isKindOfClass:[AGNImageScrollView class]]) {
        return [(AGNImageScrollView *)photoVC.view imageView];
    }
    return nil;
}

#pragma mark <UIPageViewControllerDataSource>
- (UIViewController *)pageViewController:(UIPageViewController *)pvc viewControllerBeforeViewController:(AGNPhotoViewController *)vc
{
    NSInteger currentIndex = vc.pageIndex - 1;
    if (currentIndex >= 0) {
        AGNPhotoViewController *photoVC;
        if (self.photoVCBeforeStarting && currentIndex == self.startingIndex - 1) {
            photoVC = self.photoVCBeforeStarting;
            self.photoVCBeforeStarting = nil; // Release memory
        } else {
            photoVC = [[AGNPhotoViewController alloc] init];
            photoVC.pageIndex = currentIndex;
            photoVC.image = [self.album fullResolutionImageAtIndex:currentIndex];
        }
        return photoVC;
    }
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pvc viewControllerAfterViewController:(AGNPhotoViewController *)vc
{
    NSUInteger currentIndex = vc.pageIndex + 1;
    if (currentIndex < self.album.assets.count) {
        AGNPhotoViewController *photoVC;
        if (self.photoVCAfterStarting && currentIndex == self.startingIndex + 1) {
            photoVC = self.photoVCAfterStarting;
            self.photoVCAfterStarting = nil;
        } else {
            photoVC = [[AGNPhotoViewController alloc] init];
            photoVC.pageIndex = currentIndex;
            photoVC.image = [self.album fullResolutionImageAtIndex:currentIndex];
        }
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

- (void)imageScrollView:(AGNImageScrollView *)imageScrollView didImageTapped:(UITapGestureRecognizer *)tap {
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController setToolbarHidden:NO];
    
    self.isFullScreen = !self.isFullScreen;
    CGFloat alpha = (self.isFullScreen) ? 0.0 : 1.0;
    
    UIView *maskView = [[UIView alloc] initWithFrame:self.view.bounds];
    maskView.backgroundColor = self.isFullScreen ? [UIColor blackColor] : [UIColor whiteColor];
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
        self.view.backgroundColor = self.isFullScreen ? [UIColor blackColor] : [UIColor whiteColor];
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

#pragma mark - Action
- (void)selectPhoto:(id)sender {
    AGNPhotoViewController *photoVC = [self.viewControllers lastObject];
    NSUInteger currentIndex = photoVC.pageIndex;
    if ([self.selectedPhotosIndexes containsObject:@(currentIndex)]) { // Deselect
        [self.selectedPhotosIndexes removeObject:@(currentIndex)];
        self.imageView.image = [UIImage imageNamed:@"ToSelectionInBar"];
    } else { // Select
        [self.selectedPhotosIndexes addObject:@(currentIndex)];
        self.imageView.image = [UIImage imageNamed:@"SelectionInBar"];
        self.imageView.transform = CGAffineTransformMakeScale(0.5, 0.5);
        [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.imageView.transform = CGAffineTransformMakeScale(1.1, 1.1);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                self.imageView.transform = CGAffineTransformMakeScale(0.9, 0.9);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.05 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    self.imageView.transform = CGAffineTransformIdentity;
                } completion:NULL];
            }];
        }];

    }
    self.doneBarButtonItem.enabled = (self.selectedPhotosIndexes.count > 0);
    self.resetBarButtonItem.enabled = (self.selectedPhotosIndexes.count > 0);
    self.infoBarButtonItem.title = self.selectedPhotosIndexes.count ? [NSString stringWithFormat:@"%ld Selected", (long)self.selectedPhotosIndexes.count] : nil;
    
    if ([self.photoDelegate respondsToSelector:@selector(pageViewController:didSelectPhotosAtIndexes:)]) {
        [self.photoDelegate pageViewController:self didSelectPhotosAtIndexes:@[@(currentIndex)]];
    }
}

- (void)reset:(UIBarButtonItem *)sender {
    NSArray *indexes = [self.selectedPhotosIndexes copy];
    [self.selectedPhotosIndexes removeAllObjects];
    self.resetBarButtonItem.enabled = NO;
    self.infoBarButtonItem.title = nil;
    self.doneBarButtonItem.enabled = NO;
    self.imageView.image = [UIImage imageNamed:@"ToSelectionInBar"];
    if ([self.photoDelegate respondsToSelector:@selector(pageViewController:didSelectPhotosAtIndexes:)]) {
        [self.photoDelegate pageViewController:self didSelectPhotosAtIndexes:indexes];
    }
}

- (void)done:(UIBarButtonItem *)sender {
    AGNPhotosPickerController *picker = (AGNPhotosPickerController *)self.navigationController;
    if ([picker.pickerDelegate respondsToSelector:@selector(photosPickerController:didFinishPickingPhotos:)]) {
        NSMutableArray *photos = [NSMutableArray array];
        for (NSNumber *indexNumber in self.selectedPhotosIndexes) {
            NSUInteger index = [indexNumber unsignedIntegerValue];
            UIImage *image = [self.album fullResolutionImageAtIndex:index];
            [photos addObject:image];
        }
        [picker.pickerDelegate photosPickerController:picker didFinishPickingPhotos:[photos copy]];
    } else {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
    }
}
@end
