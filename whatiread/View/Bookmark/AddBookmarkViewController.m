//
//  AddBookmarkViewController.m
//  whatiread
//
//  Created by Yunju on 2018. 6. 7..
//  Copyright © 2018년 Yunju Yang. All rights reserved.
//

#import "AddBookmarkViewController.h"
#import <Photos/Photos.h>
#import "LSLDatePickerDialog.h"

@interface AddBookmarkViewController () <UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    PHFetchResult *fetchResult;
    PHCachingImageManager *imgManager;
    
    UITapGestureRecognizer *bgTap;
    NSMutableArray *arrQuotes;
    
    NSDate *compDate;
    
    BOOL isEditing;     // in ModifyMode : editing/ not editing
}

@end

@implementation AddBookmarkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    compDate = [NSDate date];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy.MM.dd"];
    NSString *strDate = [format stringFromDate:compDate];
    self.compDateTextField.text = strDate;
    
    [self.compDateTextField resignFirstResponder];
    [self.compDateTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
    
    [self.rateView setStarFillColor:[UIColor colorWithHexString:@"F0C330"]];
    [self.rateView setStarNormalColor:[UIColor lightGrayColor]];
    [self.rateView setCanRate:YES];
    [self.rateView setStarSize:20.f];
    [self.rateView setStep:0.5f];
    
    // set navigation bar
    if (self.isModifyMode == NO) {
        [self setNaviBarType:BAR_ADD title:nil image:nil];
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd"];
        NSString *strDate = [df stringFromDate:[[NSDate alloc] init]];
        self.navigationItem.title = strDate;
        
        [self.placeholderLabel setHidden:NO];
        [self.addPicBtn setHidden:NO];
    } else {
        [self.navigationController setNavigationBarHidden:NO];
        [self setNaviBarType:BAR_EDIT title:nil image:nil];
        
        if (self.book) {
            UIImage *image = [UIImage imageWithData:self.book.quoteImg];
            NSMutableArray *quotes = [[NSMutableArray alloc] initWithArray:self.book.quote];
            
            compDate = self.book.completeDate;
            NSDateFormatter *format = [[NSDateFormatter alloc] init];
            [format setDateFormat:@"yyyy.MM.dd"];
            NSString *strDate = [format stringFromDate:compDate];
            
            [self.placeholderLabel setHidden:YES];
            [self.titleLabel setText:self.book.title];
            [self.authorLabel setText:self.book.author];
            [self.compDateTextField setText:strDate];
            [self.rateView setRating:self.book.rate];
            if (quotes && quotes.count > 0) {
                [self.quoteTextView setText:quotes[0]];
            }
            [self.picImageView setImage:image];
            
            [self.titleLabel setUserInteractionEnabled:NO];
            [self.authorLabel setUserInteractionEnabled:NO];
            [self.compDateTextField setUserInteractionEnabled:NO];
            [self.rateView setUserInteractionEnabled:NO];
            [self.quoteTextView setEditable:NO];
            
            [self.addPicBtn setHidden:YES];
        }
    }
    
    // test
    self.quoteTextView.layer.borderColor = [UIColor redColor].CGColor;
    self.quoteTextView.layer.borderWidth = 2.0f;
    
    arrQuotes = [NSMutableArray array];
    
    // Photo Framework
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    fetchResult = [PHAsset fetchAssetsWithOptions:options];
    imgManager = [[PHCachingImageManager alloc] init];
    
    // Add Observer
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillShowNote:) name:UIKeyboardWillShowNotification object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillHideNote:) name:UIKeyboardWillHideNotification object:self.view.window];
    
    bgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(writeFinished)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// set Blocks
- (void)setBookCompositionHandler:(Book *)book bookCreateCompleted:(BookCreateCompleted)bookCreateCompleted bookModifyCompleted:(BookModifyCompleted)bookModifyCompleted bookDeleteCompleted:(BookDeleteCompleted)bookDeleteCompleted
{
    self.book = book;
    self.bookCreateCompleted = bookCreateCompleted;
    self.bookModifyCompleted = bookModifyCompleted;
    self.bookDeleteCompleted = bookDeleteCompleted;
}

