//
//  BookShelfDetailCollectionViewCell.h
//  whatiread
//
//  Created by Yunju on 2018. 7. 13..
//  Copyright © 2018년 Yunju Yang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BookShelfDetailCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *bMarkCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *delBtn;
@property (weak, nonatomic) IBOutlet UIButton *editBtn;
@property (weak, nonatomic) IBOutlet UILabel *quoteLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *quoteLabelHeightConst;

- (IBAction)delBtnAction:(id)sender;
- (IBAction)editBtnAction:(id)sender;

@end
