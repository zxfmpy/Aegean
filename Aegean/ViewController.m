//
//  ViewController.m
//  Aegean
//
//  Created by 李凌峰 on 1/7/16.
//  Copyright © 2016 SoulBeats. All rights reserved.
//

#import "ViewController.h"
#import "AGNPhotosPickerController.h"
#import "Marcos.h"

@interface ViewController () <AGNPhotosPickerControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showPhotosPicker:(id)sender {
    AGNPhotosPickerController *photosPicker = [[AGNPhotosPickerController alloc] init];
    photosPicker.pickerDelegate = self;
    photosPicker.tintColor = HEXCOLOR(0x18b4ed);
    photosPicker.maximumNumberOfPhotos = 5;
    [self presentViewController:photosPicker animated:YES completion:NULL];
}

- (void)photosPickerControllerDidCancel:(AGNPhotosPickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:NULL];
    return;
}

- (void)photosPickerController:(AGNPhotosPickerController *)picker didFinishPickingPhotos:(NSArray *)photos {
    NSLog(@"%@", photos);
    [self dismissViewControllerAnimated:YES completion:NULL];
}
@end
