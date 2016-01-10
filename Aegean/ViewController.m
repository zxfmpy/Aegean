//
//  ViewController.m
//  Aegean
//
//  Created by 李凌峰 on 1/7/16.
//  Copyright © 2016 SoulBeats. All rights reserved.
//

#import "ViewController.h"
#import "AGNPhotosPickerController.h"

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
    photosPicker.delegate = self;
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
