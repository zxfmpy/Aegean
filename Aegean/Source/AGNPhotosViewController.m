//
//  AGNPhotosViewController.m
//  Aegean
//
//  Created by 李凌峰 on 1/10/16.
//  Copyright © 2016 SoulBeats. All rights reserved.
//

#import "AGNPhotosViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "AGNPhotosPickerController.h"
#import "AGNPhotoCell.h"
#import "Marcos.h"
#import "UIView+SLAdditions.h"

@interface AGNPhotosViewController ()
@property (nonatomic, weak) UIBarButtonItem *previewBarButtonItem;
@property (nonatomic, weak) UIBarButtonItem *doneBarButtonItem;
@property (nonatomic, strong) NSMutableArray *selectedPhotosIndexes;
@property (nonatomic, strong) UILabel *infoLabel;
@end

@implementation AGNPhotosViewController

static NSString * const kPhotoCellReuseIdentifier = @"PhotoCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.selectedPhotosIndexes = [NSMutableArray array];
    self.title = self.album.name;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:kBarButtomItemFontSize]} forState:UIControlStateNormal];
    [self p_configureToolBar];
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    CGFloat spacing = 2;
    layout.minimumInteritemSpacing = spacing;
    layout.minimumLineSpacing = spacing;
    CGFloat side = ([UIScreen mainScreen].bounds.size.width - spacing * 3) / 4;
    layout.itemSize = CGSizeMake(side, side);
    self.collectionView.contentInset = UIEdgeInsetsMake(spacing, 0, spacing, 0);
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.alwaysBounceVertical = YES;
    [self.collectionView registerNib:[UINib nibWithNibName:@"AGNPhotoCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:kPhotoCellReuseIdentifier];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.toolbarHidden = NO;
    [self.navigationController.toolbar addSubview:self.infoLabel];
}

- (void)viewWillDisappear:(BOOL)animated {
    self.navigationController.toolbarHidden = YES;
    [self.infoLabel removeFromSuperview];
    [super viewWillDisappear:animated];
}

#pragma mark <Private>
- (void)p_configureToolBar {
    UIBarButtonItem *flexibleSpaceBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *previewBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Preview" style:UIBarButtonItemStylePlain target:self action:@selector(preview:)];
    previewBarButtonItem.tintColor = [UIColor blackColor];
    [previewBarButtonItem setTitleTextAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:kBarButtomItemFontSize]} forState:UIControlStateNormal];
    UIBarButtonItem *doneBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
    doneBarButtonItem.tintColor = HEXCOLOR(0x08BB08);
    [doneBarButtonItem setTitleTextAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:kBarButtomItemFontSize]} forState:UIControlStateNormal];
    self.toolbarItems = @[previewBarButtonItem, flexibleSpaceBarButton, doneBarButtonItem];
    
    self.previewBarButtonItem = previewBarButtonItem;
    self.doneBarButtonItem = doneBarButtonItem;
    self.previewBarButtonItem.enabled = NO;
    self.doneBarButtonItem.enabled = NO;
    
    self.infoLabel = [[UILabel alloc] init];
    self.infoLabel.font = [UIFont systemFontOfSize:kBarButtomItemFontSize];
    self.infoLabel.textColor = [UIColor grayColor];
    self.infoLabel.backgroundColor = [UIColor clearColor];
    self.infoLabel.textAlignment = NSTextAlignmentCenter;
    self.infoLabel.frame = CGRectMake(0, 0, self.navigationController.toolbar.width - (57 + 40), self.navigationController.toolbar.height);
    self.infoLabel.center = CGPointMake(self.navigationController.toolbar.width / 2.0, self.navigationController.toolbar.height / 2.0);
}

#pragma mark <UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.album.photos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AGNPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPhotoCellReuseIdentifier forIndexPath:indexPath];
    NSUInteger index = indexPath.row;
    ALAsset *asset = (ALAsset *)[self.album.photos objectAtIndex:index];
    [cell setImage:[UIImage imageWithCGImage:asset.aspectRatioThumbnail]];
    cell.selectionImageView.image = [self.selectedPhotosIndexes containsObject:@(index)] ? [UIImage imageNamed:@"Selection.png"] : [UIImage imageNamed:@"ToSelection.png"];
    cell.selectionButton.tag = index;
    [cell.selectionButton addTarget:self action:@selector(selectPhoto:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

#pragma mark <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO:
}

#pragma mark <Action>
- (void)cancel:(UIBarButtonItem *)sender {
    AGNPhotosPickerController *picker = (AGNPhotosPickerController *)self.navigationController;
    if ([picker.delegate respondsToSelector:@selector(photosPickerControllerDidCancel:)]) {
        [picker.delegate photosPickerControllerDidCancel:picker];
    } else {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
    }
}

- (void)preview:(UIBarButtonItem *)sender {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)done:(UIBarButtonItem *)sender {
    AGNPhotosPickerController *picker = (AGNPhotosPickerController *)self.navigationController;
    if ([picker.delegate respondsToSelector:@selector(photosPickerController:didFinishPickingPhotos:)]) {
        NSMutableArray *photos = [NSMutableArray array];
        for (NSNumber *indexNumber in self.selectedPhotosIndexes) {
            NSUInteger index = [indexNumber unsignedIntegerValue];
            ALAsset *asset = [self.album.photos objectAtIndex:index];
            ALAssetRepresentation *representation = asset.defaultRepresentation;
            UIImage *image = [[UIImage alloc] initWithCGImage:representation.fullResolutionImage scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
            [photos addObject:image];
        }
        [picker.delegate photosPickerController:picker didFinishPickingPhotos:[photos copy]];
    } else {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
    }
}

- (void)selectPhoto:(UIButton *)sender {
    NSUInteger index = sender.tag;
    AGNPhotoCell *cell = (AGNPhotoCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    if ([self.selectedPhotosIndexes containsObject:@(index)]) {
        [self.selectedPhotosIndexes removeObject:@(index)];
        cell.selectionImageView.image = [UIImage imageNamed:@"ToSelection.png"];
    } else {
        [self.selectedPhotosIndexes addObject:@(index)];
        cell.selectionImageView.image = [UIImage imageNamed:@"Selection.png"];
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
        self.infoLabel.text = [NSString stringWithFormat:@"%ld Selected", (long)self.selectedPhotosIndexes.count];
    } else {
        self.previewBarButtonItem.enabled = NO;
        self.doneBarButtonItem.enabled = NO;
        self.infoLabel.text = nil;
    }
}
@end
