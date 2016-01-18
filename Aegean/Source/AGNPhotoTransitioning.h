//
//  AGNPhotoTransitioning.h
//  Aegean
//
//  Created by LingFeng-Li on 1/18/16.
//  Copyright © 2016 SoulBeats. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol AGNPhotoTransitioning <NSObject>
@optional
- (UIImageView *)targetImageViewWhenPushing;
- (CGRect)targetRectWhenPoppingAtIndex:(NSUInteger)index;
- (UIImageView *)targetImageViewWhenPoppingAtIndex:(NSUInteger)index;
@end
