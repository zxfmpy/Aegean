//
//  AGNPhotosPickerController.m
//  Aegean
//
//  Created by 李凌峰 on 1/7/16.
//  Copyright © 2016 SoulBeats. All rights reserved.
//

#import "AGNPhotosPickerController.h"
#import "AGNAlbumsViewController.h"

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
    
    // Appearance
    self.navigationBar.barTintColor = HEXCOLOR(0x38373C);
    self.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    self.navigationBar.barStyle = UIBarStyleBlackTranslucent;
}

@end
