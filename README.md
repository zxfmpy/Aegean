# Aegean
Aegean is a photos picker controller (Objective-C & AssetLibrary), which give you access to pick multiple photos from your Photos application. Its UI and UX is inspired from WeChat and Photos.

![Screenshot1](Screenshots/Screenshot_1.png)![Screenshot2](Screenshots/Screenshot_2.png)![Screenshot3](Screenshots/Screenshot_3.png)

##Requirements
* iOS 7+


##Setup Instruments
Add `Source` directory to your project.

##Usage
Use it like `UIImagePickerController`, and use its apis to customize:

```objc
@class AGNPhotosPickerController;
@protocol AGNPhotosPickerControllerDelegate <NSObject>
- (void)photosPickerControllerDidCancel:(AGNPhotosPickerController *)picker;
- (void)photosPickerController:(AGNPhotosPickerController *)picker didFinishPickingPhotoAssets:(NSArray *)photoAssets;
@end

@interface AGNPhotosPickerController : UINavigationController
@property (nonatomic, weak) id<AGNPhotosPickerControllerDelegate> pickerDelegate;
@property (nonatomic, strong) UIColor *tintColor; // Color for selection appearance and done item
@property (nonatomic, assign) NSUInteger maximumNumberOfSelectedPhotos;
@end
```

##MIT License
```
The MIT License (MIT)

Copyright (c) 2015 Soul

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

