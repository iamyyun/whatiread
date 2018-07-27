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
@property (weak, nonatomic) IBOutlet UILabel *quoteLabel;
@property (weak, nonatomic) IBOutlet UIImageView *quoteImgView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *quoteLabelHeightConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *quoteImgViewHeightConst;

@end
