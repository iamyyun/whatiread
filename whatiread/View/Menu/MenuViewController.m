//
//  MenuViewController.m
//  whatiread
//
//  Created by Yunju on 2018. 6. 7..
//  Copyright © 2018년 Yunju Yang. All rights reserved.
//

#import "MenuViewController.h"

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
    [menuList addObject:@{@"title":@"Bookmark",
                          @"image":@"bookmark"
                          }];
    [menuList addObject:@{@"title":@"Bookshelf",
                          @"image":@"bookshelf"
                          }];
    [menuList addObject:@{@"title":@"Settings",
                          @"image":@"settings"
                          }];
    
    [self drawViews];
}

- (void)drawViews
{
    CGFloat viewWidth = CGRectGetWidth(self.view.frame) - 110.0f;
    
    NSString *strTitle = @"whatiread";
    CGFloat width = [strTitle boundingRectWithSize:CGSizeMake(1000, 21) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20.0f]} context:nil].size.width;
    UILabel *logo = [[UILabel alloc] initWithFrame:CGRectMake(viewWidth/2-(width/2), 100, width, 21)];
    [logo setText:@"whatiread"];
    [logo setTextColor:[UIColor darkGrayColor]];
    [self.view addSubview:logo];
    
    CGFloat iPosY = 100.f;
    for (int i = 0; i < menuList.count; i++) {
        
        NSDictionary *dic = [[NSDictionary alloc] initWithDictionary:menuList[i] copyItems:YES];
        
        NSString *btnTitle = NSLocalizedString(dic[@"title"], @"");
        CGFloat titleWidth = [btnTitle boundingRectWithSize:CGSizeMake(1000, 15) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0f]} context:nil].size.width;
        UIButton *menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [menuBtn setTitle:btnTitle forState:UIControlStateNormal];
//        [menuBtn.titleLabel setText:btnTitle];
        [menuBtn.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [menuBtn setImage:[UIImage imageNamed:dic[@"image"]] forState:UIControlStateNormal];
        menuBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 10, 15, 10);
        [menuBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        menuBtn.titleEdgeInsets = UIEdgeInsetsMake(30, -(30+titleWidth), 0, 0);
        [menuBtn setFrame:CGRectMake((viewWidth/2-(50/2)), 100+iPosY, 100, 50)];
        [menuBtn setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [menuBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        [menuBtn setTag:i];
        [menuBtn addTarget:self action:@selector(onClickedMenuBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:menuBtn];
        
        iPosY += (45 + 45);
    }
}

- (void)onClickedMenuBtn:(id)sender
{
    NSInteger menuIndex = [sender tag];
    if (menuIndex == MENU_BOOKMARK) {
        [SHAREDAPPDELEGATE.frostedViewController hideMenuViewController];
    }
    else if (menuIndex == MENU_BOOKSHELF) {
        
    }
    else if (menuIndex == MENU_SETTINGS) {
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
