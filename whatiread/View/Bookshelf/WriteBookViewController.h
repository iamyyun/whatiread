//
//  WriteBookViewController.h
//  whatiread
//
//  Created by Yunju on 2018. 8. 3..
//  Copyright © 2018년 Yunju Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JVFloatLabeledTextField.h"
#import "RateView.h"

typedef void (^WriteBookCreateCompleted)(NSDictionary *bookDic);
typedef void (^WriteBookModifyCompleted)(NSDictionary *bookDic);

@interface WriteBookViewController : CommonViewController

@property (nonatomic, copy) WriteBookCreateCompleted writeBookCreateCompleted;
@property (nonatomic, copy) WriteBookModifyCompleted writeBookModifyCompleted;
@property (nonatomic, strong) Book *book;

@property (nonatomic, assign) BOOL isModifyMode;    // create / modify

// localize language
@property (weak, nonatomic) IBOutlet UILabel *rateLangLabel;
@property (weak, nonatomic) IBOutlet UILabel *infoLangLabel;

@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *titleTextField;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *authorTextField;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *publishTextField;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *pubDateTextField;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *startDateTextField;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *compDateTextField;
@property (weak, nonatomic) IBOutlet UILabel *rateLabel;
@property (weak, nonatomic) IBOutlet RateView *rateView;

- (void)setWriteBookCompositionHandler:(Book *)book writeBookCreateCompleted:(WriteBookCreateCompleted)writeBookCreateCompleted writeBookModifyCompleted:(WriteBookModifyCompleted)writeBookModifyCompleted;

@end
