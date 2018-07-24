//
//  AddBookShelfViewController.m
//  whatiread
//
//  Created by Yunju on 2018. 7. 18..
//  Copyright © 2018년 Yunju Yang. All rights reserved.
//

#import "AddBookShelfViewController.h"
#import "AddBookShelfCollectionViewCell.h"
#import "AddBookShelfLastCollectionViewCell.h"
#import <Photos/Photos.h>
#import "LSLDatePickerDialog.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface AddBookShelfViewController () <UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource> {
    UITapGestureRecognizer *bgTap;
    
    NSDate *publishDate;
    NSDate *startDate;
    NSDate *compDate;
    
    NSMutableArray *bookmarkArr;
}

@end

@implementation AddBookShelfViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // set NavigationBar
    [self setNaviBarType:BAR_ADD title:nil image:nil];
    
    publishDate = [NSDate date];
    startDate = [NSDate date];
    compDate = [NSDate date];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy.MM.dd"];
    NSString *strDate = [format stringFromDate:compDate];
    self.pubDateTextField.text = strDate;
    self.startDateTextField.text = strDate;
    self.compDateTextField.text = strDate;
    
    [self.compDateTextField resignFirstResponder];
    [self.compDateTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
    
    [self.rateView setStarFillColor:[UIColor colorWithHexString:@"F0C330"]];
    [self.rateView setStarNormalColor:[UIColor lightGrayColor]];
    [self.rateView setCanRate:YES];
    [self.rateView setStarSize:20.f];
    [self.rateView setStep:0.5f];
    
    bookmarkArr = [NSMutableArray array];
    
    if (self.isModifyMode) {
        if (self.book) {
            if (self.book.isSearchMode) {
                [self.titleLabel setUserInteractionEnabled:NO];
                [self.authorLabel setUserInteractionEnabled:NO];
                [self.publisherLabel setUserInteractionEnabled:NO];
                [self.pubDateTextField setUserInteractionEnabled:NO];
                
                [self.coverImgView setImage:[UIImage imageWithData:self.book.coverImg]];
            }
            bookmarkArr = [NSMutableArray arrayWithArray:self.book.quote];
            
            publishDate = self.book.publishDate;
            startDate = self.book.startDate;
            compDate = self.book.completeDate;
            NSDateFormatter *format = [[NSDateFormatter alloc] init];
            [format setDateFormat:@"yyyy.MM.dd"];
            
            [self.titleLabel setText:self.book.title];
            [self.authorLabel setText:self.book.author];
            [self.publisherLabel setText:self.book.publisher];
            [self.pubDateTextField setText:[format stringFromDate:publishDate]];
            [self.startDateTextField setText:[format stringFromDate:startDate]];
            [self.compDateTextField setText:[format stringFromDate:compDate]];
            [self.rateView setRating:self.book.rate];
            
        }
    } else {
        if (self.isSearchMode) {
            if (self.bookDic) {
                NSString *style = @"<meta charset=\"UTF-8\"><style> body { font-family: 'HelveticaNeue'; font-size: 15px; } b {font-family: 'MarkerFelt-Wide'; }</style>";
                NSString *bTitle = [NSString stringWithFormat:@"%@%@", style, [self.bookDic objectForKey:@"title"]];
                NSDictionary *options = @{ NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType };
                NSAttributedString *attrString = [[NSAttributedString alloc] initWithData:[bTitle dataUsingEncoding:NSUTF8StringEncoding] options:options documentAttributes:nil error:nil];
                
                NSDateFormatter *format = [[NSDateFormatter alloc] init];
                [format setDateFormat:@"yyyy.MM.dd"];
                NSString *strDate = [format stringFromDate:compDate];
                
                NSString *strPubDate = [self makeDateString:[self.bookDic objectForKey:@"pubdate"]];
                publishDate = [format dateFromString:strPubDate];
                
                [self.titleLabel setText:[attrString string]];
                [self.authorLabel setText:[self.bookDic objectForKey:@"author"]];
                [self.publisherLabel setText:[self.bookDic objectForKey:@"publisher"]];
                [self.pubDateTextField setText:strPubDate];
                [self.startDateTextField setText:strDate];
                [self.compDateTextField setText:strDate];
                [self.coverImgView sd_setImageWithURL:[NSURL URLWithString:[self.bookDic objectForKey:@"image"]]];
                
                [self.titleLabel setUserInteractionEnabled:NO];
                [self.authorLabel setUserInteractionEnabled:NO];
                [self.publisherLabel setUserInteractionEnabled:NO];
                [self.pubDateTextField setUserInteractionEnabled:NO];
            }
        }
    }
    
//    [self.collectionView setAllowsSelection:YES];
    [self.collectionView registerNib:[UINib nibWithNibName:@"AddBookShelfCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"AddBookShelfCollectionViewCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"AddBookShelfLastCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"AddBookShelfLastCollectionViewCell"];
    
    // Add Observer
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillShowNote:) name:UIKeyboardWillShowNotification object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillHideNote:) name:UIKeyboardWillHideNotification object:self.view.window];
    bgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(writeFinished)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// set block
