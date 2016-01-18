//
//  AGNAlbum.m
//  Aegean
//
//  Created by 李凌峰 on 1/9/16.
//  Copyright © 2016 SoulBeats. All rights reserved.
//

#import "AGNAlbum.h"
#import <objc/runtime.h>

@interface AGNAlbum ()
@property (nonatomic, strong) NSMutableArray *aspectRatioThumbnails;
@end

@implementation AGNAlbum
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.assets = [NSMutableArray array];
        self.aspectRatioThumbnails = [NSMutableArray array];
    }
    return self;
}

- (NSString *)description
{
    NSMutableString *propertyDescriptions = [NSMutableString stringWithString:@""];
    for (NSString *key in [self describablePropertyNames])
    {
        id value = [self valueForKey:key];
        [propertyDescriptions appendFormat:@"; %@ = %@", key, value];
    }
    return propertyDescriptions;
}

- (NSArray *)describablePropertyNames
{
    // Loop through our superclasses until we hit NSObject
    NSMutableArray *array = [NSMutableArray array];
    Class subclass = [self class];
    while (subclass != [NSObject class])
    {
        unsigned int propertyCount;
        objc_property_t *properties = class_copyPropertyList(subclass,&propertyCount);
        for (int i = 0; i < propertyCount; i++)
        {
            // Add property name to array
            objc_property_t property = properties[i];
            const char *propertyName = property_getName(property);
            [array addObject:@(propertyName)];
        }
        free(properties);
        subclass = [subclass superclass];
    }
    
    // Return array of property names
    return array;
}

- (void)loadAspectRatioThumbnailsAsynchronously {
    if (self.aspectRatioThumbnails.count < self.assets.count) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            for (int i = (int)self.aspectRatioThumbnails.count; i < self.assets.count; i++) {
                ALAsset *asset = [self.assets objectAtIndex:i];
                [self.aspectRatioThumbnails addObject:[UIImage imageWithCGImage:asset.aspectRatioThumbnail scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp]];
            }
        });
    }
}

- (UIImage *)fullResolutionImageAtIndex:(NSUInteger)index {
    UIImage *image = nil;
    if (index < self.assets.count) {
        ALAsset *asset = [self.assets objectAtIndex:index];
        image = [[UIImage alloc] initWithCGImage:asset.defaultRepresentation.fullResolutionImage scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
    }
    return image;
}

- (UIImage *)aspectRatioThumbnailAtIndex:(NSUInteger)index {
    UIImage *thumbnail = nil;
    if (index < self.aspectRatioThumbnails.count) {
        thumbnail = [self.aspectRatioThumbnails objectAtIndex:index];
    } else if (index < self.assets.count) {
        thumbnail = [UIImage imageWithCGImage:((ALAsset *)[self.assets objectAtIndex:index]).aspectRatioThumbnail scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
    }
    return thumbnail;
}
@end
