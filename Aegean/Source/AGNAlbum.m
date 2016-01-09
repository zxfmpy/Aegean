//
//  AGNAlbum.m
//  Aegean
//
//  Created by 李凌峰 on 1/9/16.
//  Copyright © 2016 SoulBeats. All rights reserved.
//

#import "AGNAlbum.h"
#import <objc/runtime.h> 

@implementation AGNAlbum
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.photos = [NSMutableArray array];
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
@end
