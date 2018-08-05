//
//  AddBookmarkViewController.h
//  whatiread
//
//  Created by Yunju on 2018. 7. 25..
//  Copyright © 2018년 Yunju Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "whatiread+CoreDataModel.h"

typedef void (^BookmarkCreateCompleted)(NSString *strQuote);

@interface AddBookmarkViewController : CommonViewController

@property (nonatomic, copy) BookmarkCreateCompleted bookmarkCreateCompleted;
@property (nonatomic, strong) Book *book;
@property (nonatomic, strong) NSIndexPath *indexPath;

@property (assign) BOOL isModifyMode;

@property (nonatomic, strong) NSString *strOcrText;

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

- (void)setBookmarkCompositionHandler:(Book *)book bookmarkCreateCompleted:(BookmarkCreateCompleted)bookmarkCreateCompleted;

@end
