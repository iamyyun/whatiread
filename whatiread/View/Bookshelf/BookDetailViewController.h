//
//  BookDetailViewController.h
//  whatiread
//
//  Created by Yunju on 2018. 7. 5..
//  Copyright © 2018년 Yunju Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "whatiread+CoreDataModel.h"
#import "CoreDataAccess.h"
#import "RateView.h"
#import "BookShelfViewController.h"

@interface BookDetailViewController : CommonViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController <Book *> *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) Book *book;
@property (nonatomic, strong) NSIndexPath *indexPath;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UILabel *publisherLabel;
@property (weak, nonatomic) IBOutlet UILabel *pubDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *startDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *compDateLabel;
@property (weak, nonatomic) IBOutlet RateView *rateView;
@property (weak, nonatomic) IBOutlet UIImageView *coverImgView;
@property (weak, nonatomic) IBOutlet UILabel *bmCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *addBmBtn;
@property (weak, nonatomic) IBOutlet UIButton *editBsBtn;
@property (weak, nonatomic) IBOutlet UIButton *deleteBsBtn;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *emptyView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelHeightConst;

- (IBAction)addBookmarkBtnAction:(id)sender;
- (IBAction)EditBookShelfBtnAction:(id)sender;
- (IBAction)deleteBookShelfBtnAction:(id)sender;

@end