#pragma mark - Navigation Bar Actions
- (void)leftBarBtnClick:(id)sender
{
    // create mode
    if (self.isModifyMode == NO) {
        NSString *strTitle = self.titleLabel.text;
        NSString *strAuthor = self.authorLabel.text;
        NSString *strQuotes = self.quoteTextView.text;
        
        if (strTitle.length > 0 || strAuthor.length > 0 || strQuotes.length > 0) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Close", @"") message:NSLocalizedString(@"작성중인 글이 있습니다.", @"") preferredStyle:UIAlertControllerStyleActionSheet];
            
            NSString *strFirst = NSLocalizedString(@"Keep writing", @"");
            NSString *strSecond = NSLocalizedString(@"Delete & Leave", @"");
            NSString *strThird = NSLocalizedString(@"Save & Leave", @"");
            UIAlertAction *firstAction = [UIAlertAction actionWithTitle:strFirst style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                [alert dismissViewControllerAnimated:YES completion:nil];
            }];
            UIAlertAction *secondAction = [UIAlertAction actionWithTitle:strSecond style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self popController:YES];
                NSLog(@"YJ << delete");
            }];
            UIAlertAction *thirdAction = [UIAlertAction actionWithTitle:strThird style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                [self popController:YES];
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
    } else {    // modify mode
        [self popController:YES];
    }
}

- (void)rightBarBtnClick:(id)sender
{
    // create mode
    if (self.isModifyMode == NO) {
        if (self.titleLabel.text.length <= 0) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Please write title.", @"") message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
            [alert addAction:okAction];
            [self presentController:alert animated:YES];
        } else if (self.quoteTextView.text.length <= 0) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Please write quotes.", @"") message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
            [alert addAction:okAction];
            [self presentController:alert animated:YES];
        } else {
            // create bookmark data
            if (self.bookCreateCompleted) {
                NSMutableArray *arr = [[NSMutableArray alloc] initWithObjects:self.quoteTextView.text, nil];
                self.bookCreateCompleted(self.titleLabel.text, self.authorLabel.text, compDate, self.rateView.rating, arr, self.picImageView.image);
            }
            [self popController:YES];
        }
    }
    else {  // modify mode
        if (isEditing) {
            if (self.titleLabel.text.length <= 0) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Please write title.", @"") message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
                [alert addAction:okAction];
                [self presentController:alert animated:YES];
            } else if (self.quoteTextView.text.length <= 0) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Please write quotes.", @"") message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
                [alert addAction:okAction];
                [self presentController:alert animated:YES];
            } else {
                // create bookmark data
                if (self.bookModifyCompleted) {
                    NSMutableArray *arr = [[NSMutableArray alloc] initWithObjects:self.quoteTextView.text, nil];
                    self.bookModifyCompleted(self.titleLabel.text, self.authorLabel.text, compDate, self.rateView.rating, arr, self.picImageView.image);
                }
                [self popController:YES];
            }
        } else {
            NSInteger tag = [sender tag];
            // delete btn
            if (tag == BTN_TYPE_DELETE) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Delete", @"") message:NSLocalizedString(@"Do you really want to delete?", @"") preferredStyle:UIAlertControllerStyleActionSheet];
                
                NSString *strFirst = NSLocalizedString(@"Deleting", @"");
                NSString *strSecond = NSLocalizedString(@"Cancel", @"");
                UIAlertAction *firstAction = [UIAlertAction actionWithTitle:strFirst style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                    if (self.bookDeleteCompleted) {
                        self.bookDeleteCompleted(self.indexPath);
                        [self popController:YES];
                    }
                }];
                UIAlertAction *secondAction = [UIAlertAction actionWithTitle:strSecond style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    [alert dismissViewControllerAnimated:YES completion:nil];
                }];
                
                [alert addAction:firstAction];
                [alert addAction:secondAction];
                [self presentViewController:alert animated:YES completion:nil];
            }
            // edit btn
            else if (tag == BTN_TYPE_EDIT) {
                isEditing = YES;
                [self setNaviBarType:BAR_ADD title:nil image:nil];
                
                [self.titleLabel setUserInteractionEnabled:YES];
                [self.authorLabel setUserInteractionEnabled:YES];
                [self.compDateTextField setUserInteractionEnabled:YES];
                [self.rateView setUserInteractionEnabled:YES];
                [self.quoteTextView setEditable:YES];
                
                [self.titleLabel becomeFirstResponder];
                [self.addPicBtn setHidden:NO];
            }
        }
        
    }
    NSLog(@"YJ << save book data");
}

