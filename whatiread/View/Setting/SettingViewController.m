//
//  SettingViewController.m
//  whatiread
//
//  Created by Yunju on 2018. 8. 17..
//  Copyright © 2018년 Yunju Yang. All rights reserved.
//

#import "SettingViewController.h"
#import <CloudKit/CloudKit.h>

@interface SettingViewController () {
    CoreDataAccess *coreData;
}

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.navigationController setNavigationBarHidden:NO];
    [self setNaviBarType:BAR_BACK title:NSLocalizedString(@"Settings", @"") image:nil];
    
    coreData = [CoreDataAccess sharedInstance];
    
    [self.savePicLabel setText:NSLocalizedString(@"Save Picture Automatically", @"")];
    [self.backupLabel setText:NSLocalizedString(@"Data Backup(iCloud)", @"")];
    
    // save picture
    NSString *strStat = [[NSUserDefaults standardUserDefaults] objectForKey:SWITCH_SAVEPIC_STATUS];
    if (!strStat || strStat.length <= 0) {
        strStat = SWITCH_SAVEPIC_ON;
    }
    if ([strStat isEqualToString:SWITCH_SAVEPIC_ON]) {
        [self.savePicSwitch setOn:YES];
    } else if ([strStat isEqualToString:SWITCH_SAVEPIC_OFF]) {
        [self.savePicSwitch setOn:NO];
    }
    
    // backup data
    self.backupBtn.layer.cornerRadius = 5.f;
    
    NSString *strDate = @"";
    NSDate *date = [[NSUserDefaults standardUserDefaults] objectForKey:BACKUP_DATE];
    NSString *strBuDate = [NSDate NSDateChangeToNSString:date];
    if (!strBuDate || strBuDate.length <= 0) {
        strDate = NSLocalizedString(@"The backup data not exist.", @"");
    } else {
        strDate = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"The latest backup date is", @""), strBuDate];
    }
    [self.backupDescLabel setText:strDate];
    
    // top Constraint
    if ([self isiPad]) {
        self.topConstraint.constant = 64.f;
    } else {
        if ([self isAfteriPhoneX]) {
            self.topConstraint.constant = 88.f;
        } else {
            self.topConstraint.constant = 64.f;
        }
    }
    [self updateViewConstraints];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [CloudKitManager fetchAllBooksWithCompletionHandler:^(NSArray *result, NSError *error) {
    }];
    
    [CloudKitManager fetchAllQuotesWithCompletionHandler:^(NSArray *results, NSError *error) {
    }];
}

#pragma mark - Actions
- (IBAction)savePicSwitchAction:(id)sender {
    BOOL state = [sender isOn];
    
    [[NSUserDefaults standardUserDefaults] setObject:state ? SWITCH_SAVEPIC_ON : SWITCH_SAVEPIC_OFF forKey:SWITCH_SAVEPIC_STATUS];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)actionBackupBtn:(id)sender {
    NSArray *bookArr = [coreData getAllBooks];
    if (bookArr.count > 0) {
        if ([CloudKitManager isiCloudAccountIsSignedIn]) { // icloud account is signed in
            
            [[CKContainer defaultContainer] accountStatusWithCompletionHandler:^(CKAccountStatus accountStatus, NSError * _Nullable error) {
                if (error) {
                    [self showAlertViewController:NSLocalizedString(@"iCloud is not available.", @"") msg:NSLocalizedString(@"iCloud is temporarily unavailable.", @"")];
                } else {
                    if (accountStatus == CKAccountStatusAvailable) {
                        // need another uiWindow in ios13
//                        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//                        [appDelegate.alertWindow makeKeyAndVisible];
                        
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Do you want to backup your data in iCloud?", @"") message:nil preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
//                            [appDelegate.alertWindow setHidden:YES];
                        }];
                        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//                            [appDelegate.alertWindow setHidden:YES];
                            [self dismissViewControllerAnimated:YES completion:nil];
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [IndicatorUtil startProcessIndicator];
                            });
                            
                            // Delete All iCloud Data
                            [CloudKitManager fetchAllQuotesWithCompletionHandler:^(NSArray *results, NSError *error) {
                                if (!error || error.code == 11) {
                                    if (results && results.count > 0) {
                                        [CloudKitManager removeQuoteRecord:results completionHandler:^(NSArray *results, NSError *error) {
                                            if (!error) {
                                                [self deleteBooksAndBackup];
                                            } else {
                                                [IndicatorUtil stopProcessIndicator];
                                                [self.view makeToast:NSLocalizedString(@"Data backup failed!", @"")];
                                            }
                                        }];
                                    } else {
                                        [self deleteBooksAndBackup];
                                    }
                                } else {
                                    [IndicatorUtil stopProcessIndicator];
                                    [self.view makeToast:NSLocalizedString(@"Data backup failed!", @"")];
                                }
                            }];
                        }];
                        [alert addAction:cancelAction];
                        [alert addAction:okAction];
                        [self presentController:alert animated:YES];
//                        [appDelegate.alertWindow.rootViewController presentViewController:alert animated:YES completion:nil];
                    } else {
                        [self showAlertViewController:NSLocalizedString(@"iCloud is not available.", @"") msg:NSLocalizedString(@"iCloud is temporarily unavailable.", @"")];
                    }
                }
            }];
            
        } else {
            [self showAlertViewController:NSLocalizedString(@"iCloud is disabled.", @"") msg:NSLocalizedString(@"iCloud is disalbed. Please enable iCloud Drive in Settings->iCloud.", @"")];
        }
    } else {
        [self showAlertViewController:NSLocalizedString(@"There is no data to backup.", @"") msg:nil];
    }
}

