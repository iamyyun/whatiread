//
//  BookmarkDetailViewController.m
//  whatiread
//
//  Created by Yunju on 2018. 8. 4..
//  Copyright © 2018년 Yunju Yang. All rights reserved.
//

#import "BookmarkDetailViewController.h"
#import "BookDetailViewController.h"
#import "AddBookmarkViewController.h"

@interface BookmarkDetailViewController () <UITextViewDelegate>

@end

@implementation BookmarkDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setNaviBarType:BAR_EDIT title:@"책갈피 수정" image:nil];
    
    if (self.isFromBookshelf) {
        [self.arrowImgView setHidden:YES];
        self.titleLabelTrailingMarginConst.constant = 60.f;
        self.authorLabelTrailingMarginConst.constant = 60.f;
    } else {
        [self.arrowImgView setHidden:NO];
        self.titleLabelTrailingMarginConst.constant = 15.f;
        self.authorLabelTrailingMarginConst.constant = 15.f;
    }
    
    if (self.book) {
        [self.titleLabel setText:self.book.title];
        [self.authorLabel setText:self.book.author];
        if (self.book.quotes.count > 0) {
            NSSortDescriptor *desc = [NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES];
            NSArray *quoteArr = [self.book.quotes sortedArrayUsingDescriptors:[NSArray arrayWithObject:desc]];
            Quote *quote = quoteArr[self.indexPath.item];
            [self.textView setText:quote.data];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation Actions
- (void)leftBarBtnClick:(id)sender {
    [self popController:YES];
}

- (void)rightBarBtnClick:(id)sender {
    switch ([sender tag]) {
        case BTN_TYPE_DELETE:
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Delete", @"") message:NSLocalizedString(@"Do you really want to delete?", @"") preferredStyle:UIAlertControllerStyleActionSheet];
            
            NSString *strFirst = NSLocalizedString(@"Deleting", @"");
            NSString *strSecond = NSLocalizedString(@"Cancel", @"");
            UIAlertAction *firstAction = [UIAlertAction actionWithTitle:strFirst style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                //                [self deleteBook:self.indexPath];
            }];
            UIAlertAction *secondAction = [UIAlertAction actionWithTitle:strSecond style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self dismissController:alert animated:YES];
            }];
            
            [alert addAction:firstAction];
            [alert addAction:secondAction];
            [self presentController:alert animated:YES];
        }
            break;
        case BTN_TYPE_EDIT:
        {
            AddBookmarkViewController *addVC = [[AddBookmarkViewController alloc] init];
            addVC.isModifyMode = YES;
            addVC.indexPath = self.indexPath;
            addVC.book = self.book;
            [self pushController:addVC animated:YES];
        }
            break;
        default:
            break;
    }
}

#pragma mark - Actions
- (IBAction)bookBtnAction:(id)sender {
    BookDetailViewController *detailVC = [[BookDetailViewController alloc] init];
    detailVC.book = self.book;
    [self pushController:detailVC animated:YES];
}


@end
