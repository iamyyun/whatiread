//
//  AddBookmarkViewController.h
//  whatiread
//
//  Created by Yunju on 2018. 6. 7..
//  Copyright © 2018년 Yunju Yang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddBookmarkViewController : CommonViewController

@property (weak, nonatomic) IBOutlet UITextField *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *authorLabel;
@property (weak, nonatomic) IBOutlet UITextField *quoteLabel;
@property (weak, nonatomic) IBOutlet UIButton *addPicBtn;

- (IBAction)addPicBtnAction:(id)sender;

@end
