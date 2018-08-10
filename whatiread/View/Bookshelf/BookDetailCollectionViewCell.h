//
//  BookDetailCollectionViewCell.h
//  whatiread
//
//  Created by Yunju on 2018. 7. 13..
//  Copyright © 2018년 Yunju Yang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BookDetailCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *bMarkCountLabel;
@property (weak, nonatomic) IBOutlet UITextView *quoteTextView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *quoteTextViewHeightConst;

@end
