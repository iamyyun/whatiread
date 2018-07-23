//
//  MenuViewController.h
//  whatiread
//
//  Created by Yunju on 2018. 6. 7..
//  Copyright © 2018년 Yunju Yang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSInteger
{
    MENU_BOOKSHELF = 0,   // bookshelf
    MENU_BOOKMARK,   // bookmark
    MENU_SETTINGS       // settings
} MENU_BTN_TYPE;

@interface MenuViewController : CommonViewController

@end
