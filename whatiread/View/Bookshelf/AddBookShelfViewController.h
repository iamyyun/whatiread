//
//  AddBookShelfViewController.h
//  whatiread
//
//  Created by Yunju on 2018. 7. 18..
//  Copyright © 2018년 Yunju Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RateView.h"

typedef void (^BookshelfCreateCompleted)(NSDictionary *bookDic);
typedef void (^BookshelfModifyCompleted)(NSDictionary *bookDic);

@interface AddBookShelfViewController : CommonViewController

@property (nonatomic, copy) BookshelfCreateCompleted bookshelfCreateCompleted;
@property (nonatomic, copy) BookshelfModifyCompleted bookshelfModifyCompleted;
@property (nonatomic, strong) Book *book;
@property (nonatomic, strong) NSDictionary *bookDic;

@property (nonatomic, assign) BOOL isModifyMode;    // create / modify
@property (nonatomic, assign) BOOL isSearchMode;    // search / write

@property (weak, nonatomic) IBOutlet UITextField *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *authorLabel;
@property (weak, nonatomic) IBOutlet UITextField *publisherLabel;
@property (weak, nonatomic) IBOutlet UITextField *pubDateTextField;
@property (weak, nonatomic) IBOutlet UITextField *startDateTextField;
@property (weak, nonatomic) IBOutlet UITextField *compDateTextField;
@property (weak, nonatomic) IBOutlet RateView *rateView;
@property (weak, nonatomic) IBOutlet UIImageView *coverImgView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collViewBottomConst;

- (void)setBookshelfCompositionHandler:(NSDictionary *)bDic bookshelfCreateCompleted:(BookshelfCreateCompleted)bookshelfCreateCompleted bookshelfModifyCompleted:(BookshelfModifyCompleted)bookshelfModifyCompleted;

@end
