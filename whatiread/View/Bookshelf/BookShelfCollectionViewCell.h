//
//  BookShelfCollectionViewCell.h
//  whatiread
//
//  Created by 양윤주 on 2018. 7. 13..
//  Copyright © 2018년 Yunju Yang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BookShelfCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UILabel *compDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *bMarkCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *rateLabel;

@end
