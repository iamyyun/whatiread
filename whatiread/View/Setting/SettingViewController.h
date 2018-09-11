//
//  SettingViewController.h
//  whatiread
//
//  Created by Yunju on 2018. 8. 17..
//  Copyright © 2018년 Yunju Yang. All rights reserved.
//

#import "CommonViewController.h"

@interface SettingViewController : CommonViewController

@property (weak, nonatomic) IBOutlet UILabel *savePicLabel;
@property (weak, nonatomic) IBOutlet UILabel *backupLabel;
@property (weak, nonatomic) IBOutlet UISwitch *savePicSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *backupSwitch;
- (IBAction)savePicSwitchAction:(id)sender;
- (IBAction)backupSwitchAction:(id)sender;

@end
