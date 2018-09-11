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
#import "IndicatorUtil.h"
#import "UIColor+ColorString.h"
#import "XMLDictionary.h"

// App Delegate Object
#define SHAREDAPPDELEGATE ((AppDelegate *)[[UIApplication sharedApplication] delegate])

// current version
#define CUR_VERSION     [NSString stringWithFormat:@"%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]]

// UserDefault Key
#define SWITCH_SAVEPIC_STATUS   @"SWITCH_SAVEPIC_STATUS"
#define SWITCH_BACKUP_STATUS    @"SWTICH_BACKUP_STATUS"

// UserDefault Value
#define SWITCH_SAVEPIC_ON       @"SWITCH_SAVEPIC_ON"
#define SWITCH_SAVEPIC_OFF      @"SWITCH_SAVEPIC_OFF"
#define SWITCH_BACKUP_ON        @"SWITCH_BACKUP_ON"
#define SWITCH_BACKUP_OFF       @"SWITCH_BACKUP_OFF"

