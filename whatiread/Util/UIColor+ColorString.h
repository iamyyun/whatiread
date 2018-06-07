//
//  UIColor+ColorString.h
// livebank
//
//  Created by Choi Wonsik on 2015. 9.
//  Copyright (c) 2014년 ATsolutions. All rights reserved.
//

#import <UIKit/UIKit.h>

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed: ((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 green: ((float)((rgbValue & 0xFF00) >> 8)) / 255.0 blue: ((float)(rgbValue & 0xFF)) / 255.0 alpha: 1.0]
#define UIColorFromRGBWithAlpha(rgbValue, a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]

@interface UIColor (ColorString)
+ (UIColor *)colorWithRGBHex:(UInt32)hex;
+ (UIColor *)colorWithHexString:(NSString *)stringToConvert;//16진수 컬러값 문자열로 색상생성
+ (UIColor *)colorFromRGB:(int)red green:(int)green blue:(int)blue;
+ (CGFloat)getAlphaFromHex:(NSString *)aHexString;

@end
