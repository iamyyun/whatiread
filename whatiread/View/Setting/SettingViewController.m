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
    
    [self.savePicLabel setText:NSLocalizedString(@"Save Picture Automatically", @"")];
    [self.backupLabel setText:NSLocalizedString(@"Data Backup(iCloud)", @"")];
    
    NSString *strStat = [[NSUserDefaults standardUserDefaults] objectForKey:SWITCH_SAVEPIC_STATUS];
    if (!strStat || strStat.length <= 0) {
        strStat = SWITCH_SAVEPIC_ON;
    }
    if ([strStat isEqualToString:SWITCH_SAVEPIC_ON]) {
        [self.savePicSwitch setOn:YES];
    } else if ([strStat isEqualToString:SWITCH_SAVEPIC_OFF]) {
        [self.savePicSwitch setOn:NO];
    }
    
    
    NSString *strStatBu = [[NSUserDefaults standardUserDefaults] objectForKey:SWITCH_BACKUP_STATUS];
    if (!strStatBu || strStatBu.length <= 0) {
        strStatBu = SWITCH_BACKUP_OFF;
    }
    if ([strStatBu isEqualToString:SWITCH_BACKUP_ON]) {
        [self.backupSwitch setOn:YES];
    } else if ([strStatBu isEqualToString:SWITCH_BACKUP_OFF]) {
        [self.backupSwitch setOn:NO];
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
- (IBAction)savePicSwitchAction:(id)sender {
    BOOL state = [sender isOn];
    
    [[NSUserDefaults standardUserDefaults] setObject:state ? SWITCH_SAVEPIC_ON : SWITCH_SAVEPIC_OFF forKey:SWITCH_SAVEPIC_STATUS];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)backupSwitchAction:(id)sender {
}
@end
