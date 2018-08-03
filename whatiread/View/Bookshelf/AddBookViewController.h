//
//  AddBookViewController.h
//  whatiread
//
//  Created by Yunju on 2018. 7. 18..
//  Copyright © 2018년 Yunju Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RateView.h"

typedef void (^AddBookCreateCompleted)(NSDictionary *bookDic);
typedef void (^AddBookModifyCompleted)(NSDictionary *bookDic);

@interface AddBookViewController : CommonViewController

@property (nonatomic, copy) AddBookCreateCompleted addBookCreateCompleted;
@property (nonatomic, copy) AddBookModifyCompleted addBookModifyCompleted;
@property (nonatomic, strong) Book *book;
@property (nonatomic, strong) NSDictionary *bookDic;

@property (nonatomic, assign) BOOL isModifyMode;    // create / modify

@property (weak, nonatomic) IBOutlet UITextField *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *authorLabel;
@property (weak, nonatomic) IBOutlet UITextField *publisherLabel;
@property (weak, nonatomic) IBOutlet UITextField *pubDateTextField;
@property (weak, nonatomic) IBOutlet UITextField *startDateTextField;
@property (weak, nonatomic) IBOutlet UITextField *compDateTextField;
@property (weak, nonatomic) IBOutlet RateView *rateView;
@property (weak, nonatomic) IBOutlet UIImageView *coverImgView;

- (void)setAddBookCompositionHandler:(NSDictionary *)bDic addBookCreateCompleted:(AddBookCreateCompleted)addBookCreateCompleted addBookModifyCompleted:(AddBookModifyCompleted)addBookModifyCompleted;

@end
