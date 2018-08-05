//
//  AddBookmarkViewController.m
//  whatiread
//
//  Created by Yunju on 2018. 7. 25..
//  Copyright © 2018년 Yunju Yang. All rights reserved.
//

#import "AddBookmarkViewController.h"

@interface AddBookmarkViewController () <UITextViewDelegate> {
    UITapGestureRecognizer *bgTap;
}

@end

@implementation AddBookmarkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setNaviBarType:BAR_ADD title:@"책갈피 등록" image:nil];
    
//    [self.textView becomeFirstResponder];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.textView setContentInset:UIEdgeInsetsMake(5, 5, 5, 5)];
    
    if (self.book) {
        if (self.isModifyMode) {
            if (self.book.quotes.count > 0) {
                NSSortDescriptor *desc = [NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES];
                NSArray *quoteArr = [self.book.quotes sortedArrayUsingDescriptors:[NSArray arrayWithObject:desc]];
                Quote *quote = quoteArr[self.indexPath.item];
                [self.textView setText:quote.data];
            }
        }
        
        [self.titleLabel setText:self.book.title];
    }
    
    if (self.strOcrText && self.strOcrText.length > 0) {
        [self.textView setText:self.strOcrText];
    }
    
    // Add Observer
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillShowNote:) name:UIKeyboardWillShowNotification object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillHideNote:) name:UIKeyboardWillHideNotification object:self.view.window];
    bgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(writeFinished)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) writeFinished {
    [self.view endEditing:YES];
}

- (void)setBookmarkCompositionHandler:(Book *)book bookmarkCreateCompleted:(BookmarkCreateCompleted)bookmarkCreateCompleted
{
    self.book = book;
    self.bookmarkCreateCompleted = bookmarkCreateCompleted;
}

#pragma mark - Navigation Action
- (void)leftBarBtnClick:(id)sender {
    [self popController:YES];
}

- (void)rightBarBtnClick:(id)sender {
    if (self.textView.text.length <= 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"책갈피를 입력해주세요." message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
        [alert addAction:okAction];
        [self presentController:alert animated:YES];
    }
    if (self.bookmarkCreateCompleted) {
        self.bookmarkCreateCompleted(self.textView.text);
        [self popController:YES];
    }
}

#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    
}

#pragma mark - keyboard actions
- (void)handleKeyboardWillShowNote:(NSNotification *)notification
{
    [self.view addGestureRecognizer:bgTap];
    
    NSDictionary* userInfo = [notification userInfo];
    
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
}

- (void)handleKeyboardWillHideNote:(NSNotification *)notification
{
    [self.view removeGestureRecognizer:bgTap];
    
    NSDictionary* userInfo = [notification userInfo];
    
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
}

@end
