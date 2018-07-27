//
//  ViewController.m
//  whatiread
//
//  Created by Yunju on 2018. 5. 30..
//  Copyright © 2018년 Yunju Yang. All rights reserved.
//

#import "CommonViewController.h"

@interface CommonViewController () <UINavigationControllerDelegate> {
    UILabel *titleLabel;
    UIButton *leftBtn;
    UIButton *rightBtn;
}

@end

@implementation CommonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    SHAREDAPPDELEGATE.navigationController.interactivePopGestureRecognizer.delegate = self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation Bar
- (void)setNaviBarType:(NAVI_BAR_TYPE)type title:(NSString *)title image:(UIImage *)image
{
    [SHAREDAPPDELEGATE.navigationController.navigationBar setHidden:NO];
    if (type == BAR_NONE) {
        [SHAREDAPPDELEGATE.navigationController.navigationBar setHidden:YES];
    }
    else if (type == BAR_MENU) {
        // titleView
        if (title && title.length > 0) {
            UIView *centerView = [[UIView alloc] initWithFrame:CGRectZero];
            [centerView setBackgroundColor:[UIColor whiteColor]];
            
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
//            [imgView setImage:[UIImage imageNamed:@"icon_bookmark"]];
            [imgView setImage:image];
            [centerView addSubview:imgView];
            
            NSString *strTitle = title;
            CGFloat width = [strTitle boundingRectWithSize:CGSizeMake(1000, 44) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18.0f]} context:nil].size.width;
            titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(44, 0, width, 44)];
            [titleLabel setText:strTitle];
            [titleLabel setTextColor:[UIColor darkGrayColor]];
            [centerView addSubview:titleLabel];
            
            [centerView setFrame:CGRectMake(0, 0, 44+width, 44)];
            self.navigationItem.titleView = centerView;
        }

        // leftBarButton
        leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [leftBtn setImage:[UIImage imageNamed:@"btn_menu"] forState:UIControlStateNormal];
        [leftBtn setTag:BTN_TYPE_MENU];
        [leftBtn addTarget:self action:@selector(leftBarBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [leftBtn setFrame:CGRectMake(0, 5, 34, 34)];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
        
        // rightBarButton
        rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [rightBtn setImage:[UIImage imageNamed:@"btn_search"] forState:UIControlStateNormal];
        [rightBtn addTarget:self action:@selector(rightBarBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [rightBtn setFrame:CGRectMake(0, 5, 34, 34)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    }
    else if (type == BAR_BACK) {
        // leftBarButton
        leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [leftBtn setImage:[UIImage imageNamed:@"btn_back"] forState:UIControlStateNormal];
        [leftBtn setTag:BTN_TYPE_BACK];
        [leftBtn addTarget:self action:@selector(leftBarBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [leftBtn setFrame:CGRectMake(0, 5, 34, 34)];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
        
        if (title && title.length > 0) {
//            self.navigationItem.title = NSLocalizedString(title, @"");
//            UIView *centerView = [[UIView alloc] initWithFrame:CGRectZero];
//            [centerView setBackgroundColor:[UIColor whiteColor]];
//
            NSString *strTitle = NSLocalizedString(title, @"");
//            CGFloat width = [strTitle boundingRectWithSize:CGSizeMake(1000, 44) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18.0f]} context:nil].size.width;
            titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 64, 44)];
            [titleLabel setText:strTitle];
            [titleLabel setTextColor:[UIColor darkGrayColor]];
            [titleLabel setFont:[UIFont systemFontOfSize:17.f]];
            [titleLabel setAdjustsFontSizeToFitWidth:YES];
            [titleLabel setTextAlignment:NSTextAlignmentCenter];
//            [centerView addSubview:titleLabel];
            
//            [centerView setFrame:CGRectMake(0, 0, 44+width, 44)];
            self.navigationItem.titleView = titleLabel;
        }
    }
    else if (type == BAR_ADD) {
        // titleView
        if (title && title.length > 0) {
            UIView *centerView = [[UIView alloc] initWithFrame:CGRectZero];
            [centerView setBackgroundColor:[UIColor whiteColor]];
            
            NSString *strTitle = NSLocalizedString(title, @"");
//            CGFloat width = [strTitle boundingRectWithSize:CGSizeMake(1000, 44) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18.0f]} context:nil].size.width;
            titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 64, 44)];
            [titleLabel setText:strTitle];
            [titleLabel setTextColor:[UIColor darkGrayColor]];
            [titleLabel setFont:[UIFont systemFontOfSize:17.f]];
            [titleLabel setAdjustsFontSizeToFitWidth:YES];
            [titleLabel setTextAlignment:NSTextAlignmentCenter];
//            [centerView addSubview:titleLabel];
            
//            [centerView setFrame:CGRectMake(0, 0, 44+width, 44)];
            self.navigationItem.titleView = titleLabel;
        }
        
        // leftBarButton
        leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [leftBtn setImage:[UIImage imageNamed:@"btn_back"] forState:UIControlStateNormal];
        [leftBtn setTag:BTN_TYPE_BACK];
        [leftBtn addTarget:self action:@selector(leftBarBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [leftBtn setFrame:CGRectMake(0, 5, 34, 34)];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
        
        // rightBarButton
        NSString *rightBtnTitle = NSLocalizedString(@"Save", @"");
        self.navigationItem.rightBarButtonItems = nil;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:rightBtnTitle style:UIBarButtonItemStylePlain target:self action:@selector(rightBarBtnClick:)];
    }
    else if (type == BAR_EDIT) {
        // titleView
        if (title && title.length > 0) {
            UIView *centerView = [[UIView alloc] initWithFrame:CGRectZero];
            [centerView setBackgroundColor:[UIColor whiteColor]];
            
            NSString *strTitle = NSLocalizedString(title, @"");
//            CGFloat width = [strTitle boundingRectWithSize:CGSizeMake(1000, 44) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18.0f]} context:nil].size.width;
            titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 64, 44)];
            [titleLabel setText:strTitle];
            [titleLabel setTextColor:[UIColor darkGrayColor]];
            [titleLabel setFont:[UIFont systemFontOfSize:17.f]];
            [titleLabel setAdjustsFontSizeToFitWidth:YES];
            [titleLabel setTextAlignment:NSTextAlignmentCenter];
//            [centerView addSubview:titleLabel];
            
//            [centerView setFrame:CGRectMake(0, 0, 44+width, 44)];
            self.navigationItem.titleView = titleLabel;
        }
        
        // leftBarButton
        leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [leftBtn setImage:[UIImage imageNamed:@"btn_back"] forState:UIControlStateNormal];
        [leftBtn addTarget:self action:@selector(leftBarBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [leftBtn setFrame:CGRectMake(0, 5, 34, 34)];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
        
        // rightBarButton
        NSString *rightBtnTitle1 = NSLocalizedString(@"Delete", @"");
        NSString *rightBtnTitle2 = NSLocalizedString(@"Edit", @"");
        UIBarButtonItem *delBtn = [[UIBarButtonItem alloc] initWithTitle:rightBtnTitle1 style:UIBarButtonItemStylePlain target:self action:@selector(rightBarBtnClick:)];
        [delBtn setTag:BTN_TYPE_DELETE];
        UIBarButtonItem *editBtn = [[UIBarButtonItem alloc] initWithTitle:rightBtnTitle2 style:UIBarButtonItemStylePlain target:self action:@selector(rightBarBtnClick:)];
        [editBtn setTag:BTN_TYPE_EDIT];
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:delBtn, editBtn, nil];
    }
}

#pragma mark - Bar Buttons Action
- (void)leftBarBtnClick:(id)sender
{
    if ([sender tag] == BTN_TYPE_MENU) {
        [self showMenu];
    }
    else if ([sender tag] == BTN_TYPE_BACK) {
        [self popController:YES];
    }
}

- (void)rightBarBtnClick:(id)sender
{
    [self popController:YES];
}

- (void)setFrame
{
    CGRect rect = [UIScreen mainScreen].bounds;
    
    rect.origin.y = 20 + 44;
    rect.size.height -= (20 + 44);
    
    self.view.frame = rect;
}

- (void)showMenu
{
    // Dismiss keyboard (optional)
    //
    [self.view endEditing:YES];
    [SHAREDAPPDELEGATE.frostedViewController.view endEditing:YES];
    
    // Present the view controller
    //
    [SHAREDAPPDELEGATE.frostedViewController presentMenuViewController];
}

#pragma - Navigation
- (void)popController:(BOOL)animated {
    [SHAREDAPPDELEGATE.navigationController popViewControllerAnimated:animated];
//    SHAREDAPPDELEGATE.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (void)popController:(NSInteger)index animated:(BOOL)animated {
    NSMutableArray *controllers = [[NSMutableArray alloc] initWithArray:SHAREDAPPDELEGATE.navigationController.viewControllers];
    [controllers removeObjectAtIndex:[controllers count] - index];
    [SHAREDAPPDELEGATE.navigationController setViewControllers:controllers animated:animated];
//    SHAREDAPPDELEGATE.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (void)pushController:(UIViewController *)vc animated:(BOOL)animated {
    [SHAREDAPPDELEGATE.navigationController pushViewController:vc animated:animated];
//    SHAREDAPPDELEGATE.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)pushAndIgnoreHistory:(UIViewController *)vc animated:(BOOL)animated {
    [SHAREDAPPDELEGATE.navigationController popViewControllerAnimated:NO];
    [SHAREDAPPDELEGATE.navigationController pushViewController:vc animated:animated];
//    SHAREDAPPDELEGATE.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)pushNoHistory:(UIViewController *)vc animated:(BOOL)animated {
    [SHAREDAPPDELEGATE.navigationController popToRootViewControllerAnimated:NO];
    [SHAREDAPPDELEGATE.navigationController pushViewController:vc animated:animated];
//    SHAREDAPPDELEGATE.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)presentController:(UIViewController *)vc animated:(BOOL)animated {
    [SHAREDAPPDELEGATE.navigationController presentViewController:vc animated:animated completion:nil];
}

- (void)dismissController:(UIViewController *)vc animated:(BOOL)animated
{
    [vc dismissViewControllerAnimated:animated completion:nil];
//    [SHAREDAPPDELEGATE.navigationController dismissViewControllerAnimated:animated completion:nil];
}

@end
