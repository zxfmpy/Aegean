//
//  AGNPageViewController.h
//  Aegean
//
//  Created by LingFeng-Li on 1/13/16.
//  Copyright © 2016 SoulBeats. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AGNAlbum.h"

@class AGNPageViewController;
@protocol AGNPageViewControllerDelegate <NSObject>
- (void)pageViewController:(AGNPageViewController *)pageViewController didSelectPhotoAtIndex:(NSUInteger)index;
- (void)pageViewControllerDidResetPhotoSelections:(AGNPageViewController *)pageViewController;
@end

@interface AGNPageViewController : UIPageViewController
@property (nonatomic, strong) AGNAlbum *album;
@property (nonatomic, strong) NSMutableArray *selectedPhotosIndexes;
@property (nonatomic, assign) NSUInteger startingIndex;
@property (nonatomic, weak) id<AGNPageViewControllerDelegate> photoDelegate;
@end
