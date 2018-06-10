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
    self.navigationItem.title = @"Today's date";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation Bar Actions
- (void)leftBarBtnClick:(id)sender
{
    NSString *strTitle = self.titleLabel.text;
    NSString *strAuthor = self.authorLabel.text;
    NSString *strQuotes = self.quoteLabel.text;
    
    if (strTitle.length > 0 && strAuthor.length > 0 && strQuotes > 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Close", @"") message:NSLocalizedString(@"작성중인 글이 있습니다.", @"") preferredStyle:UIAlertControllerStyleActionSheet];
        
        NSString *strFirst = NSLocalizedString(@"Keep writing", @"");
        NSString *strSecond = NSLocalizedString(@"Delete & Leave", @"");
        NSString *strThird = NSLocalizedString(@"Save & Leave", @"");
        UIAlertAction *firstAction = [UIAlertAction actionWithTitle:strFirst style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];
        UIAlertAction *secondAction = [UIAlertAction actionWithTitle:strSecond style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSLog(@"YJ << delete");
        }];
        UIAlertAction *thirdAction = [UIAlertAction actionWithTitle:strThird style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            NSLog(@"YJ << save");
        }];
        
        [alert addAction:firstAction];
        [alert addAction:secondAction];
        [alert addAction:thirdAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        [self popController:YES];
    }
}

- (void)rightBarBtnClick:(id)sender
{
    NSLog(@"YJ << save book data");
}

#pragma mark - Actions
- (IBAction)addPicBtnAction:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    NSString *strFirst = NSLocalizedString(@"Take Photo", @"");
    NSString *strSecond = NSLocalizedString(@"Add from Library", @"");
    UIAlertAction *firstAction = [UIAlertAction actionWithTitle:strFirst style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        NSLog(@"YJ << take photo");
    }];
    UIAlertAction *secondAction = [UIAlertAction actionWithTitle:strSecond style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSLog(@"YJ << add from library");
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){}];
    
    [alert addAction:firstAction];
    [alert addAction:secondAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}
@end
