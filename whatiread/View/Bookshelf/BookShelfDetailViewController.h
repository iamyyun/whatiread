//
//  BookShelfDetailViewController.h
//  whatiread
//
//  Created by Yunju on 2018. 7. 5..
//  Copyright © 2018년 Yunju Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "whatiread+CoreDataModel.h"
#import "RateView.h"
#import "BookShelfViewController.h"

//typedef void (^BookModifyCompleted)
typedef void (^BookDeleteCompleted)(NSIndexPath *indexPath);
typedef void (^BookmarkDeleteCompleted)(NSIndexPath *indexPath, NSInteger index, id<BookShelfViewControllerDelegate>delegate);

@interface BookShelfDetailViewController : CommonViewController

@property (nonatomic, copy) BookDeleteCompleted bookDeleteCompleted;
@property (nonatomic, copy) BookmarkDeleteCompleted bookmarkDeleteCompleted;
@property (nonatomic, weak) Book *book;
@property (nonatomic, strong) NSIndexPath *indexPath;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet RateView *rateView;
@property (weak, nonatomic) IBOutlet UILabel *bmCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *completeDateLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *bookShelfCollectionView;

- (void)setBookCompositionHandler:(Book *)book bookDeleteCompleted:(BookDeleteCompleted)bookDeleteCompleted bookmarkDeleteCompleted:(BookmarkDeleteCompleted)bookmarkDeleteCompleted;

@end
