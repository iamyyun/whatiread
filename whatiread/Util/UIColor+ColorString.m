//
//  UIColor+ColorString.m
// livebank
//
//  Created by Choi Wonsik on 2015. 9.
//  Copyright (c) 2014년 ATsolutions. All rights reserved.
//

#import "UIColor+ColorString.h"

@implementation UIColor (ColorString)
+ (UIColor *)colorWithRGBHex:(UInt32)hex {
	int r = (hex >> 16) & 0xFF;
	int g = (hex >> 8) & 0xFF;
	int b = (hex) & 0xFF;
    
	return [UIColor colorWithRed:r / 255.0f
						   green:g / 255.0f
							blue:b / 255.0f
						   alpha:1.0f];
}


+ (UIColor *)colorWithRGBHexAlpha:(UInt32)hex {
	int r = (hex >> 24) & 0xFF;
	int g = (hex >> 16) & 0xFF;
	int b = (hex >> 8) & 0xFF;
    int a = (hex) & 0xFF;
	
	return [UIColor colorWithRed:r / 255.0f
						   green:g / 255.0f
							blue:b / 255.0f
						   alpha:a / 255.0f];
}



/**
   헥사 문자열을 alpha값으로 변환
 */
+ (CGFloat)getAlphaFromHex:(NSString *)aHexString {
    
    NSScanner *scanner = [NSScanner scannerWithString:aHexString];
    unsigned hex;
    if (![scanner scanHexInt: &hex]) {
        return 1.0;
    }
    
    int a = (hex) & 0xFF;
    return (a / 255.0f);
    
}


// Returns a UIColor by scanning the string for a hex number and passing that to +[UIColor colorWithRGBHex:]
// Skips any leading whitespace and ignores any trailing characters
+ (UIColor *)colorWithHexString:(NSString *)stringToConvert {
	NSScanner *scanner = [NSScanner scannerWithString:stringToConvert];
	unsigned hexNum;
	if (![scanner scanHexInt:&hexNum]) return nil;
	
	if(6 < [stringToConvert length]) {
		return [UIColor colorWithRGBHexAlpha:hexNum];
	}
	else {
		return [UIColor colorWithRGBHex:hexNum];
	}
}

+ (UIColor *)colorFromRGB:(int)red green:(int)green blue:(int)blue
{
    return [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:1.0];
}
 
@end
