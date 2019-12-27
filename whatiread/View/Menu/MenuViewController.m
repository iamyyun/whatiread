//
//  MenuViewController.m
//  whatiread
//
//  Created by Yunju on 2018. 6. 7..
//  Copyright © 2018년 Yunju Yang. All rights reserved.
//

#import "MenuViewController.h"
#import "BookmarkViewController.h"
#import "BookShelfViewController.h"
#import "SettingViewController.h"

@interface MenuViewController () {
    NSMutableArray *menuList;
}

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    menuList = [NSMutableArray array];
    [menuList addObject:@{@"title":@"Bookshelf",
                          @"image":@"icon_menu_bookshelf_color"
                          }];
    [menuList addObject:@{@"title":@"Bookmark",
                          @"image":@"icon_menu_bookmark_color"
                          }];
    [menuList addObject:@{@"title":@"Settings",
                          @"image":@"icon_menu_setting_color"
                          }];
    
    [self drawViews];
}

- (void)drawViews
{
    CGFloat viewWidth = CGRectGetWidth(self.view.frame) - 110.0f;
    
    UIImageView *logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    [logoView setFrame:CGRectMake(viewWidth/2-(190/2), 100, 176, 104)];
    [self.view addSubview:logoView];
    
    CGFloat iPosY = 100.f;
    for (int i = 0; i < menuList.count; i++) {
        
        NSDictionary *dic = [[NSDictionary alloc] initWithDictionary:menuList[i] copyItems:YES];
        
        CGFloat btnWidth = 0.f;
        
        NSString *btnTitle = NSLocalizedString(dic[@"title"], @"");
        CGFloat titleWidth = [btnTitle boundingRectWithSize:CGSizeMake(1000, 16) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15.0f]} context:nil].size.width;
        
        UIButton *menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:dic[@"image"]]];
        [menuBtn addSubview:imgView];
        
        UILabel *label = [[UILabel alloc] init];
        [label setText:btnTitle];
        [label setFont:[UIFont systemFontOfSize:15.f]];
        [label setTextColor:[UIColor colorWithHexString:@"333333"]];
        [label setTextAlignment:NSTextAlignmentCenter];
        [menuBtn addSubview:label];
        
        if (titleWidth >= 45) {
            btnWidth = titleWidth;
        } else {
            btnWidth = 45;
        }
        
        [label setFrame:CGRectMake(0, 45, btnWidth, 16)];
        [imgView setFrame:CGRectMake((btnWidth/2)-(45/2), 0, 45, 45)];
        
        [menuBtn setFrame:CGRectMake((viewWidth/2-(btnWidth/2)), 100+iPosY, btnWidth, 61)];
        [menuBtn setTag:i];
        [menuBtn setBackgroundColor:[UIColor clearColor]];
        [menuBtn addTarget:self action:@selector(onClickedMenuBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:menuBtn];
        
        iPosY += (45 + 45);
    }
}

- (void)onClickedMenuBtn:(id)sender
{
    NSInteger menuIndex = [sender tag];
    if (menuIndex == MENU_BOOKMARK) {
        if (![SHAREDAPPDELEGATE.navigationController.topViewController isKindOfClass:[BookmarkViewController class]]) {
            BookmarkViewController *bmVC = [[BookmarkViewController alloc] init];
            [self pushNoHistory:bmVC animated:NO];
        }
    }
    else if (menuIndex == MENU_BOOKSHELF) {
        if (![SHAREDAPPDELEGATE.navigationController.topViewController isKindOfClass:[BookShelfViewController class]]) {
//            BookShelfViewController *bsVC = [[BookShelfViewController alloc] init];
//            [self pushNoHistory:bsVC animated:YES];
            [self popToRootController:NO];
        }
    }
    else if (menuIndex == MENU_SETTINGS) {
        if (![SHAREDAPPDELEGATE.navigationController.topViewController isKindOfClass:[SettingViewController class]]) {
            SettingViewController *setVC = [[SettingViewController alloc] init];
            [self pushNoHistory:setVC animated:YES];
        }
    }
    [SHAREDAPPDELEGATE.frostedViewController hideMenuViewController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
