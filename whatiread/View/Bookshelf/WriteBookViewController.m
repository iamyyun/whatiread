//
//  WriteBookViewController.m
//  whatiread
//
//  Created by Yunju on 2018. 8. 3..
//  Copyright © 2018년 Yunju Yang. All rights reserved.
//

#import "WriteBookViewController.h"
#import "LSLDatePickerDialog.h"

@interface WriteBookViewController () <UITextFieldDelegate, RateViewDelegate> {
    UITapGestureRecognizer *bgTap;
    
    NSDate *publishDate;
    NSDate *startDate;
    NSDate *compDate;
    
    BOOL isEdited;
}

@end

@implementation WriteBookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setNaviBarType:BAR_ADD title:@"책 등록" image:nil];
    
    isEdited = NO;
    
    startDate = [NSDate date];
    compDate = [NSDate date];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy.MM.dd"];
    NSString *strDate = [format stringFromDate:compDate];
    
    self.startDateTextField.text = strDate;
    self.compDateTextField.text = strDate;
    
    [self.rateView setStarFillColor:[UIColor colorWithHexString:@"F0C330"]];
    [self.rateView setStarNormalColor:[UIColor lightGrayColor]];
    [self.rateView setCanRate:YES];
    [self.rateView setStarSize:30.f];
    [self.rateView setStep:0.5f];
    [self.rateView setDelegate:self];
    
    if (self.isModifyMode) {
        if (self.book) {
            
            publishDate = self.book.publishDate;
            startDate = self.book.startDate;
            compDate = self.book.completeDate;
            NSDateFormatter *format = [[NSDateFormatter alloc] init];
            [format setDateFormat:@"yyyy.MM.dd"];
            
            [self.titleTextField setText:self.book.title];
            [self.authorTextField setText:self.book.author];
            [self.publishTextField setText:self.book.publisher];
            [self.pubDateTextField setText:[format stringFromDate:publishDate]];
            [self.startDateTextField setText:[format stringFromDate:startDate]];
            [self.compDateTextField setText:[format stringFromDate:compDate]];
            [self.rateView setRating:self.book.rate];
            [self.rateLabel setText:[NSString stringWithFormat:@"%g", self.book.rate]];
            
            // set NavigationBar
            [self setNaviBarType:BAR_ADD title:@"책 수정" image:nil];
            
            if ([self isCheckField]) {
                [self.navigationItem.rightBarButtonItem setEnabled:YES];
            } else {
                [self.navigationItem.rightBarButtonItem setEnabled:NO];
            }
        }
    } else {
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
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

// check all necessary field
- (BOOL)isCheckField {
    NSString *strTitle = self.titleTextField.text;
    NSString *strAuthor = self.authorTextField.text;
    NSString *strCompDate = self.compDateTextField.text;
    float strRate = self.rateView.rating;
    
    if (strTitle.length > 0 && strAuthor.length > 0 && strCompDate.length > 0 && strRate > 0.0f) {
        return YES;
    } else {
        return NO;
    }
}

- (void) writeFinished {
    [self.view endEditing:YES];
}

// set blocks
- (void)setWriteBookCompositionHandler:(Book *)book writeBookCreateCompleted:(WriteBookCreateCompleted)writeBookCreateCompleted writeBookModifyCompleted:(WriteBookModifyCompleted)writeBookModifyCompleted
{
    self.book = book;
    self.writeBookCreateCompleted = writeBookCreateCompleted;
    self.writeBookModifyCompleted = writeBookModifyCompleted;
}

#pragma mark - Navigation Bar Action
- (void)leftBarBtnClick:(id)sender {
    
    if (isEdited) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Close", @"") message:@"작성중인 글이 있습니다." preferredStyle:UIAlertControllerStyleActionSheet];
        
        NSString *strFirst = @"계속 쓰기";
        NSString *strSecond = @"삭제하고 나가기";
        NSString *strThird = @"저장하고 나가기";
        UIAlertAction *firstAction = [UIAlertAction actionWithTitle:strFirst style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            
        }];
        UIAlertAction *secondAction = [UIAlertAction actionWithTitle:strSecond style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self popController:YES];
        }];
        UIAlertAction *thirdAction = [UIAlertAction actionWithTitle:strThird style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self rightBarBtnClick:nil];
        }];
        
        [alert addAction:firstAction];
        [alert addAction:secondAction];
        [alert addAction:thirdAction];
        [self presentController:alert animated:YES];
    } else {
        [self popController:YES];
    }
    
//    if (self.isModifyMode) {
//        [self popController:YES];
//    }
//    else {
//        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Close", @"") message:@"작성중인 글이 있습니다." preferredStyle:UIAlertControllerStyleActionSheet];
//
//        NSString *strFirst = @"계속 쓰기";
//        NSString *strSecond = @"삭제하고 나가기";
//        NSString *strThird = @"저장하고 나가기";
//        UIAlertAction *firstAction = [UIAlertAction actionWithTitle:strFirst style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
//
//        }];
//        UIAlertAction *secondAction = [UIAlertAction actionWithTitle:strSecond style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//            [self popController:YES];
//        }];
//        UIAlertAction *thirdAction = [UIAlertAction actionWithTitle:strThird style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//            [self rightBarBtnClick:nil];
//        }];
//
//        [alert addAction:firstAction];
//        [alert addAction:secondAction];
//        [alert addAction:thirdAction];
//        [self presentController:alert animated:YES];
//    }
}

