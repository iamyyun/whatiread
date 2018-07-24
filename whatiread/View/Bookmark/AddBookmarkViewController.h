//
//  AddBookmarkViewController.h
//  whatiread
//
//  Created by Yunju on 2018. 6. 7..
//  Copyright © 2018년 Yunju Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "whatiread+CoreDataModel.h"
#import "RateView.h"

typedef void (^BookCreateCompleted)(NSString *bookTitle, NSString *bookAuthor, NSDate *bookDate, CGFloat fRate, NSMutableArray *bookQuotes, UIImage *bookImage);
typedef void (^BookModifyCompleted)(NSString *bookTitle, NSString *bookAuthor, NSDate *bookDate, CGFloat fRate, NSMutableArray *bookQuotes, UIImage *bookImage);
typedef void (^BookDeleteCompleted)(NSIndexPath *indexPath);

@interface AddBookmarkViewController : CommonViewController

@property (nonatomic, copy) BookCreateCompleted bookCreateCompleted;
@property (nonatomic, copy) BookModifyCompleted bookModifyCompleted;
@property (nonatomic, copy) BookDeleteCompleted bookDeleteCompleted;
@property (nonatomic, strong) Book *book;

@property (nonatomic, assign) BOOL isModifyMode;    // create / modify
@property (nonatomic, strong) NSIndexPath *indexPath;

@property (weak, nonatomic) IBOutlet UITextField *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *authorLabel;
@property (weak, nonatomic) IBOutlet UITextField *compDateTextField;
@property (weak, nonatomic) IBOutlet RateView *rateView;
@property (weak, nonatomic) IBOutlet UITextView *quoteTextView;
@property (weak, nonatomic) IBOutlet UILabel *placeholderLabel;
@property (weak, nonatomic) IBOutlet UIImageView *picImageView;
@property (weak, nonatomic) IBOutlet UIButton *addPicBtn;

- (IBAction)addPicBtnAction:(id)sender;

- (void)setBookCompositionHandler:(Book *)book bookCreateCompleted:(BookCreateCompleted)bookCreateCompleted bookModifyCompleted:(BookModifyCompleted)bookModifyCompleted bookDeleteCompleted:(BookDeleteCompleted)bookDeleteCompleted;

@end
