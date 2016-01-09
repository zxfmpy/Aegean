//
//  Marcos.h
//  Aegean
//
//  Created by 李凌峰 on 1/9/16.
//  Copyright © 2016 SoulBeats. All rights reserved.
//

#ifndef Marcos_h
#define Marcos_h

#define SCREEN_WIDTH  ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

#define Font(x)                         [UIFont systemFontOfSize : x]
#define ItalicFont(x)                   [UIFont italicSystemFontOfSize:x]
#define BoldFont(x)                     [UIFont boldSystemFontOfSize : x]

#define RGBCOLOR(r, g, b)               [UIColor colorWithRed : (r) / 255.0f green : (g) / 255.0f blue : (b) / 255.0f alpha : 1]
#define RGBACOLOR(r, g, b, a)           [UIColor colorWithRed : (r) / 255.0f green : (g) / 255.0f blue : (b) / 255.0f alpha : (a)]

#define HEXCOLOR(hexValue)              [UIColor colorWithRed : ((CGFloat)((hexValue & 0xFF0000) >> 16)) / 255.0 green : ((CGFloat)((hexValue & 0xFF00) >> 8)) / 255.0 blue : ((CGFloat)(hexValue & 0xFF)) / 255.0 alpha : 1.0]

#define HEXACOLOR(hexValue, alphaValue) [UIColor colorWithRed : ((CGFloat)((hexValue & 0xFF0000) >> 16)) / 255.0 green : ((CGFloat)((hexValue & 0xFF00) >> 8)) / 255.0 blue : ((CGFloat)(hexValue & 0xFF)) / 255.0 alpha : (alphaValue)]

#endif /* Marcos_h */
