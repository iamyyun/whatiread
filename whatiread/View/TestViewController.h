//
//  TestViewController.h
//  whatiread
//
//  Created by 양윤주 on 2018. 5. 30..
//  Copyright © 2018년 Yunju Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "GTLBooks.h"
//#import "GTL/GTMOAuth2WindowController.h"


@interface TestViewController : CommonViewController

@property (weak, nonatomic) IBOutlet UIButton *pickBtn;
@property (weak, nonatomic) IBOutlet UIImageView *pickImageView;
@property (weak, nonatomic) IBOutlet UIImageView *analyzeView;
- (IBAction)pickBtnAction:(id)sender;

@end