#pragma mark - Common
- (void)deleteBooksAndBackup {
    [CloudKitManager fetchAllBooksWithCompletionHandler:^(NSArray *result, NSError *error) {
        if (!error || error.code == 11) {
            if (result && result.count > 0) {
                [CloudKitManager removeBookRecord:result completionHandler:^(NSArray *results, NSError *error) {
                    if (!error) {
                        // back up data
                        [self backupCoreDataToiCloud];
                    } else {
                        [IndicatorUtil stopProcessIndicator];
                        [self.view makeToast:NSLocalizedString(@"Data backup failed!", @"")];
                    }
                }];
            } else {
                [self backupCoreDataToiCloud];
            }
        } else {
            [IndicatorUtil stopProcessIndicator];
            [self.view makeToast:NSLocalizedString(@"Data backup failed!", @"")];
        }
    }];
}

- (void)backupCoreDataToiCloud {
    
    NSArray *bookArr = [coreData getAllBooks];
    NSMutableArray *muQuoteArr = [NSMutableArray array];
    for (int i = 0; i < bookArr.count; i++) {
        Book *book = bookArr[i];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
        NSArray *quoteArr = [book.quotes sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        [muQuoteArr addObjectsFromArray:quoteArr];
    }
    
    // Create Book CKRecord
    [CloudKitManager createBookRecord:bookArr completionHandler:^(NSArray *result, NSError *error) {
        if (error) {
            [IndicatorUtil stopProcessIndicator];
            NSLog(@"YJ << book backup error : %@", error.userInfo[NSLocalizedDescriptionKey]);
            [self.view makeToast:NSLocalizedString(@"Data backup succeeded!", @"")];
        } else {
            if (muQuoteArr.count > 0) {
                // Create Quote CKRecord
                [CloudKitManager createQuoteRecord:muQuoteArr completionHandler:^(NSArray *result, NSError *error) {
                    if (error) {
                        NSLog(@"YJ << quote backup error : %@", error.userInfo[NSLocalizedDescriptionKey]);
                        [IndicatorUtil stopProcessIndicator];
                        [self.view makeToast:NSLocalizedString(@"Data backup failed!", @"")];
                    } else {
                        [self.view makeToast:NSLocalizedString(@"Data backup succeeded!", @"")];
                        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:BACKUP_DATE];
                        
                        NSString *strDate = @"";
                        NSDate *date = [[NSUserDefaults standardUserDefaults] objectForKey:BACKUP_DATE];
                        NSString *strBuDate = [NSDate NSDateChangeToNSString:date];
                        if (!strBuDate || strBuDate.length <= 0) {
                            strDate = NSLocalizedString(@"The backup data not exist.", @"");
                        } else {
                            strDate = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"The latest backup date is", @""), strBuDate];
                        }
                        [self.backupDescLabel setText:strDate];
                        [self.view layoutIfNeeded];
                        
                        [IndicatorUtil stopProcessIndicator];
                    }
                }];
            } else {
                [self.view makeToast:NSLocalizedString(@"Data backup succeeded!", @"")];
                [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:BACKUP_DATE];
                
                NSString *strDate = @"";
                NSDate *date = [[NSUserDefaults standardUserDefaults] objectForKey:BACKUP_DATE];
                NSString *strBuDate = [NSDate NSDateChangeToNSString:date];
                if (!strBuDate || strBuDate.length <= 0) {
                    strDate = NSLocalizedString(@"The backup data not exist.", @"");
                } else {
                    strDate = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"The latest backup date is", @""), strBuDate];
                }
                [self.backupDescLabel setText:strDate];
                [self.view layoutIfNeeded];
                
                [IndicatorUtil stopProcessIndicator];
            }
        }
    }];
}

- (void)showAlertViewController:(NSString *)title msg:(NSString *)msg {
//    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    [appDelegate.alertWindow makeKeyAndVisible];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
    }];
    [alert addAction:okAction];
    
    [self presentController:alert animated:YES];
}

@end
