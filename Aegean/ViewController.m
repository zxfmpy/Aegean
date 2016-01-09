//
//  ViewController.m
//  Aegean
//
//  Created by 李凌峰 on 1/7/16.
//  Copyright © 2016 SoulBeats. All rights reserved.
//

#import "ViewController.h"
#import "AGNPhotosPickerController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self showPhotosPicker:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showPhotosPicker:(id)sender {
    AGNPhotosPickerController *photosPicker = [[AGNPhotosPickerController alloc] init];
    [self presentViewController:photosPicker animated:YES completion:NULL];
}
@end
