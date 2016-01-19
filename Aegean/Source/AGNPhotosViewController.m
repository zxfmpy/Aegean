//
//  AGNPhotosViewController.m
//  Aegean
//
//  Created by 李凌峰 on 1/10/16.
//  Copyright © 2016 SoulBeats. All rights reserved.
//

#import "AGNPhotosViewController.h"
#import "AGNPhotosPickerController.h"
#import "AGNPageViewController.h"
#import "AGNPhotoPushAnimator.h"
#import "AGNPhotoCell.h"

#import "Marcos.h"
#import "Constants.h"
#import "UIView+SLAdditions.h"

#define COLOR_PART_RED(color)    (((color) >> 16) & 0xff)
#define COLOR_PART_GREEN(color)  (((color) >>  8) & 0xff)
#define COLOR_PART_BLUE(color)   ( (color)        & 0xff)

@interface AGNPhotosViewController () <UINavigationControllerDelegate, AGNPageViewControllerDelegate, AGNPhotoTransitioning>
@property (nonatomic, weak) UIBarButtonItem *previewBarButtonItem;
@property (nonatomic, weak) UIBarButtonItem *infoBarButtonItem;
@property (nonatomic, weak) UIBarButtonItem *doneBarButtonItem;

@property (nonatomic, strong) NSMutableArray *selectedPhotosIndexes;
@property (nonatomic, strong) UIImage *selectionImage;
@property (nonatomic, strong) UIImage *toSelectionImage;
@property (nonatomic, strong) UIColor *tintColor;
@end

@implementation AGNPhotosViewController

static const CGFloat kSpacing = 3;
static NSString * const kPhotoCellReuseIdentifier = @"PhotoCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.selectedPhotosIndexes = [NSMutableArray array];
    self.tintColor = [(AGNPhotosPickerController *)self.navigationController tintColor];
    self.selectionImage = [UIImage imageNamed:@"Selection"];
    self.toSelectionImage = [UIImage imageNamed:@"ToSelection"];
    
    self.title = self.album.name;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self.navigationController action:@selector(cancel:)];
#pragma clang diagnostic pop
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:kBarButtomItemFontSize]} forState:UIControlStateNormal];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self p_configureToolbar];
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    layout.minimumInteritemSpacing = kSpacing;
    layout.minimumLineSpacing = kSpacing;
    CGFloat side = (MIN(SCREEN_WIDTH, SCREEN_HEIGHT) - kSpacing * 3) / 4;
    layout.itemSize = CGSizeMake(side, side);
    self.collectionView.contentInset = UIEdgeInsetsMake(kSpacing, 0, kSpacing, 0);
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.alwaysBounceVertical = YES;
    [self.collectionView registerNib:[UINib nibWithNibName:@"AGNPhotoCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:kPhotoCellReuseIdentifier];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.toolbarHidden = NO;
    [self p_refreshToolbarButtonItems];
}

- (void)viewWillDisappear:(BOOL)animated {
    if (self.isMovingFromParentViewController) { // Carefully
        self.navigationController.toolbarHidden = YES;
    }
    [super viewWillDisappear:animated];
}

- (void)setAlbum:(AGNAlbum *)album {
    _album = album;
    [_album loadAspectRatioThumbnailsAsynchronously];
}

#pragma mark - Private
- (void)p_configureToolbar {
    UIBarButtonItem *flexibleSpaceBarButton1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *flexibleSpaceBarButton2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *previewBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Preview" style:UIBarButtonItemStylePlain target:self action:@selector(preview:)];
    previewBarButtonItem.tintColor = [UIColor blackColor];
    [previewBarButtonItem setTitleTextAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:kBarButtomItemFontSize]} forState:UIControlStateNormal];
    
    UIBarButtonItem *infoBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:nil style:UIBarButtonItemStylePlain target:nil action:nil];
    infoBarButtonItem.tintColor = [UIColor lightGrayColor];
    [infoBarButtonItem setTitleTextAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:kBarButtomItemFontSize]} forState:UIControlStateNormal];
    
    UIBarButtonItem *doneBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
    doneBarButtonItem.tintColor = self.tintColor;
    [doneBarButtonItem setTitleTextAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:kBarButtomItemFontSize]} forState:UIControlStateNormal];
    
    UIBarButtonItem *fixedSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedSpacer.width = 57 - 40; // hard-coded
    self.toolbarItems = @[previewBarButtonItem, flexibleSpaceBarButton1, infoBarButtonItem,flexibleSpaceBarButton2, fixedSpacer, doneBarButtonItem];
    
    self.previewBarButtonItem = previewBarButtonItem;
    self.infoBarButtonItem = infoBarButtonItem;
    self.doneBarButtonItem = doneBarButtonItem;
    self.previewBarButtonItem.enabled = NO;
    self.doneBarButtonItem.enabled = NO;
}

- (void)p_refreshToolbarButtonItems {
    if (self.selectedPhotosIndexes.count) {
        self.previewBarButtonItem.enabled = YES;
        self.doneBarButtonItem.enabled = YES;
        self.infoBarButtonItem.title = [NSString stringWithFormat:@"%ld Selected", (long)self.selectedPhotosIndexes.count];
    } else {
        self.previewBarButtonItem.enabled = NO;
        self.doneBarButtonItem.enabled = NO;
        self.infoBarButtonItem.title = nil;
    }
}

