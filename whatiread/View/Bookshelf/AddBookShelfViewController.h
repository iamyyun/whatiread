//
//  AddBookShelfViewController.h
//  whatiread
//
//  Created by Yunju on 2018. 7. 18..
//  Copyright © 2018년 Yunju Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RateView.h"

typedef void (^BookCreateCompleted)(NSString *bookTitle, NSString *bookAuthor, NSDate *bookDate, CGFloat fRate, NSMutableArray *bookQuotes, UIImage *bookImage);
typedef void (^BookModifyCompleted)(NSString *bookTitle, NSString *bookAuthor, NSDate *bookDate, CGFloat fRate, NSMutableArray *bookQuotes, UIImage *bookimage);

@interface AddBookShelfViewController : CommonViewController

@property (nonatomic, copy) BookCreateCompleted bookCreateCompleted;
@property (nonatomic, copy) BookModifyCompleted bookModifyCompleted;
@property (nonatomic, weak) Book *book;

@property (nonatomic, assign) BOOL isModifyMode;    // create / modify

@property (weak, nonatomic) IBOutlet UITextField *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *authorLabel;
@property (weak, nonatomic) IBOutlet UITextField *compDateTextField;
@property (weak, nonatomic) IBOutlet RateView *rateView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collViewBottomConst;

- (void)setBookCompositionHandler:(BookCreateCompleted)bookCreateCompleted bookModifyCompleted:(BookModifyCompleted)bookModifyCompleted;

@end
