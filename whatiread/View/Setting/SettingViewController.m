//
//  SettingViewController.m
//  whatiread
//
//  Created by Yunju on 2018. 8. 17..
//  Copyright © 2018년 Yunju Yang. All rights reserved.
//

#import "SettingViewController.h"

@interface SettingViewController ()

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSString *strStat = [[NSUserDefaults standardUserDefaults] objectForKey:SWITCH_STATUS];
    if (!strStat || strStat.length <= 0) {
        strStat = SWITCH_ON;
    }
    if ([strStat isEqualToString:SWITCH_ON]) {
        [self.switchView setOn:YES];
    } else if ([strStat isEqualToString:SWITCH_OFF]) {
        [self.switchView setOn:NO];
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

#pragma mark - Actions
- (IBAction)switchAction:(id)sender {
    BOOL state = [sender isOn];
    
    [[NSUserDefaults standardUserDefaults] setObject:state ? SWITCH_ON : SWITCH_OFF forKey:SWITCH_STATUS];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end
