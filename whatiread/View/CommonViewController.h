//
//  ViewController.h
//  whatiread
//
//  Created by Yunju on 2018. 5. 30..
//  Copyright © 2018년 Yunju Yang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSInteger {
    BAR_NONE = 0,
    BAR_MENU,     // menu - title - search
    BAR_BACK,       // back - title
    BAR_ADD,        // cancel - title - btn(save)
    BAR_EDIT,        // back - title - btn(edit) btn(delete)
} NAVI_BAR_TYPE;

typedef enum : NSInteger
{
    BTN_TYPE_MENU = 0,   // menu
    BTN_TYPE_BACK   // btn
} LEFT_BTN_TYPE;

typedef enum : NSInteger
{
    BTN_TYPE_DELETE = 0,   // delete
    BTN_TYPE_EDIT   // edit
} RIGHT_BTN_TYPE;

@interface CommonViewController : UIViewController

// Navigation Bar
- (void)setNaviBarType:(NAVI_BAR_TYPE)type title:(NSString *)title image:(UIImage *)image;

- (void)leftBarBtnClick:(id)sender;
- (void)rightBarBtnClick:(id)sender;

- (void)showMenu;

// controller navigate
- (void)popController:(BOOL)animated;
- (void)popController:(NSInteger)index animated:(BOOL)animated;
- (void)popToRootController:(BOOL)animated;
- (void)pushController:(UIViewController *)vc animated:(BOOL)animated;
- (void)pushAndIgnoreHistory:(UIViewController *)vc animated:(BOOL)animated;
- (void)pushNoHistory:(UIViewController *)vc animated:(BOOL)animated;
- (void)presentController:(UIViewController *)vc animated:(BOOL)animated;
- (void)dismissController:(UIViewController *)vc animated:(BOOL)animated
;

@end

