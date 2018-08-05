//
//  BookmarkDetailViewController.h
//  whatiread
//
//  Created by Yunju on 2018. 8. 4..
//  Copyright © 2018년 Yunju Yang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BookmarkDetailViewController : CommonViewController

@property (assign) BOOL isFromBookshelf;
@property (nonatomic, strong) Book *book;
@property (nonatomic, strong) NSIndexPath *indexPath;

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *bookBtn;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImgView;

- (IBAction)bookBtnAction:(id)sender;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelTrailingMarginConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *authorLabelTrailingMarginConst;

@end
