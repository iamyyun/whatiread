//
//  AddBookmarkViewController.h
//  whatiread
//
//  Created by Yunju on 2018. 7. 25..
//  Copyright © 2018년 Yunju Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "whatiread+CoreDataModel.h"

typedef void (^BookmarkCreateCompleted)(NSAttributedString *attrQuote);
typedef void (^BookmarkModifyCompleted)(NSAttributedString *attrQuote, NSIndexPath *indexPath);

@interface AddBookmarkViewController : CommonViewController

@property (nonatomic, copy) BookmarkCreateCompleted bookmarkCreateCompleted;
@property (nonatomic, copy) BookmarkModifyCompleted bookmarkModifyCompleted;
@property (nonatomic, strong) Book *book;
@property (nonatomic, strong) NSIndexPath *indexPath;

@property (assign) BOOL isModifyMode;

@property (nonatomic, strong) NSString *strOcrText;

// localize language
@property (weak, nonatomic) IBOutlet UILabel *textInputLangLabel;
@property (weak, nonatomic) IBOutlet UILabel *photoInputLangLabel;

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *textInputBtn;
@property (weak, nonatomic) IBOutlet UIView *photoInputView;
@property (weak, nonatomic) IBOutlet UIButton *photoInputBtn;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewBottomMarginConst;

- (IBAction)textInputBtnAction:(id)sender;
- (IBAction)photoInputBtnAction:(id)sender;

- (void)setBookmarkCompositionHandler:(Book *)book bookmarkCreateCompleted:(BookmarkCreateCompleted)bookmarkCreateCompleted bookmarkModifyCompleted:(BookmarkModifyCompleted)bookmarkModifyCompleted;

@end
