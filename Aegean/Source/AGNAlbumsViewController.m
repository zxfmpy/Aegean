//
//  AGNAlbumsViewController.m
//  Aegean
//
//  Created by 李凌峰 on 1/9/16.
//  Copyright © 2016 SoulBeats. All rights reserved.
//

#import "AGNAlbumsViewController.h"
#import "UIViewController+SLAlert.h"
#import "AGNAlbumCell.h"

static const NSUInteger ALAssetsGroupScreenshots = (1 << 6);

@interface AGNAlbumsViewController ()
@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) NSMutableArray *albums;
@end

static NSString *const kAlbumCellReuseIdentifier = @"AlbumCell";
@implementation AGNAlbumsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Photos";
    self.albums = [NSMutableArray array];
    self.assetsLibrary = [[ALAssetsLibrary alloc] init];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{NSFontAttributeName: Font(15)} forState:UIControlStateNormal];
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.rowHeight = 90;
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"AGNAlbumCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:kAlbumCellReuseIdentifier];
    
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
        NSString *name = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"] ?: [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
        switch (error.code) {
            case ALAssetsLibraryAccessGloballyDeniedError:
            case ALAssetsLibraryAccessUserDeniedError: {
                if (&UIApplicationOpenSettingsURLString != NULL) {
                    [self showAlertWithTitle:@"Photos Denied" message:[NSString stringWithFormat:@"You can enable access in \"Settings-Privacy-Photos-%@\" or \"Settings-%@-Photos\".", name, name]  cancelButtonTitle:@"Settings" cancelActionHandler:^{
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                        [self.presentingViewController dismissViewControllerAnimated:NO completion:NULL];
                    } anotherButtonTitle:@"Cancel" anotherActionHandler:^{
                        [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
                    }];
                } else {
                    [self showAlertWithTitle:@"Photos Denied" message:[NSString stringWithFormat:@"You can enable access in \"Settings-Privacy-Photos-%@\" or \"Settings-%@-Photos\".", name, name]  cancelButtonTitle:@"Sure" cancelActionHandler:^{
                        [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
                    }];
                }
            }
                break;
            default: {
                [self showAlertWithTitle:@"Photos Unavailable" message:error.localizedFailureReason ?: @"Sorry, an unkown error appears when achieving photos." cancelButtonTitle:@"Sure" cancelActionHandler:^{
                    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
                }];
            }
                break;
        }
    };

    AGNAlbum *screenshotsAlbum = [[AGNAlbum alloc] init];
    screenshotsAlbum.name = @"Screenshots";
    screenshotsAlbum.type = ALAssetsGroupScreenshots;
    ALAssetsLibraryGroupsEnumerationResultsBlock enumerationBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
        [group setAssetsFilter:onlyPhotosFilter];
        
        if ([group numberOfAssets] > 0) {
            AGNAlbum *album = [[AGNAlbum alloc] init];
            album.name = [group valueForProperty:ALAssetsGroupPropertyName];
            album.type = [[group valueForProperty:ALAssetsGroupPropertyType] unsignedIntegerValue];
            ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (result) {
                    [album.photos addObject:result];
                    
                    // look for screenshot
                    if ([[group valueForProperty:ALAssetsGroupPropertyType] unsignedIntegerValue] == ALAssetsGroupSavedPhotos) {
                        ALAssetRepresentation *representation = result.defaultRepresentation;
                        if ([representation.UTI isEqualToString:@"public.png"]) {
                            [screenshotsAlbum.photos addObject:result];
                        }
                    }
                }
            };
            [group enumerateAssetsUsingBlock:assetsEnumerationBlock];
            [self.albums addObject:album];
        } else {
            if (![self.albums containsObject:screenshotsAlbum] && screenshotsAlbum.photos.count) {
                [self.albums addObject:screenshotsAlbum];
            }
            
            NSArray *sortedType = @[@(ALAssetsGroupSavedPhotos), @(ALAssetsGroupScreenshots), @(ALAssetsGroupPhotoStream), @(ALAssetsGroupEvent), @(ALAssetsGroupFaces), @(ALAssetsGroupAlbum), @(ALAssetsGroupLibrary), @(ALAssetsGroupAll)];
            [self.albums sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                AGNAlbum *album1 = (AGNAlbum *)obj1;
                AGNAlbum *album2 = (AGNAlbum *)obj2;
                ALAssetsGroupType albumType1 = album1.type;
                ALAssetsGroupType albumType2 = album2.type;
                NSUInteger index1 = [sortedType indexOfObject:@(albumType1)];
                NSUInteger index2 = [sortedType indexOfObject:@(albumType2)];
                if (index1 < index2) {
                    return NSOrderedAscending;
                } else if (index1 == index2) {
                    return NSOrderedSame;
                } else {
                    return NSOrderedDescending;
                }
            }];
            [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        }
    };
    
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:enumerationBlock failureBlock:failureBlock];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.albums.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AGNAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:kAlbumCellReuseIdentifier forIndexPath:indexPath];
    [cell setAlbum:[self.albums objectAtIndex:indexPath.row]];
    return cell;
}

#pragma mark - Action
- (void)cancel:(UIBarButtonItem *)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}
@end
