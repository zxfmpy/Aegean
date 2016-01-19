//
//  AGNPhotosPickerController.h
//  Aegean
//
//  Created by 李凌峰 on 1/7/16.
//  Copyright © 2016 SoulBeats. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AGNPhotosPickerController;
@protocol AGNPhotosPickerControllerDelegate <NSObject>
- (void)photosPickerControllerDidCancel:(AGNPhotosPickerController *)picker;
- (void)photosPickerController:(AGNPhotosPickerController *)picker didFinishPickingPhotos:(NSArray *)photos;
@end

@interface AGNPhotosPickerController : UINavigationController
@property (nonatomic, weak) id<AGNPhotosPickerControllerDelegate> pickerDelegate;
@property (nonatomic, strong) UIColor *tintColor;
@end
