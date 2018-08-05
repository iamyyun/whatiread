//
//  AddBookViewController.h
//  whatiread
//
//  Created by Yunju on 2018. 7. 18..
//  Copyright © 2018년 Yunju Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RateView.h"
#import "JVFloatLabeledTextField.h"

typedef void (^AddBookCreateCompleted)(NSDictionary *bookDic);
typedef void (^AddBookModifyCompleted)(NSDictionary *bookDic);

@interface AddBookViewController : CommonViewController

@property (nonatomic, copy) AddBookCreateCompleted addBookCreateCompleted;
@property (nonatomic, copy) AddBookModifyCompleted addBookModifyCompleted;
@property (nonatomic, strong) Book *book;
@property (nonatomic, strong) NSDictionary *bookDic;

@property (nonatomic, assign) BOOL isModifyMode;    // create / modify

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UILabel *publisherLabel;
@property (weak, nonatomic) IBOutlet UILabel *pubDateTextField;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *startDateTextField;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *compDateTextField;
@property (weak, nonatomic) IBOutlet RateView *rateView;
@property (weak, nonatomic) IBOutlet UILabel *rateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *coverImgView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelHeightConst;

- (void)setAddBookCompositionHandler:(NSDictionary *)bDic addBookCreateCompleted:(AddBookCreateCompleted)addBookCreateCompleted addBookModifyCompleted:(AddBookModifyCompleted)addBookModifyCompleted;

@end
