//
//  AGNImageScrollView.h
//  Aegean
//
//  Created by LingFeng-Li on 1/14/16.
//  Copyright © 2016 SoulBeats. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AGNImageScrollView;
@protocol AGNImageScrollViewDelegate <NSObject>
- (void)imageScrollView:(AGNImageScrollView *)imageScrollView didImageTapped:(UITapGestureRecognizer *)tap;
@end

@interface AGNImageScrollView : UIScrollView
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, weak) id<AGNImageScrollViewDelegate> imageDelegate;
@end