- (void)rightBarBtnClick:(id)sender
{
    if (self.titleTextField.text.length <= 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Please write title.", @"") message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
        [alert addAction:okAction];
        [self presentController:alert animated:YES];
    } else if (self.authorTextField.text.length <= 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"저자를 입력해주세요." message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
        [alert addAction:okAction];
        [self presentController:alert animated:YES];
    } else if (self.rateView.rating == 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"평점을 매겨주세요." message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
        [alert addAction:okAction];
        [self presentController:alert animated:YES];
    }
    else {
        if (self.isModifyMode) {
            if (self.writeBookModifyCompleted) {
                NSMutableDictionary *bookDic = [NSMutableDictionary dictionary];
                [bookDic setObject:self.titleTextField.text forKey:@"bTitle"];
                [bookDic setObject:self.authorTextField.text forKey:@"bAuthor"];
                [bookDic setObject:self.publishTextField.text forKey:@"bPublisher"];
                [bookDic setObject:startDate forKey:@"bStartDate"];
                [bookDic setObject:compDate forKey:@"bCompleteDate"];
                if (publishDate) [bookDic setObject:publishDate forKey:@"bPubDate"];
                [bookDic setObject:[NSNumber numberWithFloat:self.rateView.rating] forKey:@"bRate"];
                
                self.writeBookModifyCompleted(bookDic);
            }
        } else {
            // create bookmark data
            if (self.writeBookCreateCompleted) {
                NSMutableDictionary *bookDic = [NSMutableDictionary dictionary];
                [bookDic setObject:self.titleTextField.text forKey:@"bTitle"];
                [bookDic setObject:self.authorTextField.text forKey:@"bAuthor"];
                [bookDic setObject:self.publishTextField.text forKey:@"bPublisher"];
                [bookDic setObject:startDate forKey:@"bStartDate"];
                [bookDic setObject:compDate forKey:@"bCompleteDate"];
                if (publishDate) [bookDic setObject:publishDate forKey:@"bPubDate"];
                
                [bookDic setObject:[NSNumber numberWithFloat:self.rateView.rating] forKey:@"bRate"];
                self.writeBookCreateCompleted(bookDic);
            }
        }
        [self popController:YES];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    NSString *strTitle = @"";
    if (textField == self.pubDateTextField) {
        strTitle = @"출판일";
    }
    else if (textField == self.startDateTextField) {
        strTitle = @"시작일";
    }
    else if (textField == self.compDateTextField) {
        strTitle = @"완독일";
    }
    
    LSLDatePickerDialog *dpDialog = [[LSLDatePickerDialog alloc] init];
    if (textField == self.pubDateTextField) {
        [dpDialog showWithTitle:@"출판일" doneButtonTitle:@"확인" cancelButtonTitle:@"취소" defaultDate:[NSDate date] datePickerMode:UIDatePickerModeDate callback:^(NSDate *date) {
            if (date) {
                publishDate = date;
                NSDateFormatter *format = [[NSDateFormatter alloc] init];
                [format setDateFormat:@"yyyy.MM.dd"];
                NSString *strDate = [format stringFromDate:date];
                textField.text = strDate;
            }
        }];
        return NO;
    }
    else if (textField == self.startDateTextField) {
        [dpDialog showWithTitle:@"시작일" doneButtonTitle:@"확인" cancelButtonTitle:@"취소" defaultDate:[NSDate date] datePickerMode:UIDatePickerModeDate callback:^(NSDate *date) {
            if (date) {
                startDate = date;
                NSDateFormatter *format = [[NSDateFormatter alloc] init];
                [format setDateFormat:@"yyyy.MM.dd"];
                NSString *strDate = [format stringFromDate:date];
                textField.text = strDate;
            }
        }];
        return NO;
    }
    else if (textField == self.compDateTextField) {
        [dpDialog showWithTitle:@"완독일" doneButtonTitle:@"확인" cancelButtonTitle:@"취소" defaultDate:[NSDate date] datePickerMode:UIDatePickerModeDate callback:^(NSDate *date) {
            if (date) {
                compDate = date;
                NSDateFormatter *format = [[NSDateFormatter alloc] init];
                [format setDateFormat:@"yyyy.MM.dd"];
                NSString *strDate = [format stringFromDate:date];
                textField.text = strDate;
            }
        }];
        return NO;
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    isEdited = YES;
    if ([self isCheckField]) {
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
    } else {
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
    }
}

#pragma mark - RateView Delegate
- (void)rateView:(RateView *)rateView didUpdateRating:(float)rating {
    [self performSelector:@selector(setRate) withObject:nil afterDelay:0.1];
}

- (void)setRate {
    [self.rateLabel setText:[NSString stringWithFormat:@"%g", self.rateView.rating]];
    
    if ([self isCheckField]) {
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
    } else {
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
    }
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