- (void)setBookshelfCompositionHandler:(NSDictionary *)bDic bookshelfCreateCompleted:(BookshelfCreateCompleted)bookshelfCreateCompleted bookshelfModifyCompleted:(BookshelfModifyCompleted)bookshelfModifyCompleted
{
    self.bookDic = bDic;
    self.bookshelfCreateCompleted = bookshelfCreateCompleted;
    self.bookshelfModifyCompleted = bookshelfModifyCompleted;
}

- (void) writeFinished {
    [self.view endEditing:YES];
}

- (NSString *)makeDateString:(NSString *)strDate {
    NSMutableString *muString = [NSMutableString stringWithString:strDate];
    [muString insertString:@"." atIndex:4];
    [muString insertString:@"." atIndex:7];
    
    return [NSString stringWithString:muString];
}

-(void)addDoneToolBarToKeyboard:(UITextView *)textView
{
    CGFloat width = self.view.frame.size.width;
    UIToolbar* doneToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, width, 50)];
    doneToolbar.barStyle = UIBarStyleDefault;
    doneToolbar.items = [NSArray arrayWithObjects:
                         [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                         [[UIBarButtonItem alloc]initWithTitle:@"완료" style:UIBarButtonItemStyleDone target:self action:@selector(writeFinished)],
                         nil];
    [doneToolbar sizeToFit];
    textView.inputAccessoryView = doneToolbar;
}