#pragma mark - Actions
- (IBAction)addPicBtnAction:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    NSString *strFirst = NSLocalizedString(@"Take Photo", @"");
    NSString *strSecond = NSLocalizedString(@"Add from Library", @"");
    UIAlertAction *firstAction = [UIAlertAction actionWithTitle:strFirst style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        NSLog(@"YJ << take photo");
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:picker animated:YES completion:nil];
    }];
    UIAlertAction *secondAction = [UIAlertAction actionWithTitle:strSecond style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSLog(@"YJ << add from library");
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:picker animated:YES completion:nil];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){}];
    
    [alert addAction:firstAction];
    [alert addAction:secondAction];
    [alert addAction:cancelAction];
//    [self presentViewController:alert animated:YES completion:nil];
    [self presentController:alert animated:YES];
}

- (void) writeFinished {
    [self.view endEditing:YES];
}

#pragma mark - UIImagePickerController Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    // output image
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
//    self.profileImageView.image = chosenImage;
    [self.picImageView setImage:chosenImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == self.compDateTextField) {
        LSLDatePickerDialog *dpDialog = [[LSLDatePickerDialog alloc] init];
        [dpDialog showWithTitle:@"완독일" doneButtonTitle:@"확인" cancelButtonTitle:@"취소" defaultDate:[NSDate date] datePickerMode:UIDatePickerModeDate callback:^(NSDate *date) {
            if (date) {
                compDate = date;
                NSDateFormatter *format = [[NSDateFormatter alloc] init];
                [format setDateFormat:@"yyyy.MM.dd"];
                NSString *strDate = [format stringFromDate:date];
                self.compDateTextField.text = strDate;
                NSLog(@"YJ << get date : %@", strDate);
            }
        }];
        return NO;
    }
    
    return YES;
}

#pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
//    [self.memoBtn setSelected:YES];
//    [self.recentMemoBtn setSelected:NO];
    NSLog(@"YJ << textView did begin editing");
    if (textView == self.quoteTextView) {
        [self.placeholderLabel setHidden:YES];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    NSLog(@"YJ << textview did end editing");
    if (textView == self.quoteTextView) {
        if (self.quoteTextView.text.length <= 0) {
            [self.placeholderLabel setHidden:NO];
        }
    }
}

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    NSLog(@"YJ << textview should begin editing");
//    commentTxtView.text = @"";
//    commentTxtView.textColor = [UIColor blackColor];
    return YES;
}

-(void) textViewDidChange:(UITextView *)textView
{
    NSLog(@"YJ << textview did change");
//    if(commentTxtView.text.length == 0){
//        commentTxtView.textColor = [UIColor lightGrayColor];
//        commentTxtView.text = @"Comment";
//        [commentTxtView resignFirstResponder];
//    }
}


#pragma mark - keyboard actions
- (void)handleKeyboardWillShowNote:(NSNotification *)notification
{
    [self.view addGestureRecognizer:bgTap];
    
    NSDictionary* userInfo = [notification userInfo];
    
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    //    if (idTextField == TYPE_TEXTFIELD_NAME || idTextField == TYPE_TEXTFIELD_NICKNAME) {
    //        self.viewBottomConstraint.constant = -keyboardSize.height;
    //        [self.view updateConstraints];
    //    }
}

- (void)handleKeyboardWillHideNote:(NSNotification *)notification
{
    [self.view removeGestureRecognizer:bgTap];
    
    NSDictionary* userInfo = [notification userInfo];
    
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    //    if (idTextField == TYPE_TEXTFIELD_NAME || idTextField == TYPE_TEXTFIELD_NICKNAME) {
    //        self.viewBottomConstraint.constant = 0;
    //        [self.view updateConstraints];
    //    }
}

@end
