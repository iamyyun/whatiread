//
//  SettingViewController.h
//  whatiread
//
//  Created by Yunju on 2018. 8. 17..
//  Copyright © 2018년 Yunju Yang. All rights reserved.
//

#import "CommonViewController.h"

@interface SettingViewController : CommonViewController

@property (weak, nonatomic) IBOutlet UISwitch *switchView;
- (IBAction)switchAction:(id)sender;

@end
