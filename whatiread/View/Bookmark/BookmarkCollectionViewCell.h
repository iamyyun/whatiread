//
//  BookmarkCollectionViewCell.h
//  whatiread
//
//  Created by Yunju on 2018. 6. 7..
//  Copyright © 2018년 Yunju Yang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BookmarkCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *indexLabel;
@property (weak, nonatomic) IBOutlet UITextView *quoteTextView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *quoteTextViewHeightConst;

@end
