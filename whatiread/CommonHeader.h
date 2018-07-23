//
//  CommonHeader.h
//  whatiread
//
//  Created by Yunju on 2018. 5. 30..
//  Copyright © 2018년 Yunju Yang. All rights reserved.
//

#import "AppDelegate.h"
#import "CommonViewController.h"
#import "AdminConnectionManager.h"
#import "UIColor+ColorString.h"
#import "XMLDictionary.h"

// App Delegate Object
#define SHAREDAPPDELEGATE ((AppDelegate *)[[UIApplication sharedApplication] delegate])

// current version
#define CUR_VERSION     [NSString stringWithFormat:@"%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]]

