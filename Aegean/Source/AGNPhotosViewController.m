//
//  AGNPhotosViewController.m
//  Aegean
//
//  Created by 李凌峰 on 1/10/16.
//  Copyright © 2016 SoulBeats. All rights reserved.
//

#import "AGNPhotosViewController.h"
#import "AGNPhotosPickerController.h"
#import "AGNPhotoCell.h"
#import "Marcos.h"
#import "UIView+SLAdditions.h"
#import "AGNPageViewController.h"
#import "Constants.h"

@interface AGNPhotosViewController ()
@property (nonatomic, weak) UIBarButtonItem *previewBarButtonItem;
@property (nonatomic, weak) UIBarButtonItem *doneBarButtonItem;
@property (nonatomic, weak) UIBarButtonItem *infoBarButtonItem;

@property (nonatomic, strong) NSMutableArray *selectedPhotosIndexes;
@end

@implementation AGNPhotosViewController

static NSString * const kPhotoCellReuseIdentifier = @"PhotoCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.selectedPhotosIndexes = [NSMutableArray array];
    
    self.title = self.album.name;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:kBarButtomItemFontSize]} forState:UIControlStateNormal];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self p_configureToolBar];
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    CGFloat spacing = 3;
    layout.minimumInteritemSpacing = spacing;
    layout.minimumLineSpacing = spacing;
    CGFloat side = (MIN(SCREEN_WIDTH, SCREEN_HEIGHT) - spacing * 3) / 4;
    layout.itemSize = CGSizeMake(side, side);
    self.collectionView.contentInset = UIEdgeInsetsMake(spacing, 0, spacing, 0);
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.alwaysBounceVertical = YES;
    [self.collectionView registerNib:[UINib nibWithNibName:@"AGNPhotoCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:kPhotoCellReuseIdentifier];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.isMovingToParentViewController) {
        self.navigationController.toolbarHidden = NO;
    }
    if (self.selectedPhotosIndexes.count) {
        self.previewBarButtonItem.enabled = YES;
        self.doneBarButtonItem.enabled = YES;
        self.infoBarButtonItem.title = [NSString stringWithFormat:@"%ld Selected", (long)self.selectedPhotosIndexes.count];
    } else {
        self.previewBarButtonItem.enabled = NO;
        self.doneBarButtonItem.enabled = NO;
        self.infoBarButtonItem.title = nil;
    }
    [self.collectionView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    if (self.isMovingFromParentViewController) {
        self.navigationController.toolbarHidden = YES;
    }
    [super viewWillDisappear:animated];
}

- (void)setAlbum:(AGNAlbum *)album {
    _album = album;
    [_album loadAspectRatioThumbnailsAsynchronously];
}

#pragma mark - Private
- (void)p_configureToolBar {
    UIBarButtonItem *flexibleSpaceBarButton1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *flexibleSpaceBarButton2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *previewBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Preview" style:UIBarButtonItemStylePlain target:self action:@selector(preview:)];
    previewBarButtonItem.tintColor = [UIColor blackColor];
    [previewBarButtonItem setTitleTextAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:kBarButtomItemFontSize]} forState:UIControlStateNormal];
    
    UIBarButtonItem *infoBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:nil style:UIBarButtonItemStylePlain target:nil action:nil];
    infoBarButtonItem.tintColor = [UIColor lightGrayColor];
    [infoBarButtonItem setTitleTextAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:kBarButtomItemFontSize]} forState:UIControlStateNormal];
    
    UIBarButtonItem *doneBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
    doneBarButtonItem.tintColor = HEXCOLOR(0x08BB08);
    [doneBarButtonItem setTitleTextAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:kBarButtomItemFontSize]} forState:UIControlStateNormal];
    
    UIBarButtonItem *fixedSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedSpacer.width = 57 - 40;
    
    self.toolbarItems = @[previewBarButtonItem, flexibleSpaceBarButton1, infoBarButtonItem,flexibleSpaceBarButton2, fixedSpacer, doneBarButtonItem];
    
    self.previewBarButtonItem = previewBarButtonItem;
    self.infoBarButtonItem = infoBarButtonItem;
    self.doneBarButtonItem = doneBarButtonItem;
    self.previewBarButtonItem.enabled = NO;
    self.doneBarButtonItem.enabled = NO;
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
    if (index < self.album.aspectRatioThumbnails.count) {
        [cell setImage:[self.album.aspectRatioThumbnails objectAtIndex:index]];
    } else {
        [cell setImage:[UIImage imageWithCGImage:((ALAsset *)[self.album.assets objectAtIndex:index]).aspectRatioThumbnail scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp]];
    }
    cell.selectionImageView.image = [self.selectedPhotosIndexes containsObject:@(index)] ? [UIImage imageNamed:@"Selection"] : [UIImage imageNamed:@"ToSelection"];
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
    [self.navigationController pushViewController:pageVC animated:YES];
}

#pragma mark - Action
- (void)cancel:(UIBarButtonItem *)sender {
    AGNPhotosPickerController *picker = (AGNPhotosPickerController *)self.navigationController;
    if ([picker.pickerDelegate respondsToSelector:@selector(photosPickerControllerDidCancel:)]) {
        [picker.pickerDelegate photosPickerControllerDidCancel:picker];
    } else {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
    }
}

- (void)preview:(UIBarButtonItem *)sender {
#warning
}

- (void)done:(UIBarButtonItem *)sender {
    AGNPhotosPickerController *picker = (AGNPhotosPickerController *)self.navigationController;
    if ([picker.pickerDelegate respondsToSelector:@selector(photosPickerController:didFinishPickingPhotos:)]) {
        NSMutableArray *photos = [NSMutableArray array];
        for (NSNumber *indexNumber in self.selectedPhotosIndexes) {
            NSUInteger index = [indexNumber unsignedIntegerValue];
            ALAsset *asset = [self.album.assets objectAtIndex:index];
            ALAssetRepresentation *representation = asset.defaultRepresentation;
            UIImage *image = [[UIImage alloc] initWithCGImage:representation.fullResolutionImage scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
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
        cell.selectionImageView.image = [UIImage imageNamed:@"ToSelection"];
    } else {
        [self.selectedPhotosIndexes addObject:@(index)];
        cell.selectionImageView.image = [UIImage imageNamed:@"Selection"];
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
@end