#pragma mark - Navigation Bar Action
- (void)rightBarBtnClick:(id)sender
{
    if (self.titleLabel.text.length <= 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Please write title.", @"") message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
        [alert addAction:okAction];
        [self presentController:alert animated:YES];
    }
//    else if (self.quoteTextView.text.length <= 0) {
//        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Please write quotes.", @"") message:nil preferredStyle:UIAlertControllerStyleAlert];
//        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
//        [alert addAction:okAction];
//        [self presentController:alert animated:YES];
//    }
    else {
        if (self.isModifyMode) {
            if (self.bookshelfModifyCompleted) {
                NSMutableDictionary *bookDic = [NSMutableDictionary dictionary];
                [bookDic setObject:self.titleLabel.text forKey:@"bTitle"];
                [bookDic setObject:self.authorLabel.text forKey:@"bAuthor"];
                [bookDic setObject:self.publisherLabel.text forKey:@"bPublisher"];
                [bookDic setObject:publishDate forKey:@"bPubDate"];
                //                [bookDic setObject:self.coverImgView.image forKey:@""];
                [bookDic setObject:startDate forKey:@"bStartDate"];
                [bookDic setObject:compDate forKey:@"bCompleteDate"];
                [bookDic setObject:[NSNumber numberWithFloat:self.rateView.rating] forKey:@"bRate"];
                self.bookshelfModifyCompleted(bookDic);
            }
        } else {
            // create bookmark data
            if (self.bookshelfCreateCompleted) {
                NSMutableDictionary *bookDic = [NSMutableDictionary dictionary];
                [bookDic setObject:self.titleLabel.text forKey:@"bTitle"];
                [bookDic setObject:self.authorLabel.text forKey:@"bAuthor"];
                [bookDic setObject:self.publisherLabel.text forKey:@"bPublisher"];
                [bookDic setObject:publishDate forKey:@"bPubDate"];
                //                [bookDic setObject:self.coverImgView.image forKey:@""];
                [bookDic setObject:startDate forKey:@"bStartDate"];
                [bookDic setObject:compDate forKey:@"bCompleteDate"];
                
                if (self.isSearchMode) {
                    [bookDic setObject:self.coverImgView.image forKey:@"bCoverImg"];
                }
                
                [bookDic setObject:[NSNumber numberWithFloat:self.rateView.rating] forKey:@"bRate"];
                self.bookshelfCreateCompleted(bookDic);
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

#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    NSLog(@"YJ << start writing quote view");
    NSInteger tag = [textView tag];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:tag inSection:0];
    AddBookShelfCollectionViewCell *cell = (AddBookShelfCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    [cell.editView setHidden:YES];
    [cell.quoteView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    NSLog(@"YJ << end writing quote view");
    NSInteger tag = [textView tag];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:tag inSection:0];
    AddBookShelfCollectionViewCell *cell = (AddBookShelfCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    [cell.editView setHidden:NO];
    
    [bookmarkArr replaceObjectAtIndex:tag withObject:textView.text];
//    [self.collectionView reloadData];
}

- (void)textViewDidChange:(UITextView *)textView {
    NSLog(@"YJ << textview changing");
    NSInteger tag = [textView tag];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:tag inSection:0];
    AddBookShelfCollectionViewCell *cell = (AddBookShelfCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    
    CGFloat width = self.collectionView.frame.size.width;
    
    NSString *strQuote = textView.text;
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.lineBreakMode = NSLineBreakByCharWrapping;
    CGFloat height = [strQuote boundingRectWithSize:CGSizeMake(width - 30, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15.0f], NSParagraphStyleAttributeName:paragraph} context:nil].size.height;
    
    if (cell.quoteViewHeightConst.constant != height) {
        cell.quoteViewHeightConst.constant = height;
//        [self.collectionView updateConstraints];
        [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:tag inSection:0]]];
        [cell.quoteView becomeFirstResponder];
    }
    
//    cell.quoteViewHeightConst.constant = height;
//    [self.view updateConstraintsIfNeeded];
}

#pragma mark - UICollectionViewDataSource
- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"AddBookShelfCollectionViewCell";
    NSString *lastCellIdentifier = @"AddBookShelfLastCollectionViewCell";
    
    if (indexPath.item == bookmarkArr.count) {
        AddBookShelfLastCollectionViewCell *lastCell = [collectionView dequeueReusableCellWithReuseIdentifier:lastCellIdentifier forIndexPath:indexPath];
        if (!lastCell) {
            lastCell = [[[NSBundle mainBundle] loadNibNamed:lastCellIdentifier owner:self options:nil] lastObject];
        }
        return lastCell;
    } else {
        AddBookShelfCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil] lastObject];
        }
        
        NSString *strQuote = bookmarkArr[indexPath.item];
        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
        paragraph.lineBreakMode = NSLineBreakByWordWrapping;
        CGFloat height = [strQuote boundingRectWithSize:CGSizeMake(cell.quoteView.frame.size.width, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15.0f], NSParagraphStyleAttributeName:paragraph} context:nil].size.height;
        
        [cell setTag:indexPath.item];
        
        [self addDoneToolBarToKeyboard:cell.quoteView];
        [cell.quoteView setTextContainerInset:UIEdgeInsetsZero];
        cell.quoteView.delegate = self;
        [cell.quoteView setTag:indexPath.item];
        [cell.quoteView setText:strQuote];
        cell.quoteViewHeightConst.constant = height;
        [cell.quoteView becomeFirstResponder];
        
        [cell.countLabel setText:[NSString stringWithFormat:@"%ld", (indexPath.item +1)]];
        
        return cell;
    }
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return (bookmarkArr.count + 1);
}

#pragma mark - UICollectionViewDelegate
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
{
    NSLog(@"YJ << select collectionview cell");
    
    if (indexPath.item == bookmarkArr.count) {
        [bookmarkArr addObject:@""];
        [self.collectionView reloadData];
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:bookmarkArr.count inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
//    return CGSizeMake(CGRectGetWidth(collectionView.frame)-30, 90.0f);
    CGSize cellSize = CGSizeMake(0, 0);
     if (indexPath.item == bookmarkArr.count) {
        cellSize = CGSizeMake(self.collectionView.frame.size.width, 60.f);
     }
     else {
         CGFloat width = self.collectionView.frame.size.width;
         
         NSString *strQuote = bookmarkArr[indexPath.item];
         NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
         paragraph.lineBreakMode = NSLineBreakByWordWrapping;
         CGFloat height = [strQuote boundingRectWithSize:CGSizeMake(width - 30, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16.0f], NSParagraphStyleAttributeName:paragraph} context:nil].size.height;

         cellSize = CGSizeMake(self.collectionView.frame.size.width, height + 38);
     }
    return cellSize;
}

#pragma mark - keyboard actions
- (void)handleKeyboardWillShowNote:(NSNotification *)notification
{
    [self.view addGestureRecognizer:bgTap];
    
    NSDictionary* userInfo = [notification userInfo];
    
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    self.collViewBottomConst.constant = keyboardSize.height;
    [self.view updateConstraints];
    
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:bookmarkArr.count inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
}

- (void)handleKeyboardWillHideNote:(NSNotification *)notification
{
    [self.view removeGestureRecognizer:bgTap];
    
    NSDictionary* userInfo = [notification userInfo];
    
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    self.collViewBottomConst.constant = 0.f;
    [self.view updateConstraints];
}


@end