#pragma mark - Protocol
#pragma mark <UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.album.assets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AGNPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPhotoCellReuseIdentifier forIndexPath:indexPath];
    NSUInteger index = indexPath.row;
    [cell setImage:[self.album aspectRatioThumbnailAtIndex:index]];
    if ([self.selectedPhotosIndexes containsObject:@(index)]) {
        cell.selectionImageView.image = self.selectionImage;
        cell.selectionImageView.backgroundColor = self.tintColor;
    } else {
        cell.selectionImageView.image = self.toSelectionImage;
        cell.selectionImageView.backgroundColor = [UIColor clearColor];
    }
    cell.selectionButton.tag = index;
    [cell.selectionButton addTarget:self action:@selector(selectPhoto:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

#pragma mark <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    AGNPageViewController *pageVC = [[AGNPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:@{UIPageViewControllerOptionInterPageSpacingKey: @(20)}];
    pageVC.album = self.album;
    pageVC.selectedPhotosIndexes = self.selectedPhotosIndexes;
    pageVC.startingIndex = indexPath.row;
    pageVC.photoDelegate = self;
    [self.navigationController pushViewController:pageVC animated:YES];
}

#pragma mark <AGNPageViewControllerDelegate>
- (void)pageViewController:(AGNPageViewController *)pageViewController didSelectPhotosAtIndexes:(NSArray *)indexes {
    CGPoint contentOffset = self.collectionView.contentOffset;
    for (NSNumber *indexNum in indexes) {
        [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:[indexNum unsignedIntegerValue] inSection:0]]];
    }
    self.collectionView.contentOffset = contentOffset;
}

#pragma mark <UINavigationControllerDelegate>
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    if (operation == UINavigationControllerOperationPush && [toVC conformsToProtocol:@protocol(AGNPhotoTransitioning)]) {
        AGNPhotoPushAnimator *animator = [[AGNPhotoPushAnimator alloc] init];
        NSIndexPath *indexPath = [[self.collectionView indexPathsForSelectedItems] firstObject];
        AGNPhotoCell *cell = (AGNPhotoCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        animator.fromImageView = cell.imageView;
        
        animator.photo = [self.album fullResolutionImageAtIndex:indexPath.row];
        CGRect startRect = cell.frame;
        startRect.origin = CGPointMake(startRect.origin.x - self.collectionView.contentOffset.x, startRect.origin.y - self.collectionView.contentOffset.y);
        animator.startRect = startRect;
        return animator;
    }
    return nil;
}

#pragma mark <AGNPhotoTransitioning>
- (CGRect)targetRectWhenPoppingAtIndex:(NSUInteger)index {
    UICollectionViewLayoutAttributes *attributes = [self.collectionView layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    CGRect targetRect = attributes.frame;
    
    NSMutableArray *indexes = [NSMutableArray array];
    for (UICollectionViewCell *cell in self.collectionView.visibleCells) {
        CGFloat top = cell.frame.origin.y - self.collectionView.contentOffset.y;
        CGFloat bottom = top + cell.height;
        if (top >= self.navigationController.navigationBar.height + [UIApplication sharedApplication].statusBarFrame.size.height && bottom <= self.collectionView.height - self.navigationController.toolbar.height) {
            [indexes addObject:@([self.collectionView indexPathForCell:cell].row)];
        }
    }
    [indexes sortUsingSelector:@selector(compare:)];
    if (index < [[indexes firstObject] unsignedIntegerValue]) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
    } else if (index > [[indexes lastObject] unsignedIntegerValue]) {
        CGPoint contentOffset = self.collectionView.contentOffset;
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
        if (self.collectionView.contentOffset.y <= contentOffset.y) {
            contentOffset.y = attributes.frame.origin.y + attributes.frame.size.height + kSpacing - (self.collectionView.height - self.navigationController.toolbar.height);
            self.collectionView.contentOffset = contentOffset;
        }
    }
    
    targetRect.origin.x = targetRect.origin.x - self.collectionView.contentOffset.x;
    targetRect.origin.y = targetRect.origin.y - self.collectionView.contentOffset.y;
    return targetRect;
}

- (UIImageView *)targetImageViewWhenPoppingAtIndex:(NSUInteger)index {
    AGNPhotoCell *cell = (AGNPhotoCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    if (cell) {
        return cell.imageView;
    }
    return nil;
}

#pragma mark - Action
- (void)preview:(UIBarButtonItem *)sender {
#warning
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

- (void)selectPhoto:(UIButton *)sender {
    NSUInteger index = sender.tag;
    AGNPhotoCell *cell = (AGNPhotoCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    if ([self.selectedPhotosIndexes containsObject:@(index)]) {
        [self.selectedPhotosIndexes removeObject:@(index)];
        cell.selectionImageView.image = self.toSelectionImage;
        cell.selectionImageView.backgroundColor = [UIColor clearColor];
    } else {
        [self.selectedPhotosIndexes addObject:@(index)];
        cell.selectionImageView.image = self.selectionImage;
        cell.selectionImageView.backgroundColor = self.tintColor;
        cell.selectionImageView.transform = CGAffineTransformMakeScale(0.5, 0.5);
        [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            cell.selectionImageView.transform = CGAffineTransformMakeScale(1.1, 1.1);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                cell.selectionImageView.transform = CGAffineTransformMakeScale(0.9, 0.9);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.05 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    cell.selectionImageView.transform = CGAffineTransformIdentity;
                } completion:NULL];
            }];
        }];
    }
    
    [self p_refreshToolbarButtonItems];
}
@end
