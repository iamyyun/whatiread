//
//  AddBookShelfCollectionViewCell.h
//  whatiread
//
//  Created by Yunju on 2018. 7. 18..
//  Copyright © 2018년 Yunju Yang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddBookShelfCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UIView *editView;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet UIButton *editBtn;
@property (weak, nonatomic) IBOutlet UITextView *quoteView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *quoteViewHeightConst;

- (IBAction)deleteBtnAction:(id)sender;
- (IBAction)editBtnAction:(id)sender;

@end
