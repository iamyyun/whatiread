//
//  AddBookmarkViewController.m
//  whatiread
//
//  Created by Yunju on 2018. 6. 7..
//  Copyright © 2018년 Yunju Yang. All rights reserved.
//

#import "AddBookmarkViewController.h"

@interface AddBookmarkViewController ()

@end

@implementation AddBookmarkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // set navigation bar
    [self setNaviBarType:BAR_ADD];
    self.navigationItem.title = @"오늘 날짜";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)rightBarBtnClick:(id)sender
{
    NSLog(@"YJ << save book data");
}

@end
